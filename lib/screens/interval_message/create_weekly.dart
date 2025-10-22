import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/controller_interval_message.dart';
import '../../models/model_interval_message.dart';

class CreateWeeklyMessageScreen extends StatefulWidget {
  const CreateWeeklyMessageScreen({super.key});

  @override
  CreateWeeklyMessageScreenState createState() =>
      CreateWeeklyMessageScreenState();
}

class CreateWeeklyMessageScreenState extends State<CreateWeeklyMessageScreen> {
  final IntervalMessageController controller =
  Get.find<IntervalMessageController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _messageController = TextEditingController();

  String _selectedDayOfWeek = '월';
  int _selectedHour = 9;
  int _selectedMinute = 0;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('요일 메시지 추가'),
          actions: [
            TextButton(
              onPressed: _saveMessage,
              child: Text(
                '저장',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDayTimeSection(),
                SizedBox(height: 24),
                _buildMessageSection(),
                SizedBox(height: 24),
                _buildPreviewSection(),
                SizedBox(height: 80),
              ],
            ),
          ),
        ),
        // 하단에 저장 버튼 추가
        bottomNavigationBar: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _saveMessage,
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 50),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: Text(
              '저장',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayTimeSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '요일 및 시간',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedDayOfWeek,
              decoration: InputDecoration(
                labelText: '요일',
                border: OutlineInputBorder(),
              ),
              items: WeeklyMessage.daysOfWeek.map((day) {
                return DropdownMenuItem(
                  value: day,
                  child: Text('$day요일'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDayOfWeek = value!;
                });
              },
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildHourPicker(),
                ),
                SizedBox(width: 8),
                Text(':', style: TextStyle(fontSize: 24)),
                SizedBox(width: 8),
                Expanded(
                  child: _buildMinutePicker(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHourPicker() {
    return DropdownButtonFormField<int>(
      value: _selectedHour,
      decoration: InputDecoration(
        labelText: '시',
        border: OutlineInputBorder(),
      ),
      items: List.generate(24, (index) {
        return DropdownMenuItem(
          value: index,
          child: Text(index.toString().padLeft(2, '0')),
        );
      }),
      onChanged: (value) {
        setState(() {
          _selectedHour = value!;
        });
      },
    );
  }

  Widget _buildMinutePicker() {
    return DropdownButtonFormField<int>(
      value: _selectedMinute,
      decoration: InputDecoration(
        labelText: '분',
        border: OutlineInputBorder(),
      ),
      items: List.generate(60, (index) {
        return DropdownMenuItem(
          value: index,
          child: Text(index.toString().padLeft(2, '0')),
        );
      }),
      onChanged: (value) {
        setState(() {
          _selectedMinute = value!;
        });
      },
    );
  }

  Widget _buildMessageSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '메시지',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: '전송할 메시지 *',
                border: OutlineInputBorder(),
                hintText: '예: 매주 월요일 정기 알림',
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              maxLength: 1000,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '메시지를 입력해주세요';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {}); // 미리보기 업데이트
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewSection() {
    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.preview, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  '미리보기',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '전송 시간',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '매주 $_selectedDayOfWeek요일 ${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Divider(),
                  SizedBox(height: 8),
                  Text(
                    '메시지 내용',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    _messageController.text.isEmpty
                        ? '(메시지를 입력하세요)'
                        : _messageController.text,
                    style: TextStyle(
                      fontSize: 14,
                      color: _messageController.text.isEmpty
                          ? Colors.grey
                          : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveMessage() async {
    if (!_formKey.currentState!.validate()) {
      Get.snackbar(
        '입력 오류',
        '모든 필수 항목을 입력해주세요',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
      );
      return;
    }

    // 로딩 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final message = WeeklyMessage(
        dayOfWeek: _selectedDayOfWeek,
        hour: _selectedHour,
        minute: _selectedMinute,
        message: _messageController.text.trim(),
        isActive: true,
      );

      final success = await controller.createWeeklyMessage(message);

      // 로딩 다이얼로그 닫기
      if (mounted) Navigator.of(context).pop();

      if (success) {
        // 생성 화면 닫기
        if (mounted) {
          Navigator.of(context).pop();
          // 스낵바는 이전 화면에서 표시
          Get.snackbar(
            '성공',
            '메시지가 생성되었습니다.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green[100],
          );
        }
      } else {
        Get.snackbar(
          '저장 실패',
          '메시지 저장에 실패했습니다.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
        );
      }
    } catch (e) {
      // 로딩 다이얼로그 닫기
      if (mounted) Navigator.of(context).pop();

      Get.snackbar(
        '오류',
        '저장 중 오류가 발생했습니다: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        duration: Duration(seconds: 5),
      );
    }
  }
}