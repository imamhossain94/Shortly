import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/services/ad_service.dart';
import '../providers/provider_keys_provider.dart';

class ProviderConfigScreen extends ConsumerStatefulWidget {
  const ProviderConfigScreen({super.key});

  @override
  ConsumerState<ProviderConfigScreen> createState() => _ProviderConfigScreenState();
}

class _ProviderConfigScreenState extends ConsumerState<ProviderConfigScreen> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _obscureText = {
    AppConstants.tinyUrl: true,
    AppConstants.cuttLy: true,
    AppConstants.bitLy: true,
  };
  final Map<String, bool> _isExpanded = {
    AppConstants.tinyUrl: false,
    AppConstants.cuttLy: false,
    AppConstants.bitLy: false,
  };

  @override
  void initState() {
    super.initState();
    final config = ref.read(providerKeysProvider);
    _controllers[AppConstants.tinyUrl] = TextEditingController(text: config.tinyUrlToken);
    _controllers[AppConstants.cuttLy] = TextEditingController(text: config.cuttLyKey);
    _controllers[AppConstants.bitLy] = TextEditingController(text: config.bitLyToken);
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _launchUrlHelper(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      AdService().suppressNextAppOpenAd();
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final config = ref.watch(providerKeysProvider);

    final allProviders = [
      AppConstants.isGd,
      AppConstants.tinyUrl,
      AppConstants.cuttLy,
      AppConstants.bitLy,
      AppConstants.cleanUri,
      AppConstants.clckRu,
      AppConstants.daGd,
      AppConstants.osdb,
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : Colors.grey.shade50,
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Configure ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const TextSpan(
                text: 'Providers',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: isDark ? AppColors.darkBg : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: isDark ? AppColors.textPrimary : Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          physics: const BouncingScrollPhysics(),
          itemCount: allProviders.length,
          itemBuilder: (context, index) {
            final provider = allProviders[index];
            final isDefault = config.defaultProvider == provider;
            
            // Check config state
            String statusLabel = 'Available';
            Color statusColor = Colors.green;
            IconData statusIcon = Icons.check_circle_outline_rounded;

            if (provider == AppConstants.tinyUrl) {
              if (config.tinyUrlToken.isNotEmpty) {
                statusLabel = 'Active (Custom Key)';
                statusColor = AppColors.accent;
                statusIcon = Icons.vpn_key_rounded;
              } else {
                statusLabel = 'Active (Legacy/Preview)';
                statusColor = Colors.amber;
                statusIcon = Icons.warning_amber_rounded;
              }
            } else if (provider == AppConstants.cuttLy) {
              if (config.cuttLyKey.isNotEmpty) {
                statusLabel = 'Active (Custom Key)';
                statusColor = AppColors.accent;
                statusIcon = Icons.vpn_key_rounded;
              } else {
                statusLabel = 'Active (Built-in Key)';
                statusColor = Colors.green;
                statusIcon = Icons.verified_rounded;
              }
            } else if (provider == AppConstants.bitLy) {
              if (config.bitLyToken.isNotEmpty) {
                statusLabel = 'Active (Custom Key)';
                statusColor = AppColors.accent;
                statusIcon = Icons.vpn_key_rounded;
              } else {
                statusLabel = 'Not Configured';
                statusColor = Colors.red;
                statusIcon = Icons.error_outline_rounded;
              }
            }

            final isPremiumProvider = provider == AppConstants.tinyUrl ||
                provider == AppConstants.cuttLy ||
                provider == AppConstants.bitLy;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDefault
                      ? AppColors.accent.withValues(alpha: 0.6)
                      : (isDark ? AppColors.darkCardBorder : Colors.grey.shade200),
                  width: isDefault ? 2.0 : 1.5,
                ),
                boxShadow: isDefault
                    ? [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  children: [
                    // Main Header Row
                    InkWell(
                      onTap: () {
                        if (isPremiumProvider) {
                          setState(() {
                            _isExpanded[provider] = !(_isExpanded[provider] ?? false);
                          });
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Favicon Letter/Icon Fallback
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: _colorFromProvider(provider).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  provider[0].toUpperCase(),
                                  style: TextStyle(
                                    color: _colorFromProvider(provider),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Provider Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        provider,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? AppColors.textPrimary : Colors.black87,
                                        ),
                                      ),
                                      if (isDefault) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppColors.accent.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: const Text(
                                            'Default',
                                            style: TextStyle(
                                              color: AppColors.accent,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(statusIcon, color: statusColor, size: 13),
                                      const SizedBox(width: 4),
                                      Text(
                                        statusLabel,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: statusColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Star Default Switch & Expand Chevron
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    ref.read(providerKeysProvider.notifier).setDefaultProvider(provider);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('$provider set as default provider!'),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isDefault
                                          ? AppColors.accent.withValues(alpha: 0.15)
                                          : Colors.transparent,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isDefault
                                          ? Icons.check_circle_rounded
                                          : Icons.radio_button_unchecked_rounded,
                                      color: isDefault ? AppColors.accent : AppColors.textMuted,
                                      size: 22,
                                    ),
                                  ),
                                ),
                                if (isPremiumProvider) ...[
                                  const SizedBox(width: 6),
                                  Icon(
                                    _isExpanded[provider] == true
                                        ? Icons.expand_less_rounded
                                        : Icons.expand_more_rounded,
                                    color: AppColors.textMuted,
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Expandable API Settings Panel
                    if (isPremiumProvider && _isExpanded[provider] == true)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark 
                              ? Colors.black.withValues(alpha: 0.12)
                              : Colors.grey.shade50,
                          border: Border(
                            top: BorderSide(
                              color: isDark ? AppColors.darkCardBorder : Colors.grey.shade100,
                            ),
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Key Field Input Label
                            Text(
                              provider == AppConstants.bitLy ? 'Access Token' : 'API Key',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.textSecondary : Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Text Input Field — redesigned card-style box
                            Container(
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkCard
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.darkCardBorder
                                      : Colors.grey.shade200,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(10, 8, 0, 8),
                                    padding: const EdgeInsets.all(9),
                                    decoration: BoxDecoration(
                                      color: AppColors.accent
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.vpn_key_rounded,
                                      size: 16,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      controller: _controllers[provider],
                                      obscureText:
                                          _obscureText[provider] ?? true,
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        color: isDark
                                            ? AppColors.textPrimary
                                            : Colors.black87,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: provider ==
                                                AppConstants.tinyUrl
                                            ? 'Enter TinyURL API token...'
                                            : provider == AppConstants.cuttLy
                                                ? 'Enter Cutt.ly API key...'
                                                : 'Enter Bitly access token...',
                                        hintStyle: const TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 13.5,
                                        ),
                                        isDense: true,
                                        filled: false,
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 16),
                                      ),
                                    ),
                                  ),
                                  _KeyActionButton(
                                    icon: _obscureText[provider] == true
                                        ? Icons.visibility_rounded
                                        : Icons.visibility_off_rounded,
                                    onTap: () {
                                      setState(() {
                                        _obscureText[provider] =
                                            !(_obscureText[provider] ?? true);
                                      });
                                    },
                                  ),
                                  _KeyActionButton(
                                    icon: Icons.content_paste_rounded,
                                    onTap: () async {
                                      final clipData = await Clipboard.getData(
                                          'text/plain');
                                      if (clipData?.text != null) {
                                        _controllers[provider]!.text =
                                            clipData!.text!;
                                      }
                                    },
                                  ),
                                  _KeyActionButton(
                                    icon: Icons.clear_rounded,
                                    onTap: () =>
                                        _controllers[provider]!.clear(),
                                  ),
                                  const SizedBox(width: 6),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            // Action Buttons (Save & Delete)
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      final val = _controllers[provider]!.text;
                                      if (provider == AppConstants.tinyUrl) {
                                        ref.read(providerKeysProvider.notifier).setTinyUrlToken(val);
                                      } else if (provider == AppConstants.cuttLy) {
                                        ref.read(providerKeysProvider.notifier).setCuttLyKey(val);
                                      } else if (provider == AppConstants.bitLy) {
                                        ref.read(providerKeysProvider.notifier).setBitLyToken(val);
                                      }
                                      FocusScope.of(context).unfocus();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('$provider credentials saved!')),
                                      );
                                    },
                                    icon: const Icon(Icons.save_rounded, size: 16, color: Colors.white),
                                    label: const Text(
                                      'Save Credentials',
                                      style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.accent,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                                if ((provider == AppConstants.tinyUrl && config.tinyUrlToken.isNotEmpty) ||
                                    (provider == AppConstants.cuttLy && config.cuttLyKey.isNotEmpty) ||
                                    (provider == AppConstants.bitLy && config.bitLyToken.isNotEmpty)) ...[
                                  const SizedBox(width: 10),
                                  IconButton.filled(
                                    onPressed: () {
                                      _controllers[provider]!.clear();
                                      if (provider == AppConstants.tinyUrl) {
                                        ref.read(providerKeysProvider.notifier).setTinyUrlToken('');
                                      } else if (provider == AppConstants.cuttLy) {
                                        ref.read(providerKeysProvider.notifier).setCuttLyKey('');
                                      } else if (provider == AppConstants.bitLy) {
                                        ref.read(providerKeysProvider.notifier).setBitLyToken('');
                                      }
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('$provider custom credentials removed.')),
                                      );
                                    },
                                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.red.withValues(alpha: 0.12),
                                      padding: const EdgeInsets.all(14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Collapsible Instructions Accordion
                            _InstructionsAccordion(
                              provider: provider,
                              isDark: isDark,
                              onLaunchUrl: _launchUrlHelper,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Color _colorFromProvider(String provider) {
    if (provider == AppConstants.tinyUrl) return const Color(0xFF1E88E5);
    if (provider == AppConstants.cuttLy) return const Color(0xFF007A87);
    if (provider == AppConstants.bitLy) return const Color(0xFFEE6123);
    if (provider == AppConstants.isGd) return const Color(0xFF43A047);
    if (provider == AppConstants.cleanUri) return const Color(0xFF8E24AA);
    if (provider == AppConstants.clckRu) return const Color(0xFFE53935);
    if (provider == AppConstants.daGd) return const Color(0xFF00ACC1);
    return const Color(0xFF5E35B1);
  }
}

/// Compact icon action used inside the redesigned API-key input box.
class _KeyActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _KeyActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 18, color: AppColors.textMuted),
      ),
    );
  }
}

class _InstructionsAccordion extends StatefulWidget {
  final String provider;
  final bool isDark;
  final Function(String) onLaunchUrl;

  const _InstructionsAccordion({
    required this.provider,
    required this.isDark,
    required this.onLaunchUrl,
  });

  @override
  State<_InstructionsAccordion> createState() => _InstructionsAccordionState();
}

class _InstructionsAccordionState extends State<_InstructionsAccordion> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.isDark 
            ? AppColors.darkSurface.withValues(alpha: 0.5)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isDark ? AppColors.darkCardBorder : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.help_outline_rounded,
                        size: 16,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'How to get a free API key?',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: widget.isDark ? AppColors.textPrimary : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    _expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1, thickness: 1),
                  const SizedBox(height: 12),
                  ..._buildSteps(context),
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildSteps(BuildContext context) {
    if (widget.provider == AppConstants.tinyUrl) {
      return [
        _buildStepItem('1', 'Sign up/Login to a free account at ', 'tinyurl.com', 'https://tinyurl.com'),
        _buildStepItem('2', 'Navigate to ', 'tinyurl.com/app/dev', 'https://tinyurl.com/app/dev'),
        _buildStepItem('3', 'Generate a new API token inside API Settings.', '', ''),
        _buildStepItem('4', 'Copy the token and paste it in the field above to get preview-free direct redirects!', '', ''),
      ];
    } else if (widget.provider == AppConstants.cuttLy) {
      return [
        _buildStepItem('1', 'Register a free account at ', 'cutt.ly', 'https://cutt.ly'),
        _buildStepItem('2', 'Open your Profile / Account Settings dashboard.', '', ''),
        _buildStepItem('3', 'Locate the plain text API Key block.', '', ''),
        _buildStepItem('4', 'Copy and paste it here to save it under your personal quotas!', '', ''),
      ];
    } else {
      return [
        _buildStepItem('1', 'Register/Login at ', 'bitly.com', 'https://bitly.com'),
        _buildStepItem('2', 'Go to Profile Settings > Generic Access Token.', '', ''),
        _buildStepItem('3', 'Verify your password to generate a secure generic access token.', '', ''),
        _buildStepItem('4', 'Copy that token and paste it here. Bit.ly requires a valid token to function.', '', ''),
      ];
    }
  }

  Widget _buildStepItem(String number, String prefixText, String linkText, String linkUrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18,
            height: 18,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.4,
                  color: widget.isDark ? AppColors.textSecondary : Colors.black54,
                ),
                children: [
                  TextSpan(text: prefixText),
                  if (linkText.isNotEmpty)
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: GestureDetector(
                        onTap: () => widget.onLaunchUrl(linkUrl),
                        child: Text(
                          linkText,
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                          ),
                        ),
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
