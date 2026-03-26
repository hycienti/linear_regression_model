from pydantic import BaseModel

class StudentFeatures(BaseModel):
    gender: int
    part_time_job: int
    absence_days: int
    extracurricular_activities: int
    weekly_self_study_hours: int
    history_score: int
    physics_score: int
    chemistry_score: int
    biology_score: int
    english_score: int
    geography_score: int