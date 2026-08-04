import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:epic_stream/core/theme/app_colors.dart';
import 'package:epic_stream/features/auth/presentation/providers/onboarding_notifier.dart';

class OnboardingData {
  final String title;
  final String description;
  final String lottieAsset;

  OnboardingData({
    required this.title,
    required this.description,
    required this.lottieAsset,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Unlimited Streaming',
      description: 'Stream your favorite movies and TV shows in 4K Ultra HD quality.',
      lottieAsset: 'assets/animations/onboarding_stream.json',
    ),
    OnboardingData(
      title: 'Watch Anywhere',
      description: 'Available on your phone, tablet, laptop, and TV. Sync your progress.',
      lottieAsset: 'assets/animations/onboarding_devices.json',
    ),
    OnboardingData(
      title: 'Offline Downloads',
      description: 'Download your favorite content and watch it anytime, anywhere.',
      lottieAsset: 'assets/animations/onboarding_download.json',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
  }

  Future<void> _complete() async {
    await context.read<OnboardingNotifier>().completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Header Row (Skip and Indicators)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: SizedBox(
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // SKIP Button - Using a defined tap area
                    SizedBox(
                      width: 80,
                      child: !isLastPage 
                        ? TextButton(
                            onPressed: _complete,
                            style: TextButton.styleFrom(
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.zero,
                            ),
                            child: const Text(
                              'SKIP',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: 1.1,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                    ),
                    
                    // Center Indicators
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        _pages.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 8,
                          width: index == _currentPage ? 24 : 8,
                          decoration: BoxDecoration(
                            color: index == _currentPage ? AppColors.primaryRed : Colors.white24,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    
                    // Right Spacer
                    const SizedBox(width: 80),
                  ],
                ),
              ),
            ),

            // 2. Main Content (PageView) - Expanded to take all available space
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final data = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.3,
                          child: Lottie.asset(
                            data.lottieAsset,
                            fit: BoxFit.contain,
                            repeat: true,
                          ),
                        ),
                        const SizedBox(height: 50),
                        Text(
                          data.title.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24, 
                            fontWeight: FontWeight.bold, 
                            color: Colors.white, 
                            letterSpacing: 1.5
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          data.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16, 
                            color: Colors.white70, 
                            height: 1.5
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // 3. Footer Action Button
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 40),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (isLastPage) {
                      _complete();
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: Text(
                    isLastPage ? 'GET STARTED' : 'CONTINUE',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
