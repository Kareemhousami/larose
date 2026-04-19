import 'package:flutter/material.dart';

import '../../app/navigation.dart';
import '../../app/routes.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

/// Privacy and security settings screen.
///
/// Allows the user to manage biometrics, two-factor auth, and data preferences.
class PrivacySecurityScreen extends StatefulWidget {
  /// Creates a [PrivacySecurityScreen].
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  static const Map<String, bool> _defaultSettings = {
    'biometrics': false,
    'twoFactor': false,
    'analytics': true,
  };

  final AuthService _authService = AuthService();
  bool _biometrics = false;
  bool _twoFactor = false;
  bool _analytics = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = {
        ..._defaultSettings,
        ...await _authService.getPrivacySettings(),
      };
      if (!mounted) {
        return;
      }
      setState(() {
        _biometrics = settings['biometrics'] ?? false;
        _twoFactor = settings['twoFactor'] ?? false;
        _analytics = settings['analytics'] ?? true;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateSetting(String key, bool value) async {
    final previousState = _currentSettings;
    setState(() {
      switch (key) {
        case 'biometrics':
          _biometrics = value;
          break;
        case 'twoFactor':
          _twoFactor = value;
          break;
        case 'analytics':
          _analytics = value;
          break;
      }
    });

    try {
      await _authService.updatePrivacySettings(_currentSettings);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _biometrics = previousState['biometrics'] ?? false;
        _twoFactor = previousState['twoFactor'] ?? false;
        _analytics = previousState['analytics'] ?? true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to save privacy settings.')),
      );
    }
  }

  Map<String, bool> get _currentSettings => {
    'biometrics': _biometrics,
    'twoFactor': _twoFactor,
    'analytics': _analytics,
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            (isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight)
                .withValues(alpha: 0.8),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
          ),
          onPressed: () => popOrGoTo(context, Routes.profile),
        ),
        title: Text(
          'Privacy & Security',
          style: AppTheme.sectionHeader(
            color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.primary10),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            )
          : ListView(
              padding: const EdgeInsets.all(AppTheme.paddingHorizontal),
              children: [
                const SizedBox(height: 16),
                Text(
                  'Biometric login and two-factor authentication are saved as preferences only for now.',
                  style: AppTheme.bodyText(color: AppTheme.textMuted),
                ),
                const SizedBox(height: 16),
                _SecurityToggle(
                  icon: Icons.fingerprint,
                  title: 'Biometric Login',
                  subtitle: 'Use fingerprint or face to sign in',
                  value: _biometrics,
                  onChanged: (v) => _updateSetting('biometrics', v),
                  isDark: isDark,
                ),
                _SecurityToggle(
                  icon: Icons.security,
                  title: 'Two-Factor Authentication',
                  subtitle: 'Add an extra layer of security',
                  value: _twoFactor,
                  onChanged: (v) => _updateSetting('twoFactor', v),
                  isDark: isDark,
                ),
                _SecurityToggle(
                  icon: Icons.analytics_outlined,
                  title: 'Usage Analytics',
                  subtitle: 'Help us improve your experience',
                  value: _analytics,
                  onChanged: (v) => _updateSetting('analytics', v),
                  isDark: isDark,
                ),
              ],
            ),
    );
  }
}

class _SecurityToggle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isDark;

  const _SecurityToggle({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.primary5)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primary10,
              borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.productCardTitle(
                    color: isDark
                        ? AppTheme.textPrimaryDark
                        : AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: AppTheme.productCardSubtitle()),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.primary,
          ),
        ],
      ),
    );
  }
}
