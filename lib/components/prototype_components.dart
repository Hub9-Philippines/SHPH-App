import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ============================================================================
// 1. DESIGN TOKENS
// ============================================================================

abstract class AppDesignTokens {
  // Brand & Core Colors
  static const Color brand = Color(0xFF1E3A8A);
  static const Color brandDark = Color(0xFF0F172A);
  static const Color brandLight = Color(0xFFEFF6FF);
  static const Color brandAccent = Color(0xFF2563EB);
  static const Color brandTint = Color(0xFF0F8A6C);

  // Surface & Canvas
  static const Color canvas = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF1F5F9);

  // Text & Inks
  static const Color ink = Color(0xFF0F172A);
  static const Color inkSecondary = Color(0xFF64748B);
  static const Color inkMuted = Color(0xFF94A3B8);

  // Semantic & Feedback
  static const Color success = Color(0xFF059669);
  static const Color successLight = Color(0xFFECFDF5);
  static const Color warning = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFFFBEB);
  static const Color danger = Color(0xFFE11D48);
  static const Color dangerLight = Color(0xFFFFF1F2);
  static const Color purple = Color(0xFF5B2E91);
  static const Color purpleAccent = Color(0xFF7C4DBE);
  static const Color teal = Color(0xFF0D9488);

  // Borders & Dividers
  static const Color borderSubtle = Color(0xFFF1F5F9);
  static const Color borderMedium = Color(0xFFE2E8F0);

  // Radiuses
  static const double radiusSm = 12.0;
  static const double radiusMd = 16.0;
  static const double radiusLg = 24.0;
  static const double radiusXl = 28.0;
  static const double radiusHero = 30.0;
  static const double radiusPill = 999.0;

  // Typography Styles
  static TextStyle eyebrow({Color color = brand}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.8,
        color: color,
      );

  static TextStyle titleLarge({Color color = ink}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        color: color,
      );

  static TextStyle titleMedium({Color color = ink}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 21,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
        color: color,
      );

  static TextStyle sectionHeader({Color color = inkSecondary}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.6,
        color: color,
      );

  static TextStyle cardTitle({Color color = ink}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: color,
      );

  static TextStyle bodyMedium({Color color = inkSecondary}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: color,
      );

  static TextStyle bodySmall({Color color = inkSecondary}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: color,
      );

  static TextStyle caption({Color color = inkMuted}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 9,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle badge({Color color = brand}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 8,
        fontWeight: FontWeight.w800,
        color: color,
      );
}

// ============================================================================
// 2. HEADER & SEARCH COMPONENTS
// ============================================================================

class PrototypeAppHeader extends StatelessWidget {
  const PrototypeAppHeader({
    super.key,
    required this.userName,
    required this.avatarUrl,
    required this.hasUnreadNotifications,
    required this.isCompact,
    required this.onNotificationTap,
    required this.onAvatarTap,
    required this.onSearchTap,
    this.onMicTap,
  });

  final String userName;
  final String avatarUrl;
  final bool hasUnreadNotifications;
  final bool isCompact;
  final VoidCallback onNotificationTap;
  final VoidCallback onAvatarTap;
  final VoidCallback onSearchTap;
  final VoidCallback? onMicTap;

