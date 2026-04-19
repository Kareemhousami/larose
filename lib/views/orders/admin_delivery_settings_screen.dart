import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/delivery_settings.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/admin_delivery_settings_viewmodel.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/app_text_field.dart';

/// Admin screen for managing store location and delivery pricing settings.
class AdminDeliverySettingsScreen extends StatefulWidget {
  const AdminDeliverySettingsScreen({super.key});

  @override
  State<AdminDeliverySettingsScreen> createState() =>
      _AdminDeliverySettingsScreenState();
}

class _AdminDeliverySettingsScreenState
    extends State<AdminDeliverySettingsScreen> {
  final _storeLabelController = TextEditingController();
  final _storeLatController = TextEditingController();
  final _storeLngController = TextEditingController();
  final _fuelPriceController = TextEditingController();
  final _kmPerLiterController = TextEditingController();
  final _overheadController = TextEditingController();
  final _profitController = TextEditingController();
  final _minFeeController = TextEditingController();
  final _maxFeeController = TextEditingController();
  final _serviceMinutesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminDeliverySettingsViewModel>().load().then((_) {
        _populateFields();
      });
    });
  }

  void _populateFields() {
    final settings = context.read<AdminDeliverySettingsViewModel>().settings;
    if (settings == null) return;
    _storeLabelController.text = settings.storeLabel;
    _storeLatController.text =
        (settings.storeLocation['lat'] ?? '').toString();
    _storeLngController.text =
        (settings.storeLocation['lng'] ?? '').toString();
    _fuelPriceController.text =
        settings.fallbackFuelPricePerLiter.toString();
    _kmPerLiterController.text =
        settings.avgKilometersPerLiter.toString();
    _overheadController.text =
        settings.operationalOverheadUsd.toString();
    _profitController.text = settings.profitMarginPercent.toString();
    _minFeeController.text = settings.minimumDeliveryFeeUsd.toString();
    _maxFeeController.text = settings.maximumDeliveryFeeUsd.toString();
    _serviceMinutesController.text =
        settings.serviceMinutesPerStop.toString();
  }

  Future<void> _saveSettings() async {
    final settings = DeliverySettings(
      storeLabel: _storeLabelController.text.trim(),
      storeLocation: {
        'lat': double.tryParse(_storeLatController.text) ?? 0,
        'lng': double.tryParse(_storeLngController.text) ?? 0,
      },
      fallbackFuelPricePerLiter:
          double.tryParse(_fuelPriceController.text) ?? 0,
      avgKilometersPerLiter:
          double.tryParse(_kmPerLiterController.text) ?? 0,
      operationalOverheadUsd:
          double.tryParse(_overheadController.text) ?? 0,
      profitMarginPercent:
          double.tryParse(_profitController.text) ?? 0,
      minimumDeliveryFeeUsd:
          double.tryParse(_minFeeController.text) ?? 0,
      maximumDeliveryFeeUsd:
          double.tryParse(_maxFeeController.text) ?? 0,
      serviceMinutesPerStop:
          int.tryParse(_serviceMinutesController.text) ?? 0,
    );
    await context.read<AdminDeliverySettingsViewModel>().save(settings);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Delivery settings saved')),
      );
    }
  }

  @override
  void dispose() {
    _storeLabelController.dispose();
    _storeLatController.dispose();
    _storeLngController.dispose();
    _fuelPriceController.dispose();
    _kmPerLiterController.dispose();
    _overheadController.dispose();
    _profitController.dispose();
    _minFeeController.dispose();
    _maxFeeController.dispose();
    _serviceMinutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final viewModel = context.watch<AdminDeliverySettingsViewModel>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            (isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight)
                .withValues(alpha: 0.8),
        title: Text(
          'Delivery Settings',
          style: AppTheme.sectionHeader(
            color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: viewModel.isLoading && viewModel.settings == null
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.paddingHorizontal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Store Location',
                    style: AppTheme.sectionHeader(
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _storeLabelController,
                    hintText: 'Store Label',
                    prefixIcon: Icons.store_outlined,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _storeLatController,
                          hintText: 'Latitude',
                          prefixIcon: Icons.location_on_outlined,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          controller: _storeLngController,
                          hintText: 'Longitude',
                          prefixIcon: Icons.location_on_outlined,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Pricing Controls',
                    style: AppTheme.sectionHeader(
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _fuelPriceController,
                    hintText: 'Fallback Fuel Price (\$/L)',
                    prefixIcon: Icons.local_gas_station_outlined,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _kmPerLiterController,
                    hintText: 'Avg km/L',
                    prefixIcon: Icons.speed_outlined,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _overheadController,
                    hintText: 'Overhead (\$)',
                    prefixIcon: Icons.attach_money_outlined,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _profitController,
                    hintText: 'Profit Margin (%)',
                    prefixIcon: Icons.trending_up_outlined,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _minFeeController,
                          hintText: 'Min Fee (\$)',
                          prefixIcon: Icons.arrow_downward_outlined,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          controller: _maxFeeController,
                          hintText: 'Max Fee (\$)',
                          prefixIcon: Icons.arrow_upward_outlined,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _serviceMinutesController,
                    hintText: 'Service Minutes/Stop',
                    prefixIcon: Icons.timer_outlined,
                    keyboardType: TextInputType.number,
                  ),
                  if (viewModel.error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      viewModel.error!,
                      style: AppTheme.bodyText(color: Colors.redAccent),
                    ),
                  ],
                  const SizedBox(height: 32),
                  PrimaryButton(
                    text: 'Save Delivery Settings',
                    isLoading: viewModel.isLoading,
                    onPressed: _saveSettings,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}
