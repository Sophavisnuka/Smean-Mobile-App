import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smean_mobile_app/core/constants/app_colors.dart';
import 'package:smean_mobile_app/data/models/card_model.dart';
import 'package:smean_mobile_app/ui/screens/audio/audio_details_screen.dart';

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

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes;
    final secs = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final createdAt = card.createdAt;
    final title = card.cardName;
    final duration = card.audioDuration ?? 0;
    
    // Format the date as you like
    String formattedDate = isKhmer
        ? DateFormat('dd/MM/yyyy').format(createdAt)
        : DateFormat('MMM dd, yyyy').format(createdAt);

    return Card(
      // color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
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
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Leading icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.mic, color: AppColors.primary, size: 26),
              ),
              const SizedBox(width: 14),
              // Title, date, and duration
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with favorite badge
                    Row(
                      children: [
                        Expanded(
                          child: _buildHighlightedText(title, searchQuery),
                        ),
                        if (onFavoriteToggle != null && card.isFavorite)
                          GestureDetector(
                            onTap: onFavoriteToggle,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.amber.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.bookmark,
                                    color: Colors.amber.shade700,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isKhmer ? 'ចូលចិត្ត' : 'Saved',
                                    style: TextStyle(
                                      color: Colors.amber.shade700,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Date and Duration row
                    Row(
                      children: [
                        Icon(Icons.calendar_today, 
                          size: 13, 
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.access_time, 
                          size: 13, 
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDuration(duration),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Menu button
              if (onEdit != null || onDelete != null || onFavoriteToggle != null)
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, 
                    color: Colors.grey[400], 
                    size: 22,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onSelected: (value) {
                    if (value == 'favorite' && onFavoriteToggle != null) {
                      onFavoriteToggle!();
                    } else if (value == 'edit' && onEdit != null) {
                      onEdit!();
                    } else if (value == 'delete' && onDelete != null) {
                      onDelete!();
                    }
                  },
                  itemBuilder: (context) => [
                    if (onFavoriteToggle != null)
                      PopupMenuItem(
                        value: 'favorite',
                        child: Row(
                          children: [
                            Icon(
                              card.isFavorite ? Icons.bookmark_remove : Icons.bookmark_add,
                              color: Colors.amber.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              card.isFavorite
                                  ? (isKhmer ? 'លុបចេញពីចំណូលចិត្ត' : 'Remove from Saved')
                                  : (isKhmer ? 'រក្សាទុក' : 'Save'),
                            ),
                          ],
                        ),
                      ),
                    if (onEdit != null)
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.black54, size: 20),
                            const SizedBox(width: 8),
                            Text(isKhmer ? 'កែប្រែ' : 'Edit'),
                          ],
                        ),
                      ),
                    if (onDelete != null)
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.redAccent, size: 20),
                            const SizedBox(width: 8),
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