  @override
  Widget build(BuildContext context) {
    final hasAvatar = avatarUrl.trim().isNotEmpty;
    final actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _HeaderIconButton(
          icon: Icons.notifications_none_rounded,
          hasBadge: hasUnreadNotifications,
          onTap: onNotificationTap,
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onAvatarTap,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDesignTokens.radiusMd),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x0D0F172A),
                    blurRadius: 4,
                    offset: Offset(0, 1))
              ],
              image: hasAvatar
                  ? DecorationImage(
                      image: NetworkImage(avatarUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: hasAvatar
                ? null
                : const Icon(
                    Icons.person_rounded,
                    color: AppDesignTokens.inkMuted,
                    size: 20,
                  ),
          ),
        ),
      ],
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeInOut,
      padding: EdgeInsets.fromLTRB(20, isCompact ? 8 : 12, 20, isCompact ? 8 : 16),
      decoration: BoxDecoration(
        color: isCompact ? AppDesignTokens.surface : null,
        gradient: isCompact
            ? null
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFECFDF5), Color(0xFFF4FFFC), AppDesignTokens.canvas],
              ),
      ),
      child: isCompact
          ? Row(
              children: [
                Expanded(
                  child: _SearchTriggerBar(
                    onTap: onSearchTap,
                    onMicTap: onMicTap,
                    isCompact: true,
                  ),
                ),
                const SizedBox(width: 8),
                actions,
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('YOUR HOME, MADE EASY',
                              style: AppDesignTokens.eyebrow()),
                          const SizedBox(height: 4),
                          Text(
                            'Good morning, $userName 👋',
                            style: AppDesignTokens.titleMedium(),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Tell us what needs fixing. We'll find the right pro.",
                            style: AppDesignTokens.bodyMedium(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    actions,
                  ],
                ),
                const SizedBox(height: 16),
                _SearchTriggerBar(
                  onTap: onSearchTap,
                  onMicTap: onMicTap,
                  isCompact: false,
                ),
              ],
            ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.hasBadge,
    required this.onTap,
  });

  final IconData icon;
  final bool hasBadge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppDesignTokens.surface,
          borderRadius: BorderRadius.circular(AppDesignTokens.radiusMd),
          boxShadow: const [
            BoxShadow(color: Color(0x0D0F172A), blurRadius: 4, offset: Offset(0, 1))
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: 20, color: AppDesignTokens.inkSecondary),
            if (hasBadge)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppDesignTokens.danger,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SearchTriggerBar extends StatelessWidget {
  const _SearchTriggerBar({
    required this.onTap,
    this.onMicTap,
    required this.isCompact,
  });

  final VoidCallback onTap;
  final VoidCallback? onMicTap;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: isCompact ? 40 : 48,
        padding: EdgeInsets.symmetric(horizontal: isCompact ? 14 : 16),
        decoration: BoxDecoration(
          color: AppDesignTokens.surface,
          borderRadius: BorderRadius.circular(AppDesignTokens.radiusMd),
          boxShadow: const [
            BoxShadow(color: Color(0x0D0F172A), blurRadius: 4, offset: Offset(0, 1))
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, size: 20, color: AppDesignTokens.inkMuted),
            SizedBox(width: isCompact ? 10 : 12),
            Expanded(
              child: Text(
                'What service do you need...',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: AppDesignTokens.bodyMedium(
                  color: AppDesignTokens.inkMuted,
                ),
              ),
            ),
            if (onMicTap != null)
              GestureDetector(
                onTap: onMicTap,
                child: const Icon(
                  Icons.mic_rounded,
                  size: 20,
                  color: AppDesignTokens.brandTint,
                ),
              )
            else
              const Icon(
                Icons.mic_rounded,
                size: 20,
                color: AppDesignTokens.brandTint,
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 3. HOME VIEW WIDGETS
// ============================================================================

class ActiveBookingCard extends StatelessWidget {
  const ActiveBookingCard({
    super.key,
    required this.title,
    required this.providerName,
    required this.category,
    required this.statusLabel,
    required this.statusColor,
    required this.statusBgColor,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.subtitleInfo,
    required this.onTrackTap,
    required this.onMessageTap,
  });

  final String title;
  final String providerName;
  final String category;
  final String statusLabel;
  final Color statusColor;
  final Color statusBgColor;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String subtitleInfo;
  final VoidCallback onTrackTap;
  final VoidCallback onMessageTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppDesignTokens.surface,
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusLg),
        border: Border.all(color: AppDesignTokens.borderSubtle),
        boxShadow: const [
          BoxShadow(color: Color(0x050F172A), blurRadius: 4, offset: Offset(0, 1))
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(AppDesignTokens.radiusMd),
                    ),
                    child: Icon(icon, color: iconColor, size: 24),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppDesignTokens.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: AppDesignTokens.cardTitle(),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusBgColor,
                            borderRadius: BorderRadius.circular(AppDesignTokens.radiusPill),
                          ),
                          child: Text(
                            statusLabel,
                            style: AppDesignTokens.badge(color: statusColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$providerName · $category',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: AppDesignTokens.caption(),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitleInfo,
                      style: AppDesignTokens.caption(color: AppDesignTokens.success),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppDesignTokens.brand,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDesignTokens.radiusSm),
                      ),
                    ),
                    onPressed: onTrackTap,
                    icon: const Icon(Icons.location_searching_rounded, size: 14, color: Colors.white),
                    label: Text(
                      'Track Service',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onMessageTap,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(AppDesignTokens.radiusSm),
                  ),
                  child: Icon(Icons.chat_bubble_outline_rounded, size: 18, color: iconColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EmergencyHelpCard extends StatelessWidget {
  const EmergencyHelpCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusXl),
        gradient: const LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFF43F5E)],
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x33EF4444), blurRadius: 16, offset: Offset(0, 6))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppDesignTokens.radiusSm),
            ),
            child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need help right now?',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Connect with an emergency service pro.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFFFF1F2),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDesignTokens.radiusSm),
              ),
            ),
            onPressed: onTap,
            child: Text(
              'Get help',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppDesignTokens.danger,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryTileItem extends StatelessWidget {
  const CategoryTileItem({
    super.key,
    required this.name,
    required this.priceSubtitle,
    required this.icon,
    required this.gradientColors,
    this.badgeLabel,
    this.isDarkText = false,
    required this.onTap,
  });

  final String name;
  final String priceSubtitle;
  final IconData icon;
  final List<Color> gradientColors;
  final String? badgeLabel;
  final bool isDarkText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkText ? const Color(0xFF451A03) : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 132,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(AppDesignTokens.radiusMd),
          boxShadow: const [
            BoxShadow(
              color: Color(0x120F172A),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDarkText
                        ? const Color(0x1F451A03)
                        : Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: textColor, size: 18),
                ),
                if (badgeLabel != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDarkText
                          ? const Color(0x26451A03)
                          : Colors.white.withValues(alpha: 0.25),
                      borderRadius:
                          BorderRadius.circular(AppDesignTokens.radiusPill),
                    ),
                    child: Text(
                      badgeLabel!.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 7,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                        color: textColor,
                      ),
                    ),
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  priceSubtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: isDarkText
                        ? const Color(0xB3451A03)
                        : Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BayanihanPoolCard extends StatelessWidget {
  const BayanihanPoolCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusLg),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF14B8A6), Color(0xFF059669)],
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x2614B8A6), blurRadius: 12, offset: Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppDesignTokens.radiusSm),
            ),
            child: const Icon(Icons.people_outline_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bayanihan Pool',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Join neighbors nearby and split the cost of a shared service booking.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                    color: const Color(0xFFF0FDFA),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDesignTokens.radiusSm),
              ),
            ),
            onPressed: onTap,
            child: Text(
              'View',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0D9488),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SeasonalOfferCard extends StatelessWidget {
  const SeasonalOfferCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusHero),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1D4ED8), Color(0xFF1E3A8A), Color(0xFF0F172A)],
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x382563EB), blurRadius: 24, offset: Offset(0, 10))
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            bottom: 0,
            child: Icon(
              Icons.home_work_outlined,
              size: 96,
              color: Colors.white.withOpacity(0.08),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SEASONAL OFFER',
                style: AppDesignTokens.eyebrow(color: const Color(0xFFBAE6FD)),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 220),
                child: Text(
                  'Get your home back in shape for the season.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 220),
                child: Text(
                  'Save 15% on appliance repair and preventive cleaning this week.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                    color: const Color(0xFFDBEAFE),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDesignTokens.radiusSm),
                  ),
                ),
                onPressed: onTap,
                child: Text(
                  'Book now',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppDesignTokens.brand,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TrendingProviderCard extends StatelessWidget {
  const TrendingProviderCard({
    super.key,
    required this.name,
    required this.category,
    required this.avatarUrl,
    required this.rating,
    required this.reviewCount,
    required this.distanceKm,
    required this.startingPrice,
    required this.onTap,
  });

  final String name;
  final String category;
  final String avatarUrl;
  final double rating;
  final int reviewCount;
  final double distanceKm;
  final int startingPrice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasAvatar = avatarUrl.trim().isNotEmpty;
    return Container(
      width: 196,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppDesignTokens.surface,
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusMd),
        border: Border.all(color: AppDesignTokens.borderSubtle),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(AppDesignTokens.radiusSm),
                      color: AppDesignTokens.surfaceMuted,
                      image: hasAvatar
                          ? DecorationImage(
                              image: NetworkImage(avatarUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: hasAvatar
                        ? null
                        : const Icon(
                            Icons.person_rounded,
                            color: AppDesignTokens.inkMuted,
                            size: 18,
                          ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: AppDesignTokens.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: AppDesignTokens.cardTitle().copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: AppDesignTokens.caption(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                decoration: BoxDecoration(
                  color: AppDesignTokens.successLight,
                  borderRadius:
                      BorderRadius.circular(AppDesignTokens.radiusPill),
                ),
                child: Text(
                  'Online',
                  style: AppDesignTokens.badge(color: AppDesignTokens.success)
                      .copyWith(fontSize: 7.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.star_rounded,
                size: 13,
                color: Color(0xFFF59E0B),
              ),
              const SizedBox(width: 3),
              Text(
                rating.toStringAsFixed(1),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: 2),
              Text(
                '($reviewCount)',
                style: AppDesignTokens.caption(color: AppDesignTokens.inkMuted)
                    .copyWith(fontSize: 8.5),
              ),
              const Spacer(),
              Text(
                'From ₱$startingPrice',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppDesignTokens.brand,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 12,
                color: AppDesignTokens.inkMuted,
              ),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  '${distanceKm.toStringAsFixed(1)} km away',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: AppDesignTokens.caption(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 32,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppDesignTokens.brandLight,
                foregroundColor: AppDesignTokens.brand,
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDesignTokens.radiusSm),
                ),
              ),
              onPressed: onTap,
              child: Text(
                'View profile',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppDesignTokens.brand,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReferralBannerCard extends StatelessWidget {
  const ReferralBannerCard({
    super.key,
    required this.promoCode,
    required this.onTap,
  });

  final String promoCode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusLg),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E293B),
            Color(0xFF1E3A8A),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x220F172A),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.antiAlias,
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF38BDF8).withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -15,
            right: 16,
            child: Icon(
              Icons.card_giftcard_rounded,
              size: 80,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius:
                            BorderRadius.circular(AppDesignTokens.radiusPill),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.18),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.stars_rounded,
                            size: 13,
                            color: Color(0xFFFCD34D),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'REFERRAL PROGRAM',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.9,
                              color: const Color(0xFFFCD34D),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Color(0xFF94A3B8),
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Give ₱50, Get ₱100',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Share Serbisyo with friends. They save ₱50 on their first booking, and you earn ₱100 credit.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                    color: const Color(0xFFCBD5E1),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius:
                              BorderRadius.circular(AppDesignTokens.radiusSm),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.16),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Code: ',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                            Text(
                              promoCode,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0F172A),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppDesignTokens.radiusSm),
                        ),
                      ),
                      onPressed: onTap,
                      icon: const Icon(
                        Icons.share_rounded,
                        size: 14,
                        color: Color(0xFF0F172A),
                      ),
                      label: Text(
                        'Invite',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 4. BOOKINGS VIEW WIDGETS
// ============================================================================

enum BookingStatus { pending, completed, canceled }

class BookingItemCard extends StatelessWidget {
  const BookingItemCard({
    super.key,
    required this.title,
    required this.providerName,
    required this.dateTimeFormatted,
    required this.priceFormatted,
    required this.status,
    required this.icon,
    this.onPrimaryAction,
    this.onSecondaryAction,
  });

  final String title;
  final String providerName;
  final String dateTimeFormatted;
  final String priceFormatted;
  final BookingStatus status;
  final IconData icon;
  final VoidCallback? onPrimaryAction;
  final VoidCallback? onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppDesignTokens.surface,
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusLg),
        border: Border.all(color: AppDesignTokens.borderSubtle),
        boxShadow: const [
          BoxShadow(color: Color(0x050F172A), blurRadius: 4, offset: Offset(0, 1))
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppDesignTokens.surfaceMuted,
                  borderRadius: BorderRadius.circular(AppDesignTokens.radiusMd),
                ),
                child: Icon(icon, color: AppDesignTokens.inkSecondary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: AppDesignTokens.cardTitle(),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildStatusBadge(status),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(providerName, style: AppDesignTokens.bodySmall()),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: AppDesignTokens.inkMuted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(dateTimeFormatted, style: AppDesignTokens.caption()),
              ),
              Text(
                priceFormatted,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppDesignTokens.ink,
                ),
              ),
            ],
          ),
          if (status != BookingStatus.canceled) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: status == BookingStatus.completed
                            ? AppDesignTokens.success
                            : AppDesignTokens.brand,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDesignTokens.radiusSm),
                        ),
                      ),
                      onPressed: onPrimaryAction,
                      icon: Icon(
                        status == BookingStatus.completed
                            ? Icons.star_rounded
                            : Icons.location_searching_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                      label: Text(
                        status == BookingStatus.completed ? 'Write Review' : 'Track Service',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: status == BookingStatus.completed
                              ? AppDesignTokens.borderMedium
                              : AppDesignTokens.brand,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDesignTokens.radiusSm),
                        ),
                      ),
                      onPressed: onSecondaryAction,
                      icon: Icon(
                        status == BookingStatus.completed
                            ? Icons.replay_rounded
                            : Icons.calendar_month_outlined,
                        size: 14,
                        color: status == BookingStatus.completed
                            ? AppDesignTokens.inkSecondary
                            : AppDesignTokens.brand,
                      ),
                      label: Text(
                        status == BookingStatus.completed ? 'Book Again' : 'Reschedule',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: status == BookingStatus.completed
                              ? AppDesignTokens.inkSecondary
                              : AppDesignTokens.brand,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onPrimaryAction,
              child: Row(
                children: [
                  const Icon(Icons.visibility_outlined, size: 14, color: AppDesignTokens.inkMuted),
                  const SizedBox(width: 6),
                  Text('View Details', style: AppDesignTokens.caption(color: AppDesignTokens.inkMuted)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BookingStatus status) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case BookingStatus.pending:
        bg = AppDesignTokens.warningLight;
        fg = AppDesignTokens.warning;
        label = 'Pending';
        break;
      case BookingStatus.completed:
        bg = AppDesignTokens.successLight;
        fg = AppDesignTokens.success;
        label = 'Completed';
        break;
      case BookingStatus.canceled:
        bg = AppDesignTokens.surfaceMuted;
        fg = AppDesignTokens.inkSecondary;
        label = 'Canceled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusPill),
      ),
      child: Text(label, style: AppDesignTokens.badge(color: fg)),
    );
  }
}

