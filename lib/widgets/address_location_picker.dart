import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../theme/app_theme.dart';

/// Lebanon-first map widget for selecting a delivery pin.
class AddressLocationPicker extends StatefulWidget {
  const AddressLocationPicker({
    super.key,
    required this.selectedLocation,
    required this.selectedLabel,
    required this.onUseCurrentLocation,
    required this.onLocationChanged,
    this.isResolvingLocation = false,
    this.statusMessage,
    this.mapOverride,
  });

  static const LatLng lebanonCenter = LatLng(33.8547, 35.8623);

  final LatLng? selectedLocation;
  final String? selectedLabel;
  final VoidCallback onUseCurrentLocation;
  final ValueChanged<LatLng> onLocationChanged;
  final bool isResolvingLocation;
  final String? statusMessage;
  final Widget? mapOverride;

  @override
  State<AddressLocationPicker> createState() => _AddressLocationPickerState();
}

class _AddressLocationPickerState extends State<AddressLocationPicker> {
  GoogleMapController? _mapController;

  @override
  void didUpdateWidget(covariant AddressLocationPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    final loc = widget.selectedLocation;
    if (loc != null && loc != oldWidget.selectedLocation) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(loc, 16.0),
      );
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final target = widget.selectedLocation ?? AddressLocationPicker.lebanonCenter;

    return Container(
      padding: const EdgeInsets.all(AppTheme.cardPadding),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.primary5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery location',
            style: AppTheme.sectionHeader(
              color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the map in Lebanon to drop your delivery pin.',
            style: AppTheme.bodyText(
              color: isDark ? AppTheme.textSubtleDark : AppTheme.textSubtle,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            child: SizedBox(
              height: 260,
              width: double.infinity,
              child: widget.mapOverride ??
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: target,
                      zoom: widget.selectedLocation == null ? 8.4 : 15.5,
                    ),
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    markers: widget.selectedLocation == null
                        ? const <Marker>{}
                        : {
                            Marker(
                              markerId: const MarkerId('delivery-location'),
                              position: widget.selectedLocation!,
                            ),
                          },
                    onTap: widget.onLocationChanged,
                  ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton.icon(
                onPressed: widget.onUseCurrentLocation,
                icon: const Icon(Icons.my_location),
                label: const Text('Use my location'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(color: AppTheme.primary10),
            ),
            child: Row(
              children: [
                const Icon(Icons.place, color: AppTheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.selectedLabel ?? 'No delivery pin selected yet.',
                    style: AppTheme.bodyText(
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimary,
                    ),
                  ),
                ),
                if (widget.isResolvingLocation)
                  const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.primary,
                    ),
                  ),
              ],
            ),
          ),
          if (widget.statusMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              widget.statusMessage!,
              style: AppTheme.bodyText(
                color: isDark ? AppTheme.textSubtleDark : AppTheme.textSubtle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
