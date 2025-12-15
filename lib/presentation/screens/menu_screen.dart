import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/theme_provider.dart';

class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(title: const Text("Menu")),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Appearance",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    child: Column(
                      children: [
                        RadioListTile<ThemeMode>(
                          title: const Text("System Default"),
                          secondary: const Icon(Icons.brightness_auto),
                          value: ThemeMode.system,
                          groupValue: themeMode,
                          onChanged: (val) =>
                              ref.read(themeProvider.notifier).setTheme(val!),
                        ),
                        RadioListTile<ThemeMode>(
                          title: const Text("Light Mode"),
                          secondary: const Icon(Icons.light_mode),
                          value: ThemeMode.light,
                          groupValue: themeMode,
                          onChanged: (val) =>
                              ref.read(themeProvider.notifier).setTheme(val!),
                        ),
                        RadioListTile<ThemeMode>(
                          title: const Text("Dark Mode"),
                          secondary: const Icon(Icons.dark_mode),
                          value: ThemeMode.dark,
                          groupValue: themeMode,
                          onChanged: (val) =>
                              ref.read(themeProvider.notifier).setTheme(val!),
                        ),
                      ],
                    ),
                  ).animate().fadeIn().slideY(begin: 0.1),

                  const SizedBox(height: 32),
                  Text(
                    "About",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    child: ListTile(
                      leading: const Icon(Icons.info),
                      title: const Text("Version"),
                      trailing: const Text("1.0.0"),
                    ),
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),

                  const SizedBox(height: 32),
                  Center(
                    child: Text(
                      "Made with ❤️ by Flutter",
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