// ============================================================================
// 5. MESSAGES VIEW WIDGETS
// ============================================================================

class ConversationChatCard extends StatelessWidget {
  const ConversationChatCard({
    super.key,
    required this.name,
    required this.avatarUrl,
    required this.timeAgo,
    required this.messageSnippet,
    this.unreadCount = 0,
    this.isCompleted = false,
    required this.onTap,
  });

  final String name;
  final String avatarUrl;
  final String timeAgo;
  final String messageSnippet;
  final int unreadCount;
  final bool isCompleted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppDesignTokens.surface,
          borderRadius: BorderRadius.circular(AppDesignTokens.radiusLg),
          border: Border.all(color: AppDesignTokens.borderSubtle),
          boxShadow: const [
            BoxShadow(color: Color(0x050F172A), blurRadius: 4, offset: Offset(0, 1))
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 29,
                  backgroundImage: NetworkImage(avatarUrl),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isCompleted ? AppDesignTokens.inkMuted : AppDesignTokens.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(name, style: AppDesignTokens.cardTitle().copyWith(fontSize: 12)),
                      Text(timeAgo, style: AppDesignTokens.caption()),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    messageSnippet,
                    style: AppDesignTokens.caption(color: AppDesignTokens.inkSecondary).copyWith(height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isCompleted ? AppDesignTokens.brandLight : AppDesignTokens.successLight,
                          borderRadius: BorderRadius.circular(AppDesignTokens.radiusPill),
                        ),
                        child: Text(
                          isCompleted ? 'Completed' : 'Conversation',
                          style: AppDesignTokens.badge(
                            color: isCompleted ? AppDesignTokens.brand : AppDesignTokens.success,
                          ),
                        ),
                      ),
                      if (unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppDesignTokens.brand,
                            borderRadius: BorderRadius.circular(AppDesignTokens.radiusPill),
                          ),
                          child: Text(
                            '$unreadCount unread',
                            style: AppDesignTokens.badge(color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 6. PROFILE VIEW WIDGETS
// ============================================================================

class ProfileHeroCard extends StatelessWidget {
  const ProfileHeroCard({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatarUrl,
    required this.isVerified,
    required this.onEditPhoto,
  });

  final String name;
  final String email;
  final String phone;
  final String avatarUrl;
  final bool isVerified;
  final VoidCallback onEditPhoto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusHero),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A8A), Color(0xFF274FB5), Color(0xFF3B62D9)],
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x331E3A8A), blurRadius: 20, offset: Offset(0, 8))
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.85), width: 2),
                  image: DecorationImage(
                    image: NetworkImage(avatarUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: onEditPhoto,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Color(0x26000000), blurRadius: 4, offset: Offset(0, 1))
                      ],
                    ),
                    child: const Icon(Icons.camera_alt_rounded, size: 14, color: AppDesignTokens.brand),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isVerified) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.verified_rounded, color: Color(0xFF67E8F9), size: 16),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFDBEAFE),
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  phone,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFDBEAFE),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileMenuGroup extends StatelessWidget {
  const ProfileMenuGroup({
    super.key,
    required this.title,
    required this.items,
  });

  final String title;
  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(title, style: AppDesignTokens.sectionHeader()),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppDesignTokens.surface,
            borderRadius: BorderRadius.circular(AppDesignTokens.radiusLg),
            border: Border.all(color: AppDesignTokens.borderSubtle),
            boxShadow: const [
              BoxShadow(color: Color(0x050F172A), blurRadius: 4, offset: Offset(0, 1))
            ],
          ),
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                items[i],
                if (i < items.length - 1)
                  const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16, color: AppDesignTokens.borderSubtle),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class ProfileMenuItem extends StatelessWidget {
  const ProfileMenuItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDesignTokens.radiusLg),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(AppDesignTokens.radiusSm),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppDesignTokens.cardTitle().copyWith(fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppDesignTokens.caption()),
                ],
              ),
            ),
            trailing ?? const Icon(Icons.chevron_right_rounded, color: AppDesignTokens.inkMuted, size: 18),
          ],
        ),
      ),
    );
  }
}
