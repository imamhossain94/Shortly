import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants.dart';
import '../providers/shortener_provider.dart';
import '../dialogs/result_dialog.dart';

class ShortenerView extends ConsumerStatefulWidget {
  const ShortenerView({super.key});

  @override
  ConsumerState<ShortenerView> createState() => _ShortenerViewState();
}

class _ShortenerViewState extends ConsumerState<ShortenerView>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _urlController = TextEditingController();
  String _selectedProvider = AppConstants.tinyUrl;

  final List<String> _providers = [
    AppConstants.tinyUrl,
    AppConstants.chilpIt,
    AppConstants.clckRu,
    AppConstants.daGd,
    AppConstants.isGd,
    AppConstants.osdb,
    AppConstants.cuttLy,
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _handleShorten() {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter a URL")));
      return;
    }
    ref.read(shortenerProvider.notifier).shorten(_selectedProvider, url);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Listen for success state to show dialog
    ref.listen(shortenerProvider, (previous, next) {
      if (next.result != null && next.error == null && !next.isLoading) {
        showDialog(
          context: context,
          builder: (c) => ResultDialog(result: next.result!),
        ).then((_) {
          // Optional: clear result on close, or keep it.
          // keeping it allows user to interact again if they rotate?
          // But usually we want to reset for next op.
          // ref.read(shortenerProvider.notifier).clearResult();
          // _urlController.clear();
        });
      }
    });

    final state = ref.watch(shortenerProvider);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLandscape = constraints.maxWidth > 600;

          if (isLandscape) {
            return _buildLandscapeLayout(state);
          }
          return _buildPortraitLayout(state);
        },
      ),
    );
  }

  Widget _buildPortraitLayout(ShortenerState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          _buildHeader(),
          const SizedBox(height: 32),
          _buildInputs(),
          const SizedBox(height: 24),
          _buildButton(state),
          _buildError(state),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout(ShortenerState state) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  Text(
                    "Select a provider and enter your long URL to get started. Our service supports multiple providers for your convenience.",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 32),
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInputs(),
                  const SizedBox(height: 24),
                  _buildButton(state),
                  _buildError(state),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Shorten your link",
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ).animate().fadeIn().moveX(begin: -10, end: 0),
        const SizedBox(height: 8),
        Text(
          "Select a provider and enter your long URL below.",
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ).animate().fadeIn(delay: 200.ms),
      ],
    );
  }

  Widget _buildInputs() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: _selectedProvider,
          decoration: InputDecoration(
            labelText: "Provider",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.hub),
          ),
          items: _providers
              .map((p) => DropdownMenuItem(value: p, child: Text(p)))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedProvider = value);
            }
          },
        ).animate().fadeIn(delay: 300.ms),

        const SizedBox(height: 16),

        TextField(
          controller: _urlController,
          decoration: InputDecoration(
            labelText: "Long URL",
            hintText: "https://example.com",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.link),
            suffixIcon: IconButton(
              icon: const Icon(Icons.paste),
              onPressed: () async {
                final data = await Clipboard.getData('text/plain');
                if (data?.text != null) {
                  _urlController.text = data!.text!;
                }
              },
            ),
          ),
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _handleShorten(),
        ).animate().fadeIn(delay: 400.ms),
      ],
    );
  }

  Widget _buildButton(ShortenerState state) {
    return FilledButton.icon(
      onPressed: state.isLoading ? null : _handleShorten,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: state.isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.auto_fix_high),
      label: Text(state.isLoading ? "Shortening..." : "Shorten URL"),
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildError(ShortenerState state) {
    if (state.error != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  state.error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ],
          ),
        ).animate().shake(),
      );
    }
    return const SizedBox.shrink();
  }
}
