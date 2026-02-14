import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/app_provider.dart';
import '../../services/mock_data_service.dart';
import '../../widgets/parking_card.dart';
import '../../widgets/real_map_widget.dart';
import '../search/search_screen.dart';
import '../parking/parking_details_screen.dart';

/// Map & Explore Home Screen with search bar, filters, and nearby parking
/// Matches reference: map_&_explore_home/screen.png
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ValueNotifier<double> _uiHideProgress = ValueNotifier<double>(0.0);

  @override
  void dispose() {
    _uiHideProgress.dispose();
    super.dispose();
  }

  void _onSheetPositionChanged(double position) {
    // Hide UI progressively as bottom sheet expands.
    // 0.58 -> start hiding, 0.85 -> fully hidden.
    final progress = ((position - 0.58) / 0.27).clamp(0.0, 1.0);
    if ((progress - _uiHideProgress.value).abs() > 0.002) {
      _uiHideProgress.value = progress;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          // Real map (full screen, will be clipped by bottom sheet)
          RealMapWidget(
            height: MediaQuery.of(context).size.height,
            parkingSpots: provider.filteredSpots,
            uiHideProgressListenable: _uiHideProgress,
            onMarkerTap: (spot) {
              provider.selectSpot(spot);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ParkingDetailsScreen(spot: spot),
                ),
              );
            },
          ),

          // Animated Search bar at top
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 20,
            right: 20,
            child: ValueListenableBuilder<double>(
              valueListenable: _uiHideProgress,
              builder: (context, progress, child) {
                return IgnorePointer(
                  ignoring: progress > 0.95,
                  child: Opacity(
                    opacity: 1 - progress,
                    child: Transform.translate(
                      offset: Offset(0, -22 * progress),
                      child: Transform.scale(
                        scale: 1 - (0.06 * progress),
                        alignment: Alignment.topCenter,
                        child: Row(
                          children: [
                            // Search field
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    PageRouteBuilder(
                                      pageBuilder: (_, __, ___) => const SearchScreen(),
                                      transitionsBuilder: (_, animation, __, child) {
                                        return FadeTransition(
                                            opacity: animation, child: child);
                                      },
                                      transitionDuration:
                                          const Duration(milliseconds: 300),
                                    ),
                                  );
                                },
                                child: Container(
                                  height: 52,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(28),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 16,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.search,
                                          color: AppColors.primary, size: 22),
                                      const SizedBox(width: 12),
                                      Text(
                                        AppStrings.whereAreYouGoing,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: AppColors.textHint,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Notification bell
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  const Center(
                                    child: Icon(Icons.notifications_outlined,
                                        color: AppColors.textPrimary, size: 24),
                                  ),
                                  Positioned(
                                    top: 12,
                                    right: 12,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: AppColors.error,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom sheet with filters and nearby parking
          NotificationListener<DraggableScrollableNotification>(
            onNotification: (notification) {
              _onSheetPositionChanged(notification.extent);
              return false;
            },
            child: DraggableScrollableSheet(
              initialChildSize: 0.52,
              minChildSize: 0.35,
              maxChildSize: 0.9,
              snap: true,
              snapSizes: const [0.35, 0.52, 0.9],
              builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 25,
                      offset: const Offset(0, -8),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 16),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.cardBorder,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    // Quick Filters
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        AppStrings.quickFilters,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textHint,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Filter chips
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: MockDataService.quickFilters.length,
                        itemBuilder: (context, index) {
                          final filter = MockDataService.quickFilters[index];
                          final isSelected = provider.selectedFilter == filter;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => provider.setFilter(filter),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.cardBorder,
                                  ),
                                ),
                                child: Text(
                                  filter,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Nearby Parking header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.nearbyParking,
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                '${provider.filteredSpots.length * 5} spaces available',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              AppStrings.seeAll,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Horizontal parking cards
                    SizedBox(
                      height: 210,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: provider.filteredSpots.length,
                        itemBuilder: (context, index) {
                          final spot = provider.filteredSpots[index];
                          return ParkingCardCompact(
                            spot: spot,
                            onTap: () {
                              provider.selectSpot(spot);
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ParkingDetailsScreen(spot: spot),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
            ),
          ),
        ],
      ),
    );
  }

}
