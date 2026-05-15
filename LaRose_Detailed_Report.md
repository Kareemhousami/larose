# La Rose - Flower Delivery Application
## Complete Technical & Design Report

---

## 1. Project Overview

**La Rose** is a production-grade, cross-platform flower delivery mobile application built with Flutter and Firebase. The app allows customers in Lebanon to browse bouquets by event or flower type, manage delivery addresses via interactive Google Maps, place cash-on-delivery orders, and track delivery progress in real-time. It includes a full admin panel for order lifecycle management and dynamic delivery pricing configuration.

**Key Philosophy**: No backend servers, no cloud functions — all business logic runs client-side in Dart with Firestore transactions for data consistency. This reduces infrastructure complexity and hosting costs to zero beyond Firebase's free tier.

---

## 2. Technology Stack

| Layer | Technology | Version | Purpose |
|-------|-----------|---------|---------|
| Framework | Flutter (Dart) | SDK 3.10.8+ | Cross-platform UI |
| State Management | Provider | v6.1.2 | ChangeNotifier-based MVVM |
| Authentication | Firebase Auth | Latest | Email/password auth |
| Database | Cloud Firestore | Latest | NoSQL document store |
| File Storage | Firebase Cloud Storage | Latest | Product images, hero banners |
| Maps Widget | Google Maps Flutter | v2.12.0 | Interactive map picker |
| Device Location | Geolocator | v14.0.2 | GPS coordinates |
| Geocoding | Geocoding Package | v4.0.0 | Reverse geocoding |
| Places API | Google Places | REST | Address autocomplete |
| Animations | Lottie | v3.3.1 | Onboarding animations |
| Typography | Google Fonts | Latest | Plus Jakarta Sans, Great Vibes |
| Image Caching | Cached Network Image | Latest | Efficient image loading |
| Loading States | Shimmer | Latest | Skeleton loading screens |
| Local Storage | Shared Preferences | Latest | Dark mode, onboarding flag |
| Date Formatting | intl | Latest | Locale-aware formatting |
| External Links | url_launcher | Latest | Phone/email links |
| Network Status | connectivity_plus | Latest | Online/offline detection |
| CI/CD | GitHub Actions | Latest | Automated APK builds |

---

## 3. Application Architecture (MVVM)

### 3.1 Entry Point (`main.dart`)

