import 'package:app_tracking_transparency/app_tracking_transparency.dart';

class AttService {
  bool _requestedThisSession = false;

  Future<void> requestIfNeeded() async {
    if (_requestedThisSession) return;

    try {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        _requestedThisSession = true;
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
    } catch (_) {
      // Best-effort; do not block app startup.
    }
  }
}

