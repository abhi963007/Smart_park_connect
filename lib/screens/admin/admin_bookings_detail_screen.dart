import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../models/booking.dart';

class AdminBookingsDetailScreen extends StatefulWidget {
  const AdminBookingsDetailScreen({super.key});

  @override
  State<AdminBookingsDetailScreen> createState() =>
      _AdminBookingsDetailScreenState();
}

class _AdminBookingsDetailScreenState extends State<AdminBookingsDetailScreen>
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

  List<Booking> _filter(List<Booking> bookings) {
    switch (_tabController.index) {
      case 1:
        return bookings
            .where((b) => b.status == 'active' || b.status == 'confirmed')
            .toList();
      case 2:
        return bookings.where((b) => b.status == 'completed').toList();
      case 3:
        return bookings.where((b) => b.status == 'cancelled').toList();
      default:
        return bookings;
    }
  }

  int _cnt(List<Booking> b, int tab) {
    switch (tab) {
      case 1:
        return b
            .where((x) => x.status == 'active' || x.status == 'confirmed')
            .length;
      case 2:
        return b.where((x) => x.status == 'completed').length;
      case 3:
        return b.where((x) => x.status == 'cancelled').length;
      default:
        return b.length;
    }
  }

  Color _sc(String s) {
    switch (s) {
      case 'confirmed':
        return AppColors.primary;
      case 'active':
        return AppColors.success;
      case 'completed':
        return AppColors.textSecondary;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textHint;
    }
  }

  IconData _si(String s) {
    switch (s) {
      case 'confirmed':
        return Icons.schedule;
      case 'active':
        return Icons.play_circle_outline;
      case 'completed':
        return Icons.check_circle_outline;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  String _fmtDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  String _fmtTime(DateTime d) {
    final h = d.hour;
    final m = d.minute.toString().padLeft(2, '0');
    final p = h >= 12 ? 'PM' : 'AM';
    final dh = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$dh:$m $p';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final all = provider.allBookings;
    final filtered = _filter(all);
    final totalRev = all
        .where((b) => b.status == 'completed')
        .fold(0.0, (s, b) => s + b.totalPrice);
    final tabs = ['All', 'Active', 'Done', 'Cancelled'];

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.success,
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
                      colors: [Color(0xFF10B981), Color(0xFF059669)]),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${all.length}',
                            style: GoogleFonts.poppins(
                                fontSize: 48,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1)),
                        const SizedBox(height: 4),
                        Text('Total Bookings',
                            style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.85))),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _pill(Icons.play_circle_outline, '${_cnt(all, 1)}',
                                'Active'),
                            const SizedBox(width: 8),
                            _pill(Icons.check_circle_outline, '${_cnt(all, 2)}',
                                'Done'),
                            const SizedBox(width: 8),
                            _pill(
                                Icons.account_balance_wallet_outlined,
                                '\u20B9${totalRev.toStringAsFixed(0)}',
                                'Revenue'),
                          ],
                        ),
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
                  labelColor: AppColors.success,
                  unselectedLabelColor: AppColors.textHint,
                  indicatorColor: AppColors.success,
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
                            color: AppColors.success.withValues(alpha: 0.08),
                            shape: BoxShape.circle),
                        child: Icon(Icons.calendar_today,
                            size: 40,
                            color: AppColors.success.withValues(alpha: 0.4))),
                    const SizedBox(height: 16),
                    Text('No bookings found',
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
                itemBuilder: (_, i) => _bookingCard(filtered[i]),
              ),
      ),
    );
  }

  Widget _pill(IconData icon, String count, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: Colors.white),
        const SizedBox(width: 6),
        Text(count,
            style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
        const SizedBox(width: 4),
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.9))),
      ]),
    );
  }

  Widget _bookingCard(Booking b) {
    final sc = _sc(b.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          // Top colored accent bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: sc,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                          colors: [sc, sc.withValues(alpha: 0.4)]),
                    ),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      child: Text(
                          b.userName.isNotEmpty
                              ? b.userName[0].toUpperCase()
                              : 'U',
                          style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: sc)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b.userName.isEmpty ? 'User' : b.userName,
                          style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                      Text(b.parkingName,
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  )),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text('\u20B9${b.totalPrice.toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: sc.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: sc.withValues(alpha: 0.3), width: 0.5)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(_si(b.status), size: 12, color: sc),
                        const SizedBox(width: 4),
                        Text(b.status.toUpperCase(),
                            style: GoogleFonts.poppins(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: sc,
                                letterSpacing: 0.3)),
                      ]),
                    ),
                  ]),
                ]),
                const SizedBox(height: 14),
                // Detail grid
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(14)),
                  child: Row(children: [
                    Expanded(
                        child: _detailItem(Icons.calendar_today_outlined,
                            'Date', _fmtDate(b.startTime))),
                    Container(
                        width: 1, height: 36, color: AppColors.cardBorder),
                    Expanded(
                        child: _detailItem(
                            Icons.access_time, 'Time', _fmtTime(b.startTime))),
                    Container(
                        width: 1, height: 36, color: AppColors.cardBorder),
                    Expanded(
                        child: _detailItem(Icons.timer_outlined, 'Duration',
                            '${b.duration}h')),
                  ]),
                ),
                const SizedBox(height: 10),
                // Location row
                Row(children: [
                  Icon(Icons.location_on_outlined,
                      size: 14, color: AppColors.textHint),
                  const SizedBox(width: 4),
                  Expanded(
                      child: Text(b.parkingAddress,
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: AppColors.textHint),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis)),
                ]),
                if (b.vehicleNumber.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(children: [
                    Icon(Icons.directions_car_outlined,
                        size: 14, color: AppColors.textHint),
                    const SizedBox(width: 4),
                    Text(b.vehicleNumber,
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary)),
                  ]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailItem(IconData icon, String label, String value) {
    return Column(children: [
      Icon(icon, size: 16, color: AppColors.textHint),
      const SizedBox(height: 4),
      Text(value,
          style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary)),
      Text(label,
          style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textHint)),
    ]);
  }
}
