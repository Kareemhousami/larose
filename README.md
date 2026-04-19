# La Rose

La Rose is a Flutter flower delivery application for browsing bouquets, saving favorites, managing delivery addresses, placing cash-on-delivery orders, and tracking fulfillment in real time. The app is backed directly by Firebase and includes both customer-facing flows and admin order management screens.

## Overview

This repository contains the production Flutter client for La Rose. The codebase is organized around a straightforward app structure:

- `Provider` for application state
- `Firebase Auth` for sign-in and session handling
- `Cloud Firestore` for catalog, carts, addresses, orders, and admin-managed data
- `Cloud Storage` for product imagery
- `Google Maps` for delivery address selection and map-based checkout inputs

## Highlights

- Firebase-backed authentication, catalog, cart, favorites, addresses, and orders
- Delivery-aware checkout with map-based address selection
- Customer order history and live tracking timeline
- Admin order operations, notes, status updates, and delivery settings
- Flutter codebase with no Cloud Functions dependency for core order workflows

## Feature Areas

### Customer experience

- Browse featured bouquets and collections
- Search catalog items
- Save and manage favorites
- Add and edit delivery addresses
- Place cash-on-delivery orders
- Review order history and tracking status

### Admin operations

- View all orders
- Review order details
- Update order status
- Add admin notes
- Configure delivery settings used by checkout logic

## Stack

- Flutter
- Firebase Authentication
- Cloud Firestore
- Cloud Storage
- Google Maps
- Provider

## Project Structure

```text
lib/
  app/         App shell, routes, navigation, and theme wiring
  config/      Firebase and maps configuration
  models/      Domain models for products, orders, addresses, and users
  services/    Firebase, storage, and business-logic services
  viewmodels/  Provider state management
  views/       Customer and admin UI screens
  widgets/     Shared presentation components
```

## Firebase Data Model

- `users/{uid}`
- `users/{uid}/favorites/{productId}`
- `users/{uid}/addresses/{addressId}`
- `users/{uid}/cart/active/items/{productId}`
- `products/{productId}`
- `categories/{categoryId}`
- `orders/{orderId}`
- `orders/{orderId}/events/{eventId}`
- `delivery_settings/{docId}`

## Getting Started

### Prerequisites

- Flutter SDK
- A Firebase project
- Android Studio, Xcode, or another supported Flutter target environment

### Firebase Setup

1. Create or connect a Firebase project.
2. Enable Email/Password authentication.
3. Add your Firebase platform configuration files for the targets you use.
4. Deploy Firestore rules and indexes:

```powershell
firebase deploy --only firestore:rules,firestore:indexes
```

5. Deploy Storage rules if you use Firebase Storage in your environment:

```powershell
firebase deploy --only storage
```

6. Populate Firestore with your production catalog and supporting collections.

### Maps Setup

- Provide a valid Google Maps API key for the platforms you build.
- Make sure the app configuration for maps matches your target environments.

## Run Locally

```powershell
flutter pub get
flutter run
```

## Quality Checks

```powershell
flutter analyze
```

## Repository Standards

- Internal planning files and generated automation output are excluded from the public repo surface.
- GitHub issue templates and a pull request template are included for cleaner collaboration.
- GitHub Actions runs Flutter static analysis on pushes and pull requests.

## Notes

- Product and catalog imagery is served from Firebase Storage.
- Core checkout and order workflows run in the Flutter/Dart codebase.
- Internal planning files, generated reports, and local automation artifacts are intentionally excluded from the repository surface.
