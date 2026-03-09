import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recoverylab_front/configurations/colors.dart';
import 'package:recoverylab_front/providers/api/api_provider.dart';
import 'package:recoverylab_front/providers/exception/snack_bar.dart';
import 'package:recoverylab_front/providers/session/user_session_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:solar_icons/solar_icons.dart';

// Re-use the same model types as the questionnaire page.
enum _QuestionType { text, singleChoice, multipleChoice, boolean }

class _Option {
  final int id;
  final String text;
  _Option({required this.id, required this.text});
}

class _Question {
  final int id;
  final String text;
  final _QuestionType type;
  final List<_Option> options;

  _Question({
    required this.id,
    required this.text,
    required this.type,
    this.options = const [],
  });

  factory _Question.fromJson(Map<String, dynamic> json) {
    final typeStr = (json['type'] as String?) ?? 'text';
    final _QuestionType type;
    switch (typeStr) {
      case 'single_choice':
        type = _QuestionType.singleChoice;
        break;
      case 'multiple_choice':
        type = _QuestionType.multipleChoice;
        break;
      case 'boolean':
        type = _QuestionType.boolean;
        break;
      default:
        type = _QuestionType.text;
    }
    final answersRaw = (json['answers'] as List<dynamic>?) ?? [];
    final options = answersRaw
        .map((a) => _Option(
              id: (a as Map<String, dynamic>)['id'] as int,
              text: a['text'] as String,
            ))
        .toList();
    return _Question(id: json['id'] as int, text: json['text'] as String, type: type, options: options);
  }
}

// ─────────────────────────────────────────────
// Page
// ─────────────────────────────────────────────

class EditHealthSurveyPage extends ConsumerStatefulWidget {
  const EditHealthSurveyPage({super.key});

  @override
  ConsumerState<EditHealthSurveyPage> createState() => _EditHealthSurveyPageState();
}

