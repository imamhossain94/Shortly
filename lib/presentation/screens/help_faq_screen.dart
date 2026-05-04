import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../widgets/app_custom_bar.dart';

class HelpFaqScreen extends StatelessWidget {
  const HelpFaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final List<Map<String, String>> faqs = [
      {
        'q': 'How do I shorten a URL?',
        'a': 'Simply go to the Home tab, paste your long URL into the input field, select your preferred provider, and tap "Shorten Now".'
      },
      {
        'q': 'Are my links private?',
        'a': 'Yes, your link history is stored locally on your device. However, the shortened links themselves are public and handled by the respective providers.'
      },
      {
        'q': 'Why did URL expansion fail?',
        'a': 'Some links may be broken, expired, or point to services that block programmatic expansion to protect against scraping.'
      },
      {
        'q': 'What does "Shortly Pro" offer?',
        'a': 'Shortly Pro provides a completely ad-free experience, allowing you to shorten, verify, and manage your links without any interruptions.'
      },
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : Colors.white,
      body: Column(
        children: [
          const AppCustomBar(title: 'Help & FAQ'),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: faqs.length,
              itemBuilder: (context, index) {
                final faq = faqs[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.darkCardBorder : Colors.grey.shade200,
                    ),
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      iconColor: AppColors.accent,
                      collapsedIconColor: isDark ? AppColors.textSecondary : Colors.black54,
                      title: Text(
                        faq['q']!,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: isDark ? AppColors.textPrimary : Colors.black87,
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Text(
                            faq['a']!,
                            style: TextStyle(
                              color: isDark ? AppColors.textSecondary : Colors.black54,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
