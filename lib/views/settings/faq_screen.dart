import 'package:flutter/material.dart';
import '../../app/navigation.dart';
import '../../app/routes.dart';
import '../../theme/app_theme.dart';

/// FAQ screen with common questions organized by topic.
class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  static const _faqs = <_FaqItem>[
    _FaqItem(
      question: 'How do I place an order?',
      answer:
          'Browse our collection, add items to your cart, and proceed to checkout. '
          'Enter your shipping address and confirm your order. Payment is cash on delivery.',
    ),
    _FaqItem(
      question: 'What payment methods do you accept?',
      answer:
          'We currently accept Cash on Delivery only. Your order is confirmed when placed '
          'and payment is collected when your flowers arrive.',
    ),
    _FaqItem(
      question: 'How long does delivery take?',
      answer:
          'We offer same-day delivery for orders placed before 2:00 PM. Orders placed after '
          '2:00 PM will be delivered the next day. Delivery times may vary during peak seasons.',
    ),
    _FaqItem(
      question: 'Can I track my order?',
      answer:
          'Yes! Go to My Orders and tap on any order to see its tracking timeline. '
          'You will see real-time status updates from order confirmation to delivery.',
    ),
    _FaqItem(
      question: 'What if my flowers arrive damaged?',
      answer:
          'We take great care in packaging, but if your flowers arrive damaged, please contact us '
          'within 24 hours with a photo. We will arrange a replacement or full refund.',
    ),
    _FaqItem(
      question: 'Can I cancel or modify my order?',
      answer:
          'You can request a cancellation before your order enters the "Packed" stage. '
          'Please contact our support team as soon as possible for modifications.',
    ),
    _FaqItem(
      question: 'Do you deliver to all areas?',
      answer:
          'We currently deliver within Beirut and surrounding areas. We are expanding our '
          'delivery zones regularly. Check your postal code during checkout for availability.',
    ),
    _FaqItem(
      question: 'How do I save my favorite bouquets?',
      answer:
          'Tap the heart icon on any product to save it to your favorites. You can view '
          'all your favorites from the Favorites tab in the bottom navigation.',
    ),
  ];

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
          onPressed: () => popOrGoTo(context, Routes.settings),
        ),
        title: Text(
          'FAQ',
          style: AppTheme.sectionHeader(
            color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppTheme.paddingHorizontal),
        itemCount: _faqs.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (_, index) {
          final faq = _faqs[index];
          return Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surfaceDark : AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              border: Border.all(color: AppTheme.primary5),
            ),
            child: Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.cardPadding,
                  vertical: 4,
                ),
                childrenPadding: const EdgeInsets.only(
                  left: AppTheme.cardPadding,
                  right: AppTheme.cardPadding,
                  bottom: AppTheme.cardPadding,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                ),
                iconColor: AppTheme.primary,
                collapsedIconColor: AppTheme.textMuted,
                title: Text(
                  faq.question,
                  style: AppTheme.productCardTitle(
                    color: isDark
                        ? AppTheme.textPrimaryDark
                        : AppTheme.textPrimary,
                  ).copyWith(fontSize: 14),
                ),
                children: [
                  Text(
                    faq.answer,
                    style: AppTheme.bodyText(
                      color: isDark
                          ? AppTheme.textSubtleDark
                          : AppTheme.textSubtle,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});
}
