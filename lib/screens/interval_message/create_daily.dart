import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/controller_interval_message.dart';
import '../../models/model_interval_message.dart';

class CreateDailyMessageScreen extends StatefulWidget {
  const CreateDailyMessageScreen({super.key});

  @override
  CreateDailyMessageScreenState createState() =>
      CreateDailyMessageScreenState();
}

class CreateDailyMessageScreenState extends State<CreateDailyMessageScreen> {
  final IntervalMessageController controller =
  Get.find<IntervalMessageController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _messageController = TextEditingController();

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
          title: Text('매일 메시지 추가'),
          actions: [
            IconButton(
              icon: Icon(Icons.check),
              onPressed: _saveMessage,
              tooltip: '저장',
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
                _buildTimeSection(),
                SizedBox(height: 24),
                _buildMessageSection(),
                SizedBox(height: 24),
                _buildPreviewSection(),
                SizedBox(height: 80),
              ],
            ),
          ),
        ),
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

  Widget _buildTimeSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '시간',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildHourPicker(),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(':', style: TextStyle(fontSize: 24)),
                ),
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
      initialValue: _selectedHour,
      decoration: InputDecoration(
        labelText: '시',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      isExpanded: true,
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
      initialValue: _selectedMinute,
      decoration: InputDecoration(
        labelText: '분',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      isExpanded: true,
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
                hintText: '예: 매일 아침 알림',
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
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewSection() {
    return Card(
      color: Colors.orange[50],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.preview, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  '미리보기',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[900],
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
                    '매일 ${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')}',
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('모든 필수 항목을 입력해주세요')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    final message = DailyMessage(
      hour: _selectedHour,
      minute: _selectedMinute,
      message: _messageController.text.trim(),
      isActive: true,
    );

    final success = await controller.createDailyMessage(message);

    if (mounted) {
      Navigator.of(context).pop(); // 로딩 닫기

      if (success) {
        Navigator.of(context).pop(); // 화면 닫기
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('메시지가 생성되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('메시지 저장에 실패했습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}