import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:share_plus/share_plus.dart';

class SuccessPage extends StatelessWidget {
  final String name;
  final String amount;

  const SuccessPage({super.key, required this.name, required this.amount});

  void _shareSuccess() {
    Share.share(
      'I just donated ₹$amount to support a noble cause! Join me in making a difference. #CharityApp #GivingBack',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Success Animation Container
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 80,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Thank You Text
                      Text(
                        'Thank You!',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.text,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Donor Name
                      Text(
                        name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Success Message
                      Text(
                        'Your donation has been successfully processed',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textLight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      // Amount Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: AppDecorations.cardDecoration.copyWith(
                          color: AppColors.primary.withOpacity(0.1),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Donation Amount',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.textLight,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '₹$amount',
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Impact Message
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: AppDecorations.cardDecoration,
                        child: Column(
                          children: [
                            const Icon(
                              Icons.volunteer_activism,
                              color: AppColors.accent,
                              size: 32,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Your generosity makes a real difference',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.text,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Your contribution will help support those in need and create positive change in our community.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textLight,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Share Button
                      OutlinedButton.icon(
                        onPressed: _shareSuccess,
                        icon: const Icon(Icons.share),
                        label: const Text('Share Your Impact'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Bottom Buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Make Another Donation'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/home',
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Back to Home'),
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
}
