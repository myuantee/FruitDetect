# FruitDetect

FruitDetect is a fruit recognition mobile application that can classify four types of fruits as either rotten or fresh using a custom CNN machine learning model.
A deep learning model was developed to classify fresh and rotten fruits (apples, bananas, oranges, and lime) based on their images. The dataset used in this study consisted of 12,532 training images and 3,246 testing images of fruits, divided into four classes (apples, bananas, oranges, and lime) and labeled as either ‘fresh’ or ‘rotten’.
The dataset was pre-processed and used to train two different models, MobileNetV2 and DenseNet121. Evaluation results showed that DenseNet121 performed better than MobileNetV2, with a loss of 0.0258 and accuracy of 0.9914 on test data.
This paper demonstrates the integration of a custom machine-learning model built and trained to classify fruit types and conditions from images, then deployed and utilized in a mobile application targeted at visually-impaired users to assist them in choosing good-conditioned fruits when shopping or eating.

# Fruit Classification

This project contains two folders: `fruit_model` and `fruit_detect`.

## Fruit Model

The `fruit_model` folder contains a Python Jupyter Notebook file that includes the following Python libraries: `itertools`, `glob`, `numpy`, `cv2`, `random`, `matplotlib.pyplot`, `tensorflow.keras`, `keras.utils.to_categorical`, `keras.preprocessing.image`, `keras.applications.MobileNetV2`, `keras.layers.Dense`, `keras.layers.GlobalAveragePooling2D`, `keras.models.Model`, `tensorflow.keras.preprocessing.image.img_to_array`, `keras.preprocessing.image.ImageDataGenerator` and `keras.applications.DenseNet121`.

This file also includes dataset preparation and training of the model. However, it is important to note that the model has already been trained and converted to a `.tflite` file, which has been integrated into the `fruit_detect` project. Therefore, there is no need to train the model again.

## Fruit Detect

The `fruit_detect` folder contains the code for a Flutter project that uses the trained model to detect fruits in images. You can use Visual Studio Code to open the folder and click on the new terminal to execute the command `flutter run`. Before executing this command, you may need to create an Android emulator device from Android Studio. After that, you can execute the command `flutter emulators --launch Pixel_4_API_33`. Note that `Pixel_4_API_33` needs to be changed to the device name that you created.

## Usage

To use this project, first make sure you have all the required libraries installed. Then, navigate to the `fruit_detect` folder and follow the instructions above to run the Flutter project and detect fruits in images using the trained model.

1. flutter emulators --launch Pixel_4_API_33 <!-- Noted that you may create an emulators before you run your flutter application -->
2. flutter run
