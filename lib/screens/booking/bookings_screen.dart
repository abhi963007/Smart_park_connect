import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_provider.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  Color _sc(String s) {
    switch (s) { case 'confirmed': return AppColors.primary; case 'active': return AppColors.success; case 'completed': return AppColors.textSecondary; default: return AppColors.error; }
  }

  IconData _si(String s) {
    switch (s) { case 'confirmed': return Icons.schedule; case 'active': return Icons.play_circle_outline; case 'completed': return Icons.check_circle_outline; default: return Icons.cancel_outlined; }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final bookings = provider.bookings;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            const SizedBox(height: 16),
            Center(child: Text('My Bookings',
                style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
            const SizedBox(height: 16),
            // ── Tabs ──
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))],
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textHint,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.label,
                dividerColor: Colors.transparent,
                labelStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                unselectedLabelStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
                tabs: const [Tab(text: 'Upcoming'), Tab(text: 'Active'), Tab(text: 'Past')],
              ),
            ),
            const SizedBox(height: 4),
            // ── Tab content ──
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _list(bookings.where((b) => b.status == 'confirmed').toList(), 'No upcoming bookings', 'Book a parking spot to see\nyour upcoming reservations here.', Icons.calendar_today_outlined),
                  _list(bookings.where((b) => b.status == 'active').toList(), 'No active bookings', 'You don\'t have any active\nparking sessions right now.', Icons.play_circle_outline),
                  _list(bookings.where((b) => b.status == 'completed').toList(), 'No past bookings', 'Your completed bookings\nwill appear here.', Icons.check_circle_outline),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _list(List bookings, String emptyTitle, String emptySub, IconData emptyIcon) {
    if (bookings.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 80, height: 80, decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.06), shape: BoxShape.circle),
          child: Icon(emptyIcon, size: 40, color: AppColors.primary.withValues(alpha: 0.3))),
        const SizedBox(height: 16),
        Text(emptyTitle, style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        Text(emptySub, style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textHint, height: 1.5), textAlign: TextAlign.center),
      ]));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      itemCount: bookings.length,
      itemBuilder: (_, i) => _card(bookings[i]),
    );
  }

  Widget _card(dynamic b) {
    final df = DateFormat('dd MMM, hh:mm a');
    final sc = _sc(b.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(children: [
        // Color accent bar
        Container(height: 3, decoration: BoxDecoration(color: sc, borderRadius: const BorderRadius.vertical(top: Radius.circular(20)))),
        Padding(padding: const EdgeInsets.all(14), child: Column(children: [
          Row(children: [
            // Image with rounded corners
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(b.parkingImage, width: 72, height: 72, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(width: 72, height: 72,
                  decoration: BoxDecoration(gradient: LinearGradient(colors: [sc.withValues(alpha: 0.1), sc.withValues(alpha: 0.04)]), borderRadius: BorderRadius.circular(14)),
                  child: Icon(Icons.local_parking, size: 28, color: sc.withValues(alpha: 0.5)))),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(b.parkingName, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Row(children: [
                Icon(Icons.location_on_outlined, size: 13, color: AppColors.textHint),
                const SizedBox(width: 3),
                Expanded(child: Text(b.parkingAddress, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: sc.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: sc.withValues(alpha: 0.3), width: 0.5)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(_si(b.status), size: 12, color: sc),
                  const SizedBox(width: 4),
                  Text(b.status.toString().toUpperCase(), style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w700, color: sc, letterSpacing: 0.3)),
                ]),
              ),
            ])),
          ]),
          const SizedBox(height: 12),
          // Info row
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.backgroundLight, borderRadius: BorderRadius.circular(12)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(df.format(b.startTime), style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                Text(b.durationFormatted, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
              ]),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary.withValues(alpha: 0.1), AppColors.primary.withValues(alpha: 0.04)]), borderRadius: BorderRadius.circular(10)),
                child: Text('\u20B9${b.totalPrice.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ),
            ]),
          ),
        ])),
      ]),
    );
  }
}