The app bootstraps Firebase, then wraps the entire widget tree in a `MultiProvider` with 8 providers:

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthViewModel()..init()),
    ChangeNotifierProvider(create: (_) => ProductViewModel()),
    ChangeNotifierProxyProvider<AuthViewModel, CartViewModel>(...),
    ChangeNotifierProxyProvider<AuthViewModel, FavoritesViewModel>(...),
    ChangeNotifierProxyProvider<AuthViewModel, AddressViewModel>(...),
    ChangeNotifierProxyProvider<AuthViewModel, OrdersViewModel>(...),
    ChangeNotifierProvider(create: (_) => AdminOrdersViewModel()),
    ChangeNotifierProvider(create: (_) => AdminDeliverySettingsViewModel()),
  ],
)
```

**Key Design**: `CartViewModel`, `FavoritesViewModel`, `AddressViewModel`, and `OrdersViewModel` are all `ProxyProvider`s that automatically rebind when the authenticated user changes. This means switching accounts instantly shows the correct cart, favorites, and addresses without manual refresh.

### 3.2 Complete File Structure

```
lib/
  main.dart                              - App entry, Firebase init, Provider setup
  app/
    app.dart                             - Root MaterialApp with theme switching
    routes.dart                          - 30+ named routes with slide transitions
    navigation.dart                      - popOrGoTo() helper for safe navigation
  config/
    app_firebase_options.dart            - Platform-specific Firebase credentials
    maps_config.dart                     - Google Maps API key constant
  models/
    user.dart                            - User model (id, email, names, admin flag)
    product.dart                         - Product model (title, price, images, category)
    order.dart                           - Order model + OrderEvent + OrderStatus enum
    cart_item.dart                       - CartItem (product + quantity)
    address.dart                         - Address model (location, label, phone, note)
    delivery_settings.dart               - DeliverySettings model (all pricing params)
  services/
    firebase_bootstrap_service.dart      - Firebase.initializeApp wrapper
    auth_service.dart                    - Sign in/up, profile CRUD, preferences
    catalog_service.dart                 - Product/category/flowerType queries
    order_service.dart                   - Order creation, retrieval, status updates
    cart_service.dart                    - Firestore cart persistence
    address_service.dart                 - Address CRUD with deduplication
    favorites_service.dart               - Favorites subcollection management
    device_location_service.dart         - GPS permission & coordinates
    google_places_service.dart           - Places autocomplete & reverse geocode
    storage_service.dart                 - SharedPreferences wrapper (singleton)
    firestore_paths.dart                 - Centralized collection path constants
    api/
      order_api.dart                     - Order placement with pricing snapshot
      delivery_api.dart                  - Delivery fee orchestration
      delivery_pricing.dart              - Pure pricing math (no Firebase)
      delivery_planning.dart             - Haversine distance calculation
  viewmodels/
    auth_viewmodel.dart                  - Auth state, dark mode, error mapping
    product_viewmodel.dart               - Product list, search, categories
    cart_viewmodel.dart                  - Cart state, total price, user binding
    orders_viewmodel.dart                - Order placement, pricing, tracking
    address_viewmodel.dart               - Address list, default selection
    favorites_viewmodel.dart             - Favorites state, toggle logic
    admin_orders_viewmodel.dart          - All orders, filters, status transitions
    admin_delivery_settings_viewmodel.dart - Settings load/save
  views/
    auth/
      login_screen.dart                  - Email/password login
      signup_screen.dart                 - Registration with name
      forgot_password_screen.dart        - Password reset email
    onboarding/
      onboarding_screen.dart             - 3-page swipeable intro
    home/
      home_screen.dart                   - Landing with hero, search, featured
    shop/
      shop_screen.dart                   - Browse by event or flower type
      shop_categories_screen.dart        - Event categories grid
      shop_types_screen.dart             - Flower types grid
      shop_collection_screen.dart        - Products in one category
      search_screen.dart                 - Dedicated search results
    product/
      product_details_screen.dart        - Full product view with carousel
    cart/
      cart_screen.dart                   - Cart items with quantity controls
      checkout_screen.dart               - Address + pricing + place order
    favorites/
      favorites_screen.dart              - 2-column grid of saved products
    orders/
      orders_screen.dart                 - Customer order list
      order_details_screen.dart          - Single order breakdown
      order_tracking_screen.dart         - Timeline + ETA + confirm delivery
      admin_orders_screen.dart           - All orders with filters
      admin_order_details_screen.dart    - Admin order management
      admin_delivery_settings_screen.dart - Pricing configuration
    profile/
      profile_screen.dart                - Avatar, name, menu items
      edit_profile_screen.dart           - Edit name/email form
      addresses_screen.dart              - Saved addresses list
      add_address_screen.dart            - Map picker + phone + note
      add_payment_screen.dart            - Payment info (COD info)
      notifications_screen.dart          - Toggle preferences
      privacy_security_screen.dart       - Security toggles
    settings/
      settings_screen.dart               - Settings menu
      about_screen.dart                  - Company info
      contact_screen.dart                - Support links
      faq_screen.dart                    - FAQ accordion
      privacy_policy_screen.dart         - Legal text
      terms_screen.dart                  - Terms of service
    shared/
      splash_screen.dart                 - Initial loading screen
      save_confirmation_screen.dart      - Order success confirmation
  widgets/
    app_text_field.dart                  - Styled text input with icon
    primary_button.dart                  - Rose-themed pill button with loading
    bottom_nav_bar.dart                  - 5-tab navigation bar
    product_card.dart                    - Grid card with fav/cart buttons
    section_header.dart                  - Title + "View All" link
    shimmer_loading.dart                 - Skeleton loading placeholders
    image_carousel.dart                  - Multi-image swiper
    rating_stars.dart                    - Star rating display
    price_display.dart                   - Formatted price widget
    order_status_badge.dart              - Color-coded status chip
    empty_state.dart                     - No-data placeholder with CTA
    error_state.dart                     - Error display with retry
    confirmation_dialog.dart             - Destructive action confirm
    address_location_picker.dart         - Google Maps picker widget
    address_search_sheet.dart            - Places autocomplete bottom sheet
    add_to_cart_feedback.dart            - Success snackbar after add
    feature_bullet.dart                  - Bullet point for feature lists
    remote_image.dart                    - Network image with fallback
  theme/
    app_theme.dart                       - All colors, typography, spacing, ThemeData
