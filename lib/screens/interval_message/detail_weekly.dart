import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/controller_interval_message.dart';
import '../../models/model_interval_message.dart';
import '../../utils/date_formatter.dart';

class WeeklyMessageDetailScreen extends StatefulWidget {
  final WeeklyMessage message;

  const WeeklyMessageDetailScreen({super.key, required this.message});

  @override
  WeeklyMessageDetailScreenState createState() =>
      WeeklyMessageDetailScreenState();
}

class WeeklyMessageDetailScreenState extends State<WeeklyMessageDetailScreen> {
  final IntervalMessageController controller =
  Get.find<IntervalMessageController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _messageController;

  late String _selectedDayOfWeek;
  late int _selectedHour;
  late int _selectedMinute;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController(text: widget.message.message);
    _selectedDayOfWeek = widget.message.dayOfWeek;
    _selectedHour = widget.message.hour;
    _selectedMinute = widget.message.minute;
    _isActive = widget.message.isActive;
  }

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
          title: Text('요일 메시지 수정'),
          actions: [
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: _showDeleteDialog,
            ),
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
                _buildActiveToggle(),
                SizedBox(height: 16),
                _buildDayTimeSection(),
                SizedBox(height: 24),
                _buildMessageSection(),
                SizedBox(height: 24),
                _buildPreviewSection(),
                SizedBox(height: 24),
                _buildMetadataSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveToggle() {
    return Card(
      child: SwitchListTile(
        title: Text(
          '활성 상태',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(_isActive ? '이 메시지는 활성화되어 있습니다' : '이 메시지는 비활성화되어 있습니다'),
        value: _isActive,
        onChanged: (value) {
          setState(() {
            _isActive = value;
          });
        },
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
                  child: Text('${day}요일'),
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
                  Row(
                    children: [
                      Text(
                        '상태: ',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _isActive ? Colors.green : Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _isActive ? '활성' : '비활성',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
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

  Widget _buildMetadataSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '메타데이터',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            if (widget.message.createdAt != null)
              _buildMetadataRow(
                  '생성일',
                  DateFormatter.formatDateTime(widget.message.createdAt!)
              ),
            if (widget.message.updatedAt != null)
              _buildMetadataRow(
                  '수정일',
                  DateFormatter.formatDateTime(widget.message.updatedAt!)
              ),
            if (widget.message.id != null)
              _buildMetadataRow('ID', widget.message.id!),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _saveMessage() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (widget.message.id == null) {
      Get.snackbar('오류', '메시지 ID를 찾을 수 없습니다.');
      return;
    }

    final updatedMessage = widget.message.copyWith(
      dayOfWeek: _selectedDayOfWeek,
      hour: _selectedHour,
      minute: _selectedMinute,
      message: _messageController.text.trim(),
      isActive: _isActive,
    );

    final success = await controller.updateWeeklyMessage(
      widget.message.id!,
      updatedMessage,
    );

    if (success) {
      Get.back();
    }
  }

  void _showDeleteDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('메시지 삭제'),
        content: Text('이 메시지를 삭제하시겠습니까?\n\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Get.back(); // 다이얼로그 닫기
              if (widget.message.id != null) {
                final success = await controller.deleteWeeklyMessage(widget.message.id!);
                if (success) {
                  Get.back(); // 상세 화면도 닫기
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('삭제'),
          ),
        ],
      ),
    );
  }
}