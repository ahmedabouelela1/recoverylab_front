import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/providers/api/api_provider.dart';
import 'package:recoverylab_front/providers/exception/snack_bar.dart';
import 'package:recoverylab_front/providers/navigation/routes_generator.dart';
import 'package:sizer/sizer.dart';
import 'package:solar_icons/solar_icons.dart';

// ─────────────────────────────────────────────
// Data models (mirrors backend schema)
// ─────────────────────────────────────────────

enum QuestionType { text, singleChoice, multipleChoice, boolean }

class QuestionOption {
  final int id;
  final String text;
  QuestionOption({required this.id, required this.text});

  factory QuestionOption.fromJson(Map<String, dynamic> json) =>
      QuestionOption(id: json['id'] as int, text: json['text'] as String);
}

class Question {
  final int id;
  final String text;
  final QuestionType type;
  final List<QuestionOption> options;

  Question({
    required this.id,
    required this.text,
    required this.type,
    this.options = const [],
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    final typeStr = (json['type'] as String?) ?? 'text';
    final QuestionType type;
    switch (typeStr) {
      case 'single_choice':
        type = QuestionType.singleChoice;
        break;
      case 'multiple_choice':
        type = QuestionType.multipleChoice;
        break;
      case 'boolean':
        type = QuestionType.boolean;
        break;
      default:
        type = QuestionType.text;
    }

    final answersRaw = (json['answers'] as List<dynamic>?) ?? [];
    final options =
        answersRaw.map((a) => QuestionOption.fromJson(a as Map<String, dynamic>)).toList();

    return Question(
      id: json['id'] as int,
      text: json['text'] as String,
      type: type,
      options: options,
    );
  }
}

// ─────────────────────────────────────────────
// Page
// ─────────────────────────────────────────────

class QuestionnairePage extends ConsumerStatefulWidget {
  const QuestionnairePage({super.key});

  @override
  ConsumerState<QuestionnairePage> createState() => _QuestionnairePageState();
}

class _QuestionnairePageState extends ConsumerState<QuestionnairePage>
    with SingleTickerProviderStateMixin {
  // ── Loading state ──────────────────────────
  bool _loading = true;
  String? _loadError;
  List<Question> _questions = [];

  // ── Progress / answers ─────────────────────
  int _currentIndex = 0;
  final Map<int, dynamic> _answers = {};
  final TextEditingController _textController = TextEditingController();

  // ── Animation ─────────────────────────────
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.08, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _fadeAnimation =
        CurvedAnimation(parent: _slideController, curve: Curves.easeOut);
    _slideController.forward();

    _fetchQuestions();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _textController.dispose();
    super.dispose();
  }

  // ── API ────────────────────────────────────

