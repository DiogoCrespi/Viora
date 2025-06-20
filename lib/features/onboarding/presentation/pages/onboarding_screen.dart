import 'package:flutter/material.dart';
import 'package:viora/core/constants/theme_extensions.dart';
import 'package:viora/features/auth/presentation/pages/login_screen.dart';
import 'package:viora/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:viora/core/config/supabase_config.dart';
import 'package:viora/presentation/pages/main_screen.dart';
import 'package:viora/routes.dart';

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
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_seen_onboarding', true);
      debugPrint('OnboardingScreen: Saved has_seen_onboarding = true');

      if (mounted) {
        debugPrint('OnboardingScreen: Checking authentication status');
        final session = SupabaseConfig.client.auth.currentSession;

        if (session != null) {
          debugPrint(
              'OnboardingScreen: User is authenticated, navigating to main');
          context.pushReplacementNamed(AppRoutes.main, arguments: {'selectedIndex': 0});
        } else {
          debugPrint(
              'OnboardingScreen: User is not authenticated, navigating to login');
          context.pushReplacementNamed(AppRoutes.login);
        }
      }
    } catch (e) {
      debugPrint('OnboardingScreen: Error in _navigateToNext: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
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
