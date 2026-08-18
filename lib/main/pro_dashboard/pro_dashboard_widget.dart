import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/api/resources/users_api.dart';
import '/auth/base_auth_user_provider.dart';
import '/backend/supabase/database/tables/payment_methods.dart';
import '/services/auth_service.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/services/chat_service.dart';
import '/services/dispatch/dispatch_models.dart';
import '/services/dispatch/dispatch_service.dart';
import '/services/logging_service.dart';
import '/services/pro_bookings_service.dart';
import '/theme/app_theme.dart';

// Profile pages

export 'pro_dashboard_model.dart';

class ProDashboardWidget extends StatefulWidget {
  const ProDashboardWidget({
    super.key,
    this.initialPage,
    this.page,
    this.disableResizeToAvoidBottomInset = false,
  });

  final String? initialPage;
  final Widget? page;
  final bool disableResizeToAvoidBottomInset;

  static String routeName = 'ProDashboard';
  static String routePath = '/pro-dashboard';

  @override
  State<ProDashboardWidget> createState() => _ProDashboardWidgetState();
}

class _ProDashboardWidgetState extends State<ProDashboardWidget> {
  String _currentPageName = 'ProJobs';
  late Widget? _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPageName = widget.initialPage ?? _currentPageName;
    _currentPage = widget.page;
  }

  @override
  Widget build(BuildContext context) {
    final tabs = {
      'ProJobs': const ProJobsWidget(),
      'ProSchedule': const ProScheduleWidget(),
      'ProEarnings': const ProEarningsWidget(),
      'ProMessages': const ProMessagesWidget(),
      'ProProfile': const ProProfileWidget(),
    };
    final currentIndex = tabs.keys.toList().indexOf(_currentPageName);
    final theme = AppTheme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: !widget.disableResizeToAvoidBottomInset,
      backgroundColor: AppTheme.of(context).secondaryBackground,
      body: _currentPage ?? tabs[_currentPageName],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 24,
              offset: Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (i) => safeSetState(() {
              _currentPage = null;
              _currentPageName = tabs.keys.toList()[i];
            }),
            backgroundColor: Colors.white,
            selectedItemColor: theme.primary,
            unselectedItemColor: const Color(0xFF7B8794),
            selectedLabelStyle: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            showSelectedLabels: true,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.work_outline,
                  size: 24,
                ),
                label: 'Jobs',
                tooltip: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.calendar_today_outlined,
                  size: 24,
                ),
                label: 'Schedule',
                tooltip: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 24,
                ),
                label: 'Earnings',
                tooltip: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.chat_outlined,
                  size: 24,
                ),
                label: 'Messages',
                tooltip: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.person,
                  size: 24,
                ),
                label: 'Profile',
                tooltip: '',
              )
            ],
          ),
        ),
      ),
    );
  }
}

// Job Requests Tab
class ProJobsWidget extends StatefulWidget {
  const ProJobsWidget({super.key});

  @override
  State<ProJobsWidget> createState() => _ProJobsWidgetState();
}

class _ProJobsWidgetState extends State<ProJobsWidget> {
  List<Map<String, dynamic>> jobRequests = [];
  List<ProviderOfferView> dispatchOffers = [];
  bool isLoading = true;
  bool isLoadingDispatch = true;
  String? loadError;
  String? dispatchLoadError;
  final ProBookingsService _bookingsService = ProBookingsService.instance;
  StreamSubscription<List<ProviderOfferView>>? _offerSubscription;

  @override
  void initState() {
    super.initState();
    _loadJobRequests();
    _subscribeDispatchOffers();
  }

  @override
  void dispose() {
    _offerSubscription?.cancel();
    super.dispose();
  }

  void _subscribeDispatchOffers() {
    final stream = DispatchService.instance.watchProviderOffers();
    _offerSubscription = stream.listen(
      (offers) {
        if (!mounted) {
          return;
        }
        setState(() {
          dispatchOffers = offers;
          isLoadingDispatch = false;
        });
      },
      onError: (e) {
        if (!mounted) {
          return;
        }
        setState(() {
          isLoadingDispatch = false;
          dispatchLoadError = 'Could not load dispatch offers.';
        });
      },
    );
  }

  Future<void> _loadJobRequests() async {
    setState(() {
      isLoading = true;
      loadError = null;
    });
    try {
      final requests = await _bookingsService.getPendingJobRequests();
      setState(() {
        jobRequests = requests;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        loadError = 'We could not load job requests right now.';
      });
    }
  }

