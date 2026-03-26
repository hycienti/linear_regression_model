class StudentFeatures {
  final int gender;
  final int partTimeJob;
  final int absenceDays;
  final int extracurricularActivities;
  final int weeklySelfStudyHours;
  final String careerAspiration;
  final int historyScore;
  final int physicsScore;
  final int chemistryScore;
  final int biologyScore;
  final int englishScore;
  final int geographyScore;

  StudentFeatures({
    required this.gender,
    required this.partTimeJob,
    required this.absenceDays,
    required this.extracurricularActivities,
    required this.weeklySelfStudyHours,
    required this.careerAspiration,
    required this.historyScore,
    required this.physicsScore,
    required this.chemistryScore,
    required this.biologyScore,
    required this.englishScore,
    required this.geographyScore,
  });

  Map<String, dynamic> toJson() => {
        'gender': gender,
        'part_time_job': partTimeJob,
        'absence_days': absenceDays,
        'extracurricular_activities': extracurricularActivities,
        'weekly_self_study_hours': weeklySelfStudyHours,
        'career_aspiration': careerAspiration,
        'history_score': historyScore,
        'physics_score': physicsScore,
        'chemistry_score': chemistryScore,
        'biology_score': biologyScore,
        'english_score': englishScore,
        'geography_score': geographyScore,
      };

  static const List<String> careerAspirations = [
    'Artist',
    'Banker',
    'Business Owner',
    'Construction Engineer',
    'Designer',
    'Doctor',
    'Game Developer',
    'Government Officer',
    'Lawyer',
    'Real Estate Developer',
    'Scientist',
    'Software Engineer',
    'Stock Investor',
    'Teacher',
    'Unknown',
    'Writer',
  ];
}
