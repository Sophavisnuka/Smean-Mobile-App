import 'package:flutter/material.dart';
import 'package:smean_mobile_app/data/models/card_model.dart';
import 'package:smean_mobile_app/ui/widgets/recent_activity_card.dart';

/// Audio cards list builder
class AudioListWidget extends StatelessWidget {
  const AudioListWidget({
    super.key,
    required this.cards,
    required this.isKhmer,
    required this.onEdit,
    required this.onDelete,
    required this.onFavoriteToggle,
    required this.onRefresh,
  });

  final List<CardModel> cards;
  final bool isKhmer;
  final Function(CardModel) onEdit;
  final Function(CardModel) onDelete;
  final Function(CardModel) onFavoriteToggle;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: cards.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (_, _) => const SizedBox(height: 15),
      itemBuilder: (context, index) {
        final card = cards[index];
        return RecentActivityCard(
          isKhmer: isKhmer,
          card: card,
          onEdit: () => onEdit(card),
          onDelete: () => onDelete(card),
          onFavoriteToggle: () => onFavoriteToggle(card),
          onRefresh: onRefresh,
        );
      },
    );
  }
}