```

---

## 4. UI/UX Design System (AppTheme)

### 4.1 Color System

| Token | Hex | Usage |
|-------|-----|-------|
| `primary` | #C8828E | Buttons, links, accents, brand identity |
| `backgroundLight` | #F8F6F6 | Light mode scaffold background |
| `backgroundDark` | #221015 | Dark mode background (deep burgundy) |
| `surface` | #FFFFFF | Cards, modals, inputs in light mode |
| `surfaceDark` | #1E293B | Cards in dark mode (slate-800) |
| `navDark` | #0F172A | Bottom nav in dark mode (slate-900) |
| `textPrimary` | #0F172A | Body text light mode (slate-900) |
| `textPrimaryDark` | #F1F5F9 | Body text dark mode (slate-100) |
| `textMuted` | #94A3B8 | Placeholder, inactive icons (slate-400) |
| `textMutedDark` | #64748B | Placeholders in dark mode (slate-500) |
| `textSubtle` | #475569 | Secondary text light (slate-600) |
| `textSubtleDark` | #CBD5E1 | Secondary text dark (slate-300) |
| `textSlate500` | #64748B | Card subtitles |
| `textSlate800` | #1E293B | Card titles light mode |

**Opacity Variants**: `primary5` (5%), `primary10` (10%), `primary20` (20%), `primary30` (30%), `primary50` (50%), `primary60` (60%), `primary90` (90%) — each used for specific UI elements like backgrounds, borders, shadows, and hover states.

### 4.2 Typography System

All text uses **Plus Jakarta Sans** via Google Fonts. **Great Vibes** is used exclusively for the brand wordmark.

| Style Method | Size | Weight | Use Case |
|-------------|------|--------|----------|
| `brandWordmark()` | 34sp | w400 | "La Rose" script logo |
| `appBarTitle()` | 24sp | w700/w800 | Screen titles |
| `heroHeading()` | 30sp | w700 | Hero banner heading |
| `sectionHeader()` | 18sp | w700 | Section titles |
| `viewAllLink()` | 14sp | w600 | "View All" links |
| `categoryChip()` | 14sp | w500 | Category chips, tags |
| `productCardTitle()` | 14sp | w700 | Product names |
| `productCardSubtitle()` | 10sp | w400 | Product meta text |
| `productPriceHome()` | 18sp | w700 | Prices on home cards |
| `productPriceShop()` | 14sp | w700 | Prices in shop grid |
| `occasionLabel()` | 11sp | w500 | Small labels |
| `navLabel()` | 10sp | w500/w700 | Bottom nav text |
| `specialOfferTag()` | 12sp | w700 | Uppercase tags (letter-spacing: 2.0) |
| `bodyText()` | 14sp | w400 | Body copy (line-height: 1.625) |
| `buttonText()` | 16sp | w700 | Button labels (white) |

### 4.3 Spacing & Sizing Constants

| Constant | Value | Usage |
|----------|-------|-------|
| `paddingHorizontal` | 16dp | Screen edge padding |
| `cardGap` | 16dp | Between cards in grids |
| `sectionPaddingVertical` | 24dp | Vertical section spacing |
| `cardPadding` | 16dp | Internal card padding (home) |
| `cardPaddingShop` | 12dp | Internal card padding (shop grid) |
| `heroMinHeight` | 288dp | Minimum hero card height |
| `heroPadding` | 24dp | Hero internal padding |
| `homeCardWidth` | 256dp | Home product card width |
| `homeCardImageHeight` | 192dp | Home card image height |
| `buttonHeight` | 48dp | Primary button height |
| `buttonPaddingHorizontal` | 32dp | Button horizontal padding |
| `appBarIconSize` | 40dp | App bar icon button size |
| `actionButtonSize` | 32dp | Add/favorite button size |

### 4.4 Border Radius Scale

| Token | Value | Usage |
|-------|-------|-------|
| `radiusDefault` | 8dp | Input fields, small buttons |
| `radiusLg` | 16dp | Cards, icon containers |
| `radiusXl` | 24dp | Large cards, hero sections |
| `radiusFull` | 9999dp | Pill buttons, chips, badges |

### 4.5 ThemeData Configuration

Both `lightTheme` and `darkTheme` configure:
- `scaffoldBackgroundColor` — overall page background
- `colorScheme` — primary, secondary, surface, onPrimary, onSurface
- `appBarTheme` — transparent, no elevation, centered title in brand wordmark style
- `bottomNavigationBarTheme` — surface background, primary selected, muted unselected
- `elevatedButtonTheme` — full-width pill button, 48dp height, stadium border, elevation 4 with primary30 shadow
- `inputDecorationTheme` — filled, radiusXl corners, no border (focus: 2px primary50 border), 14sp placeholder text
- `cardTheme` — surface color, radiusXl, primary5 border, elevation 1

---

## 5. Authentication System (Detailed)

### 5.1 AuthService Class

**Location**: `lib/services/auth_service.dart`

**Constructor**: Accepts optional `FirebaseAuth` and `FirebaseFirestore` for testability.

**Methods**:
- `authStateChanges()` — Returns `Stream<User?>` from Firebase
- `getCurrentUser()` — Gets current auth user, loads Firestore profile, checks admin claims
- `signIn(email, password)` — Signs in, loads profile
- `signUp(email, password, firstName, lastName)` — Creates auth user, writes Firestore profile document with auto-generated username (`firstName.lastName` lowercase)
- `updateProfile(uid, firstName, lastName, email)` — Updates Firestore doc, if email changed calls `verifyBeforeUpdateEmail()` which sends verification email
- `sendPasswordResetEmail(email)` — Delegates to Firebase
- `signOut()` — Firebase sign out
- `getNotificationPreferences()` — Reads `notificationPreferences` map from user doc
- `updateNotificationPreferences(Map)` — Merges notification prefs into user doc
- `getPrivacySettings()` — Reads `privacySettings` map from user doc
- `updatePrivacySettings(Map)` — Merges privacy settings into user doc

**Profile Loading Logic** (`_loadProfile`):
1. Gets Firestore document at `users/{uid}`
2. Calls `getIdTokenResult(true)` to check for `admin` custom claim
3. If document doesn't exist, creates it from auth user data (splits displayName into first/last, generates username)
4. Returns `User` model from merged JSON data

**Name Splitting** (`_splitName`):
- Empty/null → defaults to ("La", "Rose")
- Single word → (word, "")
- Multiple words → (first, rest joined)

### 5.2 AuthViewModel Class

**Location**: `lib/viewmodels/auth_viewmodel.dart`

**State Variables**:
- `_user: User?` — current authenticated user
- `_isLoading: bool` — loading spinner state
- `_isInitialized: bool` — whether init() completed
- `_isDarkMode: bool` — persisted dark mode preference
- `_error: String?` — current error message
- `_errorAction: AuthErrorAction` — none, goToSignup, or goToLogin

**Enum `AuthErrorAction`**: `none`, `goToSignup`, `goToLogin`

**Error Mapping (Login)**:
| Firebase Code | User Message | Action |
|--------------|-------------|--------|
| `invalid-email` | "Please enter a valid email address." | none |
| `user-not-found` / `invalid-credential` | "This account does not exist. Create one instead." | goToSignup |
| `wrong-password` | "Incorrect password. Please try again." | none |
| `network-request-failed` | "No internet connection. Please check your network." | none |

**Error Mapping (Signup)**:
| Firebase Code | User Message | Action |
|--------------|-------------|--------|
| `invalid-email` | "Please enter a valid email address." | none |
| `email-already-in-use` | "An account with this email already exists." | goToLogin |
| `weak-password` | "Password is too weak. Use at least 6 characters." | none |
| `network-request-failed` | "No internet connection." | none |

**Error Mapping (Profile Update)**:
- Adds `requires-recent-login`: "Please sign in again before changing your email address."

**Dark Mode**: Stored in SharedPreferences under key `'dark_mode'`, toggled via `toggleDarkMode()`.

**Name Parsing on Signup**: `"John Doe Smith"` → firstName: "John", lastName: "Doe Smith"

### 5.3 Login Screen UI

**Layout** (centered, scrollable):
1. **Logo**: 64x64 circle, primary10 bg, primary20 border, `local_florist` icon
2. **Brand**: "La Rose" in Great Vibes script, 32sp
3. **Divider**: 1px line, 48dp wide, primary30 color
4. **Welcome**: "Welcome Back" in 28sp bold
5. **Subtitle**: "Sign in to manage your orders, favorites, and cart"
6. **Email Field**: mail_outline icon, email keyboard, "Email Address" hint
7. **Password Field**: lock_outline icon, visibility toggle suffix, obscured text
8. **Forgot Password**: Right-aligned link, primary color, 13sp semibold
9. **Error Notice**: Conditional `_AuthErrorNotice` widget with optional action button
10. **Sign In Button**: `PrimaryButton` with loading state
11. **Signup Link**: "Don't have an account? Join the Garden"

**`_AuthErrorNotice` Widget**:
- Container with primary5 bg, radiusLg corners, primary20 border, 16px blur shadow
- Icon in 30x30 rounded container (error icon or email icon depending on action)
- Message text in 14sp semibold
- If action available: helper text + full-width outlined button with arrow icon

### 5.4 Signup Screen UI

**Layout**:
1. **Header**: "Join the Garden" in 28sp bold
2. **Brand Tag**: "LA ROSE" in specialOfferTag style (12sp, letter-spacing 2.0)
3. **Full Name Field**: person_outline icon, "Full Name" hint
4. **Email Field**: mail_outline icon, "Email Address" hint
5. **Password Field**: lock_outline icon, visibility toggle, min 6 chars validation
6. **Error Notice**: Same `_AuthErrorNotice` widget (but with person_add_alt icon for action)
7. **Create Account Button**: PrimaryButton with loading
8. **Login Link**: "Already have an account? Login"

### 5.5 Forgot Password Screen UI

**Layout**:
1. **Back Arrow**: Navigates to login
2. **Icon**: 64x64 circle, primary10 bg, `lock_reset` icon
3. **Title**: "Reset Password" in 24sp
4. **Description**: "Enter your email address and we'll send you a link..."
5. **Email Field**: Uses `AppTextField` widget
6. **Success Indicator**: check_circle icon + "Reset link sent!" text (shown after send)
7. **Button**: "Send Reset Link" → changes to "Resend Link" after first send
8. **Back Link**: "Back to Sign In"
9. **Snackbar**: "Password reset email sent! Check your inbox." on success

---

## 6. Onboarding System

### 6.1 OnboardingScreen

**3-page PageView** with dot indicators and Next/Get Started button.

**Pages**:
1. `local_florist` icon → "Welcome to La Rose" (mixed style: regular + Great Vibes) → "Discover beautiful, hand-crafted flower arrangements delivered fresh to your doorstep."
2. `shopping_bag_outlined` → "Easy Ordering" → "Browse our curated collection, add to cart, and checkout with cash on delivery. Simple and secure."
3. `delivery_dining` → "Fast Delivery" → "Same-day delivery for orders placed before 2 PM. Track your order in real-time from confirmation to your door."

**Each page layout**:
- 120x120 circle with primary10 bg
- 56px icon in primary color
- 40dp gap
- Title in 24sp bold
- 16dp gap
- Description in bodyText style

**Dot Indicators**: AnimatedContainer, active = 24dp wide pill, inactive = 8dp circle, primary vs primary20

**Skip Button**: Top-right, "Skip" in muted text, completes onboarding

**Persistence**: Sets `'has_seen_onboarding'` to true in SharedPreferences

**Navigation**: On complete → pushReplacementNamed to login

---

## 7. Home Screen (Detailed)

### 7.1 Structure

**AppBar**: Transparent bg, hamburger menu (left), "La Rose" in Great Vibes (center), person + settings icons (right)

**Body** (SingleChildScrollView with RefreshIndicator):
1. Search Bar
2. Hero Section
3. Quick Actions
4. Our Story Section
5. Promotions Section
6. Featured Bouquets Section

**Bottom Navigation**: BottomNavBar with currentIndex: 0

### 7.2 Search Bar
- 48dp height container with 24dp border radius
- primary10 border, surface background
- search_rounded icon in primary60
- Live TextField with `onChanged` → `productVm.searchProducts()`
- Clear button (X in 24dp circle) appears when query is non-empty

### 7.3 Hero Section
- Full-width card, 288dp min height, radiusXl corners
- **Background**: Firebase Storage image (`flower_types/roses/1.png`) loaded at runtime
- **Gradient overlay**: Bottom-left to top-center, 3 stops (88% → 52% → 8% opacity of backgroundDark)
- **Content** (bottom-left, max 240dp width):
  - "NEW COLLECTION" pill badge (primary at 85% opacity, white text, 10sp)
  - "Explore Our Flower Shop" in heroHeading (26sp)
  - "Fresh blooms delivered to your door" in 13sp white
  - "Shop Now" button (44dp height, primary bg, 12px blur shadow, arrow icon)

### 7.4 Quick Actions
- 4 equally-spaced columns: Events, Types, Favorites, Orders
- Each: 60x60 container with primary10 bg + radiusLg, icon 26px, label 12sp below

### 7.5 Our Story Section
- Full-width card with gradient (surface → primary5), 22dp padding
- 52x52 icon container with `auto_awesome_rounded` icon
- "Our Story" title 22sp
- Brand story paragraph
- "Learn more about us" ElevatedButton

### 7.6 Promotions Section ("Special Touches")
- LayoutBuilder: stacks on narrow (<720dp), side-by-side on wide
- **Welcome Card**: Gradient primary → primary90, white text, shipping icon
  - "WELCOME OFFER" eyebrow, "15% off and free delivery on your first order"
- **Birthday Card**: Surface → primary5 gradient, primary10 border
  - "BIRTHDAY TREAT" eyebrow, "Celebrate January 1 birthdays with a 25% floral gift"
- Both: minHeight 214dp, 20dp padding, decorative 92dp circle in top-right

### 7.7 Featured Bouquets
- SectionHeader: "Featured Bouquets" / "Search Results" + "View All" link
- Loading: `HomeProductSkeletonRow` shimmer
- Empty: Card with "No bouquets found" + suggestion text
- Data: Horizontal ListView, max 10 items, 300dp height
- Each card (`_HomeProductCard`): 200dp wide, product image (expand), title, price, add-to-cart button (36x36, primary bg, + icon)

### 7.8 Navigation Drawer
- Drawer with branded header ("La Rose" + description)
- 7 items: Home, Shop, Favorites, Orders, Cart, About Us, Profile
- Each: InkWell with 38x38 icon container, label, chevron_right
- Footer: "Navigate quickly through the app."

---

## 8. Shopping System

### 8.1 Shop Screen (Entry Point)
- Title: "Shop" in appBarTitle(isShop: true) — 24sp, w800
- "Choose How To Browse" heading (24sp)
- Two `_BrowseCard` options:
  - **Browse Events**: grid_view icon, "SHOP BY EVENT" eyebrow, routes to categories
  - **Browse Flower Types**: local_florist icon, "SHOP BY TYPE" eyebrow, routes to types

### 8.2 Product Card Widget (`product_card.dart`)
- Used across favorites grid, shop collection, search results
- **Layout**: AspectRatio(1:1) image + info section below
- **Image**: Network image with shimmer loading, error fallback
- **Favorite Button**: Top-right 32dp circle overlay, toggles via FavoritesViewModel
- **Title**: 14sp bold, max 1 line with ellipsis
- **Description** (optional): 12sp, 2 lines max
- **Tags**: Horizontal scroll of category + flowerType pills
- **Price + Cart**: Row with price (14sp bold primary) + 32dp add button
- **Add to Cart**: Calls `cartVm.addToCart()`, shows `showAddToCartFeedback()` snackbar on success

### 8.3 Grid Layout Calculation
`ProductCard.gridMainAxisExtent(cardWidth)`:
- Without description: cardWidth + 140
- With description: cardWidth + 178

---

## 9. Cart System

### 9.1 Cart Screen UI
- **AppBar**: "Your Cart", back arrow, clear cart icon (trash bag)
- **Empty State**: `EmptyState` widget with shopping_bag icon, "Your cart is empty", "Start Shopping" button
- **Cart Items**: ListView with 12dp internal padding cards
  - Each item: 80x80 image + title + price + delete icon + quantity controls
  - Quantity: – button / number / + button (28x28 primary10 containers)
- **Footer**: Sticky bottom container with "Total" + price (20sp) + "Checkout" PrimaryButton
- **Clear Cart**: Confirmation dialog before clearing ("Clear cart?" / "Remove all items?")

### 9.2 CartViewModel
- `bindUser(String? userId)` — loads cart from Firestore when user changes
- `addToCart(Product)` — adds with quantity 1 or increments existing
- `removeFromCart(String productId)` — removes item
- `updateQuantity(String productId, int quantity)` — sets quantity, removes if 0
- `clearCart()` — removes all items
- `totalPrice` — computed sum of all item.totalPrice

---

## 10. Checkout & Order Placement

### 10.1 Checkout Screen UI
- **No Addresses**: EmptyState with "Add a delivery address to continue"
- **Address Selection**: Radio-button cards for each saved address
  - Shows: locationLabel, deliveryNote, phone
  - Selected: 2px primary border
  - "Add New" TextButton in header
- **Payment Method**: Info card showing "Cash on Delivery" with payments_outlined icon
- **Order Summary**: Line items (product title x quantity = price)
- **Pricing Breakdown**:
  - Products subtotal
  - Delivery fee (calculated from API)
  - Divider
  - Total (bold, large)
- **Errors**: Red text for pricing errors or order errors
- **Place Order Button**: Disabled until pricing is loaded and valid

### 10.2 Pricing Request Optimization
```dart
_loadPricingIfNeeded() {
  final key = '${address.id}_${items.length}_$total';
  if (key == _lastPricingKey) return; // Skip duplicate requests
  _lastPricingKey = key;
  ordersVm.loadCheckoutPricing(address, items);
}
```
This prevents repeated API calls during widget rebuilds.

### 10.3 Order Placement Flow
1. `ordersVm.placeCashOnDeliveryOrder(address, items)` → returns orderId
2. On success: `cartVm.clearCart()` clears cart
3. Navigate to confirmation screen with orderId, remove all previous routes

---

## 11. Google Maps & Location System

### 11.1 AddressLocationPicker Widget

**Lebanon-centered map** defaulting to coordinates (33.8547, 35.8623) at zoom 8.4.

**Layout**:
1. Header: "Delivery location"
2. Instructions: "Tap the map in Lebanon to drop your delivery pin."
3. **Google Maps Widget** (260dp height, clipped with radiusXl):
   - `myLocationEnabled: true`
   - `zoomControlsEnabled: false`
   - Single marker at selected location
   - `onTap` callback fires `onLocationChanged`
4. "Use my location" OutlinedButton
5. **Location Display Box**: place icon + resolved label (or "No delivery pin selected yet.") + spinner during resolution

**Camera Animation**: When location changes, `animateCamera` to new position at zoom 16.0

### 11.2 Add Address Screen

**Full Flow**:
1. User sees map centered on Lebanon
2. User taps map → pin drops, `_setSelectedLocation()` fires
3. System resolves address:
   a. First tries Google Places reverse geocode via API key
   b. Falls back to device `geocoding` package (locale: en_LB)
   c. Final fallback: "Pinned location in Lebanon"
4. User enters phone number + delivery note
5. Save button enabled when: location selected + phone filled + note filled + not resolving
6. Save creates/updates Address in Firestore via AddressViewModel

**"Use my location" Flow**:
1. Calls `DeviceLocationService.getCurrentLocation()`
2. Handles `LocationServiceException` with user-friendly message
3. Sets source as `'current_location'`

### 11.3 DeviceLocationService
- Checks if location services are enabled
- Requests permission (handles denied/deniedForever)
- Returns `{'lat': double, 'lng': double}` on success
- Reverse geocode via `geocoding` package with locale `en_LB`

### 11.4 GooglePlacesService
- `autocomplete(query, apiKey)` — filtered to country `'lb'` (Lebanon)
- `reverseGeocode(lat, lng, apiKey)` — HTTP call to Google Geocoding API
- Returns formatted address string

---

## 12. Delivery Pricing Algorithm

### 12.1 DeliveryPlanning (Haversine Formula)

```dart
static double haversineDistanceMeters({lat1, lng1, lat2, lng2}) {
  const earthRadius = 6371000.0; // meters
  final dLat = toRadians(lat2 - lat1);
  final dLng = toRadians(lng2 - lng1);
  final a = sin(dLat/2)^2 + cos(lat1) * cos(lat2) * sin(dLng/2)^2;
  return 2 * earthRadius * asin(sqrt(a));
}
```

### 12.2 DeliveryPricing (Fee Calculation)

**Input Parameters** (all from admin-configurable `delivery_settings/config`):
- `distanceMeters` — Haversine result
- `fuelPricePerLiter` — USD per liter
- `avgKilometersPerLiter` — vehicle efficiency
- `operationalOverheadUsd` — fixed overhead per delivery
- `profitMarginPercent` — percentage markup
- `minimumDeliveryFeeUsd` — floor
- `maximumDeliveryFeeUsd` — ceiling

**Algorithm**:
```
distanceKm = distanceMeters / 1000
litersUsed = distanceKm / avgKilometersPerLiter
fuelCostUsd = litersUsed * fuelPricePerLiter
beforeProfit = fuelCostUsd + operationalOverheadUsd
withProfit = beforeProfit * (1 + profitMarginPercent / 100)
finalFee = max(minimumFee, min(maximumFee, withProfit))
finalFee = round to 2 decimal places
```

**Return**: `DeliveryFeeResult(finalFeeUsd, fuelCostUsd, litersUsed)`

### 12.3 Locked Pricing Snapshot

At checkout, `buildLockedPricingSnapshot()` captures:
```json
{
  "deliveryFee": 4.50,
  "pricingVersion": 1,
  "fuelSource": "admin_config",
  "fuelPricePerLiter": 1.20,
  "routeDistanceMeters": 8500,
  "fuelCostUsd": 0.85,
  "litersUsed": 0.71
}
```
This is stored with the order so the price never changes after placement.

---

## 13. Order Tracking System

### 13.1 Order Status Enum
```dart
enum OrderStatus {
  awaitingConfirmation,
  preparing,
  donePreparing,
  outForDelivery,
  delivered,
  cancelled,
}
```

### 13.2 OrderTrackingScreen

**Auto-Refresh**: Every 2 minutes when status is `outForDelivery`

**Countdown Timer**: Local countdown that decrements every minute:
```dart
elapsed = now.difference(etaUpdatedAt).inMinutes
remaining = (etaMinutes - elapsed).clamp(0, etaMinutes)
```

**Timeline Widget** (`_TimelineStep`):
- Vertical line connecting circles
- Completed: Primary filled circle with check icon
- Current: Primary50 circle with white dot center, 2px border
- Future: Primary10 empty circle
- Line: primary (completed) or primary10 (future)

**Delivery Progress Card** (shown when outForDelivery):
- "Almost here!" when remainingMinutes <= 2
- "About X min" when countdown active
- "About X-Y min" when range available
- "Refresh estimate" button → calls `_refreshTracking()`
- "Received my order" PrimaryButton → `_confirmDelivered()`

### 13.3 Customer Confirmation
- `confirmDelivered(orderId)` marks the order as customer-confirmed
- Reloads order to show updated status

---

## 14. Admin Panel

### 14.1 Admin Orders Screen
- **Access Control**: Checks `authVm.isAdmin`, shows "You do not have permission" if false
- **Search**: TextField for order ID or customer name
- **Status Filter Chips**: Horizontal scrollable chips (All, Awaiting, Preparing, Done Preparing, Out for Delivery, Delivered, Cancelled)
- **Orders List**: Cards showing order ID, status badge, customer name, shipping address
- **Tap**: Navigates to admin order details

### 14.2 Admin Delivery Settings Screen

**10 configurable fields**:
1. Store Label (text)
2. Latitude (number)
3. Longitude (number)
4. Fallback Fuel Price $/L (number)
5. Avg km/L (number)
6. Overhead $ (number)
7. Profit Margin % (number)
8. Min Fee $ (number)
9. Max Fee $ (number)
10. Service Minutes/Stop (number)

**Save**: Validates, creates DeliverySettings model, calls viewModel.save(), shows snackbar

---

## 15. Profile & Settings

### 15.1 Profile Screen
- **Avatar**: 40dp radius CircleAvatar with network image or person icon
- **Name + Email**: Section header + muted body text
- **Edit Profile Button**: Pill chip with primary10 bg
- **Menu Items**: My Orders, Manage Orders (admin only), Addresses, Payment Info, Notifications, Help & Support, Privacy & Security
- **Logout**: Primary5 container with logout icon + text

### 15.2 Edit Profile Screen
- First Name, Last Name, Email fields
- Validation: all required
- On save: calls `authVm.updateProfile()` → shows snackbar with result.message
- If email changed: "A verification email has been sent to your new address."

### 15.3 Notifications Screen
**4 Toggle Switches** (persisted to Firestore):
- Order Updates (default: ON) — "Get notified about your order status"
- Promotions (default: OFF) — "Receive special offers and deals"
- New Arrivals (default: OFF) — "Know when new flowers are available"
- Delivery Alerts (default: ON) — "Real-time delivery tracking updates"

**Optimistic Update**: Changes UI immediately, reverts on save failure with snackbar error.

### 15.4 Privacy & Security Screen
**3 Toggle Switches** (persisted to Firestore):
- Biometric Login (default: OFF) — "Use fingerprint or face to sign in"
- Two-Factor Authentication (default: OFF) — "Add an extra layer of security"
- Usage Analytics (default: ON) — "Help us improve your experience"

**Note**: "Biometric login and two-factor authentication are saved as preferences only for now."

---

## 16. Favorites System

### 16.1 FavoritesScreen
- **AppBar**: "My Favorites" with back arrow
- **Empty**: EmptyState with favorite_border icon, "No favorites yet", "Browse Flowers" button
- **Grid**: 2-column GridView using ProductCard with `showDescription: true`
- **Tab**: BottomNavBar currentIndex: 2

### 16.2 Toggle Logic
- `FavoritesViewModel.toggleFavorite(product)` — adds/removes from Firestore subcollection
- `isFavorite(productId)` — checks local set for instant UI response
- Synced via Firestore listener when user binds

---

## 17. Reusable Widgets

| Widget | Purpose | Key Props |
|--------|---------|-----------|
| `PrimaryButton` | Main CTA button | text, isLoading, onPressed (null = disabled) |
| `AppTextField` | Styled input | controller, hintText, prefixIcon, keyboardType, maxLines, validator |
| `BottomNavBar` | 5-tab navigation | currentIndex (Home/Shop/Favorites/Cart/Profile) |
| `ProductCard` | Grid product card | product, showDescription, onAddToCartSuccess |
| `SectionHeader` | Title + View All | title, onViewAll callback |
| `ShimmerLoading` | Skeleton placeholder | width, height, borderRadius |
| `ImageCarousel` | Multi-image swiper | images list, height |
| `RatingStars` | Star rating display | rating value |
| `OrderStatusBadge` | Colored status chip | OrderStatus enum |
| `EmptyState` | No-data view | icon, title, subtitle, actionLabel, onAction |
| `ErrorState` | Error with retry | message, onRetry |
| `ConfirmationDialog` | Destructive confirm | title, message, confirmLabel, isDestructive |
| `AddressLocationPicker` | Map + pin | selectedLocation, onLocationChanged, statusMessage |
| `AddressSearchSheet` | Places autocomplete | Bottom sheet with search results |
| `AddToCartFeedback` | Success snackbar | Shows product name added confirmation |
| `RemoteImage` | Network image | URL with placeholder/error fallback |
| `FeatureBullet` | Bullet point item | icon + text for feature lists |

---

## 18. Database Schema (Complete)

### 18.1 Firestore Collections

```
users/{uid}
  ├── id: string
  ├── email: string
  ├── firstName: string
  ├── lastName: string
  ├── username: string (auto-generated: "first.last")
  ├── avatarUrl: string
  ├── role: "customer" | "admin"
  ├── isAdmin: boolean (derived from claims)
  ├── createdAt: Timestamp
  ├── updatedAt: Timestamp
  ├── notificationPreferences: { orderUpdates, promotions, newArrivals, deliveryAlerts }
  ├── privacySettings: { biometrics, twoFactor, analytics }
  │
  ├── favorites/{productId}
  │     └── (product data snapshot)
  ├── addresses/{addressId}
  │     ├── fullName, phone, line1, city, postalCode, country
  │     ├── deliveryNote, locationLabel, locationSource
  │     ├── location: { lat: number, lng: number }
  │     └── isDefault: boolean
  └── cart/active/items/{productId}
        ├── productId, quantity, addedAt

