import 'package:flutter/material.dart';

import '../../app/navigation.dart';
import '../../app/routes.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

/// Notification preferences screen.
///
/// Allows the user to toggle various notification types.
class NotificationsScreen extends StatefulWidget {
  /// Creates a [NotificationsScreen].
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const Map<String, bool> _defaultPreferences = {
    'orderUpdates': true,
    'promotions': false,
    'newArrivals': false,
    'deliveryAlerts': true,
  };

  final AuthService _authService = AuthService();
  bool _orderUpdates = true;
  bool _promotions = false;
  bool _newArrivals = false;
  bool _deliveryAlerts = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final preferences = {
        ..._defaultPreferences,
        ...await _authService.getNotificationPreferences(),
      };
      if (!mounted) {
        return;
      }
      setState(() {
        _orderUpdates = preferences['orderUpdates'] ?? true;
        _promotions = preferences['promotions'] ?? false;
        _newArrivals = preferences['newArrivals'] ?? false;
        _deliveryAlerts = preferences['deliveryAlerts'] ?? true;
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

  Future<void> _updatePreference(String key, bool value) async {
    final previousState = _currentPreferences;
    setState(() {
      switch (key) {
        case 'orderUpdates':
          _orderUpdates = value;
          break;
        case 'promotions':
          _promotions = value;
          break;
        case 'newArrivals':
          _newArrivals = value;
          break;
        case 'deliveryAlerts':
          _deliveryAlerts = value;
          break;
      }
    });

    try {
      await _authService.updateNotificationPreferences(_currentPreferences);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _orderUpdates = previousState['orderUpdates'] ?? true;
        _promotions = previousState['promotions'] ?? false;
        _newArrivals = previousState['newArrivals'] ?? false;
        _deliveryAlerts = previousState['deliveryAlerts'] ?? true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save notification preferences.'),
        ),
      );
    }
  }

  Map<String, bool> get _currentPreferences => {
    'orderUpdates': _orderUpdates,
    'promotions': _promotions,
    'newArrivals': _newArrivals,
    'deliveryAlerts': _deliveryAlerts,
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
          'Notifications',
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
                _NotificationToggle(
                  title: 'Order Updates',
                  subtitle: 'Get notified about your order status',
                  value: _orderUpdates,
                  onChanged: (v) => _updatePreference('orderUpdates', v),
                  isDark: isDark,
                ),
                _NotificationToggle(
                  title: 'Promotions',
                  subtitle: 'Receive special offers and deals',
                  value: _promotions,
                  onChanged: (v) => _updatePreference('promotions', v),
                  isDark: isDark,
                ),
                _NotificationToggle(
                  title: 'New Arrivals',
                  subtitle: 'Know when new flowers are available',
                  value: _newArrivals,
                  onChanged: (v) => _updatePreference('newArrivals', v),
                  isDark: isDark,
                ),
                _NotificationToggle(
                  title: 'Delivery Alerts',
                  subtitle: 'Real-time delivery tracking updates',
                  value: _deliveryAlerts,
                  onChanged: (v) => _updatePreference('deliveryAlerts', v),
                  isDark: isDark,
                ),
              ],
            ),
    );
  }
}

class _NotificationToggle extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isDark;

  const _NotificationToggle({
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
