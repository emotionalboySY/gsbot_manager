import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';
import '../../controllers/controller_boss.dart';
import '../../models/model_boss.dart';
import '../../utils/date_formatter.dart';

// 페이즈 폼 데이터
class PhaseFormData {
  final TextEditingController hpController;
  final TextEditingController shieldController;
  final TextEditingController monsterLevelController;
  final TextEditingController authenticForceController;

  PhaseFormData({
    String hp = '',
    String shield = '',
    String monsterLevel = '',
    String authenticForce = '',
  })  : hpController = TextEditingController(text: hp),
        shieldController = TextEditingController(text: shield),
        monsterLevelController = TextEditingController(text: monsterLevel),
        authenticForceController = TextEditingController(text: authenticForce);

  void dispose() {
    hpController.dispose();
    shieldController.dispose();
    monsterLevelController.dispose();
    authenticForceController.dispose();
  }
}

// 난이도별 폼 데이터
class DifficultyFormData {
  final TextEditingController monsterLevelController;
  final TextEditingController defenseRateController;
  final TextEditingController arcaneForceController;
  final TextEditingController authenticForceController;
  final TextEditingController crystalPriceController;
  final TextEditingController solErdaController;
  final TextEditingController itemController; // 아이템 입력용
  final RxList<String> items;
  final RxList<PhaseFormData> phases;

  // 특수 아이템
  final Map<String, RxList<String>> specialItemsMap;
  final Map<String, TextEditingController> specialItemControllers;

  static const List<String> specialCategories = [
    'yeomyeong', 'chilheuk', 'absolab', 'arcane', 'eternal', 'gwanghwi', 'exceptional',
  ];

  DifficultyFormData({
    String monsterLevel = '200',
    String defenseRate = '300',
    String arcaneForce = '',
    String authenticForce = '',
    String crystalPrice = '0',
    String solErda = '',
    List<String>? itemsList,
    List<PhaseFormData>? phasesList,
    Map<String, List<String>>? specialItems,
  })  : monsterLevelController = TextEditingController(text: monsterLevel),
        defenseRateController = TextEditingController(text: defenseRate),
        arcaneForceController = TextEditingController(text: arcaneForce),
        authenticForceController = TextEditingController(text: authenticForce),
        crystalPriceController = TextEditingController(text: crystalPrice),
        solErdaController = TextEditingController(text: solErda),
        itemController = TextEditingController(),
        items = RxList<String>(itemsList ?? []),
        phases = RxList<PhaseFormData>(
          phasesList ?? [PhaseFormData(hp: '0')],
        ),
        specialItemsMap = {
          for (final key in specialCategories)
            key: RxList<String>(specialItems?[key] ?? []),
        },
        specialItemControllers = {
          for (final key in specialCategories)
            key: TextEditingController(),
        };

  void dispose() {
    monsterLevelController.dispose();
    defenseRateController.dispose();
    arcaneForceController.dispose();
    authenticForceController.dispose();
    crystalPriceController.dispose();
    solErdaController.dispose();
    itemController.dispose();
    for (final p in phases) {
      p.dispose();
    }
    for (final c in specialItemControllers.values) {
      c.dispose();
    }
  }
}

class BossDetailScreen extends StatefulWidget {
  final Boss boss;

  const BossDetailScreen({super.key, required this.boss});

  @override
  BossDetailScreenState createState() => BossDetailScreenState();
}

