import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../models/parking_spot.dart';

/// Horizontal parking card used in search results
class ParkingCard extends StatelessWidget {
  final ParkingSpot spot;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;
  final VoidCallback onBookTap;

  const ParkingCard({
    super.key,
    required this.spot,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteTap,
    required this.onBookTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 14, offset: const Offset(0, 4))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(spot.imageUrl, width: 100, height: 100, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(width: 100, height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.08), AppColors.primary.withOpacity(0.03)]),
                      borderRadius: BorderRadius.circular(14)),
                    child: Icon(Icons.local_parking, color: AppColors.primary.withOpacity(0.3)))),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(spot.name, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  GestureDetector(onTap: onFavoriteTap,
                    child: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.pink : AppColors.textHint, size: 20)),
                ]),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.star_rounded, color: AppColors.starYellow, size: 14),
                  const SizedBox(width: 3),
                  Text('${spot.rating}', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(width: 4),
                  Text('(${spot.reviewCount})', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                ]),
                const SizedBox(height: 4),
                Row(children: [
                  Icon(Icons.location_on_outlined, size: 13, color: AppColors.primary),
                  const SizedBox(width: 3),
                  Text('${spot.distance} km', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(width: 4),
                  Container(width: 3, height: 3, decoration: BoxDecoration(color: AppColors.textHint, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text('${spot.walkTime} min walk', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                ]),
                const SizedBox(height: 8),
                Wrap(spacing: 6, runSpacing: 4, children: spot.tags.map((tag) => _buildTag(tag)).toList()),
              ])),
            ]),
            const SizedBox(height: 12),
            // Price + Book row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: AppColors.backgroundLight, borderRadius: BorderRadius.circular(14)),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('PRICE', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textHint, letterSpacing: 1)),
                  Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
                    Text('\u20B9${spot.pricePerHour.toInt()}', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    Text('/hr', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
                  ]),
                ]),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFF7C3AED)]),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))]),
                  child: ElevatedButton(
                    onPressed: onBookTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent, shadowColor: Colors.transparent, foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                    child: Text('Book', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildTag(String tag) {
    IconData icon;
    Color bgColor;
    Color textColor;
    switch (tag.toUpperCase()) {
      case 'COVERED': icon = Icons.umbrella; bgColor = AppColors.tagBlue; textColor = AppColors.tagBlueText; break;
      case 'CCTV': icon = Icons.videocam; bgColor = AppColors.tagBlue; textColor = AppColors.tagBlueText; break;
      case 'EV CHARGING': icon = Icons.bolt; bgColor = AppColors.tagGreen; textColor = AppColors.tagGreenText; break;
      case 'VALET': icon = Icons.directions_car; bgColor = AppColors.tagPurple; textColor = AppColors.tagPurpleText; break;
      case 'RESIDENTIAL': icon = Icons.home; bgColor = AppColors.tagGreen; textColor = AppColors.tagGreenText; break;
      case 'VERIFIED': icon = Icons.verified; bgColor = AppColors.tagGreen; textColor = AppColors.tagGreenText; break;
      default: icon = Icons.label; bgColor = AppColors.tagBlue; textColor = AppColors.tagBlueText;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(6)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: textColor), const SizedBox(width: 4),
        Text(tag, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: textColor)),
      ]),
    );
  }
}

/// Compact horizontal parking card for the home screen carousel
class ParkingCardCompact extends StatelessWidget {
  final ParkingSpot spot;
  final VoidCallback onTap;

  const ParkingCardCompact({
    super.key,
    required this.spot,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 14, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with overlays
            Stack(children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: Image.network(spot.imageUrl, width: 220, height: 120, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(width: 220, height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.08), AppColors.primary.withOpacity(0.03)]),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(18))),
                    child: Icon(Icons.local_parking, color: AppColors.primary.withOpacity(0.3), size: 40))),
              ),
              // Gradient overlay
              Positioned.fill(child: Container(decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.2)])))),
              // Price badge
              Positioned(bottom: 8, left: 8, child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFF7C3AED)]),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))]),
                child: Text('\u20B9${spot.pricePerHour.toInt()}/hr',
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)))),
              // Rating badge
              Positioned(top: 8, right: 8, child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6)]),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.star_rounded, color: AppColors.starYellow, size: 14),
                  const SizedBox(width: 2),
                  Text('${spot.rating}', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                ]))),
            ]),
            // Details
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(spot.name, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 5),
                Row(children: [
                  Icon(Icons.location_on_outlined, size: 13, color: AppColors.textHint),
                  const SizedBox(width: 3),
                  Text('${spot.distance} km', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
                  const SizedBox(width: 8),
                  Container(width: 3, height: 3, decoration: BoxDecoration(color: AppColors.textHint, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Icon(Icons.local_parking_outlined, size: 13, color: AppColors.textHint),
                  const SizedBox(width: 3),
                  Text(spot.type[0].toUpperCase() + spot.type.substring(1),
                    style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
                ]),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
