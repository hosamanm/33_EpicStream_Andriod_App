import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/banner_item.dart';

class BannerProvider extends ChangeNotifier {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  Timer? _timer;

  final List<BannerItem> _banners = [
    const BannerItem(
      id: 'b1',
      title: 'The Dark Knight',
      description: 'When the menace known as the Joker wreaks havoc and chaos on the people of Gotham, Batman must accept one of the greatest psychological and physical tests of his ability to fight injustice.',
      imageUrl: 'https://images.unsplash.com/photo-1478720568477-152d9b164e26?q=80&w=2070&auto=format&fit=crop',
      genres: ['Action', 'Crime', 'Drama'],
      rating: '9.0',
      year: '2008',
      duration: '2h 32m',
      language: 'English',
    ),
    const BannerItem(
      id: 'b2',
      title: 'Interstellar',
      description: 'A team of explorers travel through a wormhole in space in an attempt to ensure humanity\'s survival.',
      imageUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?q=80&w=2094&auto=format&fit=crop',
      genres: ['Sci-Fi', 'Drama', 'Adventure'],
      rating: '8.7',
      year: '2014',
      duration: '2h 49m',
      language: 'English',
    ),
    const BannerItem(
      id: 'b3',
      title: 'Inception',
      description: 'A thief who steals corporate secrets through the use of dream-sharing technology is given the inverse task of planting an idea into the mind of a C.E.O.',
      imageUrl: 'https://images.unsplash.com/photo-1626814026160-2237a95fc5a0?q=80&w=2070&auto=format&fit=crop',
      genres: ['Action', 'Sci-Fi', 'Adventure'],
      rating: '8.8',
      year: '2010',
      duration: '2h 28m',
      language: 'English',
    ),
  ];

  List<BannerItem> get banners => _banners;
  int get currentIndex => _currentIndex;
  PageController get pageController => _pageController;

  void init() {
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_banners.isNotEmpty) {
        _currentIndex = (_currentIndex + 1) % _banners.length;
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _currentIndex,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOutCubic,
          );
        }
      }
    });
  }

  void onPageChanged(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }
}
