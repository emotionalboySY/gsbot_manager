import 'package:get/get.dart';
import '../models/model_boss.dart';
import '../services/api_service.dart';

class BossController extends GetxController {
  final ApiService _apiService = ApiService();

  // Observable 변수들
  final RxList<Boss> bosses = <Boss>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedDifficulty = ''.obs;
  final RxInt selectedLevel = 0.obs;
  final Rx<Boss?> selectedBoss = Rx<Boss?>(null);

  // 필터링된 보스 목록
  List<Boss> get filteredBosses {
    List<Boss> filtered = bosses.toList();

    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((boss) {
        return boss.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            boss.aliases.any((alias) =>
                alias.toLowerCase().contains(searchQuery.value.toLowerCase()));
      }).toList();
    }

    if (selectedDifficulty.value.isNotEmpty) {
      filtered = filtered.where((boss) =>
          boss.availableDifficulties.contains(selectedDifficulty.value)).toList();
    }

    if (selectedLevel.value > 0) {
      filtered = filtered.where((boss) =>
      boss.entryLevel <= selectedLevel.value).toList();
    }

    return filtered;
  }

  @override
  void onInit() {
    super.onInit();
    loadBosses();
  }

  // 모든 보스 로드
  Future<void> loadBosses() async {
    try {
      isLoading.value = true;
      final result = await _apiService.getAllBosses();
      bosses.value = result;
    } catch (e) {
      Get.snackbar(
        '오류',
        '보스 정보를 불러오는데 실패했습니다: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // 특정 보스 조회
  Future<void> loadBossById(String id) async {
    try {
      isLoading.value = true;
      final boss = await _apiService.getBossById(id);
      selectedBoss.value = boss;
    } catch (e) {
      Get.snackbar(
        '오류',
        '보스 정보를 불러오는데 실패했습니다: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // 새 보스 생성
  Future<bool> createBoss(Boss boss) async {
    try {
      isLoading.value = true;
      final newBoss = await _apiService.createBoss(boss);
      bosses.add(newBoss);
      Get.snackbar(
        '성공',
        '${newBoss.name}이(가) 생성되었습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        '오류',
        '보스 생성에 실패했습니다: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // 보스 정보 수정
  Future<bool> updateBoss(String id, Boss boss) async {
    try {
      isLoading.value = true;
      final updatedBoss = await _apiService.updateBoss(id, boss);

      final index = bosses.indexWhere((b) => b.id == id);
      if (index != -1) {
        bosses[index] = updatedBoss;
      }

      if (selectedBoss.value?.id == id) {
        selectedBoss.value = updatedBoss;
      }

      Get.snackbar(
        '성공',
        '${updatedBoss.name}이(가) 수정되었습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        '오류',
        '보스 정보 수정에 실패했습니다: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // 보스 삭제
  Future<bool> deleteBoss(String id) async {
    try {
      isLoading.value = true;
      await _apiService.deleteBoss(id);

      final deletedBoss = bosses.firstWhere((boss) => boss.id == id);
      bosses.removeWhere((boss) => boss.id == id);

      if (selectedBoss.value?.id == id) {
        selectedBoss.value = null;
      }

      Get.snackbar(
        '성공',
        '${deletedBoss.name}이(가) 삭제되었습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        '오류',
        '보스 삭제에 실패했습니다: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // 특정 난이도의 보스 정보 업데이트
  Future<bool> updateBossDifficulty(String bossId, String difficulty, Difficulty difficultyData) async {
    try {
      isLoading.value = true;

      final boss = bosses.firstWhere((b) => b.id == bossId);
      final updatedDifficulties = Map<String, Difficulty>.from(boss.difficulties);
      updatedDifficulties[difficulty] = difficultyData;

      final updatedBoss = Boss(
        id: boss.id,
        name: boss.name,
        aliases: boss.aliases,
        entryLevel: boss.entryLevel,
        availableDifficulties: boss.availableDifficulties,
        difficulties: updatedDifficulties,
      );

      final result = await updateBoss(bossId, updatedBoss);
      return result;
    } catch (e) {
      Get.snackbar(
        '오류',
        '보스 난이도 정보 수정에 실패했습니다: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // 검색어 설정
  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  // 난이도 필터 설정
  void setDifficultyFilter(String difficulty) {
    selectedDifficulty.value = difficulty;
  }

  // 레벨 필터 설정
  void setLevelFilter(int level) {
    selectedLevel.value = level;
  }

  // 필터 초기화
  void clearFilters() {
    searchQuery.value = '';
    selectedDifficulty.value = '';
    selectedLevel.value = 0;
  }

  // 새로고침
  @override
  Future<void> refresh() async {
    await loadBosses();
  }

  // 보스 이름으로 검색
  Boss? findBossByName(String name) {
    try {
      return bosses.firstWhere((boss) =>
      boss.name.toLowerCase() == name.toLowerCase() ||
          boss.aliases.any((alias) => alias.toLowerCase() == name.toLowerCase())
      );
    } catch (e) {
      return null;
    }
  }

  // 입장 가능한 보스들 조회
  List<Boss> getBossesForLevel(int level) {
    return bosses.where((boss) => boss.entryLevel <= level).toList()
      ..sort((a, b) => b.entryLevel.compareTo(a.entryLevel)); // 높은 레벨순 정렬
  }

  // 특정 난이도를 가진 보스들 조회
  List<Boss> getBossesWithDifficulty(String difficulty) {
    return bosses.where((boss) =>
        boss.availableDifficulties.contains(difficulty)).toList();
  }

  // 보스 통계 정보
  Map<String, int> getBossStatistics() {
    final stats = <String, int>{};

    stats['총 보스 수'] = bosses.length;

    final difficulties = ['이지', '노말', '하드', '카오스', '익스트림'];
    for (final difficulty in difficulties) {
      stats['$difficulty 난이도'] = getBossesWithDifficulty(difficulty).length;
    }

    return stats;
  }
}