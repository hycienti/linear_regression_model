import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../models/student_features.dart';
import '../services/api_service.dart';
import '../widgets/section_card.dart';
import '../widgets/score_slider.dart';
import '../widgets/result_bottom_sheet.dart';

class PredictorScreen extends StatefulWidget {
  const PredictorScreen({super.key});

  @override
  State<PredictorScreen> createState() => _PredictorScreenState();
}

class _PredictorScreenState extends State<PredictorScreen> {
  // Tour keys
  final _appBarKey = GlobalKey();
  final _profileKey = GlobalKey();
  final _studyHabitsKey = GlobalKey();
  final _careerKey = GlobalKey();
  final _scoresKey = GlobalKey();
  final _submitKey = GlobalKey();

  TutorialCoachMark? _tutorialCoachMark;

  // Form state — no controllers needed, sliders enforce bounds
  int _gender = 0; // 0 = Female, 1 = Male
  bool _partTimeJob = false;
  bool _extracurricular = false;
  int _absenceDays = 0;
  int _studyHours = 0;
  String? _careerAspiration;

  // Subject scores
  int _historyScore = 50;
  int _physicsScore = 50;
  int _chemistryScore = 50;
  int _biologyScore = 50;
  int _englishScore = 50;
  int _geographyScore = 50;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkAndShowTour();
  }

  // ── Tour ──────────────────────────────────────────────────────────────

  Future<void> _checkAndShowTour() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenTour = prefs.getBool('hasSeenTour') ?? false;
    if (!hasSeenTour) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showTour());
    }
  }

  void _showTour() {
    final targets = <TargetFocus>[
      _buildTarget('appBar', _appBarKey, ContentAlign.bottom,
          'Welcome to ScorePredict AI',
          'This app uses AI to predict your math score based on your profile and subject scores. Let\'s walk through it!'),
      _buildTarget('profile', _profileKey, ContentAlign.bottom,
          'Student Profile',
          'Start by entering your basic info — gender, part-time job status, and extracurricular activities.'),
      _buildTarget('studyHabits', _studyHabitsKey, ContentAlign.bottom,
          'Study Habits',
          'Adjust your absence days and weekly self-study hours using the sliders.'),
      _buildTarget('career', _careerKey, ContentAlign.top, 'Career Aspiration',
          'Tap a chip to select your career goal. The model factors this into your prediction.'),
      _buildTarget('scores', _scoresKey, ContentAlign.top, 'Subject Scores',
          'Use the sliders to set your scores (0–100) for six subjects.'),
      _buildTarget('submit', _submitKey, ContentAlign.top,
          'Get Your Prediction',
          'Once everything is set, tap this button to get your AI-predicted math score!',
          isLast: true),
    ];

    final colorScheme = Theme.of(context).colorScheme;

    _tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: colorScheme.surface,
      opacityShadow: 0.92,
      paddingFocus: 10,
      textSkip: 'SKIP',
      textStyleSkip: TextStyle(
        color: colorScheme.onSurface.withValues(alpha: 0.6),
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.2,
      ),
      onFinish: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('hasSeenTour', true);
      },
      onSkip: () {
        SharedPreferences.getInstance().then((prefs) {
          prefs.setBool('hasSeenTour', true);
        });
        return true;
      },
    );
    _tutorialCoachMark!.show(context: context);
  }

  TargetFocus _buildTarget(String id, GlobalKey key, ContentAlign align,
      String title, String description,
      {bool isLast = false}) {
    return TargetFocus(
      identify: id,
      keyTarget: key,
      alignSkip: Alignment.bottomCenter,
      shape: ShapeLightFocus.RRect,
      radius: 16,
      contents: [
        TargetContent(
          align: align,
          child: _tourContent(title, description, isLast: isLast),
        ),
      ],
    );
  }

  Widget _tourContent(String title, String description,
      {bool isLast = false}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                if (isLast) {
                  _tutorialCoachMark?.finish();
                } else {
                  _tutorialCoachMark?.next();
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isLast ? 'GOT IT' : 'NEXT',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onPrimary,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Predict ───────────────────────────────────────────────────────────

  Future<void> _predict() async {
    if (_careerAspiration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a career aspiration')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final features = StudentFeatures(
        gender: _gender,
        partTimeJob: _partTimeJob ? 1 : 0,
        absenceDays: _absenceDays,
        extracurricularActivities: _extracurricular ? 1 : 0,
        weeklySelfStudyHours: _studyHours,
        careerAspiration: _careerAspiration!,
        historyScore: _historyScore,
        physicsScore: _physicsScore,
        chemistryScore: _chemistryScore,
        biologyScore: _biologyScore,
        englishScore: _englishScore,
        geographyScore: _geographyScore,
      );

      final score = await ApiService.predictScore(features);

      if (mounted) {
        showResultBottomSheet(context, score);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Collapsing app bar
          SliverAppBar(
            title: Row(
              key: _appBarKey,
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Icon(
                    Icons.auto_graph,
                    color: colorScheme.onPrimaryContainer,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'ScorePredict AI',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            centerTitle: true,
            floating: true,
            snap: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.help_outline, size: 20),
                tooltip: 'Show tour',
                onPressed: _showTour,
              ),
              const SizedBox(width: 4),
            ],
          ),

          // Body
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            sliver: SliverList.list(
              children: [
                // Tagline
                Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      'Powered by Machine Learning',
                      style: TextStyle(
                        color: colorScheme.primary.withValues(alpha: 0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Student Profile
                SectionCard(
                  sectionKey: _profileKey,
                  title: 'Student Profile',
                  icon: Icons.person_outline,
                  child: Column(
                    children: [
                      _buildSegmentedRow(
                        label: 'Gender',
                        icon: Icons.wc,
                        child: SegmentedButton<int>(
                          segments: const [
                            ButtonSegment(
                              value: 0,
                              label: Text('Female'),
                              icon: Icon(Icons.female, size: 18),
                            ),
                            ButtonSegment(
                              value: 1,
                              label: Text('Male'),
                              icon: Icon(Icons.male, size: 18),
                            ),
                          ],
                          selected: {_gender},
                          onSelectionChanged: (v) =>
                              setState(() => _gender = v.first),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSegmentedRow(
                        label: 'Part-time Job',
                        icon: Icons.work_outline,
                        child: SegmentedButton<bool>(
                          segments: const [
                            ButtonSegment(value: false, label: Text('No')),
                            ButtonSegment(value: true, label: Text('Yes')),
                          ],
                          selected: {_partTimeJob},
                          onSelectionChanged: (v) =>
                              setState(() => _partTimeJob = v.first),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSegmentedRow(
                        label: 'Extracurriculars',
                        icon: Icons.extension_outlined,
                        child: SegmentedButton<bool>(
                          segments: const [
                            ButtonSegment(value: false, label: Text('No')),
                            ButtonSegment(value: true, label: Text('Yes')),
                          ],
                          selected: {_extracurricular},
                          onSelectionChanged: (v) =>
                              setState(() => _extracurricular = v.first),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Study Habits
                SectionCard(
                  sectionKey: _studyHabitsKey,
                  title: 'Study Habits',
                  icon: Icons.schedule,
                  child: Column(
                    children: [
                      ScoreSlider(
                        label: 'Absence Days',
                        icon: Icons.event_busy,
                        value: _absenceDays,
                        min: 0,
                        max: 365,
                        divisions: 365,
                        unit: 'days',
                        onChanged: (v) => setState(() => _absenceDays = v),
                      ),
                      const SizedBox(height: 8),
                      ScoreSlider(
                        label: 'Weekly Self-Study',
                        icon: Icons.menu_book,
                        value: _studyHours,
                        min: 0,
                        max: 40,
                        divisions: 40,
                        unit: 'hrs',
                        onChanged: (v) => setState(() => _studyHours = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Career Aspiration
                SectionCard(
                  sectionKey: _careerKey,
                  title: 'Career Aspiration',
                  icon: Icons.rocket_launch,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: StudentFeatures.careerAspirations.map((career) {
                      final selected = _careerAspiration == career;
                      return ChoiceChip(
                        label: Text(career),
                        selected: selected,
                        onSelected: (_) =>
                            setState(() => _careerAspiration = career),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // Subject Scores
                SectionCard(
                  sectionKey: _scoresKey,
                  title: 'Subject Scores',
                  icon: Icons.school,
                  child: Column(
                    children: [
                      ScoreSlider(
                        label: 'History',
                        icon: Icons.history_edu,
                        value: _historyScore,
                        onChanged: (v) => setState(() => _historyScore = v),
                      ),
                      ScoreSlider(
                        label: 'Physics',
                        icon: Icons.science,
                        value: _physicsScore,
                        onChanged: (v) => setState(() => _physicsScore = v),
                      ),
                      ScoreSlider(
                        label: 'Chemistry',
                        icon: Icons.biotech,
                        value: _chemistryScore,
                        onChanged: (v) => setState(() => _chemistryScore = v),
                      ),
                      ScoreSlider(
                        label: 'Biology',
                        icon: Icons.eco,
                        value: _biologyScore,
                        onChanged: (v) => setState(() => _biologyScore = v),
                      ),
                      ScoreSlider(
                        label: 'English',
                        icon: Icons.translate,
                        value: _englishScore,
                        onChanged: (v) => setState(() => _englishScore = v),
                      ),
                      ScoreSlider(
                        label: 'Geography',
                        icon: Icons.public,
                        value: _geographyScore,
                        onChanged: (v) => setState(() => _geographyScore = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                FilledButton.icon(
                  key: _submitKey,
                  onPressed: _isLoading ? null : _predict,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.auto_awesome, size: 20),
                  label: Text(
                      _isLoading ? 'ANALYZING...' : 'PREDICT MATH SCORE'),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedRow({
    required String label,
    required IconData icon,
    required Widget child,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 10),
            Text(label, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(width: double.infinity, child: child),
      ],
    );
  }
}
