import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/app_provider.dart';
import '../auth/phone_auth_screen.dart' show LoginScreen;

/// Onboarding screen with 3 pages and page indicator
/// Matches reference: onboarding_-_find_parking/screen.png
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Onboarding data
  final List<_OnboardingData> _pages = [
    _OnboardingData(
      imagePath: 'assets/images/onboarding_1.png',
      title: AppStrings.onboardingTitle1,
      description: AppStrings.onboardingDesc1,
    ),
    _OnboardingData(
      imagePath: 'assets/images/onboarding_2.png',
      title: AppStrings.onboardingTitle2,
      description: AppStrings.onboardingDesc2,
    ),
    _OnboardingData(
      imagePath: 'assets/images/onboarding_3.png',
      title: AppStrings.onboardingTitle3,
      description: AppStrings.onboardingDesc3,
    ),
  ];

  void _goToAuth() {
    context.read<AppProvider>().completeOnboarding();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 16, right: 20),
                child: TextButton(
                  onPressed: _goToAuth,
                  child: Text(
                    'Skip',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            // Page indicator
            SmoothPageIndicator(
              controller: _pageController,
              count: _pages.length,
              effect: const ExpandingDotsEffect(
                dotWidth: 10,
                dotHeight: 10,
                activeDotColor: AppColors.primary,
                dotColor: Color(0xFFD1D5DB),
                expansionFactor: 3,
              ),
            ),
            const SizedBox(height: 40),
            // Title and description (below indicator, matching reference)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  Text(
                    _pages[_currentPage].title,
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _pages[_currentPage].description,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Next / Get Started button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _goToAuth();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _currentPage < _pages.length - 1
                            ? 'Next'
                            : 'Get Started',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration image
          Image.asset(
            data.imagePath,
            width: 470,
            height: 470,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}

class _OnboardingData {
  final String imagePath;
  final String title;
  final String description;

  const _OnboardingData({
    required this.imagePath,
    required this.title,
    required this.description,
  });
}