  Future<void> _fetchQuestions() async {
    try {
      final raw = await ref.read(apiProvider).getQuestions();
      final questions = raw.map((j) => Question.fromJson(j)).toList();
      if (mounted) {
        setState(() {
          _questions = questions;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadError = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _submitAnswers() async {
    setState(() => _submitting = true);
    try {
      final payload = _buildPayload();
      await ref.read(apiProvider).submitAnswersBulk(payload);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, Routes.navbar);
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.show(context, 'Could not save answers. Please try again.');
      setState(() => _submitting = false);
    }
  }

  /// Convert _answers map to the bulk API payload.
  List<Map<String, dynamic>> _buildPayload() {
    final List<Map<String, dynamic>> payload = [];

    for (final q in _questions) {
      final answer = _answers[q.id];
      if (answer == null) continue;

      switch (q.type) {
        case QuestionType.singleChoice:
          payload.add({
            'question_id': q.id,
            'answer_id': answer as int,
            'custom_answer': null,
          });
          break;
        case QuestionType.multipleChoice:
          for (final id in (answer as Set<int>)) {
            payload.add({
              'question_id': q.id,
              'answer_id': id,
              'custom_answer': null,
            });
          }
          break;
        case QuestionType.boolean:
          payload.add({
            'question_id': q.id,
            'answer_id': null,
            'custom_answer': (answer as bool) ? 'true' : 'false',
          });
          break;
        case QuestionType.text:
          final text = answer as String;
          if (text.isNotEmpty) {
            payload.add({
              'question_id': q.id,
              'answer_id': null,
              'custom_answer': text,
            });
          }
          break;
      }
    }

    return payload;
  }

  // ── Navigation ─────────────────────────────

  Question get _current => _questions[_currentIndex];
  int get _total => _questions.length;
  bool get _isLast => _currentIndex == _total - 1;

  bool get _canAdvance {
    if (_questions.isEmpty) return false;
    final answer = _answers[_current.id];
    switch (_current.type) {
      case QuestionType.singleChoice:
        return answer != null;
      case QuestionType.multipleChoice:
        return answer != null && (answer as Set).isNotEmpty;
      case QuestionType.boolean:
        return answer != null;
      case QuestionType.text:
        return _textController.text.trim().isNotEmpty;
    }
  }

  void _goNext() async {
    if (_current.type == QuestionType.text) {
      _answers[_current.id] = _textController.text.trim();
    }
    if (!_canAdvance) return;

    if (_isLast) {
      await _submitAnswers();
      return;
    }

    await _slideController.reverse();
    setState(() {
      _currentIndex++;
      if (_current.type == QuestionType.text) {
        _textController.text = (_answers[_current.id] as String?) ?? '';
      }
    });
    _slideController.forward();
  }

  void _goBack() async {
    if (_currentIndex == 0) {
      Navigator.pop(context);
      return;
    }
    await _slideController.reverse();
    setState(() {
      _currentIndex--;
      if (_current.type == QuestionType.text) {
        _textController.text = (_answers[_current.id] as String?) ?? '';
      }
    });
    _slideController.forward();
  }

  void _skip() {
    Navigator.pushReplacementNamed(context, Routes.navbar);
  }

  // ── Build helpers ──────────────────────────

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'QUESTION ${_currentIndex + 1} OF $_total',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            Text(
              '${((_currentIndex + 1) / _total * 100).round()}%',
              style: TextStyle(
                color: AppColors.info,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              Container(
                height: 0.6.h,
                width: double.infinity,
                color: AppColors.dividerColor,
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                height: 0.6.h,
                width: ((_currentIndex + 1) / _total) * 100.w - 8.w,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSingleChoice(Question q) {
    final selected = _answers[q.id] as int?;
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: q.options.length,
      separatorBuilder: (_, __) => SizedBox(height: 1.5.h),
      itemBuilder: (_, i) {
        final opt = q.options[i];
        final isSelected = selected == opt.id;
        return GestureDetector(
          onTap: () => setState(() => _answers[q.id] = opt.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.08)
                  : AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.dividerColor,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 5.5.w,
                  height: 5.5.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textTertiary,
                      width: 2,
                    ),
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.15)
                        : Colors.transparent,
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 2.5.w,
                            height: 2.5.w,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    opt.text,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontSize: 14.sp,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMultipleChoice(Question q) {
    final selected = (_answers[q.id] as Set<int>?) ?? <int>{};
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: q.options.length,
      separatorBuilder: (_, __) => SizedBox(height: 1.5.h),
      itemBuilder: (_, i) {
        final opt = q.options[i];
        final isSelected = selected.contains(opt.id);
        return GestureDetector(
          onTap: () {
            setState(() {
              final s = Set<int>.from(selected);
              if (isSelected) {
                s.remove(opt.id);
              } else {
                s.add(opt.id);
              }
              _answers[q.id] = s;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.info.withOpacity(0.08)
                  : AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.info : AppColors.dividerColor,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 5.5.w,
                  height: 5.5.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.info
                          : AppColors.textTertiary,
                      width: 2,
                    ),
                    color: isSelected ? AppColors.info : Colors.transparent,
                  ),
                  child: isSelected
                      ? Icon(Icons.check, color: Colors.white, size: 13.sp)
                      : null,
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    opt.text,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontSize: 14.sp,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBoolean(Question q) {
    final selected = _answers[q.id] as bool?;
    return Row(
      children: [
        Expanded(
          child: _buildBoolTile(
            q: q,
            value: true,
            label: 'Yes',
            icon: SolarIconsOutline.checkCircle,
            isSelected: selected == true,
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: _buildBoolTile(
            q: q,
            value: false,
            label: 'No',
            icon: SolarIconsOutline.closeCircle,
            isSelected: selected == false,
          ),
        ),
      ],
    );
  }

  Widget _buildBoolTile({
    required Question q,
    required bool value,
    required String label,
    required IconData icon,
    required bool isSelected,
  }) {
    final color = value ? AppColors.success : AppColors.textSecondary;
    return GestureDetector(
      onTap: () => setState(() => _answers[q.id] = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 14.h,
        decoration: BoxDecoration(
          color:
              isSelected ? color.withOpacity(0.1) : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : AppColors.dividerColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? color : AppColors.textTertiary,
              size: 28.sp,
            ),
            SizedBox(height: 1.h),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : AppColors.textSecondary,
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextInput(Question q) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerColor),
      ),
      child: TextField(
        controller: _textController,
        maxLines: 6,
        onChanged: (_) => setState(() {}),
        style: TextStyle(color: AppColors.textPrimary, fontSize: 14.sp),
        decoration: InputDecoration(
          hintText: 'Type your answer here...',
          hintStyle:
              TextStyle(color: AppColors.textTertiary, fontSize: 13.sp),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(4.w),
        ),
      ),
    );
  }

  Widget _buildQuestionBody(Question q) {
    switch (q.type) {
      case QuestionType.singleChoice:
        return _buildSingleChoice(q);
      case QuestionType.multipleChoice:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.info.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    SolarIconsOutline.checkSquare,
                    color: AppColors.info,
                    size: 13.sp,
                  ),
                  SizedBox(width: 1.5.w),
                  Text(
                    'SELECT ALL THAT APPLY',
                    style: TextStyle(
                      color: AppColors.info,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
            _buildMultipleChoice(q),
          ],
        );
      case QuestionType.boolean:
        return _buildBoolean(q);
      case QuestionType.text:
        return _buildTextInput(q);
    }
  }

  Widget _buildTypeBadge(QuestionType type) {
    switch (type) {
      case QuestionType.singleChoice:
        return _badge(
          icon: SolarIconsOutline.checkCircle,
          label: 'SINGLE CHOICE',
          color: AppColors.info,
        );
      case QuestionType.multipleChoice:
        return _badge(
          icon: SolarIconsOutline.checkSquare,
          label: 'MULTIPLE CHOICE',
          color: AppColors.info,
        );
      case QuestionType.boolean:
        return _badge(
          icon: SolarIconsOutline.help,
          label: 'YES / NO',
          color: AppColors.info,
        );
      case QuestionType.text:
        return _badge(
          icon: SolarIconsOutline.textField,
          label: 'OPEN ANSWER',
          color: AppColors.info,
        );
    }
  }

  Widget _badge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13.sp),
          SizedBox(width: 1.5.w),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Main build ─────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: _loading ? null : _goBack,
          child: Padding(
            padding: EdgeInsets.only(left: 4.w),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.textPrimary,
              size: 18.sp,
            ),
          ),
        ),
        title: Text(
          'Wellness Profile',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _skip,
            child: Text(
              'Skip',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13.sp,
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _loadError != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Failed to load questions',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _loading = true;
                            _loadError = null;
                          });
                          _fetchQuestions();
                        },
                        child: Text(
                          'Retry',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                )
              : _questions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'No questions available',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          TextButton(
                            onPressed: _skip,
                            child: Text(
                              'Continue to app',
                              style: TextStyle(color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    )
                  : SafeArea(
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5.w),
                            child: _buildProgressBar(),
                          ),
                          SizedBox(height: 3.h),
                          Expanded(
                            child: SingleChildScrollView(
                              padding: EdgeInsets.symmetric(horizontal: 5.w),
                              child: SlideTransition(
                                position: _slideAnimation,
                                child: FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildTypeBadge(_current.type),
                                      SizedBox(height: 1.5.h),
                                      Text(
                                        _current.text,
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                          height: 1.3,
                                        ),
                                      ),
                                      SizedBox(height: 3.h),
                                      _buildQuestionBody(_current),
                                      SizedBox(height: 10.h),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(5.w, 0, 5.w, 3.h),
                            child: Column(
                              children: [
                                Container(
                                    height: 0.5,
                                    color: AppColors.dividerColor),
                                SizedBox(height: 2.h),
                                Row(
                                  children: [
                                    if (_currentIndex > 0) ...[
                                      GestureDetector(
                                        onTap: _goBack,
                                        child: Container(
                                          height: 6.h,
                                          width: 14.w,
                                          decoration: BoxDecoration(
                                            color: AppColors.surfaceLight,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            border: Border.all(
                                                color: AppColors.dividerColor),
                                          ),
                                          child: Icon(
                                            Icons.arrow_back_ios_new,
                                            color: AppColors.textSecondary,
                                            size: 16.sp,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 3.w),
                                    ],
                                    Expanded(
                                      child: AnimatedOpacity(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        opacity: _canAdvance ? 1.0 : 0.5,
                                        child: GestureDetector(
                                          onTap: (_canAdvance && !_submitting)
                                              ? _goNext
                                              : null,
                                          child: Container(
                                            height: 6.h,
                                            decoration: BoxDecoration(
                                              color: AppColors.primary,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              boxShadow: _canAdvance
                                                  ? [
                                                      BoxShadow(
                                                        color: AppColors.primary
                                                            .withOpacity(0.3),
                                                        blurRadius: 12,
                                                        offset:
                                                            const Offset(0, 4),
                                                      ),
                                                    ]
                                                  : [],
                                            ),
                                            child: _submitting
                                                ? Center(
                                                    child: SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color:
                                                            AppColors.secondary,
                                                      ),
                                                    ),
                                                  )
                                                : Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        _isLast
                                                            ? 'Finish'
                                                            : 'Continue',
                                                        style: TextStyle(
                                                          color:
                                                              AppColors.secondary,
                                                          fontSize: 15.sp,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      SizedBox(width: 2.w),
                                                      Icon(
                                                        _isLast
                                                            ? Icons.check
                                                            : Icons
                                                                .arrow_forward,
                                                        color:
                                                            AppColors.secondary,
                                                        size: 16.sp,
                                                      ),
                                                    ],
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}
