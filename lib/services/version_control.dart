import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VersionControl {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final Logger _logger;

  static const String _lastUpdateCheckKey = 'last_update_check';
  static const Duration _updateCheckInterval = Duration(seconds: 30);

  VersionControl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    Logger? logger,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _logger = logger ?? Logger();

  Future<Map<String, dynamic>> checkVersion() async {
    try {
      // Get current app version
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;

      // Check if we should perform version check
      if (!await _shouldCheckUpdate()) {
        return {'isSupported': true, 'requiresUpdate': false};
      }

      // Get version requirements from Firebase
      DocumentSnapshot versionDoc = await _firestore
          .collection('app_config')
          .doc('version_control')
          .get();

      if (!versionDoc.exists) {
        _logger.w('Version control document not found');
        return {'isSupported': true, 'requiresUpdate': false};
      }

      Map<String, dynamic> versionData =
          versionDoc.data() as Map<String, dynamic>;
      String minVersion = versionData['minimum_supported_version'];
      bool enforceUpdate = versionData['enforce_update'] ?? false;

      bool isSupported = _compareVersions(currentVersion, minVersion);

      // Update last check time
      await _updateLastCheckTime();

      if (!isSupported && enforceUpdate) {
        await _handleUnsupportedVersion();
      }

      return {
        'isSupported': isSupported,
        'requiresUpdate': !isSupported && enforceUpdate,
        'updateMessage': versionData['update_message'],
        'currentVersion': currentVersion,
        'minimumVersion': minVersion,
      };
    } catch (e) {
      _logger.e('Error checking version: $e');
      return {'isSupported': false, 'requiresUpdate': true};
    }
  }

  bool _compareVersions(String current, String minimum) {
    List<int> currentParts = current.split('.').map(int.parse).toList();
    List<int> minimumParts = minimum.split('.').map(int.parse).toList();

    for (int i = 0; i < currentParts.length && i < minimumParts.length; i++) {
      if (currentParts[i] < minimumParts[i]) return false;
      if (currentParts[i] > minimumParts[i]) return true;
    }
    return currentParts.length >= minimumParts.length;
  }

  Future<void> _handleUnsupportedVersion() async {
    try {
      // Sign out user
      await _auth.signOut();

      // Clear shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      _logger.i('User signed out due to unsupported version');
    } catch (e) {
      _logger.e('Error handling unsupported version: $e');
    }
  }

  Future<bool> _shouldCheckUpdate() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? lastCheck = prefs.getInt(_lastUpdateCheckKey);

      if (lastCheck == null) return true;

      DateTime lastCheckTime = DateTime.fromMillisecondsSinceEpoch(lastCheck);
      return DateTime.now().difference(lastCheckTime) > _updateCheckInterval;
    } catch (e) {
      _logger.e('Error checking update time: $e');
      return true;
    }
  }

  Future<void> _updateLastCheckTime() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
          _lastUpdateCheckKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      _logger.e('Error updating last check time: $e');
    }
  }
}
