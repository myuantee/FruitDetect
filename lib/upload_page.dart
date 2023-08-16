// import 'dart:io';
// ignore_for_file: use_build_context_synchronously

import 'dart:math';
// import 'dart:typed_data';
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fruit_detect/result_page.dart';
import 'package:image_picker/image_picker.dart';
//implement model
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:firebase_database/firebase_database.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({Key? key}) : super(key: key);

  @override
  _UploadPageState createState() => _UploadPageState();
}

bool useCamera = false;

class _UploadPageState extends State<UploadPage> with WidgetsBindingObserver {
  late FirebaseStorage _storage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _storage = FirebaseStorage.instance;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // The app has returned to the foreground, so reset the value of useCamera
      setState(() {
        useCamera = false;
      });
    }
  }

  void _processImage(XFile image) async {
    final imageBytes = await image.readAsBytes();
    final img.Image? decodedImage = img.decodeImage(imageBytes);
    if (decodedImage != null) {
      final resizedImage =
          img.copyResize(decodedImage, width: 128, height: 128);
      // Use resizedImage here
      // Convert the resized image to a List<List<List<int>>>
      List<List<List<int>>> imageList = List.generate(
        resizedImage.height,
        (i) => List.generate(
          resizedImage.width,
          (j) {
            int pixelValue = resizedImage.getPixel(j, i);
            int red = (pixelValue >> 16) & 0xFF;
            int green = (pixelValue >> 8) & 0xFF;
            int blue = pixelValue & 0xFF;
            return [red, green, blue];
          },
        ),
      );

      // Normalize the pixel values to the range [0.0, 1.0]
      List<List<List<double>>> normalizedImageList = imageList
          .map((row) => row
              .map((pixel) => pixel.map((channel) => channel / 255.0).toList())
              .toList())
          .toList();

      // Convert the normalized image list to a 4D list with shape [1, 128, 128, 3]
      var my4DList = [normalizedImageList];
      print('my 4d list : $my4DList');

      final Reference ref =
          _storage.ref().child('images/${DateTime.now()}.jpg');
      // print('First 10 bytes: ${imageBytes.sublist(0, 10)}');
      // final UploadTask uploadTask = ref.putFile(File(image.path));
      final UploadTask uploadTask = ref.putData(imageBytes);
      final TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      print('Image uploaded to Firebase Storage: $downloadUrl');
      try {
        // Load the TFLite model
        final interpreter =
            await Interpreter.fromAsset('assets/denseclassifycon.tflite');
        // final interpreter =
        //     await Interpreter.fromAsset('assets/mv2classifycon.tflite');

        final inputTensor = interpreter.getInputTensor(0);
        final inputShape = inputTensor.shape;
        print('input shape : $inputShape');

        // Set the output tensor
        final outputTensor = interpreter.getOutputTensor(0);
        final outputShape = outputTensor.shape;
        final outputSize = outputShape.reduce((a, b) => a * b);
        print('output size : $outputSize');
        // if output tensor shape [1,2] and type is float32
        var outputList = List.filled(1 * 8, 0).reshape([1, 8]);
        // print('output buff : $outputBuffer.buffer ');

        // Run inference
        interpreter.run(my4DList, outputList);
        print('output after interpreter run: $outputList');

        // Convert outputList to a 1D list of probabilities
        final probabilities =
            outputList.reshape([outputList[0].length]).toList().cast<double>();

        // Find the index of the maximum probability
        final predictedClassIndex =
            probabilities.indexOf(probabilities.reduce(max));

        // Map the predicted class index to a class name
        final Map<int, String> classNames = {
          0: 'fresh apple',
          1: 'fresh banana',
          2: 'fresh orange',
          3: 'fresh lime',
          4: 'rotten apple',
          5: 'rotten banana',
          6: 'rotten orange',
          7: 'rotten lime'
        };
        final predictedClassName = classNames[predictedClassIndex] ?? 'Unknown';
        print('Predicted class: $predictedClassName');
        // final predictedClassName = "output";

        // Upload predicted class to Firebase Database
        final DatabaseReference dbRef = FirebaseDatabase.instance.ref();
        await dbRef.child('predictions').push().set({
          'imageUrl': downloadUrl,
          'predictedClass': predictedClassName,
        });

        // ignore: use_build_context_synchronously
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return ResultPage(
                imageUrl: downloadUrl,
                predictedClass: predictedClassName,
              );
            },
          ),
        );
      } catch (error) {
        //handle error
        print("Upload image fail");
        print(error.toString());
      }
    }
  }

  Future<void> _handleCameraOrGalleryButtonPress(bool useCamera) async {
    final ImageSource source =
        useCamera ? ImageSource.camera : ImageSource.gallery;
    if (useCamera) {
      // Check if camera permission is granted
      var status = await Permission.camera.status;
      if (status.isDenied || status.isPermanentlyDenied) {
        // Request the camera permission
        status = await Permission.camera.request();
      }
      if (status.isGranted) {
        // Camera permission is granted
        final XFile? image = await _picker.pickImage(source: source);
        if (image != null) {
          _processImage(image);
        }
      } else {
        // Camera permission is not granted
        // Show a pop-up message asking the user to allow access to the camera
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Camera Permission Required'),
              content: const Text('Please allow access to the camera !'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
        return;
      }
    } else {
      //when user select gallery icon
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        _processImage(image);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        title: const Align(
          alignment: Alignment.center,
          child: Text(
            'FruitDetect',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Roboto Slab',
              color: Colors.white,
              fontSize: 22,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Image.asset(
              'assets/Logo.png',
              fit: BoxFit.cover,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () => _handleCameraOrGalleryButtonPress(true),
                  child: Image.asset(
                    'assets/camera.png',
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: MediaQuery.of(context).size.height * 0.4,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () => _handleCameraOrGalleryButtonPress(false),
                  child: Image.asset('assets/gallery.png',
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: MediaQuery.of(context).size.height * 0.4,
                      fit: BoxFit.contain),
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6200EE),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              child: Text('Back',
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }
}
