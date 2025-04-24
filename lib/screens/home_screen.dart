import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import 'donation_page.dart';
import 'fund_detail_screen.dart';
import '../widgets/fund_card.dart';
import '../main.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Stream<QuerySnapshot> getCausesStream() {
    return FirebaseFirestore.instance.collection('causes').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Make a Difference',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              themeNotifier.value = themeNotifier.value == ThemeMode.light
                  ? ThemeMode.dark
                  : ThemeMode.light;
            },
            tooltip: "Toggle Theme",
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Profile button clicked")),
              );
            },
            tooltip: "Profile",
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: AppColors.primary,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 35,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Welcome!',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Make a difference today',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: const Icon(Icons.home_outlined, color: AppColors.primary),
                    title: const Text('Home'),
                    onTap: () => Navigator.pop(context),
                  ),
                  ListTile(
                    leading: const Icon(Icons.favorite_outline, color: AppColors.primary),
                    title: const Text('My Donations'),
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navigate to donations history
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings_outlined, color: AppColors.primary),
                    title: const Text('Settings'),
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navigate to settings
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: AppColors.error),
                    title: const Text('Logout'),
                    onTap: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/',
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getCausesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading causes',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      // Trigger a rebuild to retry
                      (context as Element).markNeedsBuild();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final causeDocs = snapshot.data!.docs;

          if (causeDocs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.volunteer_activism,
                    color: AppColors.primary,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No causes available yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check back later for new opportunities to help',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Featured Causes',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.text,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Support these worthy causes and make a real impact',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final data = causeDocs[index].data() as Map<String, dynamic>;
                      final title = data['title'] ?? 'No title';
                      final description = data['description'] ?? 'No description';
                      final imageUrl = data['imageUrl'];
                      final targetAmount = data['targetAmount']?.toString() ?? '0';
                      final raisedAmount = data['raisedAmount']?.toString() ?? '0';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: FundCard(
                          title: title,
                          description: description,
                          imageUrl: imageUrl,
                          targetAmount: targetAmount,
                          raisedAmount: raisedAmount,
                          onDonate: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DonationPage(causeTitle: title),
                              ),
                            );
                          },
                          onDetails: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FundDetailScreen(
                                  title: title,
                                  description: description,
                                  imageUrl: imageUrl,
                                  targetAmount: targetAmount,
                                  raisedAmount: raisedAmount,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    childCount: causeDocs.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Implement quick donate feature
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Quick donate feature coming soon!')),
          );
        },
        icon: const Icon(Icons.favorite),
        label: const Text('Quick Donate'),
        backgroundColor: AppColors.accent,
      ),
    );
  }
}
