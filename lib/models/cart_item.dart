import 'product.dart';

/// Represents a product added to the shopping cart with a quantity.
class CartItem {
  /// The product in the cart.
  final Product product;

  /// Quantity of this product.
  int quantity;

  /// Creates a [CartItem] with the given [product] and optional [quantity].
  CartItem({
    required this.product,
    this.quantity = 1,
  });

  /// Total price for this line item.
  double get totalPrice => product.price * quantity;

  /// Creates a [CartItem] from a JSON map.
  factory CartItem.fromJson(Map<String, dynamic> json) {
    final productJson = json['product'];
    if (productJson is Map<String, dynamic>) {
      return CartItem(
        product: Product.fromJson(productJson),
        quantity: json['quantity'] as int? ?? 1,
      );
    }

    final productId = json['productId'] ?? json['id'];
    return CartItem(
      product: Product.fromJson({
        'id': productId,
        'title': json['titleSnapshot'],
        'description': json['descriptionSnapshot'],
        'priceMinor': json['priceSnapshotMinor'],
        'thumbnail': json['imageSnapshot'],
        'category': json['categorySnapshot'],
        'stock': json['stockSnapshot'],
        'docId': json['docId'],
      }),
      quantity: json['quantity'] as int? ?? 1,
    );
  }

  /// Converts this cart item to a JSON map.
  Map<String, dynamic> toJson({bool forCart = false}) {
    if (forCart) {
      return {
        'productId': product.id,
        'docId': product.docId,
        'quantity': quantity,
        'titleSnapshot': product.title,
        'descriptionSnapshot': product.description,
        'imageSnapshot': product.thumbnail,
        'categorySnapshot': product.category,
        'priceSnapshotMinor': (product.price * 100).round(),
        'stockSnapshot': product.stock,
      };
    }

    return {
      'product': product.toJson(),
      'quantity': quantity,
    };
  }
}
