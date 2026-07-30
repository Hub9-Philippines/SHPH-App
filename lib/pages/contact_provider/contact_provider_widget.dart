import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '/backend/supabase/database/tables/profiles.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import '/services/chat_service.dart';
import '/services/logging_service.dart';
import '/theme/app_theme.dart';
import 'contact_provider_model.dart';

export 'contact_provider_model.dart';

class ContactProviderWidget extends StatefulWidget {
  const ContactProviderWidget({
    required this.providerName,
    super.key,
    this.providerId,
    this.providerPhoto,
    this.isVerified = false,
    this.mobileNumber,
    this.serviceName,
    this.serviceCategory,
    this.servicePrice,
    this.serviceDescription,
  });

  static String routeName = 'ContactProvider';
  static String routePath = '/contactProvider';

  final String providerName;
  final String? providerId;
  final String? providerPhoto;
  final bool isVerified;
  final String? mobileNumber;
  final String? serviceName;
  final String? serviceCategory;
  final String? servicePrice;
  final String? serviceDescription;

  @override
  State<ContactProviderWidget> createState() => _ContactProviderWidgetState();
}

class _ContactProviderWidgetState extends State<ContactProviderWidget> {
  late ContactProviderModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  bool _isSending = false;
  bool _isOpeningChat = false;
  String? _providerPhone;
  String? _providerPhotoUrl;
  String? _providerDisplayName;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, ContactProviderModel.new);
    _providerPhone = widget.mobileNumber;
    _providerPhotoUrl = widget.providerPhoto;
    _providerDisplayName = widget.providerName;
    _hydrateProviderProfile();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _hydrateProviderProfile() async {
    final providerId = widget.providerId;
    if (providerId == null || providerId.isEmpty) {
      return;
    }
    if ((_providerPhone ?? '').trim().isNotEmpty &&
        (_providerPhotoUrl ?? '').trim().isNotEmpty) {
      return;
    }

    try {
      final rows = await ProfilesTable().querySingleRow(
        queryFn: (q) => q.eq('id', providerId),
      );
      if (!mounted || rows.isEmpty) {
        return;
      }

      final profile = rows.first;
      setState(() {
        _providerPhone = _providerPhone?.trim().isNotEmpty == true
            ? _providerPhone
            : profile.phoneNumber;
        _providerPhotoUrl = _providerPhotoUrl?.trim().isNotEmpty == true
            ? _providerPhotoUrl
            : profile.photoUrl;
        _providerDisplayName =
            (profile.displayName ?? '').trim().isNotEmpty == true
                ? profile.displayName!.trim()
                : _providerDisplayName;
      });
    } catch (e, stackTrace) {
      LoggingService.error(
        'Failed to hydrate provider profile',
        tag: 'ContactProvider',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<Map<String, dynamic>?> _ensureDirectThread() async {
    final providerId = widget.providerId;
    if (providerId == null || providerId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This provider cannot be contacted yet.'),
          ),
        );
      }
      return null;
    }

    try {
      final thread = await ChatService.instance.getOrCreateDirectThread(
        providerId: providerId,
        providerName: _providerDisplayName ?? widget.providerName,
        providerPhoto: _providerPhotoUrl ?? widget.providerPhoto,
      );
      if (thread == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open chat right now.')),
        );
      }
      return thread;
    } catch (e, stackTrace) {
      LoggingService.error(
        'Failed to ensure direct thread',
        tag: 'ContactProvider',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open chat right now.')),
        );
      }
      return null;
    }
  }

  Future<void> _openChatThread({
    String? initialMessage,
    bool closeCurrentPage = false,
  }) async {
    if (_isOpeningChat || _isSending) {
      return;
    }

    setState(() {
      _isOpeningChat = true;
    });

    try {
      final thread = await _ensureDirectThread();
      final roomId = thread?['id']?.toString();
      if (!mounted || roomId == null || roomId.isEmpty) {
        return;
      }

      if ((initialMessage ?? '').trim().isNotEmpty) {
        final sent = await ChatService.instance.sendMessage(
          roomId,
          initialMessage!.trim(),
        );
        if (!sent && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Message could not be sent.')),
          );
        }
      }

      if (!mounted) {
        return;
      }

      if (closeCurrentPage && context.canPop()) {
        context.pop();
      }

      await context.pushNamed(
        ChatPageWidget.routeName,
        pathParameters: {'roomId': roomId},
        extra: <String, dynamic>{
          'providerName': _providerDisplayName ?? widget.providerName,
          'providerPhoto': _providerPhotoUrl ?? widget.providerPhoto,
        },
      );
    } finally {
      if (mounted) {
        setState(() {
          _isOpeningChat = false;
        });
      }
    }
  }

  Future<void> _sendMessage() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final subject = _model.subjectController.text.trim();
    final body = _model.messageController.text.trim();
    final composedMessage =
        subject.isEmpty ? body : 'Subject: $subject\n\n$body';

    setState(() => _isSending = true);
    try {
      await _openChatThread(
        initialMessage: composedMessage,
        closeCurrentPage: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _callProvider() async {
    final phone = (_providerPhone ?? widget.mobileNumber ?? '').trim();
    if (phone.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No mobile number available')),
        );
      }
      return;
    }

    try {
      await launchURL('tel:$phone');
    } catch (e, stackTrace) {
      LoggingService.error(
        'Failed to launch phone dialer',
        tag: 'ContactProvider',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch phone dialer')),
        );
      }
    }
  }

  Future<void> _startChat() async {
    await _openChatThread();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: const Color(0xFFF4F7FB),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back_rounded,
                            color: AppTheme.of(context).primaryText,
                          ),
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Contact Provider',
                              style: AppTheme.of(context).titleLarge.override(
                                    font: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w700,
                                    ),
                                    color: const Color(0xFF14213D),
                                  ),
                            ),
                            Text(
                              'Reach out to ${_providerDisplayName ?? widget.providerName} about service details or availability.',
                              style: AppTheme.of(context).bodySmall.override(
                                    font: GoogleFonts.plusJakartaSans(),
                                    color: const Color(0xFF64748B),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProviderCard(),
                        if (widget.serviceName != null) ...[
                          const SizedBox(height: 16),
                          _buildServiceCard(),
                        ],
                        const SizedBox(height: 18),
                        Text(
                          'Contact options',
                          style: AppTheme.of(context).titleMedium.override(
                                font: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w700,
                                ),
                                color: const Color(0xFF14213D),
                              ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: FFButtonWidget(
                                onPressed: _callProvider,
                                text: 'Call',
                                icon: const FaIcon(
                                  FontAwesomeIcons.phone,
                                  size: 16,
                                ),
                                options: FFButtonOptions(
                                  width: double.infinity,
                                  height: 54,
                                  color: const Color(0xFF0F8A6C),
                                  textStyle:
                                      AppTheme.of(context).titleSmall.override(
                                            font: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.w700,
                                            ),
                                            color: Colors.white,
                                          ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FFButtonWidget(
                                onPressed: _isOpeningChat ? null : _startChat,
                                text: _isOpeningChat ? 'Opening...' : 'Chat',
                                icon: const FaIcon(
                                  FontAwesomeIcons.comment,
                                  size: 16,
                                ),
                                options: FFButtonOptions(
                                  width: double.infinity,
                                  height: 54,
                                  color: AppTheme.of(context).primary,
                                  textStyle:
                                      AppTheme.of(context).titleSmall.override(
                                            font: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.w700,
                                            ),
                                            color: Colors.white,
                                          ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(18),
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
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Send a message',
                                  style:
                                      AppTheme.of(context).titleMedium.override(
                                            font: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.w700,
                                            ),
                                            color: const Color(0xFF14213D),
                                          ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'This sends your message straight into the existing in-app chat thread.',
                                  style: AppTheme.of(context).bodySmall.override(
                                        font: GoogleFonts.plusJakartaSans(),
                                        color: const Color(0xFF64748B),
                                      ),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _model.subjectController,
                                  decoration: InputDecoration(
                                    labelText: 'Subject',
                                    hintText: 'What is this about?',
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter a subject';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _model.messageController,
                                  maxLines: 5,
                                  decoration: InputDecoration(
                                    labelText: 'Message',
                                    hintText: 'Write your message here...',
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter a message';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                FFButtonWidget(
                                  onPressed: _isSending ? null : _sendMessage,
                                  text: _isSending ? 'Sending...' : 'Send Message',
                                  options: FFButtonOptions(
                                    width: double.infinity,
                                    height: 54,
                                    color: AppTheme.of(context).primary,
                                    textStyle: AppTheme.of(context)
                                        .titleMedium
                                        .override(
                                          font: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.w700,
                                          ),
                                          color: Colors.white,
                                        ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildProviderCard() => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
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
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: AppTheme.of(context).primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              child: (_providerPhotoUrl ?? '').trim().isNotEmpty
                  ? Image.network(
                      _providerPhotoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildFallbackAvatar(),
                    )
                  : _buildFallbackAvatar(),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _providerDisplayName ?? widget.providerName,
                          style: AppTheme.of(context).titleMedium.override(
                                font: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w700,
                                ),
                                color: const Color(0xFF14213D),
                              ),
                        ),
                      ),
                      if (widget.isVerified)
                        FaIcon(
                          FontAwesomeIcons.circleCheck,
                          color: AppTheme.of(context).success,
                          size: 16,
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    (_providerPhone ?? '').trim().isNotEmpty
                        ? _providerPhone!
                        : 'Phone number unavailable',
                    style: AppTheme.of(context).bodySmall.override(
                          font: GoogleFonts.plusJakartaSans(),
                          color: const Color(0xFF64748B),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildFallbackAvatar() => Center(
        child: FaIcon(
          FontAwesomeIcons.user,
          color: AppTheme.of(context).primary,
          size: 24,
        ),
      );

  Widget _buildServiceCard() => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
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
              'Service details',
              style: AppTheme.of(context).titleSmall.override(
                    font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                    color: const Color(0xFF14213D),
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.serviceName!,
              style: AppTheme.of(context).bodyLarge.override(
                    font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                    color: const Color(0xFF14213D),
                  ),
            ),
            if ((widget.serviceCategory ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                widget.serviceCategory!,
                style: AppTheme.of(context).bodySmall.override(
                      font: GoogleFonts.plusJakartaSans(),
                      color: const Color(0xFF64748B),
                    ),
              ),
            ],
            if ((widget.servicePrice ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                widget.servicePrice!,
                style: AppTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                      color: AppTheme.of(context).primary,
                    ),
              ),
            ],
            if ((widget.serviceDescription ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                widget.serviceDescription!,
                style: AppTheme.of(context).bodySmall.override(
                      font: GoogleFonts.plusJakartaSans(),
                      color: const Color(0xFF64748B),
                    ),
              ),
            ],
          ],
        ),
      );
}
