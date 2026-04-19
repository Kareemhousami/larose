import 'dart:async';

import 'package:flutter/material.dart';

import '../services/google_places_service.dart';
import '../theme/app_theme.dart';
import 'app_text_field.dart';

class AddressSearchResult {
  const AddressSearchResult({
    required this.label,
    required this.latitude,
    required this.longitude,
    this.source = 'search',
  });

  final String label;
  final double latitude;
  final double longitude;
  final String source;
}

/// Bottom sheet used to search for Lebanese delivery locations.
class AddressSearchSheet extends StatefulWidget {
  const AddressSearchSheet({
    super.key,
    required this.googlePlacesService,
    required this.apiKey,
    this.countryCode = 'lb',
  });

  final GooglePlacesService googlePlacesService;
  final String apiKey;
  final String countryCode;

  @override
  State<AddressSearchSheet> createState() => _AddressSearchSheetState();
}

class _AddressSearchSheetState extends State<AddressSearchSheet> {
  final TextEditingController _queryController = TextEditingController();
  List<Map<String, dynamic>> _results = const [];
  bool _isLoading = false;
  String? _error;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _queryController.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _queryController.dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    final query = _queryController.text.trim();

    // Cancel any pending debounce
    _debounce?.cancel();

    // Clear results if query is too short
    if (query.length < 2) {
      setState(() {
        _results = const [];
        _error = null;
      });
      return;
    }

    // Clear error on any change
    if (_error != null) {
      setState(() {
        _error = null;
      });
    }

    // Debounce 300ms then search
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _search(query);
    });
  }

  Future<void> _search(String query) async {
    if (widget.apiKey.isEmpty) {
      setState(() {
        _error = 'Search is not configured yet for this build.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await widget.googlePlacesService.search(
        query,
        widget.apiKey,
        countryCode: widget.countryCode,
      );
      // Only update if the query hasn't changed while we were fetching
      if (!mounted || _queryController.text.trim() != query) return;
      setState(() {
        _results = results;
        if (_results.isEmpty) {
          _error = 'No Lebanese locations matched that search.';
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Unable to search locations right now.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectResult(Map<String, dynamic> result) async {
    final placeId = result['place_id'] as String?;
    final fallbackLabel = result['description'] as String? ?? 'Lebanon';
    if (placeId == null || placeId.isEmpty) {
      Navigator.pop(
        context,
        const AddressSearchResult(
          label: 'Lebanon',
          latitude: 33.8547,
          longitude: 35.8623,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final details = await widget.googlePlacesService.getPlaceDetails(
        placeId,
        widget.apiKey,
      );
      final geometry = details?['geometry'] as Map<String, dynamic>?;
      final location = geometry?['location'] as Map<String, dynamic>?;
      final lat = (location?['lat'] as num?)?.toDouble();
      final lng = (location?['lng'] as num?)?.toDouble();
      if (lat == null || lng == null) {
        setState(() {
          _error = 'Unable to resolve that location.';
          _isLoading = false;
        });
        return;
      }
      if (!mounted) {
        return;
      }
      Navigator.pop(
        context,
        AddressSearchResult(
          label: details?['formatted_address'] as String? ?? fallbackLabel,
          latitude: lat,
          longitude: lng,
        ),
      );
    } catch (_) {
      setState(() {
        _error = 'Unable to resolve that location.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingHorizontal),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Search in Lebanon',
              style: AppTheme.sectionHeader(
                color:
                    isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start typing a street, landmark, or area to see suggestions.',
              style: AppTheme.bodyText(
                color: isDark ? AppTheme.textSubtleDark : AppTheme.textSubtle,
              ),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _queryController,
              hintText: 'Search for a Lebanese location',
              prefixIcon: Icons.search,
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Center(
                  child: SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ),
            if (_error != null) ...[
              Text(
                _error!,
                style: AppTheme.bodyText(color: Colors.redAccent),
              ),
              const SizedBox(height: 12),
            ],
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: _results.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 1),
                itemBuilder: (context, index) {
                  final result = _results[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.location_on_outlined,
                      color: AppTheme.primary,
                    ),
                    title: Text(
                      result['description'] as String? ?? 'Lebanon',
                      style: AppTheme.bodyText(
                        color: isDark
                            ? AppTheme.textPrimaryDark
                            : AppTheme.textPrimary,
                      ),
                    ),
                    onTap: _isLoading ? null : () => _selectResult(result),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
