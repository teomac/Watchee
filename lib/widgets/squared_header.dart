import 'package:flutter/material.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final String? imagePath;
  final String? title;
  final String? subtitle;
  final List<Widget>? additionalInfo;
  final double size;
  final bool useBackdropImage;
  final VoidCallback? onTap;
  final Widget? actionButton;

  const ProfileHeaderWidget({
    super.key,
    required this.imagePath,
    this.title,
    this.subtitle,
    this.additionalInfo,
    this.size = 400,
    this.useBackdropImage = false,
    this.onTap,
    this.actionButton,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: useBackdropImage ? size * 1.26 : size,
          height: size,
          decoration: BoxDecoration(
            color: theme.surface,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              if (imagePath != null)
                Image.network(
                  imagePath!,
                  fit: useBackdropImage ? BoxFit.cover : BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPlaceholder(context);
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                )
              else
                _buildPlaceholder(context),

              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.6, 1.0],
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.8),
                                ),
                      ),
                    ],
                    if (additionalInfo != null) ...[
                      const SizedBox(height: 8),
                      ...additionalInfo!,
                    ],
                  ],
                ),
              ),

              // Action button
              if (actionButton != null) actionButton!,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDarkMode ? Colors.grey[850] : Colors.grey[200],
      child: Center(
        child: Icon(
          useBackdropImage ? Icons.movie : Icons.person,
          size: size * 0.3,
          color: isDarkMode ? Colors.grey[700] : Colors.grey[400],
        ),
      ),
    );
  }
}
