import joblib
from fastapi import FastAPI
import pandas as pd
import numpy as np
from src.validations.student_features import StudentFeatures
from fastapi.middleware.cors import CORSMiddleware


app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], #TODO:  Change it later to allow specific origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

model = joblib.load("src/regression_models/best_model_math.pkl")
scaler = joblib.load("src/regression_models/scaler_math.pkl")

@app.post("/predict")
def predict(features: StudentFeatures):
    # Convert input to DataFrame (must match training column order)
    input_data = pd.DataFrame([features.dict()])
    
    # Scale using the same scaler from training
    input_scaled = scaler.transform(input_data)
    
    # Predict
    prediction = model.predict(input_scaled)[0]
    
    return {"predicted_math_score": round(float(prediction), 2)}


# Run the API with uvicorn
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)