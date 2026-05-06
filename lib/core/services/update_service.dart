import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';

class UpdateService {
  UpdateService._();
  static final UpdateService _instance = UpdateService._();
  factory UpdateService() => _instance;

  /// Checks Google Play for an available update.
  /// - Priority >= 4  → immediate update (blocks app until updated)
  /// - Priority  < 4  → flexible update (downloads in background)
  /// Silently swallows any errors so the app always starts normally.
  Future<void> checkForUpdate() async {
    if (kIsWeb) return;

    try {
      final info = await InAppUpdate.checkForUpdate();

      if (info.updateAvailability != UpdateAvailability.updateAvailable) {
        return;
      }

      final priority = info.updatePriority;

      if (priority >= 4 && info.immediateUpdateAllowed) {
        // Critical update — show full-screen blocker
        await InAppUpdate.performImmediateUpdate();
      } else if (info.flexibleUpdateAllowed) {
        // Non-critical — download in background, complete on next restart
        await InAppUpdate.startFlexibleUpdate();
        await InAppUpdate.completeFlexibleUpdate();
      }
    } catch (e) {
      // In-app update is a Play Store feature; ignore errors on debug / side-loads
      debugPrint('[UpdateService] in_app_update error: $e');
    }
  }
}
