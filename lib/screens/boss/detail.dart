import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // TODO: 보스 기본 정보 편집
            },
          ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: _buildBossHeader(),
            ),
            SliverPersistentHeader(
              delegate: _StickyTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabs: widget.boss.availableDifficulties.map((difficulty) {
                    return Tab(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(difficulty),
                      ),
                    );
                  }).toList(),
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: widget.boss.availableDifficulties.map((difficulty) {
            return _buildDifficultyTab(difficulty);
          }).toList(),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () => _saveBossData(),
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 50),
          ),
          child: Text('저장'),
        ),
      ),
    );
  }

  Widget _buildBossHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[200],
            ),
            child: Icon(Icons.sports_esports, size: 40),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.boss.name,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.boss.aliases.isNotEmpty)
                  Text(
                    '별칭: ${widget.boss.aliases.join(', ')}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                Text(
                  '입장 레벨: ${widget.boss.entryLevel}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyTab(String difficulty) {
    final difficultyData = widget.boss.getDifficulty(difficulty);

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBasicInfoSection(difficultyData),
          SizedBox(height: 24),
          _buildPhasesSection(difficultyData),
          SizedBox(height: 24),
          _buildRewardsSection(difficultyData),
          SizedBox(height: 80), // 하단 저장 버튼 공간 확보
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection(Difficulty? difficulty) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '기본 정보',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              initialValue: difficulty?.monsterLevel.toString() ?? '',
              decoration: InputDecoration(
                labelText: '몬스터 레벨',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextFormField(
              initialValue: difficulty?.defenseRate.toString() ?? '',
              decoration: InputDecoration(
                labelText: '방어율 (%)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextFormField(
              initialValue: difficulty?.arcaneForce?.toString() ?? '',
              decoration: InputDecoration(
                labelText: '아케인 포스 (선택사항)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextFormField(
              initialValue: difficulty?.authenticForce?.toString() ?? '',
              decoration: InputDecoration(
                labelText: '어센틱 포스 (선택사항)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhasesSection(Difficulty? difficulty) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '페이즈 정보',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    // TODO: 페이즈 추가
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            if (difficulty?.phases != null)
              ...difficulty!.phases.asMap().entries.map((entry) {
                final index = entry.key;
                final phase = entry.value;
                return _buildPhaseCard(index + 1, phase);
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseCard(int phaseNumber, Phase phase) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '페이즈 $phaseNumber',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: phase.hp.toString(),
                    decoration: InputDecoration(
                      labelText: '체력',
                      border: OutlineInputBorder(),
                      hintText: '예: 500000000',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: phase.shield?.toString() ?? '',
                    decoration: InputDecoration(
                      labelText: '방어막 (억)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardsSection(Difficulty? difficulty) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '보상 정보',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              initialValue: difficulty?.rewards.crystalPrice.toString() ?? '',
              decoration: InputDecoration(
                labelText: '결정석 가격 (메소)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextFormField(
              initialValue: difficulty?.rewards.solErda?.toString() ?? '',
              decoration: InputDecoration(
                labelText: '솔 에르다의 기운',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  void _saveBossData() {
    // TODO: 폼 데이터 수집 및 저장
    Get.snackbar('성공', '보스 정보가 저장되었습니다.');
  }
}

// 탭바를 고정하기 위한 델리게이트
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _StickyTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}