class BossDetailScreenState extends State<BossDetailScreen>
    with TickerProviderStateMixin {
  final BossController controller = Get.find<BossController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // 메인 탭 (기본 정보 / 상세 정보)
  late TabController _mainTabController;
  // 난이도 서브탭 (동적)
  TabController? _difficultyTabController;

  // 기본 정보
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _entryLevelController = TextEditingController();
  final TextEditingController _imageNameController = TextEditingController();
  final TextEditingController _aliasController = TextEditingController();
  final RxList<String> aliases = <String>[].obs;
  final RxList<String> selectedDifficulties = <String>[].obs;

  final List<String> difficultyOptions = ['이지', '노말', '하드', '카오스', '익스트림'];

  // 난이도별 폼 데이터
  final Map<String, DifficultyFormData> _difficultyForms = {};

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 2, vsync: this);
    _initBasicInfo();
    _initDifficultyForms();
    _rebuildDifficultyTabController();
  }

  void _initBasicInfo() {
    _nameController.text = widget.boss.name;
    _entryLevelController.text = widget.boss.entryLevel.toString();
    _imageNameController.text = widget.boss.imageName ?? '';
    aliases.value = List<String>.from(widget.boss.aliases);
    selectedDifficulties.value = List<String>.from(widget.boss.availableDifficulties);
  }

  void _initDifficultyForms() {
    for (final diffName in widget.boss.availableDifficulties) {
      final diff = widget.boss.getDifficulty(diffName);
      if (diff != null) {
        _difficultyForms[diffName] = _createFormFromDifficulty(diff);
      } else {
        _difficultyForms[diffName] = DifficultyFormData();
      }
    }
  }

  DifficultyFormData _createFormFromDifficulty(Difficulty diff) {
    return DifficultyFormData(
      monsterLevel: diff.monsterLevel.toString(),
      defenseRate: diff.defenseRate.toString(),
      arcaneForce: diff.arcaneForce?.toString() ?? '',
      authenticForce: diff.authenticForce?.toString() ?? '',
      crystalPrice: diff.rewards.crystalPrice.toString(),
      solErda: diff.rewards.solErda?.toString() ?? '',
      itemsList: List<String>.from(diff.rewards.items),
      phasesList: diff.phases.map((p) => PhaseFormData(
        hp: p.hp.toString(),
        shield: p.shield?.toString() ?? '',
        monsterLevel: p.monsterLevel?.toString() ?? '',
        authenticForce: p.authenticForce?.toString() ?? '',
      )).toList(),
      specialItems: {
        'yeomyeong': List<String>.from(diff.rewards.specialItems.yeomyeong),
        'chilheuk': List<String>.from(diff.rewards.specialItems.chilheuk),
        'absolab': List<String>.from(diff.rewards.specialItems.absolab),
        'arcane': List<String>.from(diff.rewards.specialItems.arcane),
        'eternal': List<String>.from(diff.rewards.specialItems.eternal),
        'gwanghwi': List<String>.from(diff.rewards.specialItems.gwanghwi),
        'exceptional': List<String>.from(diff.rewards.specialItems.exceptional),
      },
    );
  }

  void _rebuildDifficultyTabController() {
    _difficultyTabController?.dispose();
    if (selectedDifficulties.isNotEmpty) {
      _difficultyTabController = TabController(
        length: selectedDifficulties.length,
        vsync: this,
      );
    } else {
      _difficultyTabController = null;
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    _difficultyTabController?.dispose();
    _nameController.dispose();
    _entryLevelController.dispose();
    _imageNameController.dispose();
    _aliasController.dispose();
    for (final form in _difficultyForms.values) {
      form.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.boss.name),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') _showDeleteDialog();
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
            TabBar(
              controller: _mainTabController,
              tabs: [
                Tab(text: '기본 정보'),
                Tab(text: '상세 정보'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _mainTabController,
                children: [
                  _buildBasicInfoTab(),
                  _buildDetailInfoTab(),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2)),
            ],
          ),
          child: ElevatedButton(
            onPressed: _saveBoss,
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 50),
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
            child: Text('저장', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  // ===== 기본 정보 탭 =====
  Widget _buildBasicInfoTab() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildNameLevelCard(),
            SizedBox(height: 16),
            _buildAliasCard(),
            SizedBox(height: 16),
            _buildDifficultyCard(),
            SizedBox(height: 16),
            _buildMetadataCard(),
            SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildNameLevelCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('기본 정보', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: '보스 이름 *', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().isEmpty) ? '보스 이름을 입력해주세요' : null,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _entryLevelController,
              decoration: InputDecoration(labelText: '입장 가능 레벨 *', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return '입장 레벨을 입력해주세요';
                final level = int.tryParse(v);
                if (level == null || level < 1 || level > 300) return '1~300 사이의 레벨을 입력해주세요';
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAliasCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('별칭', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _aliasController,
                    decoration: InputDecoration(labelText: '별칭 추가', border: OutlineInputBorder(), hintText: '예: 가엔슬'),
                    onFieldSubmitted: (_) => _addAlias(),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(onPressed: _addAlias, child: Text('추가')),
              ],
            ),
            SizedBox(height: 12),
            Obx(() => aliases.isNotEmpty
                ? Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: aliases.map((a) => Chip(label: Text(a), onDeleted: () => aliases.remove(a))).toList(),
                  )
                : Text('별칭이 없습니다', style: TextStyle(color: Colors.grey))),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('사용 가능한 난이도 *', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Obx(() => Column(
              children: difficultyOptions.map((diff) {
                final isSelected = selectedDifficulties.contains(diff);
                return CheckboxListTile(
                  title: Text(diff),
                  value: isSelected,
                  onChanged: (value) {
                    if (value == true) {
                      selectedDifficulties.add(diff);
                      _difficultyForms.putIfAbsent(diff, () => DifficultyFormData());
                    } else {
                      selectedDifficulties.remove(diff);
                    }
                    _rebuildDifficultyTabController();
                  },
                );
              }).toList(),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('메타데이터', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            if (widget.boss.createdAt != null)
              _buildMetaRow('생성일', DateFormatter.formatDateTime(widget.boss.createdAt!)),
            if (widget.boss.updatedAt != null)
              _buildMetaRow('수정일', DateFormatter.formatDateTime(widget.boss.updatedAt!)),
            if (widget.boss.id != null)
              _buildMetaRow('ID', widget.boss.id!),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14))),
          Expanded(child: Text(value, style: TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  // ===== 상세 정보 탭 =====
  Widget _buildDetailInfoTab() {
    if (selectedDifficulties.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text('기본 정보 탭에서 난이도를 먼저 선택해주세요', style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }

    if (_difficultyTabController == null ||
        _difficultyTabController!.length != selectedDifficulties.length) {
      return SizedBox.shrink();
    }

    return Column(
      children: [
        TabBar(
          controller: _difficultyTabController,
          isScrollable: true,
          tabs: selectedDifficulties.map((d) {
            return Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(color: _getDifficultyColor(d), shape: BoxShape.circle),
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
            controller: _difficultyTabController,
            children: selectedDifficulties.map((diff) {
              return _buildDifficultyEditTab(diff);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultyEditTab(String diffName) {
    final form = _difficultyForms[diffName];
    if (form == null) return Center(child: Text('데이터 없음'));

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildDiffInfoCard(form),
          SizedBox(height: 12),
          _buildPhasesCard(form),
          SizedBox(height: 12),
          _buildRewardsCard(form),
          SizedBox(height: 12),
          _buildSpecialItemsCard(form),
          SizedBox(height: 80),
        ],
      ),
    );
  }

  // 난이도 기본 정보
  Widget _buildDiffInfoCard(DifficultyFormData form) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('기본 정보', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: form.monsterLevelController,
                    decoration: InputDecoration(labelText: '몬스터 레벨', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: form.defenseRateController,
                    decoration: InputDecoration(labelText: '방어율 (%)', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: form.arcaneForceController,
                    decoration: InputDecoration(labelText: '아케인 포스', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: form.authenticForceController,
                    decoration: InputDecoration(labelText: '어센틱 포스', border: OutlineInputBorder()),
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

  // 페이즈 편집
  Widget _buildPhasesCard(DifficultyFormData form) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('페이즈 정보 (${form.phases.length})', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.add_circle_outline, color: Colors.blue),
                  onPressed: () {
                    form.phases.add(PhaseFormData(hp: '0'));
                  },
                ),
              ],
            ),
            SizedBox(height: 8),
            ...form.phases.asMap().entries.map((entry) {
              final idx = entry.key;
              final phase = entry.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('페이즈 ${idx + 1}', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blue[700])),
                      Spacer(),
                      if (form.phases.length > 1)
                        IconButton(
                          icon: Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                          onPressed: () {
                            form.phases[idx].dispose();
                            form.phases.removeAt(idx);
                          },
                        ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: phase.hpController,
                          decoration: InputDecoration(labelText: '체력 (HP)', border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: phase.shieldController,
                          decoration: InputDecoration(labelText: '방어막', border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: phase.monsterLevelController,
                          decoration: InputDecoration(labelText: '몬스터 레벨', border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: phase.authenticForceController,
                          decoration: InputDecoration(labelText: '어센틱 포스', border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  if (idx < form.phases.length - 1) Divider(height: 24),
                ],
              );
            }),
          ],
        )),
      ),
    );
  }

  // 보상 편집
  Widget _buildRewardsCard(DifficultyFormData form) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('보상', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: form.crystalPriceController,
                    decoration: InputDecoration(labelText: '결정석 가격 (메소)', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: form.solErdaController,
                    decoration: InputDecoration(labelText: '솔 에르다의 기운', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            Divider(height: 24),
            Text('드롭 아이템', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: form.itemController,
                    decoration: InputDecoration(labelText: '아이템 추가', border: OutlineInputBorder()),
                    onFieldSubmitted: (_) => _addItem(form),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(onPressed: () => _addItem(form), child: Text('추가')),
              ],
            ),
            SizedBox(height: 8),
            Obx(() => form.items.isNotEmpty
                ? Wrap(
                    spacing: 6, runSpacing: 6,
                    children: form.items.map((item) =>
                      Chip(label: Text(item, style: TextStyle(fontSize: 12)), onDeleted: () => form.items.remove(item)),
                    ).toList(),
                  )
                : Text('아이템이 없습니다', style: TextStyle(color: Colors.grey, fontSize: 13))),
          ],
        ),
      ),
    );
  }

  // 특수 아이템 편집
  Widget _buildSpecialItemsCard(DifficultyFormData form) {
    const categoryLabels = {
      'yeomyeong': '여명',
      'chilheuk': '칠흑',
      'absolab': '앱솔랩스',
      'arcane': '아케인셰이드',
      'eternal': '에테르넬',
      'gwanghwi': '광휘',
      'exceptional': '익셉셔널',
    };

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('장비 아이템', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            ...DifficultyFormData.specialCategories.map((key) {
              final label = categoryLabels[key]!;
              final items = form.specialItemsMap[key]!;
              final ctrl = form.specialItemControllers[key]!;

              return Obx(() => ExpansionTile(
                title: Text('$label (${items.length})', style: TextStyle(fontSize: 14)),
                leading: Container(
                  width: 12, height: 12,
                  decoration: BoxDecoration(color: _getTagColor(label), borderRadius: BorderRadius.circular(2)),
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: ctrl,
                            decoration: InputDecoration(
                              labelText: '$label 아이템 추가',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            onFieldSubmitted: (_) => _addSpecialItem(form, key),
                          ),
                        ),
                        SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.add_circle, color: Colors.blue),
                          onPressed: () => _addSpecialItem(form, key),
                        ),
                      ],
                    ),
                  ),
                  if (items.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Wrap(
                        spacing: 6, runSpacing: 6,
                        children: items.map((item) =>
                          Chip(
                            label: Text(item, style: TextStyle(fontSize: 12)),
                            onDeleted: () => items.remove(item),
                          ),
                        ).toList(),
                      ),
                    ),
                ],
              ));
            }),
          ],
        ),
      ),
    );
  }

  // ===== 헬퍼 메서드 =====

  void _addAlias() {
    final alias = _aliasController.text.trim();
    if (alias.isNotEmpty && !aliases.contains(alias)) {
      aliases.add(alias);
      _aliasController.clear();
    }
    FocusScope.of(context).unfocus();
  }

  void _addItem(DifficultyFormData form) {
    final item = form.itemController.text.trim();
    if (item.isNotEmpty && !form.items.contains(item)) {
      form.items.add(item);
      form.itemController.clear();
    }
  }

  void _addSpecialItem(DifficultyFormData form, String category) {
    final ctrl = form.specialItemControllers[category]!;
    final item = ctrl.text.trim();
    if (item.isNotEmpty && !form.specialItemsMap[category]!.contains(item)) {
      form.specialItemsMap[category]!.add(item);
      ctrl.clear();
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case '이지': return Colors.green;
      case '노말': return Colors.blue;
      case '하드': return Colors.orange;
      case '카오스': return Colors.red;
      case '익스트림': return Colors.purple;
      default: return Colors.grey;
    }
  }

  Color _getTagColor(String tag) {
    switch (tag) {
      case '여명': return Colors.amber[700]!;
      case '앱솔랩스': return Colors.indigo;
      case '아케인셰이드': return Colors.cyan[700]!;
      case '칠흑': return Colors.grey[800]!;
      case '에테르넬': return Colors.teal;
      case '광휘': return Colors.orange[700]!;
      case '익셉셔널': return Colors.purple;
      default: return Colors.grey;
    }
  }

  // ===== 저장 =====
  void _saveBoss() async {
    if (!_formKey.currentState!.validate()) {
      showToast('필수 항목을 확인해주세요');
      return;
    }
    if (selectedDifficulties.isEmpty) {
      showToast('최소 하나의 난이도를 선택해주세요');
      return;
    }
    if (widget.boss.id == null) {
      showToast('보스 ID를 찾을 수 없습니다.');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    final Map<String, Difficulty> difficulties = {};
    for (final diffName in selectedDifficulties) {
      final form = _difficultyForms[diffName];
      if (form != null) {
        difficulties[diffName] = _buildDifficultyFromForm(form);
      }
    }

    final updatedBoss = Boss(
      name: _nameController.text.trim(),
      aliases: aliases.toList(),
      entryLevel: int.parse(_entryLevelController.text),
      availableDifficulties: selectedDifficulties.toList(),
      difficulties: difficulties,
      imageName: _imageNameController.text.trim().isNotEmpty
          ? _imageNameController.text.trim()
          : null,
    );

    final success = await controller.updateBoss(widget.boss.id!, updatedBoss);

    if (mounted) {
      Navigator.of(context).pop(); // 로딩 닫기
      if (success) {
        Navigator.of(context).pop(); // 화면 닫기
        showToast('보스 정보가 수정되었습니다.');
      } else {
        showToast('보스 정보 수정에 실패했습니다.');
      }
    }
  }

  Difficulty _buildDifficultyFromForm(DifficultyFormData form) {
    return Difficulty(
      monsterLevel: int.tryParse(form.monsterLevelController.text) ?? 200,
      defenseRate: int.tryParse(form.defenseRateController.text) ?? 300,
      arcaneForce: _parseOptionalInt(form.arcaneForceController.text),
      authenticForce: _parseOptionalInt(form.authenticForceController.text),
      phases: form.phases.asMap().entries.map((entry) => Phase(
        phaseNumber: entry.key + 1,
        hp: int.tryParse(entry.value.hpController.text) ?? 0,
        shield: _parseOptionalInt(entry.value.shieldController.text),
        monsterLevel: _parseOptionalInt(entry.value.monsterLevelController.text),
        authenticForce: _parseOptionalInt(entry.value.authenticForceController.text),
      )).toList(),
      rewards: Rewards(
        crystalPrice: int.tryParse(form.crystalPriceController.text) ?? 0,
        solErda: _parseOptionalInt(form.solErdaController.text),
        items: form.items.toList(),
        specialItems: SpecialItems(
          yeomyeong: form.specialItemsMap['yeomyeong']!.toList(),
          chilheuk: form.specialItemsMap['chilheuk']!.toList(),
          absolab: form.specialItemsMap['absolab']!.toList(),
          arcane: form.specialItemsMap['arcane']!.toList(),
          eternal: form.specialItemsMap['eternal']!.toList(),
          gwanghwi: form.specialItemsMap['gwanghwi']!.toList(),
          exceptional: form.specialItemsMap['exceptional']!.toList(),
        ),
      ),
    );
  }

  int? _parseOptionalInt(String text) {
    if (text.trim().isEmpty) return null;
    return int.tryParse(text);
  }

  // ===== 삭제 =====
  void _showDeleteDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('보스 삭제'),
        content: Text('${widget.boss.name}을(를) 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('취소')),
          TextButton(
            onPressed: () async {
              Get.back();
              if (widget.boss.id != null) {
                final success = await controller.deleteBoss(widget.boss.id!);
                if (success) Get.back();
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
