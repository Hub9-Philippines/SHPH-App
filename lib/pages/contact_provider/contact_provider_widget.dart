import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/theme/app_theme.dart';
import 'contact_provider_model.dart';

export 'contact_provider_model.dart';

class ContactProviderWidget extends StatefulWidget {
  const ContactProviderWidget({
    required this.providerName, super.key,
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

  @override
  void initState() {
    super.initState();
    _model = createModel(context, ContactProviderModel.new);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSending = true);

    // TODO: Implement actual message sending logic
    // This would typically create a chat room or send a message to the provider

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _isSending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message sent successfully')),
      );
      context.pop();
    }
  }

  void _callProvider() {
    if (widget.mobileNumber != null && widget.mobileNumber!.isNotEmpty) {
      // TODO: Implement phone call functionality
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Calling ${widget.mobileNumber}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No mobile number available')),
      );
    }
  }

  void _startChat() {
    // TODO: Implement chat functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening chat...')),
    );
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: AppTheme.of(context).primaryBackground,
          appBar: AppBar(
            backgroundColor: AppTheme.of(context).primaryBackground,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: AppTheme.of(context).primaryText,
                size: 24,
              ),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                }
              },
            ),
            title: Text(
              'Contact ${widget.providerName}',
              style: AppTheme.of(context).titleLarge.override(
                    font: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
            ),
            actions: const [],
            centerTitle: true,
            elevation: 0,
          ),
          body: SafeArea(
            top: true,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Provider Profile Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppTheme.of(context).accent1,
                              shape: BoxShape.circle,
                            ),
                            child: ClipOval(
                              child: widget.providerPhoto != null &&
                                      widget.providerPhoto!.isNotEmpty
                                  ? Image.network(
                                      widget.providerPhoto!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) => Center(
                                          child: FaIcon(
                                            FontAwesomeIcons.user,
                                            color: AppTheme.of(context)
                                                .primaryText,
                                            size: 24,
                                          ),
                                        ),
                                    )
                                  : Center(
                                      child: FaIcon(
                                        FontAwesomeIcons.user,
                                        color: AppTheme.of(context).primaryText,
                                        size: 24,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      widget.providerName,
                                      style: AppTheme.of(context)
                                          .titleSmall
                                          .override(
                                            font: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                    ),
                                    if (widget.isVerified) ...[
                                      const SizedBox(width: 8),
                                      FaIcon(
                                        FontAwesomeIcons.checkCircle,
                                        color: AppTheme.of(context).success,
                                        size: 16,
                                      ),
                                    ],
                                  ],
                                ),
                                if (widget.mobileNumber != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.mobileNumber!,
                                    style:
                                        AppTheme.of(context).bodySmall.override(
                                              color: AppTheme.of(context)
                                                  .secondaryText,
                                            ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Service Details Card
                    if (widget.serviceName != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Service Details',
                              style: AppTheme.of(context).titleSmall.override(
                                    font: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold),
                                  ),
                            ),
                            const SizedBox(height: 12),
                            if (widget.serviceName != null) ...[
                              Text(
                                widget.serviceName!,
                                style: AppTheme.of(context).bodyMedium.override(
                                      font: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600),
                                    ),
                              ),
                              const SizedBox(height: 4),
                            ],
                            if (widget.serviceCategory != null) ...[
                              Text(
                                widget.serviceCategory!,
                                style: AppTheme.of(context).bodySmall.override(
                                      color: AppTheme.of(context).secondaryText,
                                    ),
                              ),
                              const SizedBox(height: 8),
                            ],
                            if (widget.servicePrice != null) ...[
                              Text(
                                widget.servicePrice!,
                                style: AppTheme.of(context).bodyMedium.override(
                                      color: AppTheme.of(context).primary,
                                      font: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600),
                                    ),
                              ),
                              const SizedBox(height: 8),
                            ],
                            if (widget.serviceDescription != null) ...[
                              Text(
                                widget.serviceDescription!,
                                style: AppTheme.of(context).bodySmall.override(
                                      color: AppTheme.of(context).secondaryText,
                                    ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    // Contact Options
                    Text(
                      'Contact Options',
                      style: AppTheme.of(context).titleMedium.override(
                            font: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold),
                          ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: FFButtonWidget(
                            onPressed: _callProvider,
                            text: 'Call',
                            icon:
                                const FaIcon(FontAwesomeIcons.phone, size: 16),
                            options: FFButtonOptions(
                              width: double.infinity,
                              color: AppTheme.of(context).success,
                              textStyle:
                                  AppTheme.of(context).titleSmall.override(
                                        font: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600),
                                        color: Colors.white,
                                      ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FFButtonWidget(
                            onPressed: _startChat,
                            text: 'Chat',
                            icon: const FaIcon(FontAwesomeIcons.comment,
                                size: 16),
                            options: FFButtonOptions(
                              width: double.infinity,
                              color: AppTheme.of(context).primary,
                              textStyle:
                                  AppTheme.of(context).titleSmall.override(
                                        font: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600),
                                        color: Colors.white,
                                      ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Message Form
                    Text(
                      'Send a Message',
                      style: AppTheme.of(context).titleMedium.override(
                            font: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold),
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Send a message to ${widget.providerName} about their service.',
                      style: AppTheme.of(context).bodySmall.override(
                            color: AppTheme.of(context).secondaryText,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _model.subjectController,
                            decoration: InputDecoration(
                              labelText: 'Subject',
                              hintText: 'What is this about?',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
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
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a message';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          FFButtonWidget(
                            onPressed: _isSending ? null : _sendMessage,
                            text: _isSending ? 'Sending...' : 'Send Message',
                            options: FFButtonOptions(
                              width: double.infinity,
                              color: AppTheme.of(context).primary,
                              textStyle:
                                  AppTheme.of(context).titleMedium.override(
                                        font: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600),
                                        color: AppTheme.of(context).primaryText,
                                      ),
                              borderRadius: BorderRadius.circular(12),
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
        ),
      );
}
