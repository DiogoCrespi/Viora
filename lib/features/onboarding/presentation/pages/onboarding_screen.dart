import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:provider/provider.dart'; // For UserProvider
import 'package:viora/core/constants/theme_extensions.dart';
import 'package:viora/l10n/app_localizations.dart';
// import 'package:shared_preferences/shared_preferences.dart'; // Re-added temporarily below
// import 'package:viora/core/config/supabase_config.dart'; // Handled by provider
import 'package:viora/routes.dart';
// import 'package:viora/features/user/domain/repositories/preferences_repository.dart'; // Removed as unused
import 'package:viora/features/user/presentation/providers/user_provider.dart'; // Import UserProvider
import 'package:shared_preferences/shared_preferences.dart'; // For direct use, as per last refactor

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animationController;
  List<Animation<double>> _fadeAnimations = [];
  List<Animation<Offset>> _slideAnimations = [];
  // final UserPreferencesRepository _preferencesRepository = UserPreferencesRepository(); // Removed as unused

  List<OnboardingPage> _getPages(BuildContext context) {
    return [
      OnboardingPage(
        title: AppLocalizations.of(context)!.onboardingPage1Title,
        description: AppLocalizations.of(context)!.onboardingPage1Description,
        icon: Icons.rocket_launch,
      ),
      OnboardingPage(
        title: AppLocalizations.of(context)!.onboardingPage2Title,
        description: AppLocalizations.of(context)!.onboardingPage2Description,
        icon: Icons.assignment,
      ),
      OnboardingPage(
        title: AppLocalizations.of(context)!.onboardingPage3Title,
        description: AppLocalizations.of(context)!.onboardingPage3Description,
        icon: Icons.trending_up,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _animationController.duration = Theme.of(context).themeChangeDuration;

    final pages = _getPages(context);

    // Recriar animações apenas se ainda não foram criadas ou se o número de páginas mudou
    if (_fadeAnimations.length != pages.length) {
      _fadeAnimations = List.generate(
        pages.length,
        (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              index * 0.2,
              (index + 1) * 0.2,
              curve: Curves.easeOut,
            ),
          ),
        ),
      );
    }

    if (_slideAnimations.length != pages.length) {
      _slideAnimations = List.generate(
        pages.length,
        (index) => Tween<Offset>(
          begin: const Offset(0.0, 0.5),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              index * 0.2,
              (index + 1) * 0.2,
              curve: Curves.easeOut,
            ),
          ),
        ),
      );
    }

    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _animationController.reset();
    _animationController.forward();
  }

  Future<void> _navigateToNext() async {
    try {
      // Mark onboarding as seen via the repository
      // Assuming UserProvider holds the current user's ID or can provide it to the repository if needed.
      // For simplicity, if setHasSeenOnboarding doesn't need userId, it's direct.
      // If it does, UserProvider would be used here to get userId.
      // For this refactor, let's assume UserPreferencesRepository.setHasSeenOnboarding can be called directly
      // or it internally gets what it needs (e.g. from Supabase instance if tied to logged-in user,
      // or stores it generally if not tied to a specific user account yet).
      // Given `SharedPreferences` was used before, it's likely a general flag.
      // A more robust solution might involve a dedicated OnboardingService.
      // For now, we'll use UserPreferencesRepository as per prompt.
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.currentUser?.id; // Get user ID if available

      // The setHasSeenOnboarding method in UserPreferencesRepository might need adjustment
      // if it's user-specific or general. Let's assume it's general for now.
      // If it were user-specific and userId is null, different logic might apply.
      // However, the old code used SharedPreferences directly, implying a general flag.
      // So, a direct call to a method that sets a general flag is appropriate here.
      // Let's assume UserPreferencesRepository has a method like `markOnboardingAsSeen()`.
      // Since UserPreferencesRepository is more about user-specific prefs, this might be a slight mismatch.
      // A dedicated OnboardingService or using SharedPreferences directly via a wrapper would be cleaner.
      // For now, sticking to the available PreferencesRepository.
      // This conceptual method would be: await _preferencesRepository.markOnboardingAsCompleted();
      // As UserPreferencesRepository is tied to user.id, we need to ensure this is handled.
      // The simplest for now is to assume setHasSeenOnboarding is a general app setting.
      // Let's assume a method on UserPreferencesRepository like:
      // await _preferencesRepository.setHasSeenOnboardingFlag(true); (conceptual)

      // For the sake of this refactor, we'll assume a method that doesn't require a userId
      // on _preferencesRepository for this specific flag, or that it handles it.
      // The original code used SharedPreferences directly:
      final prefs = await SharedPreferences.getInstance(); // Re-introducing for this specific line
      await prefs.setBool('has_seen_onboarding', true);     // as repository is user-specific
      if (kDebugMode) {
        debugPrint('OnboardingScreen: Saved has_seen_onboarding = true (using direct SharedPreferences for now).');
      }


      if (mounted) {
        final bool isLoggedIn = userProvider.currentUser != null; // More abstract check

        if (kDebugMode) {
          debugPrint('OnboardingScreen: Checking authentication status: ${isLoggedIn ? "Logged In" : "Not Logged In"}');
        }

        if (isLoggedIn) {
          if (kDebugMode) {
            debugPrint('OnboardingScreen: User is authenticated, navigating to main');
          }
          context.pushReplacementNamed(AppRoutes.main, arguments: {'selectedIndex': 0});
        } else {
          if (kDebugMode) {
            debugPrint('OnboardingScreen: User is not authenticated, navigating to login');
          }
          context.pushReplacementNamed(AppRoutes.login);
        }
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('OnboardingScreen: Error in _navigateToNext: $e\n$stackTrace');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $e'), // More generic error for now
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pages = _getPages(context);

    return Scaffold(
      body: Container(
        decoration: theme.gradientDecoration,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: pages.length,
                  itemBuilder: (context, index) {
                    return _buildPage(pages[index], index);
                  },
                ),
              ),
              _buildNavigation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page, int index) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeTransition(
            opacity: _fadeAnimations[index],
            child: SlideTransition(
              position: _slideAnimations[index],
              child: Icon(page.icon, size: 100, color: theme.sunsetOrange),
            ),
          ),
          const SizedBox(height: 40),
          FadeTransition(
            opacity: _fadeAnimations[index],
            child: SlideTransition(
              position: _slideAnimations[index],
              child: Text(
                page.title,
                style: theme.futuristicTitle,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 20),
          FadeTransition(
            opacity: _fadeAnimations[index],
            child: SlideTransition(
              position: _slideAnimations[index],
              child: Text(
                page.description,
                style: theme.futuristicBody,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigation() {
    final theme = Theme.of(context);
    final pages = _getPages(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Indicadores de página
          Row(
            children: List.generate(
              pages.length,
              (index) => AnimatedContainer(
                duration: theme.themeChangeDuration,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: _currentPage == index ? 24 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? theme.sunsetOrange
                      : theme.primarySurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          // Botões de navegação
          Row(
            children: [
              // Botão Pular
              AnimatedOpacity(
                opacity: _currentPage == pages.length - 1 ? 0.0 : 1.0,
                duration: theme.themeChangeDuration,
                child: TextButton(
                  onPressed: () => _pageController.animateToPage(
                    pages.length - 1,
                    duration: theme.themeChangeDuration,
                    curve: Curves.easeInOutCubic,
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.skipButton,
                    style: theme.futuristicBody,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Botão Avançar ou Vamos Começar
              AnimatedSwitcher(
                duration: theme.themeChangeDuration,
                child: _currentPage == pages.length - 1
                    ? ElevatedButton(
                        key: const ValueKey('start'),
                        onPressed: _navigateToNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.sunsetOrange,
                          foregroundColor: theme.primaryText,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.startButton,
                          style: theme.futuristicSubtitle,
                        ),
                      )
                    : ElevatedButton(
                        key: const ValueKey('next'),
                        onPressed: () => _pageController.nextPage(
                          duration: theme.themeChangeDuration,
                          curve: Curves.easeInOutCubic,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.sunsetOrange,
                          foregroundColor: theme.primaryText,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.nextButton,
                              style: theme.futuristicSubtitle,
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward,
                              color: theme.primaryText,
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
  });
}
