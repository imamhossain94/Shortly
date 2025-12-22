import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_shortly/l10n/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';

class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(AppLocalizations.of(context)!.settings),
          ),
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
                          title: Text(AppLocalizations.of(context)!.system),
                          secondary: const Icon(Icons.brightness_auto),
                          value: ThemeMode.system,
                          groupValue: themeMode,
                          onChanged: (val) =>
                              ref.read(themeProvider.notifier).setTheme(val!),
                        ),
                        RadioListTile<ThemeMode>(
                          title: Text(AppLocalizations.of(context)!.light),
                          secondary: const Icon(Icons.light_mode),
                          value: ThemeMode.light,
                          groupValue: themeMode,
                          onChanged: (val) =>
                              ref.read(themeProvider.notifier).setTheme(val!),
                        ),
                        RadioListTile<ThemeMode>(
                          title: Text(AppLocalizations.of(context)!.dark),
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
                    AppLocalizations.of(context)!.options,
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
                        ListTile(
                          leading: const Icon(Icons.language),
                          title: const Text("Language"),
                          subtitle: Text(
                            Localizations.localeOf(context).languageCode == 'en'
                                ? "English"
                                : "Español",
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => SimpleDialog(
                                title: const Text("Select Language"),
                                children: [
                                  SimpleDialogOption(
                                    onPressed: () {
                                      ref
                                          .read(localeProvider.notifier)
                                          .setLocale(const Locale('en'));
                                      Navigator.pop(context);
                                    },
                                    child: const Text("English"),
                                  ),
                                  SimpleDialogOption(
                                    onPressed: () {
                                      ref
                                          .read(localeProvider.notifier)
                                          .setLocale(const Locale('es'));
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Español"),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.feedback_outlined),
                          title: const Text("Feedback"),
                          onTap: () async {
                            final Uri emailLaunchUri = Uri(
                              scheme: 'mailto',
                              path: 'feedback@shortly.app',
                              query: 'subject=Sortly App Feedback',
                            );
                            if (await canLaunchUrl(emailLaunchUri)) {
                              launchUrl(emailLaunchUri);
                            }
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.share),
                          title: Text(AppLocalizations.of(context)!.share),
                          onTap: () {
                            Share.share(
                              "Check out Shortly, the best URL shortener app!",
                            );
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.star_rate_rounded),
                          title: const Text("Rate App"),
                          onTap: () async {
                            final Uri url = Uri.parse(
                              "market://details?id=com.example.shortly",
                            );
                            if (await canLaunchUrl(url)) {
                              launchUrl(url);
                            } else {
                              final webUrl = Uri.parse(
                                "https://play.google.com/store/apps/details?id=com.example.shortly",
                              );
                              if (await canLaunchUrl(webUrl)) {
                                launchUrl(
                                  webUrl,
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            }
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.apps),
                          title: const Text("Other Apps"),
                          onTap: () async {
                            final Uri url = Uri.parse(
                              "https://play.google.com/store/apps/developer?id=ExampleDeveloper",
                            );
                            if (await canLaunchUrl(url)) {
                              launchUrl(
                                url,
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.privacy_tip_outlined),
                          title: const Text("Privacy Policy"),
                          onTap: () async {
                            final Uri url = Uri.parse(
                              "https://example.com/privacy",
                            );
                            if (await canLaunchUrl(url)) {
                              launchUrl(
                                url,
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

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
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

                  const SizedBox(height: 32),
                  Center(
                    child: Text(
                      "Made with ❤️ by Flutter",
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
