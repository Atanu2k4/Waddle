import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/gemini_service.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 5;
  bool _hasSwipedOnce = false;

  // Onboarding data
  DateTime? _selectedDOB;
  double _weight = 70;
  double _heightCm = 170;
  double _dailyProtein = 50;
  double _dailyCarbs = 250;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _skipAll() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.skipOnboarding();
    if (mounted) _goToDashboard();
  }

  void _completeOnboarding() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Save today's diet entry
    await GeminiService.saveDietEntry(_dailyProtein, _dailyCarbs);

    await authProvider.saveOnboardingData(
      dateOfBirth: _selectedDOB,
      weight: _weight,
      height: _heightCm,
      dailyProtein: _dailyProtein,
      dailyCarbs: _dailyCarbs,
    );
    if (mounted) _goToDashboard();
  }

  Future<void> _showDietInputDialog() async {
    // Create local controllers inside the dialog
    final List<TextEditingController> localControllers = List.generate(
      5,
      (index) => TextEditingController(),
    );

    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        bool isCalculating = false;

        return StatefulBuilder(
          builder: (context, setDialogState) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 24,
            ),
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 500,
                  maxHeight: 700,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF064E3B).withOpacity(0.95),
                      const Color(0xFF065F46).withOpacity(0.95),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF10B981).withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF059669).withOpacity(0.4),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                      spreadRadius: -5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF10B981).withOpacity(0.3),
                                      const Color(0xFF34D399).withOpacity(0.2),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.restaurant_menu,
                                  color: Color(0xFF6EE7B7),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Enter Your 5-Day Diet',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFF0FDF4),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  Navigator.pop(context, false);
                                  Future.delayed(
                                    const Duration(milliseconds: 100),
                                    () {
                                      for (var c in localControllers) {
                                        c.dispose();
                                      }
                                    },
                                  );
                                },
                                icon: const Icon(
                                  Icons.close,
                                  size: 20,
                                  color: Color(0xFFD1FAE5),
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Describe what you ate each day. Be as detailed as possible.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFFA7F3D0),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Scrollable content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(5, (index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Day ${index + 1}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF6EE7B7),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: localControllers[index],
                                    maxLines: 3,
                                    keyboardType: TextInputType.multiline,
                                    textInputAction: TextInputAction.newline,
                                    autofocus: index == 0,
                                    enableInteractiveSelection: true,
                                    style: const TextStyle(
                                      color: Color(0xFFF0FDF4),
                                    ),
                                    decoration: InputDecoration(
                                      hintText:
                                          'e.g., 2 eggs, oatmeal, chicken salad...',
                                      hintStyle: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF6EE7B7),
                                      ),
                                      filled: true,
                                      fillColor:
                                          const Color(0xFF047857).withOpacity(0.3),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: const Color(0xFF10B981)
                                              .withOpacity(0.3),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: const Color(0xFF10B981)
                                              .withOpacity(0.3),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color(0xFF34D399),
                                          width: 2,
                                        ),
                                      ),
                                      contentPadding: const EdgeInsets.all(12),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),
                    ),

                    // Bottom button
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: isCalculating
                          ? const Column(
                              children: [
                                CircularProgressIndicator(
                                  color: Color(0xFF6EE7B7),
                                  strokeWidth: 3,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Analyzing your diet...',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFFA7F3D0),
                                  ),
                                ),
                              ],
                            )
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (localControllers.every(
                                    (c) => c.text.trim().isEmpty,
                                  )) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please enter at least one day of diet',
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  setDialogState(() => isCalculating = true);

                                  final foodDays = localControllers
                                      .map((c) => c.text.trim())
                                      .where((text) => text.isNotEmpty)
                                      .toList();

                                  final nutritionData =
                                      await GeminiService.analyzeFoodItems(
                                        foodDays,
                                      );

                                  setDialogState(() => isCalculating = false);

                                  if (nutritionData != null) {
                                    final days = foodDays.length;
                                    final avgProtein =
                                        nutritionData['protein']! / days;
                                    final avgCarbs =
                                        nutritionData['carbs']! / days;

                                    // Close dialog first
                                    Navigator.pop(context, true);

                                    // Dispose controllers after dialog is closed
                                    Future.delayed(
                                      const Duration(milliseconds: 100),
                                      () {
                                        for (var c in localControllers) {
                                          c.dispose();
                                        }
                                      },
                                    );

                                    setState(() {
                                      _dailyProtein = avgProtein.clamp(
                                        0.0,
                                        300.0,
                                      );
                                      _dailyCarbs = avgCarbs.clamp(0.0, 500.0);
                                    });

                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Calculated: ${avgProtein.toStringAsFixed(0)}g protein, ${avgCarbs.toStringAsFixed(0)}g carbs per day',
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  } else {
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Failed to analyze diet. Check console for details or try again.',
                                          ),
                                          backgroundColor: Colors.red,
                                          duration: Duration(seconds: 5),
                                        ),
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  shadowColor: Colors.transparent,
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFF10B981).withOpacity(0.9),
                                        const Color(0xFF059669).withOpacity(0.9),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: const Color(0xFF34D399)
                                          .withOpacity(0.4),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF10B981)
                                            .withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(
                                        Icons.analytics_outlined,
                                        color: Color(0xFFD1FAE5),
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Calculate Nutrition',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _goToDashboard() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          final tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Image.asset(
            'assets/bg-final.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFDE978), Color(0xFFF5B04A)],
                  ),
                ),
              );
            },
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Progress + Skip
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      // Progress dots
                      Expanded(
                        child: Row(
                          children: List.generate(_totalPages, (i) {
                            return Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                height: 4,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  color: i <= _currentPage
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.3),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Skip button
                      if (_currentPage < _totalPages - 1)
                        GestureDetector(
                          onTap: _skipAll,
                          child: Text(
                            'Skip',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Pages
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                        if (!_hasSwipedOnce) _hasSwipedOnce = true;
                      });
                    },
                    children: [
                      _buildDOBPage(),
                      _buildWeightPage(),
                      _buildHeightPage(),
                      _buildDietPage(),
                      _buildCompletePage(),
                    ],
                  ),
                ),

                // Navigation Buttons (for web/testing)
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back Button
                      if (_currentPage > 0)
                        ElevatedButton.icon(
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          icon: const Icon(Icons.arrow_back, size: 18),
                          label: const Text('Back'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.9),
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 100),

                      // Next/Finish Button
                      if (_currentPage < _totalPages - 1)
                        ElevatedButton.icon(
                          onPressed: () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          icon: const Icon(Icons.arrow_forward, size: 18),
                          label: const Text('Next'),
                          iconAlignment: IconAlignment.end,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.9),
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        )
                      else
                        ElevatedButton.icon(
                          onPressed: _completeOnboarding,
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('Finish'),
                          iconAlignment: IconAlignment.end,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF007AFF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Step 1: Date of Birth
  // ─────────────────────────────────────────────
  Widget _buildDOBPage() {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildGlassCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/birthday-calender.svg',
                    width: 56,
                    height: 56,
                    colorFilter: const ColorFilter.mode(
                      Colors.black87,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'When\'s your birthday?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This helps us personalize your experience',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 28),

                  // iOS-style Date Picker Card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(13),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 60,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Selected date display
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedDOB != null
                                    ? '${_getMonthName(_selectedDOB!.month)} ${_selectedDOB!.day}, ${_selectedDOB!.year}'
                                    : 'Select Date',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                  letterSpacing: -0.408,
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: Color(0xFFFF3B30),
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        // Calendar (using Flutter's built-in)
                        SizedBox(
                          height: 300,
                          child: Theme(
                            data: ThemeData.light().copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: Color(0xFFFF3B30),
                                onPrimary: Colors.white,
                                surface: Colors.white,
                                onSurface: Colors.black,
                              ),
                            ),
                            child: CalendarDatePicker(
                              initialDate: _selectedDOB ?? DateTime(2000, 1, 1),
                              firstDate: DateTime(1940),
                              lastDate: DateTime.now(),
                              onDateChanged: (date) {
                                setState(() => _selectedDOB = date);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  if (!_hasSwipedOnce) _buildSwipeHint(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Step 2: Weight
  // ─────────────────────────────────────────────
  Widget _buildWeightPage() {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildGlassCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/weight-1.svg',
                    width: 56,
                    height: 56,
                    colorFilter: const ColorFilter.mode(
                      Colors.black87,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'What\'s your weight?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'We\'ll track your progress over time',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 36),

                  // Weight display
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _weight.toStringAsFixed(0),
                        style: const TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                          height: 1,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Text(
                          ' kg',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Slider
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: const Color(0xFF007AFF),
                      inactiveTrackColor: const Color(0x33787880),
                      thumbColor: Colors.white,
                      overlayColor: const Color(0xFF007AFF).withOpacity(0.1),
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 14,
                      ),
                    ),
                    child: Slider(
                      value: _weight,
                      min: 30,
                      max: 200,
                      onChanged: (v) => setState(() => _weight = v),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '30 kg',
                          style: TextStyle(color: Colors.black45, fontSize: 12),
                        ),
                        Text(
                          '200 kg',
                          style: TextStyle(color: Colors.black45, fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Step 3: Height
  // ─────────────────────────────────────────────
  Widget _buildHeightPage() {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildGlassCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/height.svg',
                    width: 56,
                    height: 56,
                    colorFilter: const ColorFilter.mode(
                      Colors.black87,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'How tall are you?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Helps calculate your fitness metrics',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 36),

                  // Height display
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _heightCm.toStringAsFixed(0),
                        style: const TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                          height: 1,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Text(
                          ' cm',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(_heightCm / 30.48).floor()}\'${((_heightCm / 2.54) % 12).round()}" ft',
                    style: const TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                  const SizedBox(height: 24),

                  // Slider
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: const Color(0xFF007AFF),
                      inactiveTrackColor: const Color(0x33787880),
                      thumbColor: Colors.white,
                      overlayColor: const Color(0xFF007AFF).withOpacity(0.1),
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 14,
                      ),
                    ),
                    child: Slider(
                      value: _heightCm,
                      min: 100,
                      max: 250,
                      onChanged: (v) => setState(() => _heightCm = v),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '100 cm',
                          style: TextStyle(color: Colors.black45, fontSize: 12),
                        ),
                        Text(
                          '250 cm',
                          style: TextStyle(color: Colors.black45, fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Step 4: Diet
  // ─────────────────────────────────────────────
  Widget _buildDietPage() {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildGlassCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/food-nutrition.svg',
                    width: 56,
                    height: 56,
                    colorFilter: const ColorFilter.mode(
                      Colors.black87,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Daily Nutrition',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'How much do you consume daily?',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 32),

                  // Protein
                  _buildNutrientInput(
                    label: 'Protein',
                    value: _dailyProtein,
                    unit: 'g/day',
                    min: 0,
                    max: 300,
                    color: const Color(0xFF4ECDC4),
                    icon: Icons.egg_outlined,
                    onChanged: (v) => setState(() => _dailyProtein = v),
                  ),
                  const SizedBox(height: 28),

                  // Carbs
                  _buildNutrientInput(
                    label: 'Carbs',
                    value: _dailyCarbs,
                    unit: 'g/day',
                    min: 0,
                    max: 500,
                    color: const Color(0xFFFF6B6B),
                    icon: Icons.grain,
                    onChanged: (v) => setState(() => _dailyCarbs = v),
                  ),

                  const SizedBox(height: 32),

                  // Divider
                  Container(
                    height: 1,
                    color: Colors.black12,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                  ),

                  const SizedBox(height: 24),

                  // Measure using diet button
                  GestureDetector(
                    onTap: _showDietInputDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF059669).withOpacity(0.8),
                            const Color(0xFF10B981).withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF34D399).withOpacity(0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF059669).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: const Color(0xFF10B981).withOpacity(0.2),
                            blurRadius: 40,
                            offset: const Offset(0, 16),
                            spreadRadius: -8,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.eco_outlined,
                            color: Color(0xFFD1FAE5),
                            size: 22,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Measure using your diet',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientInput({
    required String label,
    required double value,
    required String unit,
    required double min,
    required double max,
    required Color color,
    required IconData icon,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            Text(
              '${value.toStringAsFixed(0)} $unit',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: color,
            inactiveTrackColor: Colors.black12,
            thumbColor: Colors.white,
            overlayColor: color.withOpacity(0.1),
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
          ),
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  Step 5: Complete!
  // ─────────────────────────────────────────────
  Widget _buildCompletePage() {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildGlassCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Checkmark circle
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF007AFF),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF007AFF).withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'You\'re all set!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Your profile is ready.\nLet\'s start conquering!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Summary
                  if (_selectedDOB != null || _weight != 70 || _heightCm != 170)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          if (_selectedDOB != null)
                            _buildSummaryRow(
                              Icons.cake_outlined,
                              'Birthday',
                              '${_getMonthName(_selectedDOB!.month)} ${_selectedDOB!.day}, ${_selectedDOB!.year}',
                            ),
                          if (_weight != 70)
                            _buildSummaryRow(
                              Icons.monitor_weight_outlined,
                              'Weight',
                              '${_weight.toStringAsFixed(0)} kg',
                            ),
                          if (_heightCm != 170)
                            _buildSummaryRow(
                              Icons.height,
                              'Height',
                              '${_heightCm.toStringAsFixed(0)} cm',
                            ),
                          _buildSummaryRow(
                            Icons.egg_outlined,
                            'Protein',
                            '${_dailyProtein.toStringAsFixed(0)} g/day',
                          ),
                          _buildSummaryRow(
                            Icons.grain,
                            'Carbs',
                            '${_dailyCarbs.toStringAsFixed(0)} g/day',
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 28),

                  // Go to Dashboard button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xFF007AFF),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF007AFF).withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _completeOnboarding,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Go to Dashboard',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black54),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Shared Widgets
  // ─────────────────────────────────────────────
  Widget _buildGlassCard({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.black.withOpacity(0.05),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 30,
                  spreadRadius: 2,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeHint() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.swipe, size: 18, color: Colors.black45),
        SizedBox(width: 8),
        Text(
          'Swipe to continue',
          style: TextStyle(
            color: Colors.black45,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(width: 4),
        Icon(Icons.arrow_forward_ios, size: 12, color: Colors.black45),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}
