## Video Demo

[YouTube Demo Video](https://youtu.be/268GUJ5lKtY)


# Student Math Score Predictor

Predicting a student's math score based on study habits, attendance, extracurricular involvement, demographic info, and other subject scores. Schools and educators want to identify students who may struggle in a subject **before** they fail. By predicting a student's score from things we already know, teachers can intervene early and provide targeted support. The model is trained on a dataset of 2,000 students with 17 features using multiple regression algorithms, with Random Forest selected as the best performer.

## API Endpoint

**Base URL:** `https://linearregressionmodel-production-f10b.up.railway.app`

**Swagger UI:** `https://linearregressionmodel-production-f10b.up.railway.app/docs`

### `POST /predict`

**Request Body:**

```json
{
  "gender": 1,
  "part_time_job": 0,
  "absence_days": 3,
  "extracurricular_activities": 1,
  "weekly_self_study_hours": 5,
  "career_aspiration": "Software Engineer",
  "history_score": 75,
  "physics_score": 82,
  "chemistry_score": 80,
  "biology_score": 78,
  "english_score": 85,
  "geography_score": 79
}
```

**Response:**

```json
{
  "predicted_math_score": 82.45
}
```

| Field | Type | Description |
|-------|------|-------------|
| `gender` | int | 0 = Female, 1 = Male |
| `part_time_job` | int | 0 = No, 1 = Yes |
| `absence_days` | int | Number of absence days (0-10) |
| `extracurricular_activities` | int | 0 = No, 1 = Yes |
| `weekly_self_study_hours` | int | Hours of self-study per week (0-20) |
| `career_aspiration` | string | One of: Artist, Banker, Business Owner, Construction Engineer, Designer, Doctor, Game Developer, Government Officer, Lawyer, Real Estate Developer, Scientist, Software Engineer, Stock Investor, Teacher, Unknown, Writer |
| `history_score` | float | 0-100 |
| `physics_score` | float | 0-100 |
| `chemistry_score` | float | 0-100 |
| `biology_score` | float | 0-100 |
| `english_score` | float | 0-100 |
| `geography_score` | float | 0-100 |

## Video Demo

[YouTube Demo Video](https://www.loom.com/share/47c1dcd29df64248b89ae835694197a1)

## Project Structure

```
summative/
├── linear_regression/
│   └── multivariate.ipynb          # Jupyter notebook (EDA, model training, evaluation)
├── API/
│   ├── prediction.py               # FastAPI server with /predict endpoint
│   ├── requirements.txt            # Python dependencies
│   └── src/
│       ├── validations/
│       │   └── student_features.py # Pydantic request model
│       └── regression_models/
│           ├── best_model_math.pkl # Trained Random Forest model
│           └── scaler_math.pkl     # Fitted StandardScaler
└── FlutterApp/                     # Cross-platform mobile app
    ├── lib/
    │   ├── main.dart               # App entry point
    │   ├── config.dart             # API URL configuration
    │   ├── screens/                # UI screens
    │   ├── services/               # API service layer
    │   ├── models/                 # Data models
    │   ├── theme/                  # Dark mode theme
    │   └── widgets/                # Reusable UI components
    ├── pubspec.yaml                # Flutter dependencies
    └── .env                        # API URL config
```

## Setup Instructions

### Prerequisites

- Python 3.9+
- Flutter SDK 3.11.0+
- Git

### 1. Clone the Repository

```bash
git clone https://github.com/hycienti/linear_regression_model.git
cd linear_regression_model
```

### 2. Run the Jupyter Notebook

```bash
pip install jupyter pandas numpy scikit-learn matplotlib seaborn
cd summative/linear_regression
jupyter notebook multivariate.ipynb
```

Run all cells to see the full data exploration, model training, comparison, and evaluation pipeline. The notebook trains 4 models (SGD Linear Regression, Standard Linear Regression, Decision Tree, Random Forest) and exports the best one.

### 3. Run the API

```bash
cd summative/API
pip install -r requirements.txt
python prediction.py
```

The API starts at `http://0.0.0.0:8000`. Open `http://localhost:8000/docs` in your browser to access the Swagger UI and test the `/predict` endpoint interactively.

### 4. Run the Flutter Mobile App

```bash
cd summative/FlutterApp
```

**Configure the API URL:**

Edit the `.env` file to point to your running API:

```env
API_URL=http://10.0.2.2:8000    # For Android emulator
# API_URL=http://localhost:8000  # For iOS simulator or web
# API_URL=https://linearregressionmodel-production-f10b.up.railway.app  # For production
```

> **Note:** Android emulators cannot reach `localhost` directly. Use `10.0.2.2` which maps to the host machine's `localhost`. For physical devices, use your machine's local IP address or the deployed URL.

**Install dependencies and run:**

```bash
flutter pub get
flutter run
```

To target a specific platform:

```bash
flutter run -d chrome    # Web
flutter run -d android   # Android emulator/device
flutter run -d ios       # iOS simulator/device
flutter run -d macos     # macOS desktop
```

## Models Trained

| Model | Description |
|-------|-------------|
| SGD Linear Regression | Linear model using Stochastic Gradient Descent (200 epochs) |
| Standard Linear Regression | Classical closed-form linear regression |
| Decision Tree Regressor | Tree-based model (max_depth=10) |
| **Random Forest Regressor** | **Ensemble of 100 decision trees (max_depth=15) - Best model** |

Evaluation metrics: MSE (Mean Squared Error), R² Score, MAE (Mean Absolute Error). See the notebook for detailed results and visualizations.