products/{productId}
  ├── id, title, description, price
  ├── thumbnail: string (download URL)
  ├── images: string[] (multiple URLs)
  ├── category: string (event name)
  ├── flowerType: string
  ├── rating: number, stock: number
  ├── brand: string
  ├── discountPercentage: number
  ├── featured: boolean, active: boolean
  └── storagePath: string

categories/{categoryId}
  ├── name: string
  ├── sortOrder: number
  └── active: boolean

flower_types/{flowerTypeId}
  └── flowerTypeName: string

orders/{orderId}
  ├── id, userId, status: string, paymentStatus: string
  ├── items: [{ productId, title, price, quantity, thumbnail }]
  ├── totalAmount, subtotalAmount, deliveryFee: number
  ├── shippingAddress: string, shippingAddressData: map
  ├── createdAt, updatedAt, lastStatusChangedAt: Timestamp
  ├── deliveredAt: Timestamp?, customerConfirmedDelivered: boolean
  ├── adminNote: string, cancelReason: string
  ├── assignedAdminUid: string, courierLabel: string
  ├── deliveryEstimateMinutes, deliveryDistanceMeters: number
  ├── deliveryEtaMinutes, deliveryEtaRangeMinMinutes, deliveryEtaRangeMaxMinutes
  ├── deliveryEtaUpdatedAt: Timestamp
  ├── deliveryLocation: { lat, lng }, storeLocation: { lat, lng }
  ├── deliveryPricing: { deliveryFee, pricingVersion, fuelSource, ... }
  ├── currency: "USD"
  └── events/{eventId}
        ├── type: string (status name or "admin_note")
        ├── message: string
        ├── createdAt: Timestamp
        ├── actor: string, actorUid: string
        └── metadata: map

