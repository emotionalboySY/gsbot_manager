import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/model_interval_message.dart';
import '../services/api_service.dart';

class IntervalMessageController extends GetxController {
  final ApiService _apiService = ApiService();

  // Observable 변수들
  final RxList<ExactTimeMessage> exactTimeMessages = <ExactTimeMessage>[].obs;
  final RxList<WeeklyMessage> weeklyMessages = <WeeklyMessage>[].obs;
  final RxList<DailyMessage> dailyMessages = <DailyMessage>[].obs; // 추가
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxInt selectedTabIndex = 0.obs; // 0: 정확한 시간, 1: 요일 시간

  // 필터링된 매일 메시지 목록
  List<DailyMessage> get filteredDailyMessages {
    if (searchQuery.value.isEmpty) {
      return dailyMessages.toList();
    }
    return dailyMessages.where((message) {
      return message.message.toLowerCase().contains(searchQuery.value.toLowerCase());
    }).toList();
  }

  // 필터링된 정확한 시간 메시지 목록
  List<ExactTimeMessage> get filteredExactTimeMessages {
    if (searchQuery.value.isEmpty) {
      return exactTimeMessages.toList();
    }
    return exactTimeMessages.where((message) {
      return message.message.toLowerCase().contains(searchQuery.value.toLowerCase());
    }).toList();
  }

