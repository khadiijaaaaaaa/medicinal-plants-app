# 🌿 Medicinal Plant Identification Mobile Application

## Introduction

This project presents an innovative mobile application designed for the identification of medicinal plants using images captured by the user. Leveraging advanced artificial intelligence techniques, specifically deep learning models executed locally on the device, the application aims to provide a reliable and accessible tool for botanists, herbalists, students, foragers, and anyone interested in the world of medicinal flora. A key feature of this application is its ability to function entirely offline, making it particularly useful in field environments or areas with limited internet connectivity. Beyond simple identification, the app offers comprehensive details about each plant, including its scientific name, common medicinal uses, associated natural remedies, and crucial information regarding potential toxicity.


## Core Features

The application offers a suite of features designed for ease of use and comprehensive information delivery:

*   **AI-Powered Plant Identification:** Utilizes a sophisticated deep learning model (InceptionResNetV2) converted to TensorFlow Lite format for efficient on-device inference. Users can identify plants by taking a photo using the integrated camera feature (leveraging CameraX) or by uploading an existing image from their gallery.
*   **Offline Functionality:** All core features, including image recognition and access to the plant database, are designed to work without an internet connection, ensuring usability in remote locations.
*   **Detailed Plant Information:** Upon successful identification, the app displays rich information sourced from a local JSON database (`plants_data.json`). This includes the plant's common and scientific names, detailed descriptions of its medicinal uses, geographical origin, typical growth environment, and botanical category.
*   **Toxicity Warnings:** A critical safety feature, the application explicitly flags plants known to have toxic properties. It details which parts of the plant are toxic and describes the potential adverse effects of exposure or ingestion.
*   **Natural Remedies Guide:** Provides practical information on preparing natural remedies using identified plants, including required ingredients and step-by-step instructions.
*   **User Account Management:** Supports user registration and login, allowing for personalization.
*   **Identification History:** Automatically logs all successful identifications, allowing users to review plants they have previously looked up.
*   **Favorites Management:** Enables users to bookmark specific plants for quick access.
*   **Intuitive User Interface:** Developed using Flutter, the UI is designed to be user-friendly and visually appealing, ensuring a smooth experience across different mobile platforms (Android, iOS, etc.).

## Technology Stack

The application is built using a combination of modern mobile development and machine learning technologies:

*   **Mobile Framework:** Flutter (using Dart language)
*   **Machine Learning Model:** InceptionResNetV2 (Pre-trained on ImageNet, fine-tuned on medicinal plant dataset)
*   **On-Device Inference:** TensorFlow Lite
*   **Local Database:** SQLite (via `sqflite` package) for user data (history, favorites)
*   **Plant Data Storage:** JSON (`plants_data.json`)
*   **Camera Integration:** CameraX (via `camera` package)
*   **Image Processing:** Python (PIL) for data validation in the training phase.
*   **Model Training:** Python, TensorFlow/Keras, Jupyter Notebook

## System Architecture

The application follows a standard mobile architecture. The Flutter frontend handles user interactions, camera input, and data display. The core identification logic resides in the integrated TensorFlow Lite model. Plant metadata is stored locally in a JSON file for quick retrieval, while user-specific data like identification history and favorites are managed using an SQLite database. The design emphasizes modularity, separating UI, data management, and machine learning components.

## Machine Learning Model Details

*   **Model Architecture:** The identification engine is based on the InceptionResNetV2 architecture, known for its high accuracy in image classification tasks. The model was pre-trained on the large-scale ImageNet dataset and subsequently fine-tuned on a specific dataset of medicinal plant images to specialize its recognition capabilities.
*   **Dataset:** The model was trained using the "Indian Medicinal Leaf Image Dataset" available on Kaggle, augmented with necessary preprocessing steps.
*   **Training Process:** The model was trained using TensorFlow and Keras. Key steps included data validation (removing corrupt files), image preprocessing (resizing to 224x224, rescaling pixel values), data augmentation (to improve robustness), and training with appropriate callbacks like `ModelCheckpoint` (saving the best weights), `LearningRateScheduler` (adjusting learning rate during training), and `EarlyStopping` (preventing overfitting).
*   **Conversion:** The trained Keras model was converted to the TensorFlow Lite (`.tflite`) format for optimized deployment on mobile devices.

## Data Management

*   **Plant Information (`plants_data.json`):** This file serves as the primary knowledge base for the application. It contains structured information for each plant, including names, uses, toxicity details (boolean flag, toxic parts, effects), natural remedy recipes (title, ingredients, instructions), origin, and growth environment. This local storage ensures offline access to plant data.
*   **User Data (SQLite):** A local SQLite database stores user-specific information, such as login credentials (securely handled), identification history entries, and the list of plants marked as favorites.

## Project Structure Overview

The repository is organized as follows:

```
medicinal_plants_app/
 flutter_app/
 |- README.md
 |- analysis_options.yaml
 |- assets/
 | |- models/
 | |  - model_compatible1.tflite
 |- plants_data.json
 |- lib/
 | |- database/
 | |  - database_helper.dart
 |- main.dart
 | |- models/
 | |  - identification_history.dart
 | |  - user.dart
 | |  - user_favorite.dart
 | |- repositories/
 | |  - identification_history_repository.dart
 | |  - user_favorite_repository.dart
 | |  - user_repository.dart
 | |- screens/
 | |  - ToxicityWarningWidget.dart
 | |- auth/
 | |  - favorites_screen.dart
 | |  - history_page.dart
 | |  - image_classification_widget.dart
 | |- onboarding/
 | |  - plant_details_screen.dart
 | |  - profile_screen.dart
 | |  - remedies_page.dart
 | |- welcome/
 | |  - welcome_page.dart
 | |- services/
 | |  - data_importer.dart
 | |  - local_favorites_service.dart
 | |- widgets/
 | |  - bottom_nav_bar.dart- favorite_button.dart
 |- pubspec.lock
 |- pubspec.yaml
 |- test/
 |  - widget_test.dart
```

## Setup and Installation

To run the Flutter application locally:

1.  **Prerequisites:** Ensure you have Flutter SDK and an appropriate IDE (like VS Code or Android Studio with Flutter plugins) installed.
2.  **Clone Repository:** `git clone https://github.com/khadiijaaaaaaa/medicinal-plants-app.git`
3.  **Navigate to App Directory:** `cd medicinal_plants_app/flutter_app`
4.  **Place Assets:**
    *   Ensure the `medicinal_plants_model.tflite` file is located in `flutter_app/assets/models/`.
    *   Ensure the `plants_data.json` file is located in `flutter_app/assets/data/`.
5.  **Install Dependencies:** Run `flutter pub get` in the `flutter_app` directory.
6.  **Run the App:** Connect a device or start an emulator/simulator and run `flutter run`.


## Usage Guide

1.  **Launch:** Open the application.
2.  **Login/Sign Up:** Create an account or log in.
3.  **Identify:** Navigate to the identification screen. Use the camera icon to take a new picture of a plant leaf or select an existing image from your gallery.
4.  **View Results:** The app will process the image offline and display the identified plant's name, image, and a summary. Click on the result for detailed information.
5.  **Explore Details:** Review the plant's medicinal uses, toxicity warnings, and natural remedies.
6.  **Favorites:** Use the favorite icon on the details screen to save the plant for later.
7.  **History:** Access the history screen to see past identifications.
8.  **Remedies:** Browse the remedies section by category or search.
