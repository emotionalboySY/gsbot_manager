import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gsbot_manager/screens/boss/create.dart';
import '../../controllers/controller_boss.dart';
import '../../models/model_boss.dart';
import 'detail.dart';

class BossScreen extends GetView<BossController> {
  const BossScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('보스 정보'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Get.to(() => BossCreateScreen());
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => controller.refresh(),
          ),
        ],
      ),
      body: _buildBossList(),
    );
  }

  Widget _buildBossList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }

      final filteredBosses = controller.filteredBosses;

      if (filteredBosses.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                '검색 결과가 없습니다.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.refresh(),
        child: ListView.builder(
          itemCount: filteredBosses.length,
          itemBuilder: (context, index) {
            final boss = filteredBosses[index];
            return _buildBossListItem(boss);
          },
        ),
      );
    });
  }

  Widget _buildBossListItem(boss) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Get.to(() => BossDetailScreen(boss: boss));
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // 보스 이미지
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: _buildDefaultBossIcon(),
              ),
              SizedBox(width: 16),

              // 보스 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      boss.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    if (boss.aliases.isNotEmpty)
                      Text(
                        '별칭: ${boss.aliases.join(', ')}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    SizedBox(height: 4),
                    Text(
                      '입장 레벨: ${boss.entryLevel}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: boss.availableDifficulties.map<Widget>((diff) {
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(diff),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            diff,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // 액션 버튼들
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      Get.toNamed('/boss/edit', arguments: boss);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteDialog(boss),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultBossIcon() {
    return Center(
      child: Icon(
        Icons.sports_esports,
        size: 48,
        color: Colors.grey[400],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case '이지':
        return Colors.green;
      case '노말':
        return Colors.blue;
      case '하드':
        return Colors.orange;
      case '카오스':
        return Colors.red;
      case '익스트림':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _showDeleteDialog(Boss boss) {
    Get.dialog(
      AlertDialog(
        title: Text('보스 삭제'),
        content: Text('${boss.name}을(를) 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              if (boss.id != null) {
                controller.deleteBoss(boss.id!);
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