import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/controller_interval_message.dart';
import '../../models/model_interval_message.dart';
import 'create_daily.dart';
import 'create_exact.dart';
import 'create_weekly.dart';
import 'detail_daily.dart';
import 'detail_exact.dart';
import 'detail_weekly.dart';

class IntervalMessageScreen extends GetView<IntervalMessageController> {
  const IntervalMessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '정기 메시지 관리',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(letterSpacing: -1),
          ),
          bottom: TabBar(
            onTap: (index) => controller.setTabIndex(index),
            tabs: [
              Tab(text: '정확한 시간'),
              Tab(text: '요일 시간'),
              Tab(text: '매일'), // 추가
            ],
            labelStyle: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(letterSpacing: -1, fontSize: 14),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () => controller.refresh(),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _buildExactTimeTab(context),
            _buildWeeklyTab(context),
            _buildDailyTab(context), // 추가
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Obx 없이 직접 controller.selectedTabIndex.value 체크
            final tabIndex = controller.selectedTabIndex.value;
            if (tabIndex == 0) {
              Get.to(() => CreateExactTimeMessageScreen());
            } else if (tabIndex == 1) {
              Get.to(() => CreateWeeklyMessageScreen());
            } else {
              Get.to(() => CreateDailyMessageScreen()); // 추가
            }
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildExactTimeTab(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.exactTimeMessages.isEmpty) {
        return Center(child: CircularProgressIndicator());
      }

      final messages = controller.filteredExactTimeMessages;

      if (messages.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.schedule, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                '등록된 메시지가 없습니다.',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  color: Colors.grey,
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.loadExactTimeMessages(),
        child: ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            return _buildExactTimeMessageCard(message, context);
          },
        ),
      );
    });
  }

  Widget _buildWeeklyTab(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.weeklyMessages.isEmpty) {
        return Center(child: CircularProgressIndicator());
      }

      final messages = controller.filteredWeeklyMessages;

      if (messages.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                '등록된 메시지가 없습니다.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.loadWeeklyMessages(),
        child: ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            return _buildWeeklyMessageCard(message);
          },
        ),
      );
    });
  }

  Widget _buildDailyTab(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.dailyMessages.isEmpty) {
        return Center(child: CircularProgressIndicator());
      }

      final messages = controller.filteredDailyMessages;

      if (messages.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.today, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                '등록된 메시지가 없습니다.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.loadDailyMessages(),
        child: ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            return _buildDailyMessageCard(message);
          },
        ),
      );
    });
  }

  Widget _buildExactTimeMessageCard(
    ExactTimeMessage message,
    BuildContext context,
  ) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Get.to(() => ExactTimeMessageDetailScreen(message: message));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.access_time,
                    color: message.isActive ? Colors.blue : Colors.grey,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      message.formattedDateTime,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 16,
                        color: message.isActive ? Colors.black : Colors.grey,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                  Transform.scale(
                    scale: 0.7,
                    child: Switch(
                      value: message.isActive,
                      onChanged: (value) {
                        if (message.id != null) {
                          controller.toggleExactTimeMessageActive(message.id!);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: SizedBox(
                height: 1,
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: Colors.grey),
                ),
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                message.message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  color: message.isActive ? Colors.black87 : Colors.grey,
                  letterSpacing: -1,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Get.to(
                      () => ExactTimeMessageDetailScreen(message: message),
                    );
                  },
                  icon: Icon(Icons.edit, size: 18, color: Theme.of(context).primaryColor,),
                  label: Text(
                    '수정',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(
                        fontSize: 14,
                        color: Theme.of(context).primaryColor,
                        letterSpacing: -1,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showDeleteDialog(
                    message.id!,
                    message.message,
                    isExact: true,
                  ),
                  icon: Icon(Icons.delete, size: 18, color: Colors.red),
                  label: Text(
                    '삭제',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 14,
                        color: Colors.red,
                        letterSpacing: -1,
                    )
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyMessageCard(WeeklyMessage message) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Get.to(() => WeeklyMessageDetailScreen(message: message));
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: message.isActive ? Colors.green : Colors.grey,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      message.formattedTime,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: message.isActive ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                  Switch(
                    value: message.isActive,
                    onChanged: (value) {
                      if (message.id != null) {
                        controller.toggleWeeklyMessageActive(message.id!);
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                message.message,
                style: TextStyle(
                  fontSize: 14,
                  color: message.isActive ? Colors.black87 : Colors.grey,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Get.to(() => WeeklyMessageDetailScreen(message: message));
                    },
                    icon: Icon(Icons.edit, size: 18),
                    label: Text('수정'),
                  ),
                  SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _showDeleteDialog(
                      message.id!,
                      message.message,
                      isExact: false,
                    ),
                    icon: Icon(Icons.delete, size: 18, color: Colors.red),
                    label: Text('삭제', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyMessageCard(DailyMessage message) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Get.to(() => DailyMessageDetailScreen(message: message));
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.today,
                    color: message.isActive ? Colors.orange : Colors.grey,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      message.formattedTime,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: message.isActive ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                  Switch(
                    value: message.isActive,
                    onChanged: (value) {
                      if (message.id != null) {
                        controller.toggleDailyMessageActive(message.id!);
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                message.message,
                style: TextStyle(
                  fontSize: 14,
                  color: message.isActive ? Colors.black87 : Colors.grey,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Get.to(() => DailyMessageDetailScreen(message: message));
                    },
                    icon: Icon(Icons.edit, size: 18),
                    label: Text('수정'),
                  ),
                  SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _showDeleteDialog(
                      message.id!,
                      message.message,
                      isDaily: true,
                    ),
                    icon: Icon(Icons.delete, size: 18, color: Colors.red),
                    label: Text('삭제', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(
    String id,
    String message, {
    bool isExact = false,
    bool isDaily = false,
  }) {
    Get.dialog(
      AlertDialog(
        title: Text('메시지 삭제'),
        content: Text('이 메시지를 삭제하시겠습니까?\n\n"$message"\n\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('취소')),
          TextButton(
            onPressed: () {
              Get.back();
              if (isExact) {
                controller.deleteExactTimeMessage(id);
              } else if (isDaily) {
                controller.deleteDailyMessage(id); // 추가
              } else {
                controller.deleteWeeklyMessage(id);
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
