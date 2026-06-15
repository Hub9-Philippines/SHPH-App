import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/flutter_flow/flutter_flow_util.dart';
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

    return Scaffold(
      resizeToAvoidBottomInset: !widget.disableResizeToAvoidBottomInset,
      body: _currentPage ?? tabs[_currentPageName],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => safeSetState(() {
          _currentPage = null;
          _currentPageName = tabs.keys.toList()[i];
        }),
        backgroundColor: AppTheme.of(context).primaryBackground,
        selectedItemColor: AppTheme.of(context).primary,
        unselectedItemColor: AppTheme.of(context).secondaryText,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
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
  bool isLoading = true;
  final ProBookingsService _bookingsService = ProBookingsService.instance;

  @override
  void initState() {
    super.initState();
    _loadJobRequests();
  }

  Future<void> _loadJobRequests() async {
    setState(() => isLoading = true);
    try {
      final requests = await _bookingsService.getPendingJobRequests();
      setState(() {
        jobRequests = requests;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading jobs: $e')),
      );
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

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(
            'Job Requests',
            style: AppTheme.of(context).titleLarge.override(
                  font: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
          ),
          backgroundColor: AppTheme.of(context).primaryBackground,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadJobRequests,
            ),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : jobRequests.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.work_off_outlined,
                          size: 64,
                          color: AppTheme.of(context).secondaryText,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No job requests yet',
                          style: AppTheme.of(context).bodyLarge.override(
                                color: AppTheme.of(context).secondaryText,
                              ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadJobRequests,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: jobRequests.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final job = jobRequests[index];
                        return _buildJobCard(context, job);
                      },
                    ),
                  ),
      );

  Widget _buildJobCard(BuildContext context, Map<String, dynamic> job) {
    final isPending = job['status'] == 'pending';

    // Extract nested data from Supabase response
    final serviceListing = job['service_listings'] as Map<String, dynamic>?;
    final profile = job['profiles'] as Map<String, dynamic>?;

    final clientName =
        profile?['display_name'] ?? profile?['first_name'] ?? 'Unknown Client';
    final clientPhoto = profile?['photo_url'];
    final serviceName = serviceListing?['name'] ?? 'Unknown Service';
    const location = 'Location N/A'; // TODO: Get from address if available
    final bookingDate = job['booking_date'] != null
        ? DateTime.parse(job['booking_date'])
        : DateTime.now();
    final bookingTime = job['booking_time'] ?? 'N/A';
    final price = (job['total_price'] as num?)?.toDouble() ?? 0.0;
    final jobId = job['id'] as String?;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.of(context).primaryText.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with client info
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
                    ? const Icon(Icons.person, color: Colors.white)
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
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isPending
                      ? AppTheme.of(context).warning
                      : AppTheme.of(context).success,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  job['status'].toString().toUpperCase(),
                  style: AppTheme.of(context).bodySmall.override(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
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
                '₱${price.toStringAsFixed(0)}',
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
  final ProBookingsService _bookingsService = ProBookingsService.instance;

  @override
  void initState() {
    super.initState();
    _loadScheduledJobs();
  }

  Future<void> _loadScheduledJobs() async {
    setState(() => isLoading = true);
    try {
      final jobs = await _bookingsService.getScheduledJobs();
      setState(() {
        scheduledJobs = jobs;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading schedule: $e')),
      );
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

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(
            'Schedule',
            style: AppTheme.of(context).titleLarge.override(
                  font: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
          ),
          backgroundColor: AppTheme.of(context).primaryBackground,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadScheduledJobs,
            ),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : scheduledJobs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 64,
                          color: AppTheme.of(context).secondaryText,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No scheduled jobs',
                          style: AppTheme.of(context).bodyLarge.override(
                                color: AppTheme.of(context).secondaryText,
                              ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadScheduledJobs,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: scheduledJobs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final job = scheduledJobs[index];
                        return _buildScheduleCard(context, job);
                      },
                    ),
                  ),
      );

  Widget _buildScheduleCard(BuildContext context, Map<String, dynamic> job) {
    // Extract nested data from Supabase response
    final serviceListing = job['service_listings'] as Map<String, dynamic>?;
    final profile = job['profiles'] as Map<String, dynamic>?;

    final clientName =
        profile?['display_name'] ?? profile?['first_name'] ?? 'Unknown Client';
    final clientPhoto = profile?['photo_url'];
    final serviceName = serviceListing?['name'] ?? 'Unknown Service';
    const location = 'Location N/A';
    final bookingDate = job['booking_date'] != null
        ? DateTime.parse(job['booking_date'])
        : DateTime.now();
    final bookingTime = job['booking_time'] ?? 'N/A';
    final price = (job['total_price'] as num?)?.toDouble() ?? 0.0;
    final jobId = job['id'] as String?;
    final status = job['status'] as String? ?? 'accepted';
    final isCompleted = status == 'completed';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.of(context).primaryText.withValues(alpha: 0.1),
          width: 1,
        ),
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
                    ? const Icon(Icons.person, color: Colors.white)
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
                '₱${price.toStringAsFixed(0)}',
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
                    onTap: () {
                      // TODO: Navigate to job details
                    },
                    child: Center(
                      child: Text(
                        isCompleted ? 'Completed ✓' : 'View Details',
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
                  color: AppTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.of(context).primary,
                    width: 1,
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    // TODO: Call client - would need phone number
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Calling client...')),
                    );
                  },
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

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text(
          'Earnings',
          style: AppTheme.of(context).titleLarge.override(
                font: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
        ),
        backgroundColor: AppTheme.of(context).primaryBackground,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEarnings,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadEarnings,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // Balance Card
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            24, 24, 24, 24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.of(context).primary,
                              AppTheme.of(context)
                                  .primary
                                  .withValues(alpha: 0.8),
                            ],
                            begin: const AlignmentDirectional(-1, -1),
                            end: const AlignmentDirectional(1, 1),
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Earnings',
                              style: AppTheme.of(context).bodyMedium.override(
                                    color: Colors.white70,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '₱${totalEarnings.toStringAsFixed(2)}',
                              style: AppTheme.of(context).displaySmall.override(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$totalJobs jobs completed',
                              style: AppTheme.of(context).bodySmall.override(
                                    color: Colors.white70,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        // TODO: Navigate to cash out page
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Cash out feature coming soon')),
                                        );
                                      },
                                      child: Center(
                                        child: Text(
                                          'Cash Out',
                                          style: AppTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                color: AppTheme.of(context)
                                                    .primary,
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
                        ),
                      ),
                    ),
                    // Weekly Summary
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            20, 20, 20, 20),
                        decoration: BoxDecoration(
                          color: AppTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.of(context)
                                .primaryText
                                .withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'This Week',
                              style: AppTheme.of(context).titleMedium.override(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Earnings',
                                      style: AppTheme.of(context)
                                          .bodySmall
                                          .override(
                                            color: AppTheme.of(context)
                                                .secondaryText,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '₱${thisWeek.toStringAsFixed(2)}',
                                      style: AppTheme.of(context)
                                          .headlineMedium
                                          .override(
                                            color: AppTheme.of(context).success,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'vs Last Week',
                                      style: AppTheme.of(context)
                                          .bodySmall
                                          .override(
                                            color: AppTheme.of(context)
                                                .secondaryText,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.trending_up,
                                          size: 16,
                                          color: AppTheme.of(context).success,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '+₱${(thisWeek - lastWeek).toStringAsFixed(2)}',
                                          style: AppTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                color: AppTheme.of(context)
                                                    .success,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Recent Transactions
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recent Transactions',
                            style: AppTheme.of(context).titleMedium.override(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 16),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: recentTransactions.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final transaction = recentTransactions[index];
                              return _buildTransactionCard(
                                  context, transaction);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ));
}

Widget _buildTransactionCard(
    BuildContext context, Map<String, dynamic> transaction) {
  final isEarning = transaction['type'] == 'earning';

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppTheme.of(context).secondaryBackground,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: AppTheme.of(context).primaryText.withValues(alpha: 0.1),
        width: 1,
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                transaction['description'],
                style: AppTheme.of(context).bodyMedium.override(
                      fontWeight: FontWeight.w600,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                transaction['date'],
                style: AppTheme.of(context).bodySmall.override(
                      color: AppTheme.of(context).secondaryText,
                    ),
              ),
            ],
          ),
        ),
        Text(
          '${isEarning ? '+' : ''}₱${transaction['amount'].toStringAsFixed(2)}',
          style: AppTheme.of(context).bodyLarge.override(
                color: isEarning
                    ? AppTheme.of(context).success
                    : AppTheme.of(context).error,
                fontWeight: FontWeight.bold,
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
  List<Map<String, dynamic>> chatRooms = [];
  bool isLoading = true;
  StreamSubscription? _chatRoomsSubscription;

  @override
  void initState() {
    super.initState();
    _loadChatRooms();
    _subscribeToChatRooms();
  }

  @override
  void dispose() {
    _chatRoomsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadChatRooms() async {
    setState(() => isLoading = true);
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        setState(() => isLoading = false);
        return;
      }

      // Get the service_listing IDs for this pro user
      final serviceListingsResponse = await Supabase.instance.client
          .from('service_listings')
          .select('id')
          .eq('provider', userId);

      final serviceIds = (serviceListingsResponse as List)
          .map((sl) => sl['id'] as int)
          .toList();

      if (serviceIds.isEmpty) {
        if (mounted) {
          setState(() {
            chatRooms = [];
            isLoading = false;
          });
        }
        return;
      }

      // Fetch chat rooms for any of this pro's services
      final chatRoomsResponse = await Supabase.instance.client
          .from('chat_rooms')
          .select('*')
          .filter('provider_id', 'in', serviceIds)
          .order('updated_at', ascending: false);

      final rooms = List<Map<String, dynamic>>.from(chatRoomsResponse);

      // Fetch customer profiles and last messages separately
      for (final room in rooms) {
        final clientId = room['client_id'];
        final lastMessageId = room['last_message_id'];

        // Fetch customer profile
        if (clientId != null) {
          try {
            final profileResponse = await Supabase.instance.client
                .from('profiles')
                .select('id, display_name, first_name, photo_url')
                .eq('id', clientId)
                .maybeSingle();
            room['customer'] = profileResponse;
          } catch (profileError) {
            room['customer'] = null;
          }
        }

        // Fetch last message
        if (lastMessageId != null) {
          try {
            final messageResponse = await Supabase.instance.client
                .from('chat_messages')
                .select('content, created_at')
                .eq('id', lastMessageId)
                .maybeSingle();
            room['last_message'] = messageResponse;
          } catch (messageError) {
            room['last_message'] = null;
          }
        }
      }

      if (mounted) {
        setState(() {
          chatRooms = rooms;
          isLoading = false;
        });
      }
    } catch (e) {
      LoggingService.error('Error loading chat rooms: $e', tag: 'ProMessages');
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading messages: $e')),
        );
      }
    }
  }

  void _subscribeToChatRooms() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      return;
    }

    // Subscribe to all chat rooms and let _loadChatRooms filter appropriately
    _chatRoomsSubscription = Supabase.instance.client
        .from('chat_rooms')
        .stream(primaryKey: ['id']).listen((data) {
      _loadChatRooms();
    });
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

  void _navigateToChat(Map<String, dynamic> chatRoom) {
    final customer = chatRoom['customer'] as Map<String, dynamic>?;
    if (customer == null) {
      return;
    }

    context.pushNamed(
      'ChatPage',
      queryParameters: {
        'chatRoomId': chatRoom['id'].toString(),
        'otherUserId': customer['id'].toString(),
        'otherUserName':
            customer['display_name'] ?? customer['first_name'] ?? 'Customer',
        'otherUserPhoto': customer['photo_url']?.toString() ?? '',
      },
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(
            'Messages',
            style: AppTheme.of(context).titleLarge.override(
                  font: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
          ),
          backgroundColor: AppTheme.of(context).primaryBackground,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadChatRooms,
            ),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadChatRooms,
                child: chatRooms.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: chatRooms.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final chatRoom = chatRooms[index];
                          return _buildChatRoomCard(context, chatRoom);
                        },
                      ),
              ),
      );

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: AppTheme.of(context).secondaryText,
            ),
            const SizedBox(height: 16),
            Text(
              'No messages yet',
              style: AppTheme.of(context).titleMedium.override(
                    color: AppTheme.of(context).secondaryText,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your conversations with customers will appear here',
              style: AppTheme.of(context).bodyMedium.override(
                    color: AppTheme.of(context).secondaryText,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatRoomCard(
      BuildContext context, Map<String, dynamic> chatRoom) {
    final customer = chatRoom['customer'] as Map<String, dynamic>?;
    final lastMessage = chatRoom['last_message'] as Map<String, dynamic>?;

    final customerName =
        customer?['display_name'] ?? customer?['first_name'] ?? 'Customer';
    final customerPhoto = customer?['photo_url'];
    final lastMessageText = lastMessage?['content'] ?? 'No messages yet';
    final lastMessageTime = lastMessage?['created_at'] != null
        ? DateTime.parse(lastMessage!['created_at'])
        : null;
    final unreadCount = chatRoom['unread_provider_count'] ?? 0;

    return GestureDetector(
      onTap: () => _navigateToChat(chatRoom),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.of(context).primaryText.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.of(context).primary,
                image: customerPhoto != null
                    ? DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(customerPhoto),
                      )
                    : null,
                shape: BoxShape.circle,
              ),
              child: customerPhoto == null
                  ? const Icon(Icons.person, color: Colors.white, size: 30)
                  : null,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customerName,
                      style: AppTheme.of(context).bodyLarge.override(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      lastMessageText,
                      style: AppTheme.of(context).bodyMedium.override(
                            color: AppTheme.of(context).secondaryText,
                            fontSize: 14,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatTime(lastMessageTime),
                  style: AppTheme.of(context).bodySmall.override(
                        color: const Color(0xFF767676),
                      ),
                ),
                if (unreadCount > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.of(context).primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      unreadCount.toString(),
                      style: AppTheme.of(context).bodySmall.override(
                            color: Colors.white,
                            fontSize: 10,
                          ),
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
    setState(() => isLoading = true);
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        setState(() => isLoading = false);
        return;
      }

      final response = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      setState(() {
        profileData = response;
        isAvailable = response['is_available'] ?? true;
        hourlyRate = (response['hourly_rate'] as num?)?.toDouble() ?? 500.0;
        _rateController.text = hourlyRate.toStringAsFixed(0);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateAvailability(bool value) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        return;
      }

      await Supabase.instance.client
          .from('profiles')
          .update({'is_available': value}).eq('id', userId);

      setState(() => isAvailable = value);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating availability: $e')),
      );
    }
  }

  Future<void> _logout() async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
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
              foregroundColor: Colors.red,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    // If user cancelled, don't logout
    if (shouldLogout != true) {
      return;
    }

    try {
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(
            'Profile',
            style: AppTheme.of(context).titleLarge.override(
                  font: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
          ),
          backgroundColor: AppTheme.of(context).primaryBackground,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadProfile,
            ),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // Profile Header
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(24, 24, 24, 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: AppTheme.of(context).primary,
                                  image: profileData?['photo_url'] != null
                                      ? DecorationImage(
                                          fit: BoxFit.cover,
                                          image: NetworkImage(
                                              profileData!['photo_url']),
                                        )
                                      : null,
                                  shape: BoxShape.circle,
                                ),
                                child: profileData?['photo_url'] == null
                                    ? const Icon(Icons.person,
                                        color: Colors.white, size: 50)
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () =>
                                      context.pushNamed('ProEditProfile'),
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: AppTheme.of(context).primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            profileData?['display_name'] ??
                                profileData?['first_name'] ??
                                'Service Provider',
                            style: AppTheme.of(context).headlineMedium.override(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            profileData?['service_category'] ??
                                'Professional Service Provider',
                            style: AppTheme.of(context).bodyMedium.override(
                                  color: AppTheme.of(context).secondaryText,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: (profileData?['verification_status'] ==
                                      'verified')
                                  ? AppTheme.of(context)
                                      .success
                                      .withValues(alpha: 0.1)
                                  : AppTheme.of(context)
                                      .warning
                                      .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  (profileData?['verification_status'] ==
                                          'verified')
                                      ? Icons.verified
                                      : Icons.pending,
                                  size: 16,
                                  color: (profileData?['verification_status'] ==
                                          'verified')
                                      ? AppTheme.of(context).success
                                      : AppTheme.of(context).warning,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  (profileData?['verification_status'] ==
                                          'verified')
                                      ? 'Verified Provider'
                                      : 'Pending Verification',
                                  style:
                                      AppTheme.of(context).bodySmall.override(
                                            color: (profileData?[
                                                        'verification_status'] ==
                                                    'verified')
                                                ? AppTheme.of(context).success
                                                : AppTheme.of(context).warning,
                                            fontWeight: FontWeight.w600,
                                          ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Create Service Button
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 16),
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppTheme.of(context).primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () => context.pushNamed('CreateService'),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.add_circle_outline,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Create a Service',
                                  style:
                                      AppTheme.of(context).titleSmall.override(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                ),
                              ],
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
                              color: AppTheme.of(context).secondaryBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.of(context)
                                    .primaryText
                                    .withValues(alpha: 0.1),
                                width: 1,
                              ),
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
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      isAvailable
                                          ? 'Available for bookings'
                                          : 'Not accepting bookings',
                                      style: AppTheme.of(context)
                                          .bodySmall
                                          .override(
                                            color: AppTheme.of(context)
                                                .secondaryText,
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
                              color: AppTheme.of(context).secondaryBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.of(context)
                                    .primaryText
                                    .withValues(alpha: 0.1),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hourly Rate',
                                  style:
                                      AppTheme.of(context).bodyLarge.override(
                                            fontWeight: FontWeight.w600,
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
                                        color: AppTheme.of(context)
                                            .primaryBackground,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: AppTheme.of(context)
                                              .primaryText
                                              .withValues(alpha: 0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '₱',
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
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                              color: AppTheme.of(context)
                                                  .primaryText
                                                  .withValues(alpha: 0.2),
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                              color: AppTheme.of(context)
                                                  .primaryText
                                                  .withValues(alpha: 0.2),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                              color:
                                                  AppTheme.of(context).primary,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                        style: AppTheme.of(context).bodyLarge,
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
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        hourlyRate = double.tryParse(
                                                _rateController.text) ??
                                            500.00;
                                      });
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content:
                                                Text('Hourly rate updated')),
                                      );
                                    },
                                    child: Center(
                                      child: Text(
                                        'Update Rate',
                                        style: AppTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
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
                            () => context.pushNamed('ProEditProfile'),
                          ),
                          _buildMenuOption(
                            context,
                            Icons.description_outlined,
                            'Service History',
                            () => context.pushNamed('ServiceHistory'),
                          ),
                          _buildMenuOption(
                            context,
                            Icons.star_outline,
                            'Reviews & Ratings',
                            () => context.pushNamed('ReviewsRatings'),
                          ),
                          _buildMenuOption(
                            context,
                            Icons.help_outline,
                            'Help & Support',
                            () => context.pushNamed('HelpSupport'),
                          ),
                          _buildMenuOption(
                            context,
                            Icons.info_outline,
                            'About',
                            () => context.pushNamed('About'),
                          ),
                          const SizedBox(height: 16),
                          // Logout Button
                          Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppTheme.of(context).error,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              onTap: _logout,
                              child: Center(
                                child: Text(
                                  'Log Out',
                                  style:
                                      AppTheme.of(context).titleSmall.override(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                ),
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
            color: AppTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.of(context).primaryText.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(
                icon,
                size: 24,
                color: AppTheme.of(context).primaryText,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: AppTheme.of(context).bodyLarge.override(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: AppTheme.of(context).secondaryText,
              ),
            ],
          ),
        ),
      );
}
