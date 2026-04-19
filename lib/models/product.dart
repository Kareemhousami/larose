/// Represents a product stored in Firestore.
class Product {
  /// Firestore document ID used for lookups.
  final String docId;

  /// Unique product identifier.
  final int id;

  /// Product display name.
  final String title;

  /// Product description text.
  final String description;

  /// Price in USD.
  final double price;

  /// URL of the product thumbnail image.
  final String thumbnail;

  /// List of product image URLs.
  final List<String> images;

  /// Product category name.
  final String category;

  /// Product flower type name.
  final String flowerType;

  /// Average rating (0-5).
  final double rating;

  /// Current stock count.
  final int stock;

  /// Product brand name.
  final String brand;

  /// Discount percentage.
  final double discountPercentage;

  /// Whether the product is featured.
  final bool featured;

  /// Whether the product is active for sale.
  final bool isActive;

  /// Firebase Storage path for this product's image.
  final String storagePath;

  /// Creates a [Product] instance.
  const Product({
    this.docId = '',
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.thumbnail,
    this.images = const [],
    this.category = '',
    this.flowerType = '',
    this.rating = 0.0,
    this.stock = 0,
    this.brand = '',
    this.discountPercentage = 0.0,
    this.featured = false,
    this.isActive = true,
    this.storagePath = '',
  });

  /// Creates a [Product] from Firestore or JSON data.
  factory Product.fromJson(Map<String, dynamic> json, {String? docId}) {
    final rawId = json['id'] ?? docId;
    final parsedId = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '') ?? 0;
    return Product(
      docId: docId ?? json['docId'] as String? ?? '$parsedId',
      id: parsedId,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: _resolvePrice(json),
      thumbnail: json['thumbnail'] as String? ?? json['imageUrl'] as String? ?? '',
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      category: json['category'] as String? ?? '',
      flowerType: json['flowerType'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      stock: json['stock'] as int? ?? json['inventoryCount'] as int? ?? 0,
      brand: json['brand'] as String? ?? '',
      discountPercentage:
          (json['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      featured: json['featured'] as bool? ?? false,
      isActive: json['active'] as bool? ?? true,
      storagePath: json['storagePath'] as String? ?? '',
    );
  }

  /// Converts this product to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'docId': docId,
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'thumbnail': thumbnail,
      'images': images,
      'category': category,
      'flowerType': flowerType,
      'rating': rating,
      'stock': stock,
      'brand': brand,
      'discountPercentage': discountPercentage,
      'featured': featured,
      'active': isActive,
      'storagePath': storagePath,
    };
  }

  Product copyWith({
    String? thumbnail,
    List<String>? images,
    String? storagePath,
  }) {
    return Product(
      docId: docId,
      id: id,
      title: title,
      description: description,
      price: price,
      thumbnail: thumbnail ?? this.thumbnail,
      images: images ?? this.images,
      category: category,
      flowerType: flowerType,
      rating: rating,
      stock: stock,
      brand: brand,
      discountPercentage: discountPercentage,
      featured: featured,
      isActive: isActive,
      storagePath: storagePath ?? this.storagePath,
    );
  }

  static double _resolvePrice(Map<String, dynamic> json) {
    final price = json['price'];
    if (price is num) {
      return price.toDouble();
    }
    final minor = json['priceMinor'];
    if (minor is num) {
      return minor.toDouble() / 100;
    }
    return 0.0;
  }
}
