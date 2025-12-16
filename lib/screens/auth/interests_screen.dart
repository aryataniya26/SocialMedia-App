import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../config/routes.dart';

class InterestsScreen extends StatefulWidget {
  const InterestsScreen({super.key});

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  final List<Map<String, dynamic>> _interests = [
    {'icon': '👗', 'name': 'Fashion'},
    {'icon': '🍔', 'name': 'Food'},
    {'icon': '🎬', 'name': 'Pop culture'},
    {'icon': '🎵', 'name': 'Musicals'},
    {'icon': '📚', 'name': 'Reading'},
    {'icon': '📹', 'name': 'Vlogging'},
    {'icon': '🏃', 'name': 'Adventure'},
    {'icon': '🌲', 'name': 'Nature'},
    {'icon': '💃', 'name': 'Dance'},
    {'icon': '🚗', 'name': 'Automobile'},
    {'icon': '🎮', 'name': 'E-sports'},
    {'icon': '🔥', 'name': 'Other'},
  ];

  final Set<String> _selectedInterests = {};

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else {
        _selectedInterests.add(interest);
      }
    });
  }

  Future<void> _handleDone() async {
    // TODO: Save interests to backend
    Navigator.pushReplacementNamed(context, AppRoutes.bottomNav);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Title
              const Text(
                'Tell us what you like!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),
              // Interests Grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: _interests.length,
                  itemBuilder: (context, index) {
                    final interest = _interests[index];
                    final isSelected = _selectedInterests.contains(interest['name']);

                    return GestureDetector(
                      onTap: () => _toggleInterest(interest['name']),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.1)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              interest['icon'],
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              interest['name'],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              // Skip Button
              TextButton(
                onPressed: _handleDone,
                child: const Text(
                  'Skip for now',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Done Button
              CustomButton(
                text: 'Done',
                onPressed: _handleDone,
              ),
            ],
          ),
        ),
      ),
    );
  }
}