  // 필터링된 요일 메시지 목록
  List<WeeklyMessage> get filteredWeeklyMessages {
    if (searchQuery.value.isEmpty) {
      return weeklyMessages.toList();
    }
    return weeklyMessages.where((message) {
      return message.message.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          message.dayOfWeek.contains(searchQuery.value);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadAllMessages();
  }

  // 모든 메시지 로드
  Future<void> loadAllMessages() async {
    await Future.wait([
      loadExactTimeMessages(),
      loadWeeklyMessages(),
      loadDailyMessages(),
    ]);
  }

  // 정확한 시간 메시지 로드
  Future<void> loadExactTimeMessages() async {
    try {
      isLoading.value = true;
      final result = await _apiService.getAllExactTimeMessages();
      exactTimeMessages.value = result;
    } catch (e) {
      Get.snackbar(
        '오류',
        '정확한 시간 메시지를 불러오는데 실패했습니다: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // 요일 메시지 로드
  Future<void> loadWeeklyMessages() async {
    try {
      isLoading.value = true;
      final result = await _apiService.getAllWeeklyMessages();
      weeklyMessages.value = result;
    } catch (e) {
      Get.snackbar(
        '오류',
        '요일 메시지를 불러오는데 실패했습니다: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // 매일 메시지 로드
  Future<void> loadDailyMessages() async {
    try {
      isLoading.value = true;
      final result = await _apiService.getAllDailyMessages();
      dailyMessages.value = result;
    } catch (e) {
      Get.snackbar(
        '오류',
        '매일 메시지를 불러오는데 실패했습니다: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // 새 정확한 시간 메시지 생성
  Future<bool> createExactTimeMessage(ExactTimeMessage message) async {
    try {
      isLoading.value = true;
      final newMessage = await _apiService.createExactTimeMessage(message);
      exactTimeMessages.add(newMessage);
      exactTimeMessages.sort((a, b) {
        final dateA = DateTime(a.year, a.month, a.day, a.hour, a.minute);
        final dateB = DateTime(b.year, b.month, b.day, b.hour, b.minute);
        return dateA.compareTo(dateB);
      });
      Get.snackbar(
        '성공',
        '메시지가 생성되었습니다.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
      );
      return true;
    } catch (e) {
      Get.snackbar(
        '오류',
        '메시지 생성에 실패했습니다: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // 정확한 시간 메시지 수정
  Future<bool> updateExactTimeMessage(String id, ExactTimeMessage message) async {
    try {
      isLoading.value = true;
      final updatedMessage = await _apiService.updateExactTimeMessage(id, message);

      final index = exactTimeMessages.indexWhere((m) => m.id == id);
      if (index != -1) {
        exactTimeMessages[index] = updatedMessage;
        exactTimeMessages.sort((a, b) {
          final dateA = DateTime(a.year, a.month, a.day, a.hour, a.minute);
          final dateB = DateTime(b.year, b.month, b.day, b.hour, b.minute);
          return dateA.compareTo(dateB);
        });
      }

      Get.snackbar(
        '성공',
        '메시지가 수정되었습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        '오류',
        '메시지 수정에 실패했습니다: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // 정확한 시간 메시지 삭제
  Future<bool> deleteExactTimeMessage(String id) async {
    try {
      isLoading.value = true;
      await _apiService.deleteExactTimeMessage(id);
      exactTimeMessages.removeWhere((message) => message.id == id);

      Get.snackbar(
        '성공',
        '메시지가 삭제되었습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        '오류',
        '메시지 삭제에 실패했습니다: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // 새 요일 메시지 생성
  Future<bool> createWeeklyMessage(WeeklyMessage message) async {
    try {
      isLoading.value = true;
      final newMessage = await _apiService.createWeeklyMessage(message);
      weeklyMessages.add(newMessage);
      _sortWeeklyMessages();
      Get.snackbar(
        '성공',
        '메시지가 생성되었습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        '오류',
        '메시지 생성에 실패했습니다: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // 요일 메시지 수정
  Future<bool> updateWeeklyMessage(String id, WeeklyMessage message) async {
    try {
      isLoading.value = true;
      final updatedMessage = await _apiService.updateWeeklyMessage(id, message);

      final index = weeklyMessages.indexWhere((m) => m.id == id);
      if (index != -1) {
        weeklyMessages[index] = updatedMessage;
        _sortWeeklyMessages();
      }

      Get.snackbar(
        '성공',
        '메시지가 수정되었습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        '오류',
        '메시지 수정에 실패했습니다: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // 요일 메시지 삭제
  Future<bool> deleteWeeklyMessage(String id) async {
    try {
      isLoading.value = true;
      await _apiService.deleteWeeklyMessage(id);
      weeklyMessages.removeWhere((message) => message.id == id);

      Get.snackbar(
        '성공',
        '메시지가 삭제되었습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        '오류',
        '메시지 삭제에 실패했습니다: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // 요일 메시지 정렬
  void _sortWeeklyMessages() {
    final dayOrder = {'일': 0, '월': 1, '화': 2, '수': 3, '목': 4, '금': 5, '토': 6};
    weeklyMessages.sort((a, b) {
      final dayCompare = (dayOrder[a.dayOfWeek] ?? 0).compareTo(dayOrder[b.dayOfWeek] ?? 0);
      if (dayCompare != 0) return dayCompare;

      final hourCompare = a.hour.compareTo(b.hour);
      if (hourCompare != 0) return hourCompare;

      return a.minute.compareTo(b.minute);
    });
  }

  // 새 매일 메시지 생성
  Future<bool> createDailyMessage(DailyMessage message) async {
    try {
      isLoading.value = true;
      final newMessage = await _apiService.createDailyMessage(message);
      dailyMessages.add(newMessage);
      _sortDailyMessages();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('createDailyMessage 오류: $e');
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // 매일 메시지 수정
  Future<bool> updateDailyMessage(String id, DailyMessage message) async {
    try {
      isLoading.value = true;
      final updatedMessage = await _apiService.updateDailyMessage(id, message);

      final index = dailyMessages.indexWhere((m) => m.id == id);
      if (index != -1) {
        dailyMessages[index] = updatedMessage;
        _sortDailyMessages();
      }

      return true;
    } catch (e) {
      print('updateDailyMessage 오류: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // 매일 메시지 삭제
  Future<bool> deleteDailyMessage(String id) async {
    try {
      isLoading.value = true;
      await _apiService.deleteDailyMessage(id);
      dailyMessages.removeWhere((message) => message.id == id);

      return true;
    } catch (e) {
      print('deleteDailyMessage 오류: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // 매일 메시지 정렬
  void _sortDailyMessages() {
    dailyMessages.sort((a, b) {
      final hourCompare = a.hour.compareTo(b.hour);
      if (hourCompare != 0) return hourCompare;
      return a.minute.compareTo(b.minute);
    });
  }

  // 검색어 설정
  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  // 탭 인덱스 설정
  void setTabIndex(int index) {
    selectedTabIndex.value = index;
  }

  // 새로고침
  @override
  Future<void> refresh() async {
    await loadAllMessages();
  }

  // 활성/비활성 토글
  Future<bool> toggleExactTimeMessageActive(String id) async {
    final message = exactTimeMessages.firstWhere((m) => m.id == id);
    return await updateExactTimeMessage(
      id,
      message.copyWith(isActive: !message.isActive),
    );
  }

  Future<bool> toggleWeeklyMessageActive(String id) async {
    final message = weeklyMessages.firstWhere((m) => m.id == id);
    return await updateWeeklyMessage(
      id,
      message.copyWith(isActive: !message.isActive),
    );
  }

  Future<bool> toggleDailyMessageActive(String id) async {
    final message = dailyMessages.firstWhere((m) => m.id == id);
    return await updateDailyMessage(
      id,
      message.copyWith(isActive: !message.isActive),
    );
  }



  // 통계 정보
  Map<String, int> getStatistics() {
    return {
      '정확한 시간 메시지': exactTimeMessages.length,
      '활성 정확한 시간': exactTimeMessages.where((m) => m.isActive).length,
      '요일 메시지': weeklyMessages.length,
      '활성 요일 메시지': weeklyMessages.where((m) => m.isActive).length,
      '매일 메시지': dailyMessages.length, // 추가
      '활성 매일 메시지': dailyMessages.where((m) => m.isActive).length,
    };
  }
}