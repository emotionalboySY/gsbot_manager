import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/controller_boss.dart';
import '../../models/model_boss.dart';

class BossDetailScreen extends StatefulWidget {
  final Boss boss;

  const BossDetailScreen({super.key, required this.boss});

  @override
  BossDetailScreenState createState() => BossDetailScreenState();
}

class BossDetailScreenState extends State<BossDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final BossController controller = Get.find<BossController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.boss.availableDifficulties.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.boss.name),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteDialog();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'delete',
                child: Text('삭제', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildBossHeader(),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: widget.boss.availableDifficulties.map((d) {
              return Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(d),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(d),
                  ],
                ),
              );
            }).toList(),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: widget.boss.availableDifficulties.map((difficulty) {
                return _buildDifficultyTab(difficulty);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // 보스 헤더: 이름, 별칭, 입장 레벨
  Widget _buildBossHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[200],
            ),
            child: Icon(Icons.sports_esports, size: 28, color: Colors.grey[400]),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.boss.name,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (widget.boss.aliases.isNotEmpty) ...[
                  SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: widget.boss.aliases.map((alias) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(alias, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                      );
                    }).toList(),
                  ),
                ],
                SizedBox(height: 4),
                Text(
                  '입장 가능 레벨: ${widget.boss.entryLevel}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 난이도별 탭 내용
  Widget _buildDifficultyTab(String difficulty) {
    final diff = widget.boss.getDifficulty(difficulty);

    if (diff == null) {
      return Center(
        child: Text('데이터 없음', style: TextStyle(color: Colors.grey)),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(diff),
          SizedBox(height: 12),
          _buildPhasesCard(diff),
          SizedBox(height: 12),
          _buildRewardsCard(diff),
          SizedBox(height: 32),
        ],
      ),
    );
  }

  // 기본 정보 카드
  Widget _buildInfoCard(Difficulty diff) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('기본 정보'),
            SizedBox(height: 12),
            _buildDataRow('몬스터 레벨', '${diff.monsterLevel}'),
            _buildDataRow('방어율', '${diff.defenseRate}%'),
            if (diff.arcaneForce != null)
              _buildDataRow('아케인 포스', '${diff.arcaneForce}'),
            if (diff.authenticForce != null)
              _buildDataRow('어센틱 포스', '${diff.authenticForce}'),
          ],
        ),
      ),
    );
  }

  // 페이즈 정보 카드
  Widget _buildPhasesCard(Difficulty diff) {
    final isSingle = diff.phases.length == 1;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
              isSingle ? '단일 페이즈' : '페이즈 정보 (${diff.phases.length}페이즈)',
            ),
            SizedBox(height: 12),
            ...diff.phases.asMap().entries.map((entry) {
              final phase = entry.value;
              final isLast = entry.key == diff.phases.length - 1;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isSingle)
                    Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Text(
                        '페이즈 ${phase.phaseNumber}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  _buildDataRow('체력', _formatHP(phase.hp)),
                  if (phase.shield != null && phase.shield! > 0)
                    _buildDataRow('방어막', _formatHP(phase.shield!)),
                  if (phase.monsterLevel != null)
                    _buildDataRow('몬스터 레벨', '${phase.monsterLevel}'),
                  if (phase.authenticForce != null)
                    _buildDataRow('어센틱 포스', '${phase.authenticForce}'),
                  if (!isLast) Divider(height: 20),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  // 보상 정보 카드
  Widget _buildRewardsCard(Difficulty diff) {
    final rewards = diff.rewards;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('주요 보상'),
            SizedBox(height: 12),
            _buildDataRow('결정석 가격', _formatMeso(rewards.crystalPrice)),
            if (rewards.solErda != null && rewards.solErda! > 0)
              _buildDataRow('솔 에르다의 기운', '${rewards.solErda}'),

            // 일반 아이템
            if (rewards.items.isNotEmpty) ...[
              Divider(height: 24),
              Text('드롭 아이템', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              SizedBox(height: 8),
              ...rewards.items.map((item) => _buildItemRow(item)),
            ],

            // 특수 아이템
            ..._buildSpecialItemsList(rewards.specialItems),
          ],
        ),
      ),
    );
  }

  // 특수 아이템 목록
  List<Widget> _buildSpecialItemsList(SpecialItems si) {
    final categories = <MapEntry<String, List<String>>>[];

    if (si.yeomyeong.isNotEmpty) categories.add(MapEntry('여명', si.yeomyeong));
    if (si.absolab.isNotEmpty) categories.add(MapEntry('앱솔', si.absolab));
    if (si.arcane.isNotEmpty) categories.add(MapEntry('아케인', si.arcane));
    if (si.chilheuk.isNotEmpty) categories.add(MapEntry('칠흑', si.chilheuk));
    if (si.eternal.isNotEmpty) categories.add(MapEntry('에테르넬', si.eternal));
    if (si.gwanghwi.isNotEmpty) categories.add(MapEntry('광휘', si.gwanghwi));
    if (si.exceptional.isNotEmpty) categories.add(MapEntry('익셉셔널', si.exceptional));

    if (categories.isEmpty) return [];

    return [
      Divider(height: 24),
      Text('장비 아이템', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      SizedBox(height: 8),
      ...categories.expand((cat) {
        return cat.value.map((item) => _buildTaggedItemRow(cat.key, item));
      }),
    ];
  }

  // 섹션 제목
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  // 데이터 행 (라벨: 값)
  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // 일반 아이템 행
  Widget _buildItemRow(String item) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 7),
            child: Icon(Icons.circle, size: 5, color: Colors.grey[400]),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(item, style: TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  // 태그가 달린 특수 아이템 행
  Widget _buildTaggedItemRow(String tag, String item) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 2),
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _getTagColor(tag),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              tag,
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(item, style: TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  // 태그 색상
  Color _getTagColor(String tag) {
    switch (tag) {
      case '여명':
        return Colors.amber[700]!;
      case '앱솔':
        return Colors.indigo;
      case '아케인':
        return Colors.cyan[700]!;
      case '칠흑':
        return Colors.grey[800]!;
      case '에테르넬':
        return Colors.teal;
      case '광휘':
        return Colors.orange[700]!;
      case '익셉셔널':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  // 난이도 색상
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

  // 체력 포맷팅 (경, 조, 억 단위)
  String _formatHP(int hp) {
    if (hp <= 0) return '0';

    List<String> parts = [];
    int remaining = hp;

    // 경 (10^16)
    if (remaining >= 10000000000000000) {
      parts.add('${_formatNum(remaining ~/ 10000000000000000)}경');
      remaining %= 10000000000000000;
    }

    // 조 (10^12)
    if (remaining >= 1000000000000) {
      parts.add('${_formatNum(remaining ~/ 1000000000000)}조');
      remaining %= 1000000000000;
    }

    // 억 (10^8)
    if (remaining >= 100000000) {
      parts.add('${_formatNum(remaining ~/ 100000000)}억');
      remaining %= 100000000;
    }

    if (parts.isEmpty) {
      return _formatNum(hp);
    }

    return parts.join(' ');
  }

  // 메소 가격 포맷팅
  String _formatMeso(int price) {
    return '${_formatNum(price)}메소';
  }

  // 숫자에 콤마 추가
  String _formatNum(int number) {
    return NumberFormat('#,###').format(number);
  }

  // 삭제 다이얼로그
  void _showDeleteDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('보스 삭제'),
        content: Text('${widget.boss.name}을(를) 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              if (widget.boss.id != null) {
                final success = await controller.deleteBoss(widget.boss.id!);
                if (success) {
                  Get.back();
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