  Future<void> _acceptJob(String jobId) async {
    final success = await _bookingsService.acceptJob(jobId);
    if (success) {
      await _loadJobRequests();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job accepted successfully')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to accept job')),
        );
      }
    }
  }

  Future<void> _rejectJob(String jobId) async {
    final success = await _bookingsService.rejectJob(jobId);
    if (success) {
      await _loadJobRequests();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job declined')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to decline job')),
        );
      }
    }
  }

  Future<void> _acceptDispatchOffer(String jobId) async {
    final success = await DispatchService.instance.acceptOffer(jobId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Offer accepted — job confirmed' : 'Failed to accept offer',
          ),
        ),
      );
    }
  }

  Future<void> _rejectDispatchOffer(String jobId) async {
    final success = await DispatchService.instance.rejectOffer(jobId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Offer declined' : 'Failed to decline offer',
          ),
        ),
      );
    }
  }

  String _requestTypeLabel(Map<String, dynamic> job) {
    if (_bookingsService.isTimeMaterialBooking(job)) {
      return 'TIME-MATERIAL';
    }
    return 'SCHEDULED';
  }

  @override
  Widget build(BuildContext context) {
    final pendingToday = jobRequests
        .where((job) => _isSameDay(_parseDate(job['booking_date'])))
        .length;

    return Scaffold(
      backgroundColor: AppTheme.of(context).secondaryBackground,
      appBar: _buildDashboardAppBar(
        context,
        title: 'Job Requests',
        subtitle: 'Review and respond to new customer bookings fast.',
        onRefresh: _loadJobRequests,
      ),
      body: RefreshIndicator(
        onRefresh: _loadJobRequests,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _DashboardHeroCard(
              accentColor: const Color(0xFF0F766E),
              title: 'Provider inbox',
              headline:
                  '${jobRequests.length} pending request${jobRequests.length == 1 ? '' : 's'}',
              subtitle: jobRequests.isEmpty
                  ? 'New service requests will appear here as soon as customers book you.'
                  : 'Quick replies help you convert more requests into confirmed jobs.',
              leading: const Icon(
                Icons.inventory_2_outlined,
                color: Colors.white,
                size: 26,
              ),
              stats: [
                _DashboardStatData(
                  label: 'Pending',
                  value: jobRequests.length.toString(),
                ),
                _DashboardStatData(
                  label: 'Today',
                  value: pendingToday.toString(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (dispatchOffers.isNotEmpty) ...[
              _buildSectionHeader(context, 'Live Dispatch Offers'),
              const SizedBox(height: 10),
              ...dispatchOffers.map(
                (offer) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _buildDispatchOfferCard(context, offer),
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (isLoadingDispatch)
              const Padding(
                padding: EdgeInsets.only(top: 12, bottom: 12),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (dispatchLoadError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _DashboardMessageCard(
                  icon: Icons.sensors_off_outlined,
                  title: 'Dispatch unavailable',
                  message: dispatchLoadError!,
                ),
              ),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 60),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (loadError != null)
              _DashboardMessageCard(
                icon: Icons.error_outline_rounded,
                title: 'Could not load requests',
                message: loadError!,
                actionLabel: 'Try Again',
                onTap: _loadJobRequests,
              )
            else if (jobRequests.isEmpty)
              const _DashboardMessageCard(
                icon: Icons.work_history_outlined,
                title: 'No job requests yet',
                message:
                    'When a client books one of your services, the request will appear here for review.',
              )
            else
              ...jobRequests.map(
                (job) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _buildJobCard(context, job),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) => Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Text(
          title,
          style: AppTheme.of(context).labelLarge.override(
                font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                color: const Color(0xFF64748B),
              ),
        ),
      );

  Widget _buildDispatchOfferCard(BuildContext context, ProviderOfferView view) {
    final theme = AppTheme.of(context);
    final serviceType = view.job.serviceType;
    final clientName = view.clientDisplayName ?? 'A client';
    final elapsed = DateTime.now().difference(view.offer.offeredAt);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A0F766E),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.bolt_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dispatch match',
                            style: theme.labelMedium.override(
                              font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                              color: Colors.white.withValues(alpha: 0.82),
                            ),
                          ),
                          Text(
                            'New offer available',
                            style: theme.titleSmall.override(
                              font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${elapsed.inSeconds ~/ 60}m ago',
                        style: theme.labelSmall.override(
                          font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.person_outline, size: 16, color: Colors.white.withValues(alpha: 0.82)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        clientName,
                        style: theme.bodyMedium.override(
                          font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.build_outlined, size: 16, color: Colors.white.withValues(alpha: 0.82)),
                    const SizedBox(width: 6),
                    Text(
                      serviceType,
                      style: theme.bodySmall.override(
                        font: GoogleFonts.plusJakartaSans(),
                        color: Colors.white.withValues(alpha: 0.90),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () => _acceptDispatchOffer(view.job.id),
                            borderRadius: BorderRadius.circular(12),
                            child: Center(
                              child: Text(
                                'Accept',
                                style: theme.bodyMedium.override(
                                  font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                                  color: const Color(0xFF0F766E),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () => _rejectDispatchOffer(view.job.id),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.50),
                            ),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Decline',
                            style: theme.bodyMedium.override(
                              font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJobCard(BuildContext context, Map<String, dynamic> job) {
    final isPending = job['status'] == 'pending';

    final serviceListing = job['service_listings'] as Map<String, dynamic>?;
    final profile = job['profiles'] as Map<String, dynamic>?;
    final address = job['addresses'] as Map<String, dynamic>?;

    final clientName =
        profile?['display_name'] ?? profile?['first_name'] ?? 'Unknown Client';
    final clientPhoto = profile?['photo_url'];
    final serviceName = serviceListing?['title'] ??
        serviceListing?['name'] ??
        'Unknown Service';
    final location = _bookingLocationText(address);
    final bookingDate = _parseDate(job['booking_date']) ?? DateTime.now();
    final bookingTime = job['booking_time'] ?? 'N/A';
    final price = (job['total_price'] as num?)?.toDouble() ?? 0.0;
    final jobId = job['id'] as String?;
    final status = job['status']?.toString();
    final isTm = _bookingsService.isTimeMaterialBooking(job);
    final tmSubCategory = _bookingsService.tmSubCategoryTitle(job);
    final tmStageLabel = _bookingsService.tmStageLabel(job);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DashboardAvatar(imageUrl: clientPhoto, size: 54),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clientName,
                      style: AppTheme.of(context).bodyLarge.override(
                            font: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                            ),
                            color: const Color(0xFF0F172A),
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      serviceName,
                      style: AppTheme.of(context).bodySmall.override(
                            font: GoogleFonts.plusJakartaSans(),
                            color: const Color(0xFF64748B),
                          ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InlineInfoChip(
                          label: _requestTypeLabel(job),
                          backgroundColor: isTm
                              ? const Color(0xFFE0F2FE)
                              : const Color(0xFFF1F5F9),
                          foregroundColor: isTm
                              ? const Color(0xFF0369A1)
                              : const Color(0xFF475569),
                        ),
                        if (isTm)
                          _InlineInfoChip(
                            label: tmSubCategory ?? tmStageLabel,
                            backgroundColor: const Color(0xFFECFDF5),
                            foregroundColor: const Color(0xFF047857),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              _StatusPill(
                label: (status ?? 'pending').toUpperCase(),
                status: status,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Job details
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppTheme.of(context).secondaryText,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  location,
                  style: AppTheme.of(context).bodySmall.override(
                        color: AppTheme.of(context).secondaryText,
                      ),
                ),
              ),
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: AppTheme.of(context).secondaryText,
              ),
              const SizedBox(width: 4),
              Text(
                '${DateFormat('MMM d, yyyy').format(bookingDate)} at $bookingTime',
                style: AppTheme.of(context).bodySmall.override(
                      color: AppTheme.of(context).secondaryText,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(
                Icons.attach_money,
                size: 16,
                color: AppTheme.of(context).primary,
              ),
              const SizedBox(width: 4),
              Text(
                'PHP ${price.toStringAsFixed(0)}',
                style: AppTheme.of(context).bodyMedium.override(
                      color: AppTheme.of(context).primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          if (isPending) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.of(context).success,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: InkWell(
                      onTap: jobId != null ? () => _acceptJob(jobId) : null,
                      child: Center(
                        child: Text(
                          'Accept',
                          style: AppTheme.of(context).bodyMedium.override(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.of(context).error,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: InkWell(
                      onTap: jobId != null ? () => _rejectJob(jobId) : null,
                      child: Center(
                        child: Text(
                          'Decline',
                          style: AppTheme.of(context).bodyMedium.override(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class ProScheduleWidget extends StatefulWidget {
  const ProScheduleWidget({super.key});

  @override
  State<ProScheduleWidget> createState() => _ProScheduleWidgetState();
}

class _ProScheduleWidgetState extends State<ProScheduleWidget> {
  List<Map<String, dynamic>> scheduledJobs = [];
  bool isLoading = true;
  String? loadError;
  final ProBookingsService _bookingsService = ProBookingsService.instance;

  @override
  void initState() {
    super.initState();
    _loadScheduledJobs();
  }

  Future<void> _loadScheduledJobs() async {
    setState(() {
      isLoading = true;
      loadError = null;
    });
    try {
      final jobs = await _bookingsService.getScheduledJobs();
      setState(() {
        scheduledJobs = jobs;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        loadError = 'We could not load your schedule right now.';
      });
    }
  }

  Future<void> _completeJob(String jobId) async {
    final success = await _bookingsService.completeJob(jobId);
    if (success) {
      await _loadScheduledJobs();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job marked as completed')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to complete job')),
        );
      }
    }
  }

  Future<void> _startTmJob(String jobId) async {
    final success = await _bookingsService.markJobInProgress(jobId);
    if (success) {
      await _loadScheduledJobs();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('TM job marked in progress')),
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to start TM job')),
      );
    }
  }

  Future<void> _requestTmHardware(String jobId) async {
    final costController = TextEditingController(text: '350');
    final descriptionController = TextEditingController(
      text: 'Replacement component needed to complete the repair safely.',
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Request Hardware Approval'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: costController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Additional Cost',
                prefixText: 'Php ',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Send Request'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    final additionalCost = double.tryParse(costController.text.trim()) ?? 0;
    final description = descriptionController.text.trim();
    final success = await _bookingsService.requestTMHardware(
      bookingId: jobId,
      title: 'Hardware Parts Required',
      description: description.isEmpty
          ? 'Additional hardware is required to complete the job.'
          : description,
      additionalCost: additionalCost,
    );

    if (success) {
      await _loadScheduledJobs();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hardware approval request sent')),
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send hardware request')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppTheme.of(context).secondaryBackground,
        appBar: _buildDashboardAppBar(
          context,
          title: 'Schedule',
          subtitle: 'Track upcoming, active, and completed provider jobs.',
          onRefresh: _loadScheduledJobs,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : loadError != null
                ? _DashboardMessageCard(
                    icon: Icons.error_outline_rounded,
                    title: 'Could not load schedule',
                    message: loadError!,
                    actionLabel: 'Try Again',
                    onTap: _loadScheduledJobs,
                  )
                : scheduledJobs.isEmpty
                    ? const _DashboardMessageCard(
                        icon: Icons.event_busy_outlined,
                        title: 'No scheduled jobs',
                        message:
                            'Accepted and active jobs will appear here once your calendar fills up.',
                      )
                    : RefreshIndicator(
                        onRefresh: _loadScheduledJobs,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: scheduledJobs.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final job = scheduledJobs[index];
                            return _buildScheduleCard(context, job);
                          },
                    ),
                  ),
              );

  Widget _buildScheduleCard(BuildContext context, Map<String, dynamic> job) {
    final serviceListing = job['service_listings'] as Map<String, dynamic>?;
    final profile = job['profiles'] as Map<String, dynamic>?;
    final address = job['addresses'] as Map<String, dynamic>?;

    final clientName =
        profile?['display_name'] ?? profile?['first_name'] ?? 'Unknown Client';
    final clientPhoto = profile?['photo_url'];
    final serviceName = serviceListing?['title'] ??
        serviceListing?['name'] ??
        'Unknown Service';
    final location = _bookingLocationText(address);
    final bookingDate = _parseDate(job['booking_date']) ?? DateTime.now();
    final bookingTime = job['booking_time'] ?? 'N/A';
    final price = (job['total_price'] as num?)?.toDouble() ?? 0.0;
    final jobId = job['id'] as String?;
    final status = job['status'] as String? ?? 'accepted';
    final isCompleted = status == 'completed';
    final isTm = _bookingsService.isTimeMaterialBooking(job);
    final tmSubCategory = _bookingsService.tmSubCategoryTitle(job);
    final tmStageLabel = _bookingsService.tmStageLabel(job);
    final isInProgress = status == 'in_progress';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.of(context).primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              DateFormat('MMM d, yyyy').format(bookingDate),
              style: AppTheme.of(context).bodySmall.override(
                    color: AppTheme.of(context).primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(height: 12),
          // Client info
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.of(context).primary,
                  image: clientPhoto != null
                      ? DecorationImage(
                          fit: BoxFit.cover,
                          image: Image.network(clientPhoto).image,
                        )
                      : null,
                  shape: BoxShape.circle,
                ),
                child: clientPhoto == null
                    ? Icon(Icons.person, color: AppTheme.of(context).onPrimary)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clientName,
                      style: AppTheme.of(context).bodyLarge.override(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      serviceName,
                      style: AppTheme.of(context).bodySmall.override(
                            color: AppTheme.of(context).secondaryText,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InlineInfoChip(
                          label: isTm ? 'TIME-MATERIAL' : 'SCHEDULED',
                          backgroundColor: isTm
                              ? const Color(0xFFE0F2FE)
                              : const Color(0xFFF1F5F9),
                          foregroundColor: isTm
                              ? const Color(0xFF0369A1)
                              : const Color(0xFF475569),
                        ),
                        if (isTm)
                          _InlineInfoChip(
                            label: tmSubCategory ?? tmStageLabel,
                            backgroundColor: const Color(0xFFECFDF5),
                            foregroundColor: const Color(0xFF047857),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Job details
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: AppTheme.of(context).secondaryText,
              ),
              const SizedBox(width: 4),
              Text(
                '$bookingTime',
                style: AppTheme.of(context).bodySmall.override(
                      color: AppTheme.of(context).secondaryText,
                    ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppTheme.of(context).secondaryText,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  location,
                  style: AppTheme.of(context)
                      .bodySmall
                      .override(color: AppTheme.of(context).secondaryText),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Price
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(
                Icons.attach_money,
                size: 16,
                color: AppTheme.of(context).primary,
              ),
              const SizedBox(width: 4),
              Text(
                'PHP ${price.toStringAsFixed(0)}',
                style: AppTheme.of(context).bodyMedium.override(
                      color: AppTheme.of(context).primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Action buttons
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              if (!isCompleted && isTm && !isInProgress) ...[
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.of(context).info,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: InkWell(
                      onTap: jobId != null ? () => _startTmJob(jobId) : null,
                      child: Center(
                        child: Text(
                          'Start TM Job',
                          style: AppTheme.of(context).bodyMedium.override(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              if (!isCompleted && isTm && isInProgress) ...[
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: InkWell(
                      onTap: jobId != null
                          ? () => _requestTmHardware(jobId)
                          : null,
                      child: Center(
                        child: Text(
                          'Request Hardware',
                          style: AppTheme.of(context).bodyMedium.override(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              if (!isCompleted) ...[
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.of(context).success,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: InkWell(
                      onTap: jobId != null ? () => _completeJob(jobId) : null,
                      child: Center(
                        child: Text(
                          'Mark Complete',
                          style: AppTheme.of(context).bodyMedium.override(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                flex: isCompleted ? 2 : 1,
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppTheme.of(context).success.withValues(alpha: 0.1)
                        : AppTheme.of(context).primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: InkWell(
                    onTap: jobId == null
                        ? null
                        : () => context.pushNamed(
                              BookingDetailsWidget.routeName,
                              extra: {'bookingId': jobId},
                            ),
                    child: Center(
                      child: Text(
                        isCompleted ? 'Completed' : 'View Details',
                        style: AppTheme.of(context).bodyMedium.override(
                              color: isCompleted
                                  ? AppTheme.of(context).success
                                  : Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F7FB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.of(context).primary,
                    width: 1,
                  ),
                ),
                child: InkWell(
                  onTap: () => _callClient(job),
                  child: Icon(
                    Icons.phone,
                    color: AppTheme.of(context).primary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _callClient(Map<String, dynamic> job) async {
    final profile = job['profiles'] as Map<String, dynamic>?;
    final phone = (profile?['phone_number'] as String?)?.trim() ?? '';
    if (phone.isEmpty) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Client phone number is not available for this job.'),
        ),
      );
      return;
    }

    try {
      await launchURL('tel:$phone');
    } catch (e, stackTrace) {
      LoggingService.error(
        'Failed to launch client dialer',
        tag: 'ProSchedule',
        error: e,
        stackTrace: stackTrace,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch phone dialer')),
      );
    }
  }
}

class ProEarningsWidget extends StatefulWidget {
  const ProEarningsWidget({super.key});

  @override
  State<ProEarningsWidget> createState() => _ProEarningsWidgetState();
}

class _ProEarningsWidgetState extends State<ProEarningsWidget> {
  Map<String, dynamic> earningsData = {};
  bool isLoading = true;
  final ProBookingsService _bookingsService = ProBookingsService.instance;

  @override
  void initState() {
    super.initState();
    _loadEarnings();
  }

  Future<void> _loadEarnings() async {
    setState(() => isLoading = true);
    try {
      final data = await _bookingsService.getEarningsSummary();
      setState(() {
        earningsData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading earnings: $e')),
      );
    }
  }

  double get totalEarnings =>
      (earningsData['totalEarnings'] as num?)?.toDouble() ?? 0.0;
  double get thisMonth =>
      (earningsData['thisMonth'] as num?)?.toDouble() ?? 0.0;
  double get lastMonth =>
      (earningsData['lastMonth'] as num?)?.toDouble() ?? 0.0;
  double get thisWeek => (earningsData['thisWeek'] as num?)?.toDouble() ?? 0.0;
  double get lastWeek => (earningsData['lastWeek'] as num?)?.toDouble() ?? 0.0;
  int get totalJobs => earningsData['totalJobs'] as int? ?? 0;
  List<Map<String, dynamic>> get weeklyEarnings =>
      (earningsData['weeklyData'] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>() ??
      [];
  List<Map<String, dynamic>> get recentTransactions =>
      (earningsData['recentTransactions'] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>() ??
      [];

  Future<void> _handleCashOut() async {
    final userId = currentUser?.uid;
    if (userId == null || userId.isEmpty) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
      return;
    }

    try {
      final methods = await PaymentMethodsTable().queryRows(
        queryFn: (q) => q.eq('user_id', userId),
      );
      if (!mounted) {
        return;
      }

      final hasEwallet = methods.any((method) => method.type == 'ewallet');
      final action = await showModalBottomSheet<String>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD6DBE1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Cash Out Setup',
                  style: AppTheme.of(context).titleMedium.override(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  hasEwallet
                      ? 'Your payout wallet is ready to review. Automated provider cash-out is not enabled yet, but you can manage the wallet that will be used for payouts.'
                      : 'Link an e-wallet first so your provider payout destination is ready when cash-out processing is enabled.',
                  style: AppTheme.of(context).bodyMedium.override(
                        color: AppTheme.of(context).secondaryText,
                      ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () =>
                        Navigator.of(context).pop(hasEwallet ? 'manage' : 'add'),
                    child: Text(
                      hasEwallet ? 'Manage Payout Wallet' : 'Add Payout Wallet',
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop('later'),
                    child: const Text('Maybe Later'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      if (!mounted) {
        return;
      }

      if (action == 'add') {
        await context.pushNamed(AddEwalletPaymentWidget.routeName);
        return;
      }

      if (action == 'manage') {
        await context.pushNamed(PaymentMethodsWidget.routeName);
      }
    } catch (e, stackTrace) {
      LoggingService.error(
        'Failed to open cash-out setup',
        tag: 'ProEarnings',
        error: e,
        stackTrace: stackTrace,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open cash-out setup')),
      );
    }
  }

  double get _weeklyDelta => thisWeek - lastWeek;
  bool get _isWeeklyTrendPositive => _weeklyDelta >= 0;

  String _currency(double amount) => 'PHP ${amount.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: AppTheme.of(context).secondaryBackground,
      appBar: _buildDashboardAppBar(
        context,
        title: 'Earnings',
        subtitle: 'Monitor payouts, momentum, and recent completed work.',
        onRefresh: _loadEarnings,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadEarnings,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                children: [
                  _buildEarningsHero(context),
                  const SizedBox(height: 16),
                  _buildEarningsHighlights(context),
                  const SizedBox(height: 16),
                  _buildWeeklySummaryCard(context),
                  const SizedBox(height: 16),
                  _buildRecentTransactionsSection(context),
                ],
              ),
            ));

  Widget _buildEarningsHero(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF0E6B58),
              Color(0xFF169873),
              Color(0xFF69C8A1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x220E6B58),
              blurRadius: 24,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Earnings',
              style: AppTheme.of(context).bodyMedium.override(
                    color: Colors.white.withValues(alpha: 0.78),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _currency(totalEarnings),
              style: AppTheme.of(context).displaySmall.override(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              '$totalJobs jobs completed',
              style: AppTheme.of(context).bodySmall.override(
                    color: Colors.white.withValues(alpha: 0.78),
                  ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _MiniHeroMetric(
                    label: 'This month',
                    value: _currency(thisMonth),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MiniHeroMetric(
                    label: 'Last month',
                    value: _currency(lastMonth),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _handleCashOut,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.of(context).primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  'Cash Out Setup',
                  style: AppTheme.of(context).labelLarge.override(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.of(context).primary,
                      ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildEarningsHighlights(BuildContext context) => Row(
        children: [
          Expanded(
            child: _DashboardStatCard(
              title: 'This Week',
              value: _currency(thisWeek),
              subtitle: 'Current 7-day earnings',
              icon: Icons.calendar_view_week_rounded,
              color: const Color(0xFF2563EB),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _DashboardStatCard(
              title: 'Weekly Delta',
              value:
                  '${_isWeeklyTrendPositive ? '+' : '-'}${_currency(_weeklyDelta.abs())}',
              subtitle: _isWeeklyTrendPositive
                  ? 'Ahead of last week'
                  : 'Behind last week',
              icon: _isWeeklyTrendPositive
                  ? Icons.trending_up_rounded
                  : Icons.trending_down_rounded,
              color: _isWeeklyTrendPositive
                  ? const Color(0xFF16A34A)
                  : const Color(0xFFEF4444),
            ),
          ),
        ],
      );

  Widget _buildWeeklySummaryCard(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Summary',
              style: AppTheme.of(context).titleMedium.override(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF14213D),
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Compare this week against your recent earning pace.',
              style: AppTheme.of(context).bodySmall.override(
                    color: const Color(0xFF64748B),
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _SummaryValueTile(
                    label: 'This week',
                    value: _currency(thisWeek),
                    valueColor: AppTheme.of(context).success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryValueTile(
                    label: 'Last week',
                    value: _currency(lastWeek),
                    valueColor: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: (_isWeeklyTrendPositive
                        ? const Color(0xFFECFDF3)
                        : const Color(0xFFFEF2F2))
                    .withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Icon(
                    _isWeeklyTrendPositive
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    color: _isWeeklyTrendPositive
                        ? const Color(0xFF027A48)
                        : const Color(0xFFB42318),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _isWeeklyTrendPositive
                          ? 'You earned ${_currency(_weeklyDelta.abs())} more than last week.'
                          : 'You earned ${_currency(_weeklyDelta.abs())} less than last week.',
                      style: AppTheme.of(context).bodySmall.override(
                            color: _isWeeklyTrendPositive
                                ? const Color(0xFF027A48)
                                : const Color(0xFFB42318),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildRecentTransactionsSection(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Recent Transactions',
                  style: AppTheme.of(context).titleMedium.override(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF14213D),
                      ),
                ),
                const Spacer(),
                Text(
                  '${recentTransactions.length} items',
                  style: AppTheme.of(context).bodySmall.override(
                        color: const Color(0xFF64748B),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'A quick view of your latest completed-job earnings.',
              style: AppTheme.of(context).bodySmall.override(
                    color: const Color(0xFF64748B),
                  ),
            ),
            const SizedBox(height: 16),
            if (recentTransactions.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 36,
                      color: AppTheme.of(context).secondaryText,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'No transactions yet',
                      style: AppTheme.of(context).titleSmall.override(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF14213D),
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Completed jobs will start appearing here as your earning history grows.',
                      textAlign: TextAlign.center,
                      style: AppTheme.of(context).bodySmall.override(
                            color: const Color(0xFF64748B),
                          ),
                    ),
                  ],
                ),
              )
            else
              ...recentTransactions.map(
                (transaction) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildTransactionCard(context, transaction),
                ),
              ),
          ],
        ),
      );

  Widget _buildTransactionCard(
    BuildContext context,
    Map<String, dynamic> transaction,
  ) {
    final isEarning = transaction['type'] == 'earning';
    final amount = (transaction['amount'] as num?)?.toDouble() ?? 0.0;
    final serviceName =
        (transaction['serviceName'] ?? transaction['description'] ?? 'Transaction')
            .toString();
    final clientName = (transaction['clientName'] ?? '').toString().trim();
    final date = (transaction['date'] ?? 'Unknown date').toString();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: (isEarning
                      ? AppTheme.of(context).success
                      : AppTheme.of(context).error)
                  .withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isEarning
                  ? Icons.south_west_rounded
                  : Icons.north_east_rounded,
              color: isEarning
                  ? AppTheme.of(context).success
                  : AppTheme.of(context).error,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  serviceName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.of(context).titleSmall.override(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF14213D),
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  clientName.isEmpty ? date : '$clientName • $date',
                  style: AppTheme.of(context).bodySmall.override(
                        color: const Color(0xFF64748B),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${isEarning ? '+' : '-'}${_currency(amount.abs())}',
            style: AppTheme.of(context).titleSmall.override(
                  color: isEarning
                      ? AppTheme.of(context).success
                      : AppTheme.of(context).error,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _MiniHeroMetric extends StatelessWidget {
  const _MiniHeroMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTheme.of(context).bodySmall.override(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppTheme.of(context).titleSmall.override(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      );
}

class _DashboardStatCard extends StatelessWidget {
  const _DashboardStatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: AppTheme.of(context).bodySmall.override(
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppTheme.of(context).titleMedium.override(
                    color: const Color(0xFF14213D),
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTheme.of(context).labelSmall.override(
                    color: const Color(0xFF94A3B8),
                  ),
            ),
          ],
        ),
      );
}

class _SummaryValueTile extends StatelessWidget {
  const _SummaryValueTile({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTheme.of(context).bodySmall.override(
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppTheme.of(context).titleSmall.override(
                    color: valueColor,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      );
}

class ProMessagesWidget extends StatefulWidget {
  const ProMessagesWidget({super.key});

  @override
  State<ProMessagesWidget> createState() => _ProMessagesWidgetState();
}

class _ProMessagesWidgetState extends State<ProMessagesWidget> {
  List<Map<String, dynamic>> _chatRooms = const [];
  bool _isLoading = true;
  StreamSubscription? _chatRoomsSubscription;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadChatRooms();
    _subscribeToChatRooms();
    _searchController.addListener(() {
      if (mounted) {
        safeSetState(() {});
      }
    });
  }

  @override
  void dispose() {
    _chatRoomsSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadChatRooms() async {
    safeSetState(() => _isLoading = true);
    try {
      final userId = currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        safeSetState(() {
          _chatRooms = const [];
          _isLoading = false;
        });
        return;
      }

      var rooms = <Map<String, dynamic>>[];
      try {
        final apiRooms = await ChatService.instance.getChatRooms();
        rooms = apiRooms
            .where(
              (room) => _stringValue(room['provider_id']) == userId,
            )
            .map(_normalizeChatRoom)
            .whereType<Map<String, dynamic>>()
            .toList();
      } catch (_) {
        rooms = const [];
      }

      if (rooms.isEmpty) {
        rooms = const [];
      }

      rooms.sort(_sortChatRoomsByActivity);

      if (mounted) {
        safeSetState(() {
          _chatRooms = rooms;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      LoggingService.error(
        'Error loading chat rooms',
        tag: 'ProMessages',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) {
        safeSetState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error loading messages')),
        );
      }
    }
  }

  void _subscribeToChatRooms() {
    final userId = currentUser?.uid;
    if (userId == null || userId.isEmpty) {
      return;
    }

    try {
      // Poll for chat room updates (realtime not available via REST)
      _chatRoomsSubscription = Stream.periodic(
        const Duration(seconds: 30),
        (_) => null,
      ).listen((_) => _loadChatRooms());
      _loadChatRooms();
    } catch (_) {}
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) {
      return '';
    }
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    }
    if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    }
    if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    }
    return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
  }

  Map<String, dynamic>? _normalizeChatRoom(Map<String, dynamic> room) {
    final roomId = _stringValue(room['id']);
    if (roomId == null) {
      return null;
    }

    final customer = _normalizeCustomer(room);
    final lastMessage = _normalizeLastMessage(room);
    return <String, dynamic>{
      ...room,
      'id': roomId,
      'customer': customer,
      'last_message': lastMessage,
      'updated_at': _stringValue(room['updated_at']),
      'unread_provider_count': _readUnreadCount(room),
    };
  }

  Map<String, dynamic>? _normalizeCustomer(Map<String, dynamic> room) {
    final nested = room['customer'] ??
        room['profiles'] ??
        room['client'] ??
        room['client_profile'] ??
        room['profiles!chat_rooms_client_id_fkey'];
    if (nested is Map<String, dynamic>) {
      return nested;
    }
    if (nested is Map) {
      return nested.map((key, value) => MapEntry('$key', value));
    }

    final clientId = _stringValue(room['client_id']) ?? _stringValue(room['other_user_id']);
    final displayName = _stringValue(room['client_name']) ??
        _stringValue(room['other_user_name']) ??
        _stringValue(room['customer_name']) ??
        _stringValue(room['display_name']) ??
        'Customer';
    final photoUrl = _stringValue(room['client_photo']) ??
        _stringValue(room['other_user_photo']) ??
        _stringValue(room['customer_photo']) ??
        _stringValue(room['photo_url']);
    return <String, dynamic>{
      'id': clientId,
      'display_name': displayName,
      'photo_url': photoUrl,
    };
  }

  Map<String, dynamic>? _normalizeLastMessage(Map<String, dynamic> room) {
    final nested = room['last_message'] ?? room['lastMessage'];
    if (nested is Map<String, dynamic>) {
      return _normalizedMessageMap(nested);
    }
    if (nested is Map) {
      return _normalizedMessageMap(
        nested.map((key, value) => MapEntry('$key', value)),
      );
    }

    final content = _stringValue(room['last_message_text']) ??
        _stringValue(room['message_text']) ??
        _stringValue(room['content']);
    final createdAt = _stringValue(room['last_message_at']) ??
        _stringValue(room['last_message_created_at']) ??
        _stringValue(room['updated_at']);

    if (content == null && createdAt == null) {
      return null;
    }
    return <String, dynamic>{
      'content': content,
      'created_at': createdAt,
    };
  }

  Map<String, dynamic> _normalizedMessageMap(Map<String, dynamic> map) =>
      <String, dynamic>{
        'content': _stringValue(map['content']) ??
            _stringValue(map['message_text']) ??
            _stringValue(map['body']),
        'created_at': _stringValue(map['created_at']) ??
            _stringValue(map['sent_at']) ??
            _stringValue(map['updated_at']),
      };

  int _readUnreadCount(Map<String, dynamic> room) {
    final raw = room['unread_provider_count'] ??
        room['unread_count'] ??
        room['unread'];
    if (raw is int) {
      return raw;
    }
    if (raw is num) {
      return raw.toInt();
    }
    return 0;
  }

  String? _stringValue(dynamic value) {
    if (value == null) {
      return null;
    }
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  DateTime? _parseRoomDate(String? value) =>
      value == null ? null : DateTime.tryParse(value);

  int _sortChatRoomsByActivity(
    Map<String, dynamic> a,
    Map<String, dynamic> b,
  ) {
    final aLast = _parseRoomDate(
      _stringValue((a['last_message'] as Map<String, dynamic>?)?['created_at']) ??
          _stringValue(a['updated_at']),
    );
    final bLast = _parseRoomDate(
      _stringValue((b['last_message'] as Map<String, dynamic>?)?['created_at']) ??
          _stringValue(b['updated_at']),
    );
    if (aLast == null && bLast == null) {
      return 0;
    }
    if (aLast == null) {
      return 1;
    }
    if (bLast == null) {
      return -1;
    }
    return bLast.compareTo(aLast);
  }

  void _navigateToChat(Map<String, dynamic> chatRoom) {
    final customer = chatRoom['customer'] as Map<String, dynamic>?;
    final roomId = _stringValue(chatRoom['id']);
    if (customer == null || roomId == null) {
      return;
    }

    context.pushNamed(
      ChatPageWidget.routeName,
      pathParameters: {'roomId': roomId},
      extra: <String, dynamic>{
        'providerName':
            customer['display_name'] ?? customer['first_name'] ?? 'Customer',
        'providerPhoto': customer['photo_url']?.toString(),
      },
    );
  }

  List<Map<String, dynamic>> get _filteredChatRooms {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return _chatRooms;
    }

    return _chatRooms.where((chatRoom) {
      final customer = chatRoom['customer'] as Map<String, dynamic>?;
      final customerName =
          customer?['display_name'] ?? customer?['first_name'] ?? 'Customer';
      final lastMessage = chatRoom['last_message'] as Map<String, dynamic>?;

      return customerName.toString().toLowerCase().contains(query) ||
          (lastMessage?['content']?.toString().toLowerCase().contains(query) ??
              false);
    }).toList();
  }

  int get _unreadConversations => _chatRooms.fold<int>(
        0,
        (total, room) => total + ((room['unread_provider_count'] ?? 0) as int),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppTheme.of(context).secondaryBackground,
        body: SafeArea(
          child: RefreshIndicator(
            color: AppTheme.of(context).primary,
            onRefresh: _loadChatRooms,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Messages',
                                    style: AppTheme.of(context)
                                        .headlineSmall
                                        .override(
                                          font: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.w700,
                                          ),
                                          color: const Color(0xFF0F172A),
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Keep customer conversations responsive and professional.',
                                    style:
                                        AppTheme.of(context).bodySmall.override(
                                              font: GoogleFonts.plusJakartaSans(),
                                              color: const Color(0xFF64748B),
                                            ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton.filledTonal(
                              onPressed: _loadChatRooms,
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppTheme.of(context).primary,
                              ),
                              icon: const Icon(Icons.refresh_rounded),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF0F172A),
                                Color(0xFF134E4A),
                                Color(0xFF0F8A6C),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x200F172A),
                                blurRadius: 28,
                                offset: Offset(0, 16),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 54,
                                    height: 54,
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.16),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: const Icon(
                                      Icons.chat_bubble_rounded,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      'Reply faster, reduce missed leads, and keep jobs moving.',
                                      style: AppTheme.of(context)
                                          .titleMedium
                                          .override(
                                            font: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.w700,
                                            ),
                                            color: Colors.white,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildMessageStat(
                                      context,
                                      label: 'Threads',
                                      value: _chatRooms.length.toString(),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _buildMessageStat(
                                      context,
                                      label: 'Unread',
                                      value: _unreadConversations.toString(),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0F000000),
                                blurRadius: 18,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search customer conversations',
                              prefixIcon: const Icon(Icons.search_rounded),
                              suffixIcon: _searchController.text.isEmpty
                                  ? null
                                  : IconButton(
                                      onPressed: _searchController.clear,
                                      icon: const Icon(Icons.close_rounded),
                                    ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(22),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(22),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(22),
                                borderSide: BorderSide(
                                  color: AppTheme.of(context)
                                      .primary
                                      .withValues(alpha: 0.22),
                                  width: 1.4,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Recent conversations',
                                style: AppTheme.of(context)
                                    .titleMedium
                                    .override(
                                      font: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w700,
                                      ),
                                      color: const Color(0xFF0F172A),
                                    ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F7F2),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '${_filteredChatRooms.length} threads',
                                style: AppTheme.of(context).labelSmall.override(
                                      font: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w700,
                                      ),
                                      color: const Color(0xFF0F8A6C),
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                if (_isLoading)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    sliver: SliverList.separated(
                      itemCount: 4,
                      itemBuilder: (_, __) => Container(
                        height: 96,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                    ),
                  )
                else if (_filteredChatRooms.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    sliver: SliverList.separated(
                      itemCount: _filteredChatRooms.length,
                      itemBuilder: (context, index) => _buildChatRoomCard(
                        context,
                        _filteredChatRooms[index],
                      ),
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );

  Widget _buildMessageStat(
    BuildContext context, {
    required String label,
    required String value,
  }) =>
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTheme.of(context).bodySmall.override(
                    font: GoogleFonts.plusJakartaSans(),
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppTheme.of(context).titleLarge.override(
                    font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                    color: Colors.white,
                  ),
            ),
          ],
        ),
      );

  Widget _buildEmptyState() => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 18,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF6F2),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 32,
                    color: AppTheme.of(context).primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _searchController.text.isEmpty
                      ? 'No messages yet'
                      : 'No conversations matched',
                  style: AppTheme.of(context).titleMedium.override(
                        font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                        color: const Color(0xFF0F172A),
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  _searchController.text.isEmpty
                      ? 'Customer conversations will appear here as soon as new leads or active bookings open a thread.'
                      : 'Try a different customer name or keyword.',
                  style: AppTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.plusJakartaSans(),
                        color: const Color(0xFF64748B),
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildChatRoomCard(
      BuildContext context, Map<String, dynamic> chatRoom) {
    final customer = chatRoom['customer'] as Map<String, dynamic>?;
    final lastMessage = chatRoom['last_message'] as Map<String, dynamic>?;

    final customerName =
        customer?['display_name'] ?? customer?['first_name'] ?? 'Customer';
    final customerPhoto = customer?['photo_url'];
    final lastMessageText =
        lastMessage?['content'] ?? chatRoom['last_message_text'] ?? 'No messages yet';
    final lastMessageTime = lastMessage?['created_at'] != null
        ? DateTime.tryParse(lastMessage!['created_at'].toString())
        : null;
    final unreadCount = chatRoom['unread_provider_count'] ?? 0;

    return GestureDetector(
      onTap: () => _navigateToChat(chatRoom),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: AppTheme.of(context).primary.withValues(alpha: 0.12),
                image: customerPhoto != null
                    ? DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(customerPhoto),
                      )
                    : null,
                shape: BoxShape.circle,
              ),
              child: customerPhoto == null
                  ? Icon(
                      Icons.person,
                      color: AppTheme.of(context).primary,
                      size: 30,
                    )
                  : null,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            customerName,
                            style: AppTheme.of(context).bodyLarge.override(
                                  font: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  color: const Color(0xFF0F172A),
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatTime(lastMessageTime),
                          style: AppTheme.of(context).bodySmall.override(
                                font: GoogleFonts.plusJakartaSans(),
                                color: const Color(0xFF94A3B8),
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      lastMessageText,
                      style: AppTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.plusJakartaSans(),
                            color: const Color(0xFF64748B),
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Customer',
                        style: AppTheme.of(context).labelSmall.override(
                              font: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                              ),
                              color: const Color(0xFF475569),
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (unreadCount > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.of(context).primary,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  unreadCount.toString(),
                  style: AppTheme.of(context).labelSmall.override(
                        font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                        color: AppTheme.of(context).onPrimary,
                  ),
                ),
              ),
            if (unreadCount <= 0)
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppTheme.of(context).secondaryText,
              ),
          ],
        ),
      ),
    );
  }
}

class ProProfileWidget extends StatefulWidget {
  const ProProfileWidget({super.key});

  @override
  State<ProProfileWidget> createState() => _ProProfileWidgetState();
}

class _ProProfileWidgetState extends State<ProProfileWidget> {
  Map<String, dynamic>? profileData;
  bool isLoading = true;
  bool isAvailable = true;
  double hourlyRate = 500;
  final TextEditingController _rateController =
      TextEditingController(text: '500');
  bool _isSavingRate = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _rateController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    if (mounted) {
      setState(() => isLoading = true);
    }
    try {
      final userId = currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        if (mounted) {
          setState(() => isLoading = false);
        }
        return;
      }

      final data = await ShphUsersApi.instance.getMe();
      final profile = data['profile'] is Map<String, dynamic>
          ? data['profile'] as Map<String, dynamic>
          : data;

      if (!mounted) {
        return;
      }

      setState(() {
        profileData = profile;
        isAvailable = profile['is_available'] as bool? ?? true;
        hourlyRate =
            (profile['hourly_rate'] as num?)?.toDouble() ?? 500.0;
        _rateController.text = hourlyRate.toStringAsFixed(0);
        isLoading = false;
      });
    } catch (e) {
      LoggingService.error('Error loading provider profile: $e',
          tag: 'ProProfile');
      if (!mounted) {
        return;
      }
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateAvailability(bool value) async {
    try {
      final userId = currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        return;
      }

      await ShphUsersApi.instance.updateMe({'is_available': value});

      if (!mounted) {
        return;
      }

      setState(() => isAvailable = value);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value
                ? 'You are live and visible to customers.'
                : 'You are paused for new requests.',
          ),
        ),
      );
    } catch (e) {
      LoggingService.error('Error updating provider availability: $e',
          tag: 'ProProfile');
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to update availability right now')),
      );
    }
  }

  Future<void> _saveHourlyRate() async {
    final parsedRate = double.tryParse(_rateController.text.trim());
    if (parsedRate == null || parsedRate <= 0) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid hourly rate')),
      );
      return;
    }

    try {
      final userId = currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        return;
      }

      setState(() => _isSavingRate = true);
      await ShphUsersApi.instance.updateMe({'hourly_rate': parsedRate});

      if (!mounted) {
        return;
      }

      setState(() {
        hourlyRate = parsedRate;
        _isSavingRate = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hourly rate updated')),
      );
    } catch (e) {
      LoggingService.error('Error updating provider hourly rate: $e',
          tag: 'ProProfile');
      if (!mounted) {
        return;
      }
      setState(() => _isSavingRate = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to update hourly rate right now')),
      );
    }
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.logout, color: AppTheme.of(context).error),
            SizedBox(width: 8),
            Text('Log Out'),
          ],
        ),
        content: const Text(
          'Are you sure you want to log out? You will need to sign in again to access your account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.of(context).error,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (shouldLogout != true) {
      return;
    }

    try {
      await AuthService.instance.logout();
      if (mounted) {
        currentUser = null;
        context.go('/');
      }
    } catch (e) {
      LoggingService.error('Error logging out provider: $e', tag: 'ProProfile');
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to log out right now')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppTheme.of(context).secondaryBackground,
        appBar: _buildDashboardAppBar(
          context,
          title: 'Profile',
          subtitle:
              'Manage your provider presence, pricing, service area, and trust signals.',
          onRefresh: _loadProfile,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadProfile,
                child: SingleChildScrollView(
                  child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // Profile Header
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(24, 24, 24, 24),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF0F172A),
                              Color(0xFF164E63),
                              Color(0xFF0F8A6C),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1F0F172A),
                              blurRadius: 28,
                              offset: Offset(0, 18),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    _DashboardAvatar(
                                      imageUrl:
                                          profileData?['photo_url']?.toString(),
                                      size: 88,
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: () => context
                                            .pushNamed(ProEditProfileWidget.routeName),
                                        child: Container(
                                          width: 34,
                                          height: 34,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: const Color(0xFF0F8A6C),
                                              width: 2,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.edit_rounded,
                                            color: Color(0xFF0F8A6C),
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        profileData?['display_name'] ??
                                            profileData?['first_name'] ??
                                            'Service Provider',
                                        style: AppTheme.of(context)
                                            .headlineSmall
                                            .override(
                                              font: GoogleFonts.plusJakartaSans(
                                                fontWeight: FontWeight.w700,
                                              ),
                                              color: Colors.white,
                                            ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        profileData?['service_category'] ??
                                            profileData?['skill_profession'] ??
                                            'Professional Service Provider',
                                        style: AppTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.plusJakartaSans(),
                                              color: Colors.white
                                                  .withValues(alpha: 0.84),
                                            ),
                                      ),
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 7,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              (profileData?['verification_status'] ==
                                                      'verified')
                                                  ? const Color(0xFFECFDF3)
                                                  : const Color(0xFFFFF7ED),
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              (profileData?[
                                                          'verification_status'] ==
                                                      'verified')
                                                  ? Icons.verified_rounded
                                                  : Icons.hourglass_top_rounded,
                                              size: 16,
                                              color: (profileData?[
                                                          'verification_status'] ==
                                                      'verified')
                                                  ? const Color(0xFF027A48)
                                                  : const Color(0xFFC2410C),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              (profileData?[
                                                          'verification_status'] ==
                                                      'verified')
                                                  ? 'Verified provider'
                                                  : 'Verification pending',
                                              style: AppTheme.of(context)
                                                  .labelSmall
                                                  .override(
                                                    font: GoogleFonts.plusJakartaSans(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                    color: (profileData?[
                                                                'verification_status'] ==
                                                            'verified')
                                                        ? const Color(
                                                            0xFF027A48)
                                                        : const Color(
                                                            0xFFC2410C),
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildProviderHeroStat(
                                    label: 'Availability',
                                    value: isAvailable ? 'Live' : 'Paused',
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildProviderHeroStat(
                                    label: 'Rate',
                                    value: 'PHP ${hourlyRate.toStringAsFixed(0)}',
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildProviderHeroStat(
                                    label: 'Location',
                                    value: profileData?['latitude'] != null
                                        ? 'Pinned'
                                        : 'Unset',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Create Service Button
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () =>
                              context.pushNamed(CreateServiceWidget.routeName),
                          icon: const Icon(Icons.add_business_rounded),
                          label: const Text('Create a Service'),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Business Settings
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Business Settings',
                            style: AppTheme.of(context).titleMedium.override(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 16),
                          // Availability Toggle
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x12000000),
                                  blurRadius: 18,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Service Availability',
                                      style: AppTheme.of(context)
                                          .bodyLarge
                                          .override(
                                            font: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.w700,
                                            ),
                                            color: const Color(0xFF0F172A),
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      isAvailable
                                          ? 'You are visible to customers and can receive bookings.'
                                          : 'You are hidden from new booking requests right now.',
                                      style: AppTheme.of(context)
                                          .bodySmall
                                          .override(
                                            font: GoogleFonts.plusJakartaSans(),
                                            color: const Color(0xFF64748B),
                                          ),
                                    ),
                                  ],
                                ),
                                Switch(
                                  value: isAvailable,
                                  onChanged: _updateAvailability,
                                  activeThumbColor:
                                      AppTheme.of(context).primary,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Hourly Rate
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x12000000),
                                  blurRadius: 18,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hourly Rate',
                                  style:
                                      AppTheme.of(context).bodyLarge.override(
                                            font: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.w700,
                                            ),
                                            color: const Color(0xFF0F172A),
                                          ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Keep your pricing current so quotes and customer expectations stay aligned.',
                                  style: AppTheme.of(context).bodySmall.override(
                                        font: GoogleFonts.plusJakartaSans(),
                                        color: const Color(0xFF64748B),
                                      ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: const Color(0xFFE2E8F0),
                                          width: 1,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'â‚±',
                                          style: AppTheme.of(context)
                                              .bodyLarge
                                              .override(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextField(
                                        controller: _rateController,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          hintText: '500',
                                          filled: true,
                                          fillColor: const Color(0xFFF8FAFC),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            borderSide: BorderSide.none,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            borderSide: BorderSide(
                                              color:
                                                  AppTheme.of(context).primary,
                                              width: 1.5,
                                            ),
                                          ),
                                        ),
                                        style: AppTheme.of(context)
                                            .bodyLarge
                                            .override(
                                              font: GoogleFonts.plusJakartaSans(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppTheme.of(context).primary,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: InkWell(
                                    onTap: _isSavingRate ? null : _saveHourlyRate,
                                    child: Center(
                                      child: Text(
                                        _isSavingRate
                                            ? 'Saving...'
                                            : 'Update Rate',
                                        style: AppTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.plusJakartaSans(
                                                fontWeight: FontWeight.w700,
                                              ),
                                              color: AppTheme.of(context).onPrimary,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Service Location
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Service Location',
                            style: AppTheme.of(context).titleMedium.override(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () async {
                              await context
                                  .pushNamed(ProEditProfileWidget.routeName);
                              await _loadProfile();
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x12000000),
                                    blurRadius: 18,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: profileData?['latitude'] != null
                                          ? const Color(0xFFEAF6F2)
                                          : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(
                                      profileData?['latitude'] != null
                                          ? Icons.place_rounded
                                          : Icons.location_off_outlined,
                                      size: 20,
                                      color: profileData?['latitude'] != null
                                          ? AppTheme.of(context).primary
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          profileData?['latitude'] != null
                                              ? 'Pinned service area'
                                              : 'Service location not set',
                                          style: AppTheme.of(context)
                                              .bodySmall
                                              .override(
                                                font: GoogleFonts.plusJakartaSans(),
                                                color: const Color(0xFF64748B),
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          profileData?['location_label']
                                                  as String? ??
                                              (profileData?['latitude'] != null
                                                  ? '${(profileData!['latitude'] as num).toStringAsFixed(5)}, ${(profileData!['longitude'] as num).toStringAsFixed(5)}'
                                                  : 'Tap to set your service location'),
                                          style: AppTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.plusJakartaSans(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                                color: const Color(0xFF0F172A),
                                              ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    size: 20,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Menu Options
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Account',
                            style: AppTheme.of(context).titleMedium.override(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 16),
                          _buildMenuOption(
                            context,
                            Icons.edit_outlined,
                            'Edit Profile',
                            () => context
                                .pushNamed(ProEditProfileWidget.routeName),
                          ),
                          const SizedBox(height: 12),
                          _buildMenuOption(
                            context,
                            Icons.description_outlined,
                            'Service History',
                            () =>
                                context.pushNamed(ServiceHistoryWidget.routeName),
                          ),
                          const SizedBox(height: 12),
                          _buildMenuOption(
                            context,
                            Icons.star_outline,
                            'Reviews & Ratings',
                            () => context
                                .pushNamed(ReviewsRatingsWidget.routeName),
                          ),
                          const SizedBox(height: 12),
                          _buildMenuOption(
                            context,
                            Icons.help_outline,
                            'Help & Support',
                            () =>
                                context.pushNamed(HelpSupportWidget.routeName),
                          ),
                          const SizedBox(height: 12),
                          _buildMenuOption(
                            context,
                            Icons.info_outline,
                            'About',
                            () => context.pushNamed(AboutWidget.routeName),
                          ),
                          const SizedBox(height: 16),
                          // Logout Button
                          InkWell(
                            onTap: _logout,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x12000000),
                                    blurRadius: 18,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFFFEEF0),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      Icons.logout_rounded,
                                      size: 22,
                                      color: AppTheme.of(context).error,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      'Log Out',
                                      style: AppTheme.of(context).bodyLarge.override(
                                        font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                                        color: AppTheme.of(context).error,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ));

  Widget _buildProviderHeroStat({
    required String label,
    required String value,
  }) =>
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTheme.of(context).bodySmall.override(
                    font: GoogleFonts.plusJakartaSans(),
                    color: Colors.white.withValues(alpha: 0.78),
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppTheme.of(context).titleMedium.override(
                    font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                    color: Colors.white,
                  ),
            ),
          ],
        ),
      );

  Widget _buildMenuOption(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) =>
      InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: AppTheme.of(context).bodyLarge.override(
                        font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                        color: const Color(0xFF0F172A),
                      ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      );
}

PreferredSizeWidget _buildDashboardAppBar(
  BuildContext context, {
  required String title,
  required String subtitle,
  required VoidCallback onRefresh,
}) =>
    AppBar(
      backgroundColor: AppTheme.of(context).secondaryBackground,
      elevation: 0,
      titleSpacing: 20,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.of(context).titleLarge.override(
                  font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                  color: const Color(0xFF0F172A),
                ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTheme.of(context).bodySmall.override(
                  font: GoogleFonts.plusJakartaSans(),
                  color: const Color(0xFF64748B),
                ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 14),
          child: IconButton.filledTonal(
            onPressed: onRefresh,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.of(context).primary,
            ),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ),
      ],
    );

class _DashboardHeroCard extends StatelessWidget {
  const _DashboardHeroCard({
    required this.accentColor,
    required this.title,
    required this.headline,
    required this.subtitle,
    required this.leading,
    required this.stats,
  });

  final Color accentColor;
  final String title;
  final String headline;
  final String subtitle;
  final Widget leading;
  final List<_DashboardStatData> stats;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              accentColor,
              accentColor.withValues(alpha: 0.86),
            ],
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 24,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(child: leading),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTheme.of(context).labelLarge.override(
                              font: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w600,
                              ),
                              color: Colors.white.withValues(alpha: 0.82),
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        headline,
                        style: AppTheme.of(context).headlineSmall.override(
                              font: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                              ),
                              color: Colors.white,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              subtitle,
              style: AppTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.plusJakartaSans(),
                    color: Colors.white.withValues(alpha: 0.86),
                  ),
            ),
            if (stats.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(
                children: stats
                    .map(
                      (stat) => Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stat.label,
                                style: AppTheme.of(context).bodySmall.override(
                                      font: GoogleFonts.plusJakartaSans(),
                                      color:
                                          Colors.white.withValues(alpha: 0.78),
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                stat.value,
                                style:
                                    AppTheme.of(context).titleMedium.override(
                                          font: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.w700,
                                          ),
                                          color: Colors.white,
                                        ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      );
}

class _DashboardStatData {
  const _DashboardStatData({required this.label, required this.value});

  final String label;
  final String value;
}

class _DashboardMessageCard extends StatelessWidget {
  const _DashboardMessageCard({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 28),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 48, color: const Color(0xFF94A3B8)),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: AppTheme.of(context).titleMedium.override(
                        font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                        color: const Color(0xFF0F172A),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: AppTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.plusJakartaSans(),
                        color: const Color(0xFF64748B),
                      ),
                  textAlign: TextAlign.center,
                ),
                if (actionLabel != null && onTap != null) ...[
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: onTap,
                    child: Text(actionLabel!),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
}

class _DashboardAvatar extends StatelessWidget {
  const _DashboardAvatar({required this.imageUrl, this.size = 50});

  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppTheme.of(context).primary,
          shape: BoxShape.circle,
          image: imageUrl != null && imageUrl!.isNotEmpty
              ? DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(imageUrl!),
                )
              : null,
        ),
        child: imageUrl == null || imageUrl!.isEmpty
            ? Icon(Icons.person, color: AppTheme.of(context).onPrimary, size: size * 0.48)
            : null,
      );
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.status});

  final String label;
  final String? status;

  @override
  Widget build(BuildContext context) {
    final normalized = (status ?? '').toLowerCase();
    final (background, foreground) = switch (normalized) {
      'pending' => (const Color(0xFFFFF7ED), const Color(0xFFC2410C)),
      'completed' => (const Color(0xFFECFDF3), const Color(0xFF027A48)),
      'accepted' || 'confirmed' || 'in_progress' => (
          const Color(0xFFEFF6FF),
          const Color(0xFF1D4ED8)
        ),
      _ => (const Color(0xFFF1F5F9), const Color(0xFF475569)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTheme.of(context).bodySmall.override(
              font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
              color: foreground,
              fontSize: 10,
            ),
      ),
    );
  }
}

class _InlineInfoChip extends StatelessWidget {
  const _InlineInfoChip({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: AppTheme.of(context).labelSmall.override(
                color: foregroundColor,
                fontWeight: FontWeight.w700,
              ),
        ),
      );
}

DateTime? _parseDate(dynamic raw) {
  if (raw == null) {
    return null;
  }
  if (raw is DateTime) {
    return raw;
  }
  return DateTime.tryParse(raw.toString());
}

bool _isSameDay(DateTime? date) {
  if (date == null) {
    return false;
  }
  final now = DateTime.now();
  return date.year == now.year &&
      date.month == now.month &&
      date.day == now.day;
}

String _bookingLocationText(Map<String, dynamic>? address) {
  if (address == null) {
    return 'Location pending';
  }
  final line1 = address['address_line1']?.toString().trim() ?? '';
  final line2 = address['address_line2']?.toString().trim() ?? '';
  final city = address['city']?.toString().trim() ?? '';
  final parts = [line1, line2, city].where((part) => part.isNotEmpty).toList();
  return parts.isEmpty ? 'Location pending' : parts.join(', ');
}
