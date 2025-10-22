import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gsbot_manager/services/api_service.dart';
import 'package:intl/date_symbol_data_local.dart';
import '/screens/boss/index.dart';
import '/screens/interval_message/index.dart';
import 'controllers/controller_boss.dart';
import 'controllers/controller_interval_message.dart';
// import 'controllers/hexa_controller.dart';
// import 'controllers/response_controller.dart';
// import 'screens/hexa_screen.dart';
// import 'screens/response_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Intl 한국어 로케일 초기화
  await initializeDateFormatting('ko_KR', null);

  ApiService().init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'GSBot Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        textTheme: GoogleFonts.notoSansKrTextTheme(
          Theme.of(context).textTheme
        ).copyWith(
          titleLarge: GoogleFonts.notoSansKr(fontWeight: FontWeight.w900),
          titleMedium: GoogleFonts.notoSansKr(fontWeight: FontWeight.bold),
          bodyLarge: GoogleFonts.notoSansKr(fontWeight: FontWeight.w400),
          bodyMedium: GoogleFonts.notoSansKr(fontWeight: FontWeight.w300),
        ),
      ),// Locale 설정 추가
      locale: Locale('ko', 'KR'),
      fallbackLocale: Locale('en', 'US'),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('ko', 'KR'),
        Locale('en', 'US'),
      ],
      home: MainScreen(),
      initialBinding: BindingsBuilder(() {
        Get.put(BossController());
        Get.put(IntervalMessageController());
        // Get.put(HexaController());
        // Get.put(ResponseController());
      }),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    BossScreen(),             // 0: 보스 정보 관리
    IntervalMessageScreen(),  // 1: 정기 메시지 관리
    // HexaScreen(),          // 2: HEXA 매트릭스 관리
    // ResponseScreen(),      // 3: 봇 응답 관리
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_esports_outlined),
            activeIcon: Icon(Icons.sports_esports),
            label: '보스 정보',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule_outlined),
            activeIcon: Icon(Icons.schedule),
            label: '정기 메시지',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_on_outlined),
            activeIcon: Icon(Icons.grid_on),
            label: 'HEXA 매트릭스',
          ),
        ],
      ),
    );
  }
}