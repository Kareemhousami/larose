0# La Rose - Presentation Guide (10-20 Minutes)

## Team: Karim & Tala (50/50 Split)

---

## Role Assignment

| Member | Sections | Time |
|--------|----------|------|
| **Tala** | App Intro, Tech Stack, Authentication, Onboarding, UI/UX Design System, Profile, Favorites, Notifications, Privacy, Settings, Reusable Widgets | ~10 min |
| **Karim** | Home Screen, Shopping, Product Details, Cart, Checkout, Google Maps, Address System, Delivery Pricing, Order Tracking, Admin Panel, Database | ~10 min |

---

## TALA'S PART (~10 min)

**You open the presentation. Introduce the app, cover tech stack, then own all auth, user experience design, profile features, and UI system.**

---

### What to Present:

**1. App Introduction (1 min)**
- "La Rose is a flower delivery app for the Lebanese market"
- Built with Flutter + Firebase — single codebase for Android, iOS, Web, Desktop
- No backend server — all logic runs in Dart, Firestore handles data
- Cash-on-delivery only — no payment processor integration needed

**2. Tech Stack Overview (1 min)**
- Flutter (Dart 3.10.8+) — cross-platform framework
- Firebase Auth — email/password authentication
- Cloud Firestore — NoSQL database
- Firebase Storage — product images
- Google Maps Flutter — interactive map picker
- Provider (v6.1.2) — state management with ChangeNotifier
- Google Fonts — Plus Jakarta Sans + Great Vibes
- GitHub Actions — auto-builds APK on push to main

**3. Architecture (1 min)**
- MVVM pattern: Models → Services → ViewModels → Views
- 8 Providers registered at app start (AuthViewModel, ProductViewModel, CartViewModel, FavoritesViewModel, AddressViewModel, OrdersViewModel, AdminOrdersViewModel, AdminDeliverySettingsViewModel)
- ProxyProviders: Cart, Favorites, Addresses, Orders automatically rebind when user changes
- 90+ Dart view files across 10 feature modules
- 18 reusable widget components

**4. Onboarding Flow (1 min)**
- 3-page swipeable intro shown only on first launch
- Page 1: "Welcome to La Rose" — flower icon, discover bouquets
- Page 2: "Easy Ordering" — shopping bag icon, cart + checkout + COD
- Page 3: "Fast Delivery" — delivery icon, same-day + real-time tracking
- Animated dot indicators (active: 24dp pill, inactive: 8dp circle)
- Skip button top-right, Next/Get Started button bottom
- Persists `has_seen_onboarding` flag in SharedPreferences

**5. Authentication System (2 min)**
- **Login Screen**:
  - La Rose logo (64px circle with florist icon) + Great Vibes brand name
  - Email field with mail icon, password field with visibility toggle
  - "Forgot Password?" link (right-aligned)
  - Smart error notices: "This account does not exist" with "Create account" button
  - "Don't have an account? Join the Garden" link

- **Signup Screen**:
  - "Join the Garden" heading + "LA ROSE" tag
  - Full Name (auto-splits: "John Doe" → firstName: John, lastName: Doe)
  - Email + Password (min 6 chars)
  - Error: "Account already exists" with "Go to login" button

- **Password Reset**:
  - lock_reset icon, email field, sends Firebase reset email
  - Shows success indicator + "Resend Link" option

- **Error Handling**: Maps Firebase codes to friendly messages:
  - `user-not-found` → "This account does not exist. Create one instead."
  - `email-already-in-use` → "An account with this email already exists."
  - `wrong-password` → "Incorrect password. Please try again."
  - `network-request-failed` → "No internet connection."
  - `requires-recent-login` → "Please sign in again before changing your email."

- **Session**: Firebase AuthStateChanges stream, persists across app restarts
- **Admin Detection**: Firebase custom claims (`tokenResult.claims['admin']`)
- **Dark Mode**: Toggle persisted in SharedPreferences, available on login screen

**6. Profile System (1 min)**
- Profile screen: avatar (CircleAvatar with network image), name, email, "Edit Profile" chip
- Menu items: My Orders, Manage Orders (admin only), Addresses, Payment, Notifications, Help, Privacy
- Edit Profile: first name + last name + email with validation
  - Email change → sends verification email: "A verification email has been sent to your new address"
- Logout: clears session, navigates to login, removes all routes

**7. Notifications & Privacy (1 min)**
- **Notifications Screen** (4 toggles persisted to Firestore):
  - Order Updates (ON) ��� "Get notified about your order status"
  - Promotions (OFF) — "Receive special offers and deals"
  - New Arrivals (OFF) — "Know when new flowers are available"
  - Delivery Alerts (ON) — "Real-time delivery tracking updates"
  - Optimistic update: UI changes instantly, reverts on save failure

