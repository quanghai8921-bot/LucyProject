import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucy_app/services/lms_api.dart';
import 'package:lucy_app/theme/app_colors.dart';

class LearnerQuizScreen extends StatefulWidget {
  final String attemptId;
  final String quizId;
  final String quizTitle;
  final int durationMinutes;

  const LearnerQuizScreen({
    super.key,
    required this.attemptId,
    required this.quizId,
    required this.quizTitle,
    required this.durationMinutes,
  });

  @override
  State<LearnerQuizScreen> createState() => _LearnerQuizScreenState();
}

class _LearnerQuizScreenState extends State<LearnerQuizScreen> {
  final LmsApi _lmsApi = LmsApi();
  bool _isLoading = true;
  String? _error;
  List<RoomQuizQuestion> _questions = [];
  Map<String, String> _answers = {}; // questionId -> answerText or optionId
  
  Timer? _timer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.durationMinutes * 60;
    _startQuiz();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        _submitQuiz(autoSubmit: true);
      }
    });
  }

  String get _formattedTime {
    final minutes = (_remainingSeconds / 60).floor().toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _startQuiz() async {
    try {
      // API call to mark quiz as IN_PROGRESS (startQuiz method already defined in backend)
      // await _lmsApi.startQuiz(widget.attemptId); 
      
      final qs = await _lmsApi.getQuizQuestions(widget.quizId);
      for (var q in qs) {
        if (q.questionType == 'MULTIPLE_CHOICE') {
          q.options = await _lmsApi.getQuestionOptions(q.questionId);
        }
      }
      
      if (mounted) {
        setState(() {
          _questions = qs;
          _isLoading = false;
        });
        _startTimer();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _submitQuiz({bool autoSubmit = false}) async {
    _timer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text("Đang nộp bài..."),
          ],
        ),
      ),
    );

    try {
      final result = await _lmsApi.submitQuizAttempt(widget.attemptId, _answers);
      
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      
      final scorePercent = result['scorePercent'] ?? 0;
      final isPassed = result['isPassed'] == true;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: Text(autoSubmit ? "Hết giờ!" : "Nộp bài thành công"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(autoSubmit ? "Bài của bạn đã được tự động nộp do hết thời gian làm bài." : "Bài kiểm tra của bạn đã được nộp và chấm điểm."),
              const SizedBox(height: 16),
              Text("Điểm số: $scorePercent%", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text("Kết quả: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(
                    isPassed ? "PASS" : "FAIL",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isPassed ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context); // Go back to library
              },
              child: const Text("Về Thư Viện"),
            )
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi nộp bài: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quizTitle),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _remainingSeconds <= 60 ? Colors.red.shade50 : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _remainingSeconds <= 60 ? Colors.red.shade200 : AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.timer, size: 16, color: _remainingSeconds <= 60 ? Colors.red : AppColors.primaryDark),
                    const SizedBox(width: 6),
                    Text(
                      _formattedTime,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _remainingSeconds <= 60 ? Colors.red : AppColors.primaryDark,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text("Lỗi: $_error", style: const TextStyle(color: Colors.red)))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _questions.length,
                        itemBuilder: (context, index) {
                          final q = _questions[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Câu ${index + 1}: ${q.content}",
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 12),
                                  if (q.questionType == 'ESSAY')
                                    TextField(
                                      maxLines: 4,
                                      decoration: const InputDecoration(
                                        hintText: 'Nhập câu trả lời của bạn...',
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (val) {
                                        _answers[q.questionId] = val;
                                      },
                                    )
                                  else if (q.questionType == 'MULTIPLE_CHOICE')
                                    ...q.options.map((opt) {
                                      return RadioListTile<String>(
                                        title: Text(opt.content),
                                        value: opt.optionId,
                                        groupValue: _answers[q.questionId],
                                        activeColor: AppColors.primary,
                                        onChanged: (val) {
                                          setState(() {
                                            _answers[q.questionId] = val!;
                                          });
                                        },
                                      );
                                    }).toList(),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
                        ],
                      ),
                      child: SafeArea(
                        child: ElevatedButton(
                          onPressed: () => _submitQuiz(autoSubmit: false),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("NỘP BÀI", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
