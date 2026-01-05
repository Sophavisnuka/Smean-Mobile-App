import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smean_mobile_app/core/constants/app_colors.dart';
import 'package:smean_mobile_app/data/models/card_model.dart';
import 'package:smean_mobile_app/ui/screens/audio/audio_details_screen.dart';
import 'package:smean_mobile_app/ui/widgets/icons/itshover_bookmark_icon.dart';
import 'package:smean_mobile_app/ui/widgets/icons/itshover_mic_icon.dart';
import 'package:smean_mobile_app/ui/widgets/icons/itshover_upload_icon.dart';

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
    // Default (no query)
    if (query == null || query.isEmpty) {
      return Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      );
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final spans = <TextSpan>[];

    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      final isHighlighted = lowerQuery.contains(lowerText[i]);

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

    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(children: spans),
    );
  }

  String _formatDuration(int seconds) {
    final d = Duration(seconds: seconds);
    final minutes = d.inMinutes;
    final secs = d.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Widget _savedBadge(BuildContext context) {
    return GestureDetector(
      onTap: onFavoriteToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber.shade200, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ItshoverBookmarkIcon(
              size: 14,
              color: Colors.amber.shade700,
              animate: true,
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
    );
  }

  PopupMenuButton<String> _buildMenu() {
    return PopupMenuButton<String>(
      // shrink the “big space” tap target
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      iconSize: 20,
      splashRadius: 18,
      icon: Icon(Icons.more_vert, color: Colors.grey[400]),
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
                ItshoverBookmarkIcon(
                  size: 18,
                  color: Colors.amber.shade700,
                  animate: card.isFavorite,
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
                const Icon(Icons.edit, color: Colors.black54, size: 20),
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
                const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                const SizedBox(width: 8),
                Text(isKhmer ? 'លុប' : 'Delete'),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final createdAt = card.createdAt;
    final title = card.cardName;
    final duration = card.audioDuration ?? 0;
    final source = card.audioSourceType?.toLowerCase() ?? 'recorded';
    final isUploaded = source == 'uploaded' || source == 'upload';

    final formattedDate = isKhmer
        ? DateFormat('dd/MM/yyyy').format(createdAt)
        : DateFormat('MMM dd, yyyy').format(createdAt);

    final hasMenu =
        onEdit != null || onDelete != null || onFavoriteToggle != null;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final deleted = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (context) => AudioDetailsScreen(card: card),
            ),
          );

          if (deleted == true && onRefresh != null) onRefresh!();
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // LEFT: mic icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: isUploaded
                    ? ItshoverUploadIcon(
                        size: 24,
                        color: AppColors.primary,
                        animate: true,
                      )
                    : ItshoverMicIcon(
                        size: 24,
                        color: AppColors.primary,
                        animate: true,
                      ),
              ),
              const SizedBox(width: 12),

              // MIDDLE: title + meta (date)
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildHighlightedText(title, searchQuery),
                        ),
                        if (onFavoriteToggle != null && card.isFavorite) ...[
                          const SizedBox(width: 8),
                          _savedBadge(context),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Text(
                            formattedDate,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time,
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
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // RIGHT: menu + duration
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (hasMenu)
                    SizedBox(
                      height: 28,
                      width: 28,
                      child: Center(child: _buildMenu()),
                    )
                  else
                    const SizedBox(
                      height: 28,
                    ), // keep alignment even without menu
                  const SizedBox(height: 6),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
