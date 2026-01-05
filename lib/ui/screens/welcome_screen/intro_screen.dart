import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' as drift;
import 'package:smean_mobile_app/core/route/app_routes.dart';
import 'package:smean_mobile_app/data/database/database.dart';
import 'package:smean_mobile_app/core/providers/language_provider.dart';
import 'package:smean_mobile_app/core/constants/app_colors.dart';
import 'package:smean_mobile_app/ui/widgets/language_switcher_button.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  // Calculate current page value including fractional scroll
  double get _pageValue {
    try {
      return _pageController.page ?? _currentPage.toDouble();
    } catch (e) {
      return _currentPage.toDouble();
    }
  }

  List<IntroPageData> _getListPagesData(bool isKhmer) => [
    IntroPageData(
      title: isKhmer ? "ជំរាបសួរ!" : "Hello!",
      body: isKhmer
          ? "សូមស្វាគមន៍មកកាន់កម្មវិធី SMEAN - ដៃគូ AI របស់អ្នក"
          : "Welcome to SMEAN - Your AI companion for speech transformation",
      imagePath: 'assets/images/intro_1.png',
    ),
    IntroPageData(
      title: isKhmer ? "សំឡេងទៅជាអត្ថបទ" : "Speech to Text",
      body: isKhmer
          ? "បម្លែងសំឡេងខ្មែររបស់អ្នកទៅជាអត្ថបទក្នុងរយៈពេលវេលាខ្លី។"
          : "Transform your Khmer voice into accurate text in seconds.",
      imagePath: 'assets/images/intro_2.png',
    ),
    IntroPageData(
      title: isKhmer ? "សង្ខេបឆ្លាតវៃ" : "Smart Summarization",
      body: isKhmer
          ? "AI របស់យើងបង្កើតសេចក្តីសង្ខេបដ៏មានអត្ថន័យពីការបកប្រែ។"
          : "Our AI creates insightful summaries from your transcriptions.",
      imagePath: 'assets/images/intro_3.png',
    ),
    IntroPageData(
      title: isKhmer ? "បកប្រែផ្ទាល់" : "Live Transcription",
      body: isKhmer
          ? "ទទួលបានអត្ថបទពីសំឡេងរបស់អ្នកភ្លាមៗក្នុងពេលជាក់ស្តែង។"
          : "Get real-time text from your speech instantly as you speak.",
      imagePath: 'assets/images/intro_4.png',
    ),
  ];

  // Mark that user has seen the intro
  Future<void> _markIntroAsSeen(BuildContext context) async {
    final db = Provider.of<AppDatabase>(context, listen: false);
    final existing = await (db.select(
      db.appSession,
    )..limit(1)).getSingleOrNull();

    if (existing == null) {
      // Insert new session with hasSeenIntro = true
      await db
          .into(db.appSession)
          .insert(
            AppSessionCompanion(lastUpdated: drift.Value(DateTime.now())),
          );
    }
    // If session exists, we don't need to do anything since intro was seen
  }

  // Navigate to login and mark intro as seen
  void _completeIntro() async {
    await _markIntroAsSeen(context);
    if (context.mounted) {
      AppRoutes.navigateToLogin(context);
    }
  }

  // Skip to end
  void _handleSkip() async {
    await _markIntroAsSeen(context);
    if (context.mounted) {
      AppRoutes.navigateToLogin(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isKhmer = languageProvider.currentLocale.languageCode == 'km';
    final pages = _getListPagesData(isKhmer);
    final size = MediaQuery.of(context).size;
    final isWebOrDesktop = kIsWeb || size.width > 600;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background image extends behind top bar
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: size.height * 0.65,
            child: AnimatedBuilder(
              animation: _pageController,
              builder: (context, child) {
                return Stack(
                  children: [
                    // Show current and next image for smooth transitions
                    ...List.generate(pages.length, (index) {
                      final pageOffset = (_pageValue - index).abs();
                      final opacity = pageOffset <= 1.0
                          ? (1.0 - pageOffset).clamp(0.0, 1.0)
                          : 0.0;

                      if (opacity == 0.0) return const SizedBox.shrink();

                      return Opacity(
                        opacity: opacity,
                        child: Image.asset(
                          pages[index].imagePath,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),

          // Invisible PageView for swipe gesture handling (behind other interactive elements)
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: size.height * 0.65,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: pages.length,
              physics: const PageScrollPhysics(),
              itemBuilder: (context, index) => const SizedBox.shrink(),
            ),
          ),

          // Left Navigation Arrow
          if (_currentPage > 0)
            Positioned(
              left: 16,
              top: size.height * 0.325,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: AppColors.primary,
                  ),
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ),
            ),

          // Right Navigation Arrow
          if (_currentPage < pages.length - 1)
            Positioned(
              right: 16,
              top: size.height * 0.325,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.primary,
                  ),
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ),
            ),

          // White container with rounded top corners (fixed height)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: size.height * 0.45,
            child: AnimatedBuilder(
              animation: _pageController,
              builder: (context, child) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: _buildWhiteContainerContent(
                              pages[_currentPage],
                              isKhmer,
                              pages.length,
                              isWebOrDesktop,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),

          // Top Navigation Bar (transparent, overlays the image)
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: SafeArea(bottom: false, child: _buildTopBar(isKhmer)),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(bool isKhmer) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Skip Button with background (same size as language switcher)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: TextButton(
              onPressed: _handleSkip,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                isKhmer ? "រំលង" : "Skip",
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // SMEAN Logo
          Image.asset('assets/images/SMEAN_logo.png', height: 35),

          // Language Toggle Button
          const LanguageSwitcherButton(),
        ],
      ),
    );
  }

  // Build content for white container (title, description, buttons)
  Widget _buildWhiteContainerContent(
    IntroPageData data,
    bool isKhmer,
    int pageCount,
    bool isWebOrDesktop,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isWebOrDesktop ? 80.0 : 32.0,
        vertical: 16.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title (dark color for white background)
          Text(
            data.title,
            style: TextStyle(
              color: Colors.black87,
              fontSize: isWebOrDesktop ? 32 : 24,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: isWebOrDesktop ? 16 : 12),

          // Body/Description (dark color for white background)
          Flexible(
            child: Text(
              data.body,
              style: TextStyle(
                color: Colors.black54,
                fontSize: isWebOrDesktop ? 18 : 14,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          SizedBox(height: isWebOrDesktop ? 24 : 20),

          // Page Indicator Dots
          _buildPageIndicator(pageCount),

          SizedBox(height: isWebOrDesktop ? 24 : 20),

          // Login Button
          SizedBox(
            width: double.infinity,
            height: isWebOrDesktop ? 56 : 52,
            child: ElevatedButton(
              onPressed: _completeIntro,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: AppColors.primary.withValues(alpha: 0.3),
              ),
              child: Text(
                isKhmer ? "ចូលប្រើប្រាស់" : "Log In",
                style: TextStyle(
                  fontSize: isWebOrDesktop ? 20 : 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          SizedBox(height: isWebOrDesktop ? 12 : 12),

          // Sign Up Link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isKhmer ? "មិនទាន់មានគណនី? " : "New to SMEAN? ",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: isWebOrDesktop ? 16 : 15,
                ),
              ),
              TextButton(
                onPressed: () async {
                  await _markIntroAsSeen(context);
                  if (context.mounted) {
                    AppRoutes.navigateToRegister(context);
                  }
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  isKhmer ? "ចុះឈ្មោះ" : "Sign Up",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: isWebOrDesktop ? 16 : 15,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.primary,
                    decorationThickness: 2,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int pageCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        pageCount,
        (index) => GestureDetector(
          onTap: () {
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _currentPage == index ? 32 : 10,
            height: 10,
            decoration: BoxDecoration(
              color: _currentPage == index
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
      ),
    );
  }
}

// Data class for intro pages
class IntroPageData {
  final String title;
  final String body;
  final String imagePath;

  IntroPageData({
    required this.title,
    required this.body,
    required this.imagePath,
  });
}
