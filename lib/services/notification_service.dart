import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// 백그라운드 메시지 핸들러 (top-level 함수여야 함)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('🔔 백그라운드 메시지: ${message.notification?.title}');
}

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  // FCM 토큰
  static String? fcmToken;

  // Node.js 서버 URL (실제 EC2 서버 주소로 변경 필요)
  static const String serverUrl = 'http://ec2-3-34-171-56.ap-northeast-2.compute.amazonaws.com:3000';

  /// 알림 서비스 초기화
  static Future<void> initialize() async {
    print('🔔 NotificationService 초기화 시작...');

    // 알림 권한 요청
    final NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ 알림 권한 승인됨');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('⚠️ 알림 임시 권한 승인됨');
    } else {
      print('❌ 알림 권한 거부됨');
      return;
    }

    // FCM 토큰 가져오기
    try {
      fcmToken = await _firebaseMessaging.getToken();
      print('📱 FCM Token: $fcmToken');
    } catch (e) {
      print('❌ FCM 토큰 가져오기 실패: $e');
    }

    // 로컬 알림 초기화
    await _initializeLocalNotifications();

    // 포그라운드 메시지 수신 리스너
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 백그라운드 메시지 핸들러 등록
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 앱이 종료된 상태에서 알림 탭으로 실행된 경우
    final RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print('🚀 앱 시작: 알림으로부터');
      _handleMessageTap(initialMessage);
    }

    // 백그라운드/종료 상태에서 알림 탭
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);

    print('✅ NotificationService 초기화 완료');
  }

  /// 로컬 알림 초기화
  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('🔔 알림 탭: ${response.payload}');
      },
    );

    // Android 알림 채널 생성
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'gsbot_notification_channel',
      'GS Bot 알림',
      description: '게임 봇 알림을 받습니다',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    // try-catch로 안전하게 처리
    try {
      final plugin = _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (plugin != null) {
        await plugin.createNotificationChannel(channel);
      }
    } catch (e) {
      print('⚠️ 알림 채널 생성 중 오류: $e');
    }

    print('✅ 알림 채널 생성 완료');
  }

  /// 포그라운드 메시지 처리
  static void _handleForegroundMessage(RemoteMessage message) {
    print('📩 포그라운드 메시지 수신');
    print('   제목: ${message.notification?.title}');
    print('   내용: ${message.notification?.body}');
    print('   데이터: ${message.data}');

    // 로컬 알림 표시
    _showLocalNotification(message);
  }

  /// 로컬 알림 표시
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'gsbot_notification_channel',
      'GS Bot 알림',
      channelDescription: '게임 봇 알림을 받습니다',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? '알림',
      message.notification?.body ?? '',
      details,
      payload: message.data.isNotEmpty ? jsonEncode(message.data) : null,
    );
  }

  /// 알림 탭 처리
  static void _handleMessageTap(RemoteMessage message) {
    print('👆 알림 탭됨');
    print('   제목: ${message.notification?.title}');
    print('   데이터: ${message.data}');

    // TODO: 특정 화면으로 이동하는 로직 추가
  }

  /// FCM 토큰을 서버로 전송
  static Future<void> sendTokenToServer() async {
    if (fcmToken == null || fcmToken!.isEmpty) {
      print('❌ FCM 토큰이 없습니다');
      return;
    }

    try {
      print('📤 서버로 토큰 전송 중...');
      print('   URL: $serverUrl/api/fcm/register');
      print('   Token: ${fcmToken!.substring(0, 20)}...');

      final response = await http.post(
        Uri.parse('$serverUrl/api/fcm/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'token': fcmToken,
          'device_info': {
            'platform': 'android',
            'timestamp': DateTime.now().toIso8601String(),
          }
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('서버 연결 시간 초과');
        },
      );

      if (response.statusCode == 200) {
        print('✅ 토큰 전송 성공');
        print('   응답: ${response.body}');
      } else {
        print('❌ 토큰 전송 실패: ${response.statusCode}');
        print('   응답: ${response.body}');
      }
    } catch (e) {
      print('❌ 토큰 전송 오류: $e');
    }
  }

  /// 토큰 새로고침 리스너 설정
  static void setupTokenRefreshListener() {
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      print('🔄 FCM 토큰 갱신됨');
      print('   새 토큰: ${newToken.substring(0, 20)}...');
      fcmToken = newToken;
      sendTokenToServer();
    });
  }
}