import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/theme/app_theme.dart';
import 'chatbot_page.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  static String routeName = 'Help';
  static String routePath = '/help';

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        title: Text(
          'Help & Support',
          style: theme.titleLarge.override(
            font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        children: [
          _FaqSection(
            theme: theme,
            title: 'Booking',
            items: [
              _FaqItem(
                question: 'How do I book a service?',
                answer:
                    'Browse through our service categories, select the service you need, choose your preferred date and time, and complete the booking. You can track your booking status in the "My Bookings" section.',
              ),
              _FaqItem(
                question: 'Can I cancel a booking?',
                answer:
                    'Yes, you can cancel a booking from the booking details page. Tap on "Cancel Booking" and confirm. Cancellation policies may vary depending on how close the booking is to the scheduled time.',
              ),
              _FaqItem(
                question: 'How do I reschedule a booking?',
                answer:
                    'You can reschedule by contacting the provider directly through the chat feature. Future updates will include a self-service rescheduling option.',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _FaqSection(
            theme: theme,
            title: 'Payment',
            items: [
              _FaqItem(
                question: 'What payment methods are accepted?',
                answer:
                    'We accept major credit/debit cards, GCash, Maya, and other popular e-wallet options. You can manage your payment methods in the "Payment Methods" section of your profile.',
              ),
              _FaqItem(
                question: 'How does billing work?',
                answer:
                    'Payment is processed after the service is completed. You will receive a detailed invoice via email and in the app. All transactions are securely processed through our payment partners.',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _FaqSection(
            theme: theme,
            title: 'Account',
            items: [
              _FaqItem(
                question: 'How do I update my profile?',
                answer:
                    'Go to your Profile page and tap "Edit Profile" to update your name, phone number, email, and profile photo. Changes are saved automatically.',
              ),
              _FaqItem(
                question: 'How do I change my password?',
                answer:
                    'Navigate to Profile > Security to update your password. You can also enable additional security features from that section.',
              ),
              _FaqItem(
                question: 'How do I delete my account?',
                answer:
                    'Please contact support to request account deletion. You can reach us through the chat feature on this page.',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _FaqSection(
            theme: theme,
            title: 'Providers',
            items: [
              _FaqItem(
                question: 'How are providers verified?',
                answer:
                    'All providers undergo a verification process including identity verification and background checks. Verified providers have a badge on their profile.',
              ),
              _FaqItem(
                question: 'What if I have an issue with a provider?',
                answer:
                    'You can report issues through the chat or contact our support team. We take all concerns seriously and will investigate promptly.',
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed(ChatbotPage.routeName),
        backgroundColor: theme.primary,
        foregroundColor: theme.secondaryBackground,
        icon: const Icon(Icons.chat_rounded),
        label: const Text('Chat with us'),
      ),
    );
  }
}

class _FaqSection extends StatelessWidget {
  const _FaqSection({
    required this.theme,
    required this.title,
    required this.items,
  });

  final AppThemeData theme;
  final String title;
  final List<_FaqItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: theme.titleSmall.override(
              font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
              color: theme.secondaryText,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: List.generate(items.length, (i) {
              final isLast = i == items.length - 1;
              return Column(
                children: [
                  _FaqTile(
                    theme: theme,
                    item: items[i],
                  ),
                  if (!isLast)
                    Divider(
                      indent: 16,
                      endIndent: 16,
                      color: theme.alternate,
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.theme, required this.item});

  final AppThemeData theme;
  final _FaqItem item;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: const Border(),
        collapsedShape: const Border(),
        title: Text(
          item.question,
          style: theme.bodyMedium.override(
            font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
          ),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              item.answer,
              style: GoogleFonts.plusJakartaSans(
                color: theme.secondaryText,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqItem {
  const _FaqItem({required this.question, required this.answer});
  final String question;
  final String answer;
}
