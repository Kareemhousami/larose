import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../app/navigation.dart';
import '../../app/routes.dart';
import '../../config/maps_config.dart';
import '../../models/address.dart';
import '../../services/device_location_service.dart';
import '../../services/google_places_service.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/address_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/address_location_picker.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/app_text_field.dart';

/// Screen for adding or editing a shipping address.
///
/// Pass an [Address] as route argument to edit an existing address.
class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({
    super.key,
    this.deviceLocationService,
    this.googlePlacesService,
    this.locationPickerOverride,
  });

  final DeviceLocationService? deviceLocationService;
  final GooglePlacesService? googlePlacesService;
  final Widget? locationPickerOverride;

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _phoneController = TextEditingController();
  final _deliveryNoteController = TextEditingController();

  late final DeviceLocationService _deviceLocationService;
  late final GooglePlacesService _googlePlacesService;

  Address? _editingAddress;
  bool _didInit = false;
  LatLng? _selectedLocation;
  String? _selectedLocationLabel;
  String _locationSource = '';
  String? _statusMessage;
  bool _isResolvingLocation = false;

  @override
  void initState() {
    super.initState();
    _deviceLocationService =
        widget.deviceLocationService ?? DeviceLocationService();
    _googlePlacesService = widget.googlePlacesService ?? GooglePlacesService();
    _phoneController.addListener(_onFormChanged);
    _deliveryNoteController.addListener(_onFormChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInit) return;
    _didInit = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Address) {
      _editingAddress = args;
      _phoneController.text = args.phone;
      _deliveryNoteController.text = args.deliveryNote;
      final lat = (args.location['lat'] as num?)?.toDouble();
      final lng = (args.location['lng'] as num?)?.toDouble();
      if (lat != null && lng != null) {
        _selectedLocation = LatLng(lat, lng);
      }
      _selectedLocationLabel = args.locationLabel;
      _locationSource = args.locationSource;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _deliveryNoteController.dispose();
    super.dispose();
  }

  String get _mapsApiKey => MapsConfig.apiKey;

  bool get _canSave =>
      _selectedLocation != null &&
      _phoneController.text.trim().isNotEmpty &&
      _deliveryNoteController.text.trim().isNotEmpty &&
      !_isResolvingLocation;

  String _fallbackLocationLabel(LatLng location, String source) {
    return source == 'current_location'
        ? 'Current location in Lebanon'
        : 'Pinned location in Lebanon';
  }

  Future<void> _saveAddress() async {
    if (!_canSave) {
      return;
    }
    final authVm = context.read<AuthViewModel>();
    final user = authVm.user;
    if (user == null) {
      return;
    }
    final addressVm = context.read<AddressViewModel>();
    await addressVm.saveAddress(
      Address(
        id: _editingAddress?.id ?? '',
        fullName: user.fullName,
        phone: _phoneController.text.trim(),
        line1: _selectedLocationLabel ?? 'Pinned location in Lebanon',
        city: 'Lebanon',
        postalCode: '',
        country: 'Lebanon',
        deliveryNote: _deliveryNoteController.text.trim(),
        locationLabel: _selectedLocationLabel ?? 'Pinned location in Lebanon',
        locationSource: _locationSource.isEmpty ? 'pin' : _locationSource,
        location: {
          'lat': _selectedLocation!.latitude,
          'lng': _selectedLocation!.longitude,
        },
        isDefault: _editingAddress?.isDefault ?? addressVm.addresses.isEmpty,
      ),
    );
    if (!mounted) {
      return;
    }
    popOrGoTo(context, Routes.addresses);
  }

  bool get _isEditing => _editingAddress != null;

  void _onFormChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _handleUseCurrentLocation() async {
    try {
      final location = await _deviceLocationService.getCurrentLocation();
      final lat = location['lat'];
      final lng = location['lng'];
      if (lat == null || lng == null) {
        return;
      }
      await _setSelectedLocation(LatLng(lat, lng), source: 'current_location');
    } on LocationServiceException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _statusMessage = e.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _statusMessage = 'Unable to get your current location right now.';
      });
    }
  }

  Future<void> _setSelectedLocation(
    LatLng location, {
    required String source,
  }) async {
    setState(() {
      _selectedLocation = location;
      _locationSource = source;
      _isResolvingLocation = true;
      _statusMessage = 'Resolving the selected location in Lebanon...';
    });

    String label = _fallbackLocationLabel(location, source);
    if (_mapsApiKey.isNotEmpty) {
      try {
        final resolvedLabel = await _googlePlacesService.reverseGeocode(
          location.latitude,
          location.longitude,
          _mapsApiKey,
        );
        if (resolvedLabel != null && resolvedLabel.isNotEmpty) {
          label = resolvedLabel;
        }
      } catch (_) {
        label = _fallbackLocationLabel(location, source);
      }
    }

    if (label == _fallbackLocationLabel(location, source)) {
      try {
        final deviceResolvedLabel = await _deviceLocationService.reverseGeocode(
          location.latitude,
          location.longitude,
        );
        if (deviceResolvedLabel != null && deviceResolvedLabel.isNotEmpty) {
          label = deviceResolvedLabel;
        }
      } catch (_) {
        label = _fallbackLocationLabel(location, source);
      }
    }

    if (!mounted) {
      return;
    }
    setState(() {
      _selectedLocationLabel = label;
      _isResolvingLocation = false;
      _statusMessage = source == 'pin'
          ? 'Pin confirmed in Lebanon.'
          : 'Location confirmed in Lebanon.';
    });
  }

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
          onPressed: () => popOrGoTo(context, Routes.addresses),
        ),
        title: Text(
          _isEditing ? 'Edit Address' : 'Add Address',
          style: AppTheme.sectionHeader(
            color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.paddingHorizontal),
        child: Column(
          children: [
            const SizedBox(height: 24),
            AddressLocationPicker(
              selectedLocation: _selectedLocation,
              selectedLabel: _selectedLocationLabel,
              onUseCurrentLocation: _handleUseCurrentLocation,
              onLocationChanged: (location) {
                _setSelectedLocation(location, source: 'pin');
              },
              isResolvingLocation: _isResolvingLocation,
              statusMessage: _statusMessage,
              mapOverride: widget.locationPickerOverride,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _phoneController,
              hintText: 'Phone Number',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _deliveryNoteController,
              hintText: 'Delivery note, building, or floor',
              prefixIcon: Icons.sticky_note_2_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              text: _isEditing ? 'Update Address' : 'Save Address',
              onPressed: _canSave ? _saveAddress : null,
            ),
          ],
        ),
      ),
    );
  }
}
