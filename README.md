
# 🌿 Medicinal Plant Identification App

This mobile application is designed to **identify medicinal plants from photos using machine learning**, providing **detailed information** such as their scientific name, medicinal properties, and potential toxicity. It is optimized to work **offline**, making it accessible in field environments without internet access.

## 🧠 Project Summary

- **Goal**: Create a high-performance, offline-capable mobile app to identify medicinal plants and warn users about toxic components.
- **Target Users**: Botanists, herbalists, foragers, students, and anyone curious about natural remedies.
- **Core Features**:
  - Offline plant image classification with **MobileNetV2** (TensorFlow Lite).
  - Secondary **toxicity detection model** to flag harmful plants.
  - Local plant information database (in JSON).
  - User interface built with **Flutter**.
  - **CameraX** support for real-time image capture.
  - **SQLite** integration for saving identified plants and favorites.

---

## 📦 Project Structure

```
medicinal_plants_app/
│
├── models/
│   ├── medicinal_plants_model.ipynb          # Notebook for classification model
│   ├── medicinal_plants_model.tflite         # TFLite version of plant classifier
│   ├── toxicity_detection_model.ipynb        # (To create) Notebook for toxicity detection
│   └── toxicity_detection_model.tflite       # (To export) Toxicity model
│
├── data/
│   ├── kaggle_dataset_link.txt               # Link/reference to training dataset
│   └── plants_data.json                      # Metadata: names, uses, toxicity, remedies
│
├── flutter_app/
│   ├── lib/
│   │   ├── main.dart
│   │   ├── screens/
│   │   ├── models/
│   │   ├── services/
│   │   └── widgets/
│   ├── assets/
│   │   ├── models/
│   │   └── data/
│   ├── pubspec.yaml
│   └── android/ | ios/
│
└── README.md
```

---

## 🔍 Example Plant Data (from `plants_data.json`)

```json
{
  "name": "Aloevera",
  "scientific_name": "Aloe vera",
  "medicinal_uses": [
    "Hydratation de la peau",
    "Traitement des brûlures légères",
    "Soulagement des irritations cutanées"
  ],
  "toxicity": {
    "is_toxic": true,
    "toxic_parts": "Latex (partie jaune sous la peau de la feuille)",
    "effects": [
      "Diarrhée",
      "Crampes abdominales",
      "Irritations en usage prolongé"
    ]
  },
  "natural_remedies": [
    {
      "title": "Gel apaisant pour brûlures",
      "ingredients": [
        "Gel d’aloevera frais",
        "Huile de lavande (optionnelle)"
      ],
      "instructions": "Appliquer directement sur la brûlure 2 à 3 fois par jour."
    }
  ],
  "origin": "Afrique du Nord",
  "growth_environment": "Climat sec et ensoleillé",
  "category": "Plante médicinale"
}
```

---

## 🧰 Technologies Used

| Component             | Technology             |
|----------------------|------------------------|
| Image Classification | TensorFlow + MobileNetV2 |
| On-device Inference  | TensorFlow Lite        |
| Toxicity Detection   | (Planned) ML model     |
| UI Framework         | Flutter                |
| Camera Integration   | CameraX                |
| Local Storage        | SQLite (sqflite)       |
| Data Format          | JSON                   |
| Dataset Source       | Kaggle Dataset         |

---

## 🚀 Setup Instructions

### 1. Model Training

- Run `medicinal_plants_model.ipynb` in Kaggle to train and export the `.tflite` model.
- *(Optional)* Create and train `toxicity_detection_model.ipynb`.

### 2. Flutter Setup

```bash
cd flutter_app/
flutter pub get
flutter run
```

- Place `.tflite` models in `flutter_app/assets/models/`
- Place `plants_data.json` in `flutter_app/assets/data/`

### 3. `pubspec.yaml` Configuration

Ensure these lines are included in your `pubspec.yaml`:

```yaml
assets:
  - assets/models/medicinal_plants_model.tflite
  - assets/data/plants_data.json

dependencies:
  flutter:
    sdk: flutter
  tflite_flutter: ^0.10.0
  sqflite: ^2.2.5
  path_provider: ^2.1.2
  camera: ^0.10.5+2
```

---

## 🧪 To Do (Remaining Work)

- [ ] Train and export the toxicity detection model.
- [ ] Build Flutter UI (screens, plant info display, SQLite support).
- [ ] Integrate TFLite model inference in Flutter.
- [ ] Handle CameraX integration for image capture.
- [ ] Improve offline experience (e.g., asset preloading).