- **Privacy & Security Screen** (3 toggles):
  - Biometric Login (OFF) — "Use fingerprint or face to sign in"
  - Two-Factor Auth (OFF) ��� "Add an extra layer of security"
  - Usage Analytics (ON) — "Help us improve your experience"

**8. Favorites System (30 sec)**
- Heart icon on every product card — toggles favorite in Firestore subcollection
- Dedicated screen: 2-column grid with full ProductCard widgets
- Empty state: "No favorites yet" + "Browse Flowers" button
- Synced across devices via Firestore

**9. UI/UX Design System (1 min)**
- **Colors**: Primary #C8828E (rose pink), 7 opacity variants for different UI elements
- **Typography**: Plus Jakarta Sans (all text), Great Vibes (brand wordmark only)
- **Spacing**: 16dp padding, 16dp card gaps, 24dp section spacing
- **Border Radius**: 8dp (default), 16dp (large), 24dp (XL), 9999dp (pill)
- **Buttons**: 48dp height, stadium border, elevation 4 with primary30 shadow
- **Cards**: Surface color, radiusXl, primary5 border, elevation 1
- **Dark Mode**: Deep burgundy (#221015) background, slate-800 surfaces, slate-100 text
- **Reusable Widgets**: PrimaryButton, AppTextField, EmptyState, ErrorState, ShimmerLoading, ConfirmationDialog, ProductCard, OrderStatusBadge, BottomNavBar, SectionHeader, RatingStars, ImageCarousel

**10. Settings & Legal (30 sec)**
- Settings screen with menu items
- Privacy Policy, Terms of Service, FAQ (expandable accordion), Contact Us (email + phone links), About (company info + version)

---

### If Tala is Asked:

| Question | Answer |
|----------|--------|
| How does login error handling work? | Firebase error codes mapped to user-friendly messages with contextual action buttons (go to signup/login) |
| How is the user profile stored? | Firestore document at `users/{uid}` with subcollections for favorites, addresses, cart |
| How does dark mode persist? | SharedPreferences key `'dark_mode'`, read on AuthViewModel.init(), toggles with notifyListeners() |
| How are notification preferences saved? | Stored as a map in user's Firestore document field `notificationPreferences`, optimistic UI updates |
| What pattern is used for state management? | Provider with ChangeNotifier — each feature has its own ViewModel |
| How does the favorite toggle work? | FavoritesViewModel writes to `users/{uid}/favorites/{productId}` subcollection, local set for instant UI |
| Why Provider over BLoC or Riverpod? | Simpler, officially recommended, sufficient for medium-sized apps |
| How is the theme organized? | Single AppTheme class with all colors, typography methods, spacing constants, and ThemeData builders |
| What fonts are used? | Plus Jakarta Sans for all text, Great Vibes for the "La Rose" brand wordmark |
| How does signup split the name? | Regex split on whitespace: first word = firstName, rest joined = lastName |
| What validation exists on signup? | Name required, email required, password min 6 characters |
| How does email change work? | Calls `verifyBeforeUpdateEmail()` — Firebase sends verification to new address |
| What happens on admin detection? | `getIdTokenResult(true)` checks `claims['admin']`, sets `isAdmin` flag on User model |
| How does onboarding only show once? | SharedPreferences flag `has_seen_onboarding` = true after completion |
| What are the reusable widgets? | 18 widgets: PrimaryButton, AppTextField, BottomNavBar, ProductCard, ShimmerLoading, EmptyState, ErrorState, ConfirmationDialog, AddressLocationPicker, etc. |

---

## KARIM'S PART (~10 min)

**You handle the home screen, shopping, cart, checkout, all maps/location, delivery pricing, order tracking, admin, and database.**

---

### What to Present:

**1. Home Screen (1.5 min)**
- **AppBar**: Hamburger menu, "La Rose" in Great Vibes, profile + settings icons
- **Search Bar**: Live search with debounce, clear button, searches product titles/descriptions
- **Hero Card**: 288dp, Firebase Storage background image, gradient overlay, "NEW COLLECTION" badge, "Explore Our Flower Shop" heading, "Shop Now" CTA button
- **Quick Actions**: 4 buttons (Events, Types, Favorites, Orders) — 60px icon containers
- **Our Story**: Card with brand story paragraph, "Learn more about us" button
- **Promotions**: 2 marketing cards:
  - Welcome: "15% off + free delivery on first order" (gradient primary bg)
  - Birthday: "25% off for Jan 1 birthdays" (surface bg with border)
- **Featured Bouquets**: Horizontal scroll of product cards (max 10), shimmer loading state, empty state messaging
- **Navigation Drawer**: 7 menu items with icon containers and chevrons
- **Pull to Refresh**: RefreshIndicator triggers product reload

**2. Shopping System (1 min)**
- **Shop Screen**: "Choose How To Browse" — two large cards:
  - "Browse Events" (Anniversary, Birthday, Congratulations, Get Well, Love, Sympathy, Thank You, Wedding)
  - "Browse Flower Types" (Roses, Tulips, Orchids, Lilies, Sunflowers, etc.)
- **Collection Screen**: Grid of products filtered by category or flower type
- **Product Card**: Image (1:1 ratio) + favorite overlay + title + tags + price + add-to-cart button
- **Product Details**: Multi-image carousel, full description, reviews section, quantity selector

**3. Cart System (1 min)**
- Cart screen: Product image (80x80) + title + price + delete icon + quantity buttons (+/-)
- Total displayed at bottom in sticky footer
- "Clear cart" with confirmation dialog ("Clear cart? Remove all items?")
- Empty state: "Your cart is empty" + "Start Shopping" button
- Cart persisted in Firestore at `users/{uid}/cart/active/items/{productId}`

**4. Google Maps & Address System (2 min)**
- **AddressLocationPicker Widget**:
  - Google Maps centered on Lebanon (33.8547, 35.8623) at zoom 8.4
  - User taps map → pin drops → camera animates to zoom 16
  - Marker placed at selected coordinates
  - "Use my location" button for GPS

- **Reverse Geocoding** (3-layer fallback):
  1. Google Places API reverse geocode (via API key)
  2. Device geocoding package (locale: en_LB)
  3. Fallback: "Pinned location in Lebanon"

- **Google Places Autocomplete**: Filtered to country `'lb'` (Lebanon only)

- **Device Location Service**:
  - Checks location services enabled
  - Requests permission (handles denied/deniedForever gracefully)
  - Returns lat/lng coordinates
  - Fallback to manual pin if services unavailable

- **Address Form**: Phone number + Delivery note (building/floor) + Save button
  - Validates: location must be selected + phone required + note required
  - Supports both Add and Edit mode (passes Address as route argument)
  - Auto-sets as default if first address

**5. Delivery Pricing Algorithm (2 min)**
- **Haversine Formula**: Calculates straight-line distance between store and customer:
  ```
  Earth radius = 6,371,000 meters
  Uses: sin, cos, asin, sqrt for spherical geometry
  ```

- **Fee Calculation**:
  ```
  distanceKm = distanceMeters / 1000
  litersUsed = distanceKm / avgKmPerLiter
  fuelCost = litersUsed * fuelPricePerLiter
  baseCost = fuelCost + operationalOverhead
  withProfit = baseCost * (1 + profitMargin/100)
  finalFee = clamp(withProfit, minFee, maxFee)
  finalFee = round to 2 decimals
  ```

- **Locked Pricing Snapshot**: At checkout, captures all pricing parameters + calculated fee → stored with order permanently so fee never changes after placement

- **ETA Estimation**: serviceMinutesPerStop + travel time, shown as min/max range

- **Checkout Integration**:
  - Pricing loads automatically when address selected
  - Request key prevents duplicate API calls during widget rebuilds
  - Place Order button disabled until pricing confirmed
  - Shows: Products subtotal + Delivery fee + Total

**6. Order Tracking (1 min)**
- **Status Flow**: awaitingConfirmation → preparing → donePreparing → outForDelivery → delivered (or cancelled)
- **Timeline Widget**: Vertical line with circles (completed=check, current=pulsing dot, future=empty)
- **Auto-Refresh**: Polls server every 2 minutes when `outForDelivery`
- **Countdown Timer**: Local minute-by-minute countdown from ETA
  - "About X min" normally
  - "Almost here!" when <= 2 minutes
  - Range: "About X-Y min" when range available
- **Customer Confirmation**: "Received my order" button → marks order as customer-confirmed
- **Refresh Button**: Manual "Refresh estimate" recalculates ETA from server

**7. Admin Panel (1 min)**
- **Admin Orders Screen**:
  - Access: only if `authVm.isAdmin == true`
  - Search by order ID or customer name
  - Status filter chips (All, Awaiting, Preparing, Done Preparing, Out for Delivery, Delivered, Cancelled)
  - Each order card: ID, status badge, customer name, shipping address
  - Pull to refresh

- **Admin Order Details**: Full order view, status transition buttons, admin notes, cancel orders, assign admin

- **Admin Delivery Settings** (10 configurable fields):
  - Store Label, Latitude, Longitude
  - Fuel Price ($/L), Vehicle Efficiency (km/L)
  - Operational Overhead ($), Profit Margin (%)
  - Minimum Fee ($), Maximum Fee ($)
  - Service Minutes Per Stop
  - All fields use AppTextField with appropriate icons
  - Save → instantly affects all customer checkout pricing

**8. Database Schema (30 sec)**
- `users/{uid}` — profile + subcollections (favorites, addresses, cart)
- `products/{productId}` — title, price, images, category, flowerType, rating
- `categories/{categoryId}` — name, sortOrder, active
- `flower_types/{id}` — flowerTypeName
- `orders/{orderId}` — full order data + `events/{eventId}` subcollection (timeline)
- `delivery_settings/config` — singleton with all pricing parameters
- Currency: USD throughout

---

### If Karim is Asked:

| Question | Answer |
|----------|--------|
| Why Haversine instead of Google Directions API? | Simpler, no extra API cost, sufficient for straight-line delivery distance in a small country |
| How is the delivery fee calculated? | Distance-based: fuel cost (distance/efficiency * fuel price) + overhead, * profit margin, clamped between min/max |
| What if admin changes pricing after order placed? | Pricing snapshot is locked at checkout — stored permanently with the order |
| What if location services are denied? | Graceful fallback with error message, user can still pin manually on map |
| How does the map picker work? | Google Maps widget centered on Lebanon, user taps to drop pin, reverse geocode resolves address label |
| Why filter to Lebanon? | App targets Lebanese market, `countryCode: 'lb'` in Places API |
| How does the countdown timer work? | Calculates elapsed minutes since ETA was set, subtracts from total ETA, clamps at 0, updates every minute |
| How does auto-refresh work? | Timer.periodic every 2 minutes calls server for fresh order data while outForDelivery |
| How are orders stored? | Firestore document with full order data + events subcollection for timeline |
| What status transitions exist? | awaitingConfirmation → preparing → donePreparing → outForDelivery �� delivered (or cancelled at any point) |
| How does admin filter orders? | AdminOrdersViewModel has statusFilter and searchQuery, filteredOrders getter combines both |
| What does "pricing snapshot" contain? | deliveryFee, pricingVersion, fuelSource, fuelPricePerLiter, routeDistanceMeters, fuelCostUsd, litersUsed |
| How does checkout prevent price drift? | Button disabled until checkoutTotalAmount is loaded; uses request key to avoid duplicate pricing calls |
| How does the hero image load? | Firebase Storage reference `flower_types/roses/1.png` → getDownloadURL() at runtime |
| What happens on "Received my order"? | Sets customerConfirmedDelivered=true in Firestore, reloads order to update UI |
| How does search work? | ProductViewModel.searchProducts() filters by title/description matching the query |
| How is the cart persisted? | Firestore subcollection at `users/{uid}/cart/active/items/{productId}` with quantity field |
| What if no addresses saved at checkout? | Shows EmptyState with "Add a delivery address" + button to add address screen |

---

## Live Demo Flow (If Applicable)

1. **Tala**: Open app → show onboarding (3 pages) → skip to login
2. **Tala**: Sign up with name + email → show error handling → successful signup
3. **Karim**: Home screen tour → search → hero card → quick actions
4. **Karim**: Shop → Browse Events → pick a category → view product → add to cart
5. **Karim**: Cart → adjust quantity → proceed to checkout
6. **Karim**: Address picker → tap map → show reverse geocode → save address
7. **Karim**: Checkout → see delivery fee calculated → place order
8. **Karim**: Orders → tap order → show tracking timeline + ETA
9. **Tala**: Profile → edit name → notifications toggles → privacy toggles
10. **Tala**: Favorites → show saved products → settings screens

---

## Quick Answers (Either Member)

| Question | Answer |
|----------|--------|
| Why Flutter? | Cross-platform: one codebase for 6 platforms |
| Why Firebase? | No server needed, real-time sync, built-in auth, free tier |
| Why no Cloud Functions? | All logic in Dart, reduces complexity and cost |
| Why cash-on-delivery? | Simpler for Lebanese market, no payment processor needed |
| Is it deployed? | GitHub Actions builds APK on every push to main |
| Offline support? | Firestore has built-in offline caching |
| How many screens? | 90+ Dart view files, 30+ named routes |
| How many widgets? | 18 reusable custom widgets |
| Currency? | USD (hardcoded) |
| Target market? | Lebanon (Places API filtered, geocoding locale: en_LB) |

---

*Total time: ~20 minutes including Q&A*
