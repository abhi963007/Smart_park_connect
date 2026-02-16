import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../widgets/parking_card.dart';
import '../parking/parking_details_screen.dart';
import '../booking/select_booking_time_screen.dart';

/// Saved/Favorite parking spots screen
class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final savedSpots = provider.parkingSpots
        .where((s) => provider.isFavorite(s.id))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Saved Spots',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: savedSpots.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border,
                      size: 64, color: AppColors.textHint.withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  Text(
                    'No saved spots yet',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the heart icon on any parking\nspot to save it here.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textHint,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 12, bottom: 20),
              itemCount: savedSpots.length,
              itemBuilder: (context, index) {
                final spot = savedSpots[index];
                return ParkingCard(
                  spot: spot,
                  isFavorite: true,
                  onTap: () {
                    provider.selectSpot(spot);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ParkingDetailsScreen(spot: spot),
                      ),
                    );
                  },
                  onFavoriteTap: () => provider.toggleFavorite(spot.id),
                  onBookTap: () {
                    provider.selectSpot(spot);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SelectBookingTimeScreen(spot: spot),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
