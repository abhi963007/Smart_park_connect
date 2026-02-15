import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../models/booking.dart';

class AdminRevenueDetailScreen extends StatelessWidget {
  const AdminRevenueDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final all = provider.allBookings;
    final done = all.where((b) => b.status == 'completed').toList();
    final totalRev = done.fold(0.0, (s, b) => s + b.totalPrice);
    final avgVal = done.isNotEmpty ? totalRev / done.length : 0.0;
    final monthRev = _monthlyRevenue(done);
    final topSpots = _topEarningSpots(done);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // ── Gradient header ──
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: const Color(0xFFFBBF24),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Revenue', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.85))),
                        const SizedBox(height: 4),
                        Text('\u20B9${totalRev.toStringAsFixed(0)}',
                            style: GoogleFonts.poppins(fontSize: 44, fontWeight: FontWeight.w800, color: Colors.white, height: 1)),
                        const SizedBox(height: 12),
                        Row(children: [
                          _headerChip(Icons.receipt_long_outlined, '${done.length} Transactions'),
                          const SizedBox(width: 8),
                          _headerChip(Icons.trending_up, 'Avg \u20B9${avgVal.toStringAsFixed(0)}'),
                          const SizedBox(width: 8),
                          _headerChip(Icons.calendar_month_outlined, 'Month \u20B9${monthRev.toStringAsFixed(0)}'),
                        ]),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(20),
              child: Container(
                height: 20,
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F9FE),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
              ),
            ),
          ),

          // ── Body ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick stats row
                  Row(children: [
                    Expanded(child: _statCard('\u20B9${totalRev.toStringAsFixed(0)}', 'Total Revenue', Icons.account_balance_wallet_outlined, AppColors.success)),
                    const SizedBox(width: 10),
                    Expanded(child: _statCard('\u20B9${avgVal.toStringAsFixed(0)}', 'Avg. Booking', Icons.trending_up, AppColors.primary)),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: _statCard('\u20B9${monthRev.toStringAsFixed(0)}', 'This Month', Icons.calendar_month, AppColors.accent)),
                    const SizedBox(width: 10),
                    Expanded(child: _statCard('${provider.approvedParkingSpots.length}', 'Active Spots', Icons.local_parking, AppColors.warning)),
                  ]),
                  const SizedBox(height: 28),

                  // Top earning spots
                  _sectionHeader('TOP EARNING SPOTS'),
                  const SizedBox(height: 12),
                  if (topSpots.isEmpty)
                    _emptyState(Icons.bar_chart, 'No revenue data yet', 'Revenue will appear here once bookings are completed')
                  else
                    ...topSpots.asMap().entries.map((e) => _rankCard(e.value, e.key + 1)),
                  const SizedBox(height: 28),

                  // Recent transactions
                  _sectionHeader('RECENT TRANSACTIONS'),
                  const SizedBox(height: 12),
                  if (done.isEmpty)
                    _emptyState(Icons.receipt_long_outlined, 'No transactions yet', 'Completed bookings will show here')
                  else
                    ...done.take(10).map((b) => _txnCard(b)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header pill ──
  static Widget _headerChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: Colors.white.withOpacity(0.9)),
        const SizedBox(width: 5),
        Text(text, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
      ]),
    );
  }

  // ── Stat card ──
  Widget _statCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color.withOpacity(0.15), color.withOpacity(0.05)]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 12),
        Text(value, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        Text(label, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
      ]),
    );
  }

  // ── Section header ──
  Widget _sectionHeader(String text) {
    return Text(text, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textHint, letterSpacing: 1.2));
  }

  // ── Empty state ──
  Widget _emptyState(IconData icon, String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 3))]),
      child: Column(children: [
        Container(width: 64, height: 64, decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.08), shape: BoxShape.circle),
          child: Icon(icon, size: 32, color: AppColors.warning.withOpacity(0.4))),
        const SizedBox(height: 12),
        Text(title, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textHint)),
      ]),
    );
  }

  // ── Rank card ──
  Widget _rankCard(Map<String, dynamic> data, int rank) {
    final rc = _rankColor(rank);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Row(children: [
        // Rank badge
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [rc.withOpacity(0.2), rc.withOpacity(0.08)]),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(child: Text('#$rank', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w800, color: rc))),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(data['name'], style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          Row(children: [
            Icon(Icons.calendar_today_outlined, size: 11, color: AppColors.textHint),
            const SizedBox(width: 4),
            Text('${data['bookings']} bookings', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
          ]),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Text('\u20B9${(data['revenue'] as double).toStringAsFixed(0)}',
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.success)),
        ),
      ]),
    );
  }

  // ── Transaction card ──
  Widget _txnCard(Booking b) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(shape: BoxShape.circle,
            gradient: LinearGradient(colors: [AppColors.success, AppColors.success.withOpacity(0.4)])),
          child: const CircleAvatar(radius: 16, backgroundColor: Colors.white,
            child: Icon(Icons.check, size: 16, color: AppColors.success)),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(b.parkingName, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          Text('${b.userName.isEmpty ? 'User' : b.userName} \u2022 ${_fmtDate(b.startTime)}',
              style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
        ])),
        Text('+\u20B9${b.totalPrice.toStringAsFixed(0)}',
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.success)),
      ]),
    );
  }

  // ── Helpers ──
  double _monthlyRevenue(List<Booking> bookings) {
    final now = DateTime.now();
    return bookings.where((b) => b.startTime.month == now.month && b.startTime.year == now.year)
        .fold(0.0, (s, b) => s + b.totalPrice);
  }

  List<Map<String, dynamic>> _topEarningSpots(List<Booking> bookings) {
    final Map<String, Map<String, dynamic>> m = {};
    for (final b in bookings) {
      m.putIfAbsent(b.parkingName, () => {'name': b.parkingName, 'revenue': 0.0, 'bookings': 0});
      m[b.parkingName]!['revenue'] += b.totalPrice;
      m[b.parkingName]!['bookings'] += 1;
    }
    return (m.values.toList()..sort((a, b) => (b['revenue'] as double).compareTo(a['revenue'] as double))).take(5).toList();
  }

  Color _rankColor(int rank) {
    switch (rank) { case 1: return AppColors.starYellow; case 2: return AppColors.textSecondary; case 3: return AppColors.accent; default: return AppColors.primary; }
  }

  String _fmtDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}