class _EditHealthSurveyPageState extends ConsumerState<EditHealthSurveyPage>
    with SingleTickerProviderStateMixin {
  // ── Loading ────────────────────────────────
  bool _loading = true;
  String? _loadError;
  List<_Question> _questions = [];

  // ── Progress / answers ─────────────────────
  int _currentIndex = 0;
  final Map<int, dynamic> _answers = {};
  final TextEditingController _textController = TextEditingController();

  // ── Animation ─────────────────────────────
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  bool _saving = false;

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
    _loadData();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _textController.dispose();
    super.dispose();
  }

  // ── Fetch questions + existing answers ─────

  Future<void> _loadData() async {
    final userId = ref.read(userSessionProvider).user?.id;
    try {
      final api = ref.read(apiProvider);
      final questionsRaw = await api.getQuestions();
      final questions = questionsRaw
          .map((j) => _Question.fromJson(j))
          .toList();

      Map<int, List<Map<String, dynamic>>> existing = {};
      if (userId != null) {
        try {
          existing = await api.getUserAnswers(userId);
        } catch (_) {
          // Use empty existing if user-answers fails (e.g. 401 or no data)
        }
      }

      // Pre-fill _answers from existing server data.
      final Map<int, dynamic> prefilled = {};
      for (final q in questions) {
        final entries = existing[q.id];
        if (entries == null || entries.isEmpty) continue;

        switch (q.type) {
          case _QuestionType.singleChoice:
            final answerId = entries.first['answer_id'];
            if (answerId != null) prefilled[q.id] = answerId as int;
            break;
          case _QuestionType.multipleChoice:
            final ids = entries
                .where((e) => e['answer_id'] != null)
                .map((e) => e['answer_id'] as int)
                .toSet();
            if (ids.isNotEmpty) prefilled[q.id] = ids;
            break;
          case _QuestionType.boolean:
            final val = entries.first['custom_answer'];
            if (val != null) prefilled[q.id] = val == 'true';
            break;
          case _QuestionType.text:
            final val = entries.first['custom_answer'];
            if (val != null) prefilled[q.id] = val as String;
            break;
        }
      }

      if (mounted) {
        setState(() {
          _questions = questions;
          _answers.addAll(prefilled);
          _loading = false;
          // Seed text controller if first question is text.
          if (questions.isNotEmpty && questions.first.type == _QuestionType.text) {
            _textController.text = (prefilled[questions.first.id] as String?) ?? '';
          }
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

  // ── Save ───────────────────────────────────

  Future<void> _save() async {
    // Persist current text answer if on a text question.
    if (_questions.isNotEmpty && _current.type == _QuestionType.text) {
      _answers[_current.id] = _textController.text.trim();
    }

    setState(() => _saving = true);
    try {
      final payload = _buildPayload();
      await ref.read(apiProvider).replaceAnswersBulk(payload);
      if (!mounted) return;
      AppSnackBar.show(context, 'Health survey updated successfully');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.show(context, 'Failed to save. Please try again.');
      setState(() => _saving = false);
    }
  }

  List<Map<String, dynamic>> _buildPayload() {
    final List<Map<String, dynamic>> payload = [];
    for (final q in _questions) {
      final answer = _answers[q.id];
      if (answer == null) continue;
      switch (q.type) {
        case _QuestionType.singleChoice:
          payload.add({'question_id': q.id, 'answer_id': answer as int, 'custom_answer': null});
          break;
        case _QuestionType.multipleChoice:
          for (final id in (answer as Set<int>)) {
            payload.add({'question_id': q.id, 'answer_id': id, 'custom_answer': null});
          }
          break;
        case _QuestionType.boolean:
          payload.add({'question_id': q.id, 'answer_id': null, 'custom_answer': (answer as bool) ? 'true' : 'false'});
          break;
        case _QuestionType.text:
          final text = answer as String;
          if (text.isNotEmpty) {
            payload.add({'question_id': q.id, 'answer_id': null, 'custom_answer': text});
          }
          break;
      }
    }
    return payload;
  }

  // ── Navigation ─────────────────────────────

  _Question get _current => _questions[_currentIndex];
  int get _total => _questions.length;
  bool get _isLast => _currentIndex == _total - 1;

  bool get _canAdvance {
    if (_questions.isEmpty) return false;
    final answer = _answers[_current.id];
    switch (_current.type) {
      case _QuestionType.singleChoice:
        return answer != null;
      case _QuestionType.multipleChoice:
        return answer != null && (answer as Set).isNotEmpty;
      case _QuestionType.boolean:
        return answer != null;
      case _QuestionType.text:
        return _textController.text.trim().isNotEmpty;
    }
  }

  // Allow advancing even if unanswered when editing (question may be skipped).
  bool get _canAdvanceOrSkip => true;

  void _goNext() async {
    if (_current.type == _QuestionType.text) {
      _answers[_current.id] = _textController.text.trim();
    }

    if (_isLast) {
      await _save();
      return;
    }

    await _slideController.reverse();
    setState(() {
      _currentIndex++;
      if (_current.type == _QuestionType.text) {
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
      if (_current.type == _QuestionType.text) {
        _textController.text = (_answers[_current.id] as String?) ?? '';
      }
    });
    _slideController.forward();
  }

  // ── Widgets ────────────────────────────────

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
              Container(height: 0.6.h, width: double.infinity, color: AppColors.dividerColor),
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

  Widget _buildSingleChoice(_Question q) {
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
              color: isSelected ? AppColors.primary.withOpacity(0.08) : AppColors.cardBackground,
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
                      color: isSelected ? AppColors.primary : AppColors.textTertiary,
                      width: 2,
                    ),
                    color: isSelected ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 2.5.w,
                            height: 2.5.w,
                            decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                          ),
                        )
                      : null,
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    opt.text,
                    style: TextStyle(
                      color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                      fontSize: 14.sp,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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

  Widget _buildMultipleChoice(_Question q) {
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
              isSelected ? s.remove(opt.id) : s.add(opt.id);
              _answers[q.id] = s;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.info.withOpacity(0.08) : AppColors.cardBackground,
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
                      color: isSelected ? AppColors.info : AppColors.textTertiary,
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
                      color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                      fontSize: 14.sp,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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

  Widget _buildBoolean(_Question q) {
    final selected = _answers[q.id] as bool?;
    return Row(
      children: [
        Expanded(child: _buildBoolTile(q: q, value: true, label: 'Yes', icon: SolarIconsOutline.checkCircle, isSelected: selected == true)),
        SizedBox(width: 4.w),
        Expanded(child: _buildBoolTile(q: q, value: false, label: 'No', icon: SolarIconsOutline.closeCircle, isSelected: selected == false)),
      ],
    );
  }

  Widget _buildBoolTile({
    required _Question q,
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
          color: isSelected ? color.withOpacity(0.1) : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? color : AppColors.dividerColor, width: isSelected ? 1.5 : 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? color : AppColors.textTertiary, size: 28.sp),
            SizedBox(height: 1.h),
            Text(label, style: TextStyle(color: isSelected ? color : AppColors.textSecondary, fontSize: 15.sp, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextInput(_Question q) {
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
          hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 13.sp),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(4.w),
        ),
      ),
    );
  }

  Widget _buildQuestionBody(_Question q) {
    switch (q.type) {
      case _QuestionType.singleChoice:
        return _buildSingleChoice(q);
      case _QuestionType.multipleChoice:
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
                  Icon(SolarIconsOutline.checkSquare, color: AppColors.info, size: 13.sp),
                  SizedBox(width: 1.5.w),
                  Text(
                    'SELECT ALL THAT APPLY',
                    style: TextStyle(color: AppColors.info, fontSize: 10.sp, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
            _buildMultipleChoice(q),
          ],
        );
      case _QuestionType.boolean:
        return _buildBoolean(q);
      case _QuestionType.text:
        return _buildTextInput(q);
    }
  }

  Widget _buildTypeBadge(_QuestionType type) {
    switch (type) {
      case _QuestionType.singleChoice:
        return _badge(icon: SolarIconsOutline.checkCircle, label: 'SINGLE CHOICE', color: AppColors.info);
      case _QuestionType.multipleChoice:
        return _badge(icon: SolarIconsOutline.checkSquare, label: 'MULTIPLE CHOICE', color: AppColors.info);
      case _QuestionType.boolean:
        return _badge(icon: SolarIconsOutline.help, label: 'YES / NO', color: AppColors.info);
      case _QuestionType.text:
        return _badge(icon: SolarIconsOutline.textField, label: 'OPEN ANSWER', color: AppColors.info);
    }
  }

  Widget _badge({required IconData icon, required String label, required Color color}) {
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
          Text(label, style: TextStyle(color: color, fontSize: 10.sp, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
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
          onTap: _goBack,
          child: Padding(
            padding: EdgeInsets.only(left: 4.w),
            child: Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 18.sp),
          ),
        ),
        title: Text(
          'Health Survey',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _loadError != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Failed to load questions', style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp)),
                      SizedBox(height: 2.h),
                      TextButton(
                        onPressed: () {
                          setState(() { _loading = true; _loadError = null; });
                          _loadData();
                        },
                        child: Text('Retry', style: TextStyle(color: AppColors.primary)),
                      ),
                    ],
                  ),
                )
              : _questions.isEmpty
                  ? Center(
                      child: Text('No questions available', style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp)),
                    )
                  : SafeArea(
                      child: Column(
                        children: [
                          // Progress bar
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5.w),
                            child: _buildProgressBar(),
                          ),
                          SizedBox(height: 3.h),

                          // Scrollable question content
                          Expanded(
                            child: SingleChildScrollView(
                              padding: EdgeInsets.symmetric(horizontal: 5.w),
                              child: SlideTransition(
                                position: _slideAnimation,
                                child: FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
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

                          // Bottom nav
                          Padding(
                            padding: EdgeInsets.fromLTRB(5.w, 0, 5.w, 3.h),
                            child: Column(
                              children: [
                                Container(height: 0.5, color: AppColors.dividerColor),
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
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(color: AppColors.dividerColor),
                                          ),
                                          child: Icon(Icons.arrow_back_ios_new, color: AppColors.textSecondary, size: 16.sp),
                                        ),
                                      ),
                                      SizedBox(width: 3.w),
                                    ],
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: _saving ? null : _goNext,
                                        child: AnimatedOpacity(
                                          duration: const Duration(milliseconds: 200),
                                          opacity: _saving ? 0.7 : 1.0,
                                          child: Container(
                                            height: 6.h,
                                            decoration: BoxDecoration(
                                              color: AppColors.primary,
                                              borderRadius: BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppColors.primary.withOpacity(0.3),
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: _saving
                                                ? Center(
                                                    child: SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.secondary),
                                                    ),
                                                  )
                                                : Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        _isLast ? 'Save Changes' : 'Next',
                                                        style: TextStyle(color: AppColors.secondary, fontSize: 15.sp, fontWeight: FontWeight.bold),
                                                      ),
                                                      SizedBox(width: 2.w),
                                                      Icon(
                                                        _isLast ? SolarIconsOutline.checkCircle : Icons.arrow_forward,
                                                        color: AppColors.secondary,
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
