# Product Image Performance Design

## Goal

Improve product image loading performance across the app while minimizing regression risk. The first pass should remove avoidable image-fetch latency, standardize image rendering behavior, and preserve the current UI contract for product imagery.

## Current Problems

- Product surfaces render images through repeated `Image.network` usage in multiple widgets and screens.
- Image loading behavior is duplicated, so placeholders, error handling, and sizing are inconsistent across the app.
- Catalog reads currently resolve product image URLs at runtime by listing Firebase Storage folders and calling `getDownloadURL()` for each image.
- Product fetches therefore pay Storage round trips before the UI can even start downloading images.
- The app does not have a single product-image abstraction that can be tuned for caching and decode sizing without touching many screens.

## Design

### Product image contract

The `Product` model remains the UI contract. Existing consumers continue to read `product.thumbnail` and `product.images`.

The source of those values changes:

- Firestore product documents become the primary source of truth for image URLs.
- `thumbnail` remains the primary card/list image.
- `images` remains the product-detail gallery source.
- Compatibility fallback remains in place temporarily so incomplete product documents do not break existing screens.

This keeps screen code stable while allowing the data source and rendering path to improve underneath the same fields.

### Catalog data flow

`CatalogService` will stop treating Firebase Storage folder listings as the normal path for catalog image resolution.

Normal flow:

- Read products from Firestore.
- Populate `Product.thumbnail` and `Product.images` directly from document fields when present.
- Return products without additional Storage folder enumeration.

Compatibility flow:

- If a document lacks the required image data, keep a temporary fallback path that preserves current behavior for that product instead of failing hard.
- This fallback is a migration bridge, not the long-term default path.

This reduces latency for catalog fetches and isolates migration risk to products with incomplete data.

### Shared image rendering

Introduce a single shared widget for product imagery and migrate product image surfaces to use it instead of raw `Image.network`.

Responsibilities of the shared widget:

- Consistent loading placeholder behavior
- Consistent error fallback behavior
- Configurable fit, width, height, and border radius
- Centralized caching strategy
- Optional decode-size tuning for smaller surfaces such as cards

The widget should preserve the current visual behavior closely enough that screen layouts and error states do not materially change.

### Rollout strategy

The rollout is intentionally staged to lower regression risk:

1. Add the shared product-image widget while preserving current placeholder and fallback behavior.
2. Replace repeated `Image.network` usage in product-related surfaces with the shared widget.
3. Change catalog image sourcing to prefer Firestore document fields while keeping a compatibility fallback.
4. Verify all affected screens before removing any fallback logic in a later pass.

This sequencing limits the blast radius of each change and keeps rollback straightforward.

## Error Handling

- Empty or invalid image URLs continue to render a safe branded fallback instead of crashing.
- Products with incomplete Firestore image data continue to render through the temporary compatibility path.
- A failed image request must not block product metadata such as title, price, or actions from rendering.

## Testing

### Automated coverage

- Widget tests for the shared product-image widget covering loading, error, and standard render paths
- Widget or screen tests for core product surfaces that now use the shared widget
- Service tests for `CatalogService` covering Firestore-first image resolution and compatibility fallback behavior

### Verification

- `flutter analyze`
- `flutter test`
- Manual checks for home, product details, cart, and order detail screens

## Non-Goals

- Building a full thumbnail-generation pipeline in this pass
- Removing the compatibility fallback before Firestore image data is verified
- Redesigning product card or carousel layouts

## Follow-Up

If image payload sizes remain too large after this pass, the next phase should introduce explicit thumbnail and medium-sized image variants in storage and Firestore so the app can request smaller assets by surface type.
