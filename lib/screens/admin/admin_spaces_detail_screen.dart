import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../models/parking_spot.dart';

class AdminSpacesDetailScreen extends StatefulWidget {
  const AdminSpacesDetailScreen({super.key});

  @override
  State<AdminSpacesDetailScreen> createState() =>
      _AdminSpacesDetailScreenState();
}

class _AdminSpacesDetailScreenState extends State<AdminSpacesDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<ParkingSpot> _filter(List<ParkingSpot> spots) {
    switch (_tabController.index) {
      case 1:
        return spots.where((s) => s.status == 'approved').toList();
      case 2:
        return spots.where((s) => s.status == 'pending').toList();
      case 3:
        return spots.where((s) => s.status == 'rejected').toList();
      default:
        return spots;
    }
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'approved':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.textHint;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final allSpots = provider.allParkingSpots;
    final filtered = _filter(allSpots);
    final tabs = ['All', 'Approved', 'Pending', 'Rejected'];

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppColors.accent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF7C3AED), Color(0xFF5B4CFF)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Parking Spaces',
                                style: GoogleFonts.poppins(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    height: 1)),
                            const SizedBox(height: 4),
                            Text('Manage all parking locations',
                                style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        Colors.white.withValues(alpha: 0.85))),
                          ],
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(52),
              child: Container(
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24))),
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppColors.accent,
                  unselectedLabelColor: AppColors.textHint,
                  indicatorColor: AppColors.accent,
                  indicatorWeight: 3,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelStyle: GoogleFonts.poppins(
                      fontSize: 13, fontWeight: FontWeight.w600),
                  unselectedLabelStyle: GoogleFonts.poppins(
                      fontSize: 13, fontWeight: FontWeight.w500),
                  tabs: List.generate(4, (i) => Tab(text: tabs[i])),
                ),
              ),
            ),
          ),
        ],
        body: filtered.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.08),
                            shape: BoxShape.circle),
                        child: Icon(Icons.local_parking,
                            size: 40,
                            color: AppColors.accent.withValues(alpha: 0.4))),
                    const SizedBox(height: 16),
                    Text('No spaces found',
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text('Try a different filter',
                        style: GoogleFonts.poppins(
                            fontSize: 13, color: AppColors.textHint)),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                itemCount: filtered.length,
                itemBuilder: (_, i) => _spaceCard(filtered[i]),
              ),
      ),
    );
  }

  Widget _spaceCard(ParkingSpot spot) {
    final sc = _statusColor(spot.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with status overlay
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(spot.imageUrl,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                        height: 140,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            AppColors.accent.withValues(alpha: 0.1),
                            AppColors.primary.withValues(alpha: 0.05)
                          ]),
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20)),
                        ),
                        child: const Center(
                            child: Icon(Icons.local_parking,
                                size: 48, color: AppColors.textHint)))),
              ),
              // Gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.4)
                        ]),
                  ),
                ),
              ),
              // Status badge
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color: sc, borderRadius: BorderRadius.circular(8)),
                  child: Text(spot.status.toUpperCase(),
                      style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5)),
                ),
              ),
              // Price badge
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(
                      '\u20B9${spot.pricePerHour.toStringAsFixed(0)}/hr',
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                ),
              ),
            ],
          ),
          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(spot.name,
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Row(children: [
                  Icon(Icons.person_outline,
                      size: 14, color: AppColors.textHint),
                  const SizedBox(width: 4),
                  Text(spot.ownerName,
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: AppColors.textSecondary)),
                ]),
                const SizedBox(height: 2),
                Row(children: [
                  Icon(Icons.location_on_outlined,
                      size: 14, color: AppColors.textHint),
                  const SizedBox(width: 4),
                  Expanded(
                      child: Text(spot.address,
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: AppColors.textHint),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis)),
                ]),
                const SizedBox(height: 12),
                // Info chips
                Wrap(spacing: 8, runSpacing: 6, children: [
                  _chip(Icons.directions_car_outlined,
                      spot.type[0].toUpperCase() + spot.type.substring(1)),
                  _chip(Icons.event_seat_outlined, '${spot.capacity} spots'),
                  ...spot.amenities
                      .take(2)
                      .map((a) => _chip(Icons.star_outline, a)),
                ]),
                // Approve/Reject for pending
                if (spot.status == 'pending') ...[
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          context
                              .read<AppProvider>()
                              .rejectParkingSpot(spot.id);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('${spot.name} rejected'),
                              backgroundColor: AppColors.error,
                              behavior: SnackBarBehavior.floating));
                        },
                        icon: const Icon(Icons.close, size: 16),
                        label: Text('Reject',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600, fontSize: 13)),
                        style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context
                              .read<AppProvider>()
                              .approveParkingSpot(spot.id);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('${spot.name} approved!'),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating));
                        },
                        icon: const Icon(Icons.check, size: 16),
                        label: Text('Approve',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600, fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0),
                      ),
                    ),
                  ]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: AppColors.textHint),
        const SizedBox(width: 4),
        Text(text,
            style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary)),
      ]),
    );
  }
}