delivery_settings/config (singleton document)
  ├── storeLabel: string
  ├── storeLocation: { lat: number, lng: number }
  ├── fallbackFuelPricePerLiter: number
  ├── avgKilometersPerLiter: number
  ├── operationalOverheadUsd: number
  ├── profitMarginPercent: number
  ├── minimumDeliveryFeeUsd: number
  ├── maximumDeliveryFeeUsd: number
  └── serviceMinutesPerStop: number
```

### 18.2 Composite Indexes
- `orders`: (userId ASC, createdAt DESC)
- `categories`: (active ASC, sortOrder ASC)

---

## 19. Navigation System

### 19.1 Route Transitions
- **Default**: SlideTransition from right (300ms, Curves.easeOutCubic)
- **Modals**: Fade + scale

### 19.2 Navigation Helper
```dart
void popOrGoTo(BuildContext context, String route) {
  if (Navigator.canPop(context)) {
    Navigator.pop(context);
  } else {
    Navigator.pushReplacementNamed(context, route);
  }
}
```
This prevents blank screens when deep-linking or returning from killed processes.

---

## 20. CI/CD Pipeline

- **Trigger**: Push to `main` branch
- **Steps**: Flutter setup → `flutter pub get` → `flutter build apk --debug`
- **Output**: Debug APK uploaded as GitHub Actions artifact
- **Platform**: Primarily Android; iOS/Web/Desktop supported by codebase

---

*Document generated for La Rose project — May 2026*
