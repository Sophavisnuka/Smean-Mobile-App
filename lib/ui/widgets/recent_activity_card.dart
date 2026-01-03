import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smean_mobile_app/core/constants/app_colors.dart';
import 'package:smean_mobile_app/data/models/card_model.dart';
import 'package:smean_mobile_app/ui/widgets/audio_details_screen.dart';

class RecentActivityCard extends StatelessWidget {
  final CardModel card;

  final bool isKhmer;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onRefresh;
  final String? searchQuery;

  const RecentActivityCard({
    super.key,
    required this.card,
    required this.isKhmer,
    this.onEdit,
    this.onDelete,
    this.onFavoriteToggle,
    this.onRefresh,
    this.searchQuery,
  });

  Widget _buildHighlightedText(String text, String? query) {
    if (query == null || query.isEmpty) {
      return Text(
        text,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      );
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    List<TextSpan> spans = [];

    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      final lowerChar = lowerText[i];

      // Check if this character matches any character in the query
      bool isHighlighted = lowerQuery.contains(lowerChar);

      spans.add(
        TextSpan(
          text: char,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            backgroundColor: isHighlighted
                ? Colors.yellow.withValues(alpha: 0.5)
                : Colors.transparent,
            color: Colors.black87,
          ),
        ),
      );
    }

    return RichText(text: TextSpan(children: spans));
  }

  @override
  Widget build(BuildContext context) {
    final createdAt = card.createdAt;
    final title = card.cardName;
    // Format the date as you like
    String formattedDate = isKhmer
        ? DateFormat('dd/MM/yyyy · HH:mm').format(createdAt)
        : DateFormat('MMM dd, yyyy · HH:mm').format(createdAt);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () async {
          final deleted = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (context) => AudioDetailsScreen(card: card),
            ),
          );

          // If the card was deleted in the details screen, refresh the list
          if (deleted == true && onRefresh != null) {
            onRefresh!();
          }
        },
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Row(
            children: [
              // Leading icon
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.mic, color: AppColors.primary, size: 24),
              ),
              SizedBox(width: 12),
              // Title, date, and favorite button
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHighlightedText(title, searchQuery),
                    SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            formattedDate,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        // Favorite button on the same line as date
                        if (onFavoriteToggle != null)
                          InkWell(
                            onTap: onFavoriteToggle,
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(
                                card.isFavorite
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                color: card.isFavorite
                                    ? Colors.amber
                                    : Colors.grey,
                                size: 22,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // Menu button at top right
              if (onEdit != null || onDelete != null)
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.grey, size: 24),
                  padding: EdgeInsets.zero,
                  onSelected: (value) {
                    if (value == 'edit' && onEdit != null) {
                      onEdit!();
                    } else if (value == 'delete' && onDelete != null) {
                      onDelete!();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.black54, size: 20),
                          SizedBox(width: 8),
                          Text(isKhmer ? 'កែប្រែ' : 'Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.redAccent, size: 20),
                          SizedBox(width: 8),
                          Text(isKhmer ? 'លុប' : 'Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
