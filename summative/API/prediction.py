import joblib
from fastapi import FastAPI
import pandas as pd
import numpy as np
from src.validations.student_features import StudentFeatures
from fastapi.middleware.cors import CORSMiddleware


app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["POST"],
    allow_headers=["*"],
)

model = joblib.load("src/regression_models/best_model_math.pkl")
scaler = joblib.load("src/regression_models/scaler_math.pkl")

@app.post("/predict")
def predict(features: StudentFeatures):
    # Get the input as a dictionary
    data = features.model_dump()

    # Extract career_aspiration and remove it from the dict
    career = data.pop('career_aspiration')

    # Create the base DataFrame
    input_data = pd.DataFrame([data])

    # Add all one-hot encoded career columns (all 0 initially)
    career_columns = [
        'career_aspiration_Artist', 'career_aspiration_Banker',
        'career_aspiration_Business Owner', 'career_aspiration_Construction Engineer',
        'career_aspiration_Designer', 'career_aspiration_Doctor',
        'career_aspiration_Game Developer', 'career_aspiration_Government Officer',
        'career_aspiration_Lawyer', 'career_aspiration_Real Estate Developer',
        'career_aspiration_Scientist', 'career_aspiration_Software Engineer',
        'career_aspiration_Stock Investor', 'career_aspiration_Teacher',
        'career_aspiration_Unknown', 'career_aspiration_Writer'
    ]
    
    for col in career_columns:
        input_data[col] = 0

    # Set the matching career column to 1
    career_col = f'career_aspiration_{career}'
    if career_col in career_columns:
        input_data[career_col] = 1

    # Scale and predict
    input_scaled = scaler.transform(input_data)
    prediction = model.predict(input_scaled)[0]

    return {"predicted_math_score": round(float(prediction), 2)}

# Run the API with uvicorn
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)