import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/chatbot_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/mypage_screen.dart';
import 'screens/splash_screen.dart';
import 'models/news.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 비동기 처리를 위해 필요
  await dotenv.load(fileName: "assets/.env"); // 파일 이름 확인
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '경제콕',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        canvasColor: Colors.white,
      ),
      home: const SplashScreen(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // 즐겨찾기 상태 관리
  final Set<News> favoriteNews = {};

  // 즐겨찾기 상태를 토글하는 함수
  void _toggleFavorite(News news) {
    setState(() {
      if (favoriteNews.contains(news)) {
        favoriteNews.remove(news); // 즐겨찾기에서 제거
        print('Removed from favorites: ${news.title}');
      } else {
        favoriteNews.add(news); // 즐겨찾기에 추가
        print('Added to favorites: ${news.title}');
      }
    });

    // 현재 전체 즐겨찾기 리스트 출력
    print('Current favoriteNews: ${favoriteNews.map((n) => n.title).toList()}');
  }

  @override
  Widget build(BuildContext context) {
    // 동적으로 최신 상태를 반영하는 탭 화면 생성
    final screens = [
      HomeScreen(
        favoriteNews: favoriteNews.toList(), // List<News> 전달
        onFavoriteToggle: _toggleFavorite, // 즐겨찾기 상태 토글 함수
      ),
      FavoritesScreen(
        favoriteNews: favoriteNews.toList(), // List<News> 전달
        onFavoriteToggle: _toggleFavorite, // 즐겨찾기 상태 토글 함수
      ),
      ChatbotScreen(
        onClose: () {
          // 챗봇 화면에서 나가기 버튼을 누르면 홈 화면으로 전환
          setState(() {
            _selectedIndex = 0; // HomeScreen으로 이동
          });
        },
      ),
      const QuizScreen(),
      const MyPageScreen(),
    ];

    return Scaffold(
      body: screens[_selectedIndex], // 현재 선택된 화면 표시
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        elevation: 0,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index; // 선택된 탭 인덱스 업데이트
          });
        },
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_border_outlined),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chatbot',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz_outlined),
            label: 'Quiz',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'My Page',
          ),
        ],
      ),
    );
  }
}
