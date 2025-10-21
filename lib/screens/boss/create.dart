import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/controller_boss.dart';
import '../../models/model_boss.dart';

class BossCreateScreen extends StatefulWidget {
  const BossCreateScreen({super.key});

  @override
  BossCreateScreenState createState() => BossCreateScreenState();
}

class BossCreateScreenState extends State<BossCreateScreen> {
  final BossController controller = Get.find<BossController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // 기본 정보 컨트롤러들
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _entryLevelController = TextEditingController();
  final TextEditingController _imageNameController = TextEditingController();
  final TextEditingController _aliasController = TextEditingController();

  // 별칭과 난이도 리스트
  final RxList<String> aliases = <String>[].obs;
  final RxList<String> selectedDifficulties = <String>[].obs;

  // 사용 가능한 난이도 옵션
  final List<String> difficultyOptions = ['이지', '노말', '하드', '카오스', '익스트림'];

  @override
  void dispose() {
    _nameController.dispose();
    _entryLevelController.dispose();
    _imageNameController.dispose();
    _aliasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('새 보스 추가'),
          actions: [
            TextButton(
              onPressed: () => _saveBoss(),
              child: Text(
                '저장',
                style: TextStyle(color: Colors.black),
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
                _buildBasicInfoSection(),
                SizedBox(height: 24),
                _buildImageSection(),
                SizedBox(height: 24),
                _buildAliasSection(),
                SizedBox(height: 24),
                _buildDifficultySection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
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
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '보스 이름 *',
                border: OutlineInputBorder(),
                hintText: '예: 가디언엔젤슬라임',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '보스 이름을 입력해주세요';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _entryLevelController,
              decoration: InputDecoration(
                labelText: '입장 가능 레벨 *',
                border: OutlineInputBorder(),
                hintText: '예: 215',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '입장 가능 레벨을 입력해주세요';
                }
                final level = int.tryParse(value);
                if (level == null || level < 1 || level > 300) {
                  return '1~300 사이의 레벨을 입력해주세요';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAliasSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '별칭',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _aliasController,
                    decoration: InputDecoration(
                      labelText: '별칭 추가',
                      border: OutlineInputBorder(),
                      hintText: '예: 가엔슬',
                    ),
                    onFieldSubmitted: (value) => _addAlias(),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addAlias,
                  child: Text('추가'),
                ),
              ],
            ),
            SizedBox(height: 16),
            Obx(() => aliases.isNotEmpty
                ? Wrap(
              spacing: 8,
              runSpacing: 8,
              children: aliases.map((alias) {
                return Chip(
                  label: Text(alias),
                  onDeleted: () => _removeAlias(alias),
                );
              }).toList(),
            )
                : Text(
              '별칭이 없습니다',
              style: TextStyle(color: Colors.grey),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultySection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '사용 가능한 난이도 *',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Obx(() => Column(
              children: difficultyOptions.map((difficulty) {
                final isSelected = selectedDifficulties.contains(difficulty);
                return CheckboxListTile(
                  title: Text(difficulty),
                  value: isSelected,
                  onChanged: (bool? value) {
                    if (value == true) {
                      selectedDifficulties.add(difficulty);
                    } else {
                      selectedDifficulties.remove(difficulty);
                    }
                  },
                );
              }).toList(),
            )),
            Obx(() => selectedDifficulties.isEmpty
                ? Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                '최소 하나의 난이도를 선택해주세요',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            )
                : SizedBox.shrink()),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '보스 이미지',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _imageNameController,
              decoration: InputDecoration(
                labelText: '이미지 파일명',
                border: OutlineInputBorder(),
                hintText: 'guardian_angel_slime.png',
                helperText: 'assets/images/ 폴더의 파일명을 입력하세요',
              ),
            ),
            SizedBox(height: 16),
            Obx(() => _imageNameController.text.isNotEmpty
                ? Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/${_imageNameController.text}',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, color: Colors.red),
                          Text('이미지를 찾을 수 없습니다'),
                          Text(
                            'assets/images/${_imageNameController.text}',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            )
                : Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[100],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image, size: 48, color: Colors.grey),
                    Text('이미지 미리보기'),
                    Text(
                      'assets/images/ 폴더에 이미지를 넣고\n파일명을 입력하세요',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _addAlias() {
    final alias = _aliasController.text.trim();
    if (alias.isNotEmpty && !aliases.contains(alias)) {
      aliases.add(alias);
      _aliasController.clear();
    }
    FocusScope.of(context).unfocus();
  }

  void _removeAlias(String alias) {
    aliases.remove(alias);
  }

  void _saveBoss() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedDifficulties.isEmpty) {
      Get.snackbar('오류', '최소 하나의 난이도를 선택해주세요');
      return;
    }

    // 기본 난이도 데이터 생성
    final Map<String, Difficulty> difficulties = {};

    for (final difficulty in selectedDifficulties) {
      difficulties[difficulty] = Difficulty(
        monsterLevel: 200, // 기본값
        defenseRate: 300,  // 기본값
        phases: [
          Phase(
            phaseNumber: 1,
            hp: 1000, // 기본 1000억
          ),
        ],
        rewards: Rewards(
          crystalPrice: 10000000, // 기본 1000만 메소
          items: [],
          specialItems: SpecialItems(),
        ),
      );
    }

    final boss = Boss(
      name: _nameController.text.trim(),
      aliases: aliases.toList(),
      entryLevel: int.parse(_entryLevelController.text),
      availableDifficulties: selectedDifficulties.toList(),
      difficulties: difficulties,
      imageName: _imageNameController.text.trim().isNotEmpty
        ? _imageNameController.text.trim()
          : null,
    );

    final success = await controller.createBoss(boss);

    if (success) {
      Get.back(); // 이전 화면으로 돌아가기
    }
  }
}