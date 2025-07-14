import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inner_kid/core/models/child_profile.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ChildProfileCard extends StatelessWidget {
  final ChildProfile child;
  final VoidCallback onTap;

  const ChildProfileCard({
    super.key,
    required this.child,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Avatar
                _buildAvatar(),
                const SizedBox(height: 8),

                // Name
                Text(
                  child.name,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D3748),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                // Age
                Text(
                  '${child.ageInYears} yaş',
                  style: GoogleFonts.nunito(
                    fontSize: 10,
                    color: const Color(0xFF718096),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getAvatarColor(),
        border: Border.all(
          color: const Color(0xFF667EEA).withOpacity(0.2),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: child.avatarUrl != null
            ? CachedNetworkImage(
                imageUrl: child.avatarUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildAvatarPlaceholder(),
                errorWidget: (context, url, error) => _buildAvatarPlaceholder(),
              )
            : _buildAvatarPlaceholder(),
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getAvatarColor(),
      ),
      child: Center(
        child: Text(
          child.name.isNotEmpty ? child.name[0].toUpperCase() : '?',
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Color _getAvatarColor() {
    // Generate color based on child name for consistency
    final colors = [
      const Color(0xFF667EEA),
      const Color(0xFF38B2AC),
      const Color(0xFFED8936),
      const Color(0xFFE53E3E),
      const Color(0xFF9F7AEA),
      const Color(0xFF48BB78),
    ];

    final hash = child.name.hashCode;
    return colors[hash % colors.length];
  }
}
