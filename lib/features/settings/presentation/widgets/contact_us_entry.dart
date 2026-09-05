import 'dart:io' show Platform;

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

const _founderEmail = 'andresilitonga1101@gmail.com';
const _founderWhatsAppDisplay = '0895338891504';
const _founderWhatsAppIntl = '62895338891504';
const _founderGitHub = 'https://github.com/andrest1101';
const _founderName = 'Andre';

class ContactUsEntry extends StatelessWidget {
  const ContactUsEntry({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: InkWell(
          onTap: () => _showContactSheet(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: colors.tertiaryContainer,
                  foregroundColor: colors.onTertiaryContainer,
                  child: const Icon(Icons.support_agent_rounded),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hubungi Kami',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Email, WhatsApp, dan GitHub founder',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: colors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showContactSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _ContactUsSheet(),
    );
  }
}

class _ContactUsSheet extends StatelessWidget {
  const _ContactUsSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * .82,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            4,
            20,
            20 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hubungi Kami', style: theme.textTheme.labelLarge),
              const SizedBox(height: 4),
              Text(
                'Terhubung langsung dengan founder',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap salah satu card untuk langsung membuka aplikasi tujuannya. Setiap card juga bisa disalin.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              _ContactChannelCard(
                icon: Icons.email_outlined,
                title: 'Email Founder',
                subtitle: _founderEmail,
                description: 'Buka Gmail • penerima & pesan terisi otomatis',
                badge: 'Gmail',
                color: const Color(0xFFD93025),
                onTap: () => _openEmail(context),
                onCopy: () => _copy(context, _founderEmail, 'Email disalin.'),
              ),
              const SizedBox(height: 10),
              _ContactChannelCard(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'WhatsApp Founder',
                subtitle: _founderWhatsAppDisplay,
                description: 'Buka room chat • pesan pembuka terisi',
                badge: 'Chat',
                color: const Color(0xFF128C7E),
                onTap: () => _openWhatsApp(context),
                onCopy: () => _copy(
                  context,
                  _founderWhatsAppDisplay,
                  'Nomor WhatsApp disalin.',
                ),
              ),
              const SizedBox(height: 10),
              _ContactChannelCard(
                icon: Icons.code_rounded,
                title: 'GitHub Founder',
                subtitle: 'github.com/andrest1101',
                description: 'Buka profil GitHub di browser',
                badge: 'Website',
                color: colors.onSurface,
                onTap: () => _openGitHub(context),
                onCopy: () =>
                    _copy(context, _founderGitHub, 'Link GitHub disalin.'),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: .35),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.verified_outlined,
                      color: colors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tips laporan cepat',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Sertakan tipe HP, versi Android, dan langkah kejadian biar lebih cepat dibantu.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                              height: 1.4,
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
        ),
      ),
    );
  }

  // ── Direct open: Gmail / WhatsApp / GitHub ────────────────────

  Future<void> _openEmail(BuildContext context) async {
    const subject = 'Feedback Savu';
    const body =
        'Halo $_founderName,\n\nSaya ingin memberikan feedback tentang Savu:\n\n- Perangkat:\n- Android versi:\n- Deskripsi:\n\n';

    // Android: try native Gmail intent first (direct Gmail compose).
    if (Platform.isAndroid) {
      try {
        final intent = AndroidIntent(
          action: 'android.intent.action.SENDTO',
          data:
              'mailto:$_founderEmail?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
          package: 'com.google.android.gm',
        );
        await intent.launch();
        return;
      } catch (_) {
        // fall through to generic handlers
      }
      try {
        final intent2 = AndroidIntent(
          action: 'android.intent.action.SEND',
          type: 'message/rfc822',
          package: 'com.google.android.gm',
          arguments: <String, dynamic>{
            'android.intent.extra.EMAIL': <String>[_founderEmail],
            'android.intent.extra.SUBJECT': subject,
            'android.intent.extra.TEXT': body,
          },
        );
        await intent2.launch();
        return;
      } catch (_) {}
    }

    // Generic mailto (system chooser -> Gmail if default).
    final mailto = Uri(
      scheme: 'mailto',
      path: _founderEmail,
      query: _encodeQuery({'subject': subject, 'body': body}),
    );
    if (await _tryLaunch(mailto)) return;

    // Gmail web compose (reliably opens Gmail app via intent-filter or browser).
    final gmailWeb = Uri.parse(
      'https://mail.google.com/mail/?view=cm&fs=1'
      '&to=${Uri.encodeComponent(_founderEmail)}'
      '&su=${Uri.encodeComponent(subject)}'
      '&body=${Uri.encodeComponent(body)}',
    );
    if (await _tryLaunch(gmailWeb)) return;

    if (!context.mounted) return;
    _showError(context, 'Email $_founderEmail');
  }

  Future<void> _openWhatsApp(BuildContext context) async {
    const message =
        'Halo $_founderName, saya ingin memberikan feedback tentang Savu.';
    final enc = Uri.encodeComponent(message);

    if (Platform.isAndroid) {
      // Direct WhatsApp app via explicit package.
      try {
        final intent = AndroidIntent(
          action: 'android.intent.action.VIEW',
          data: 'https://wa.me/$_founderWhatsAppIntl?text=$enc',
          package: 'com.whatsapp',
        );
        await intent.launch();
        return;
      } catch (_) {}
      try {
        final intent2 = AndroidIntent(
          action: 'android.intent.action.VIEW',
          data: 'whatsapp://send?phone=$_founderWhatsAppIntl&text=$enc',
          package: 'com.whatsapp',
        );
        await intent2.launch();
        return;
      } catch (_) {}
      // WhatsApp Business fallback
      try {
        final intent3 = AndroidIntent(
          action: 'android.intent.action.VIEW',
          data: 'https://wa.me/$_founderWhatsAppIntl?text=$enc',
          package: 'com.whatsapp.w4b',
        );
        await intent3.launch();
        return;
      } catch (_) {}
    }

    for (final uri in <Uri>[
      Uri.parse('whatsapp://send?phone=$_founderWhatsAppIntl&text=$enc'),
      Uri.parse('https://wa.me/$_founderWhatsAppIntl?text=$enc'),
      Uri.parse(
        'https://api.whatsapp.com/send?phone=$_founderWhatsAppIntl&text=$enc',
      ),
    ]) {
      if (await _tryLaunch(uri)) return;
    }

    if (!context.mounted) return;
    _showError(context, 'WhatsApp $_founderWhatsAppDisplay');
  }

  Future<void> _openGitHub(BuildContext context) async {
    final uri = Uri.parse(_founderGitHub);
    if (await _tryLaunch(uri)) return;
    if (!context.mounted) return;
    _showError(context, 'GitHub $_founderGitHub');
  }

  Future<bool> _tryLaunch(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  String? _encodeQuery(Map<String, String> p) => p.entries
      .map(
        (e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
      )
      .join('&');

  Future<void> _copy(BuildContext c, String v, String msg) async {
    await Clipboard.setData(ClipboardData(text: v));
    if (!c.mounted) return;
    ScaffoldMessenger.of(c)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  void _showError(BuildContext c, String detail) {
    ScaffoldMessenger.of(c).showSnackBar(
      SnackBar(
        content: Text('Tidak bisa membuka $detail di perangkat ini.'),
        action: SnackBarAction(
          label: 'Salin',
          onPressed: () {
            final toCopy = detail.contains('@')
                ? _founderEmail
                : detail.contains('GitHub')
                ? _founderGitHub
                : _founderWhatsAppDisplay;
            Clipboard.setData(ClipboardData(text: toCopy));
          },
        ),
      ),
    );
  }
}

class _ContactChannelCard extends StatelessWidget {
  const _ContactChannelCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.badge,
    required this.color,
    required this.onTap,
    required this.onCopy,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final String badge;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: colors.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 11, 8, 11),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .13),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: .12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: color.withValues(alpha: .18),
                            ),
                          ),
                          child: Text(
                            badge,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: color,
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                              letterSpacing: .2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          Icons.touch_app_rounded,
                          size: 12,
                          color: colors.primary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Ketuk untuk membuka',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              // Compact secondary actions - keep total width safe for 320dp devices.
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: onCopy,
                    tooltip: 'Salin',
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.copy_outlined, size: 18),
                  ),
                  Icon(
                    Icons.open_in_new_rounded,
                    size: 16,
                    color: colors.onSurfaceVariant.withValues(alpha: .7),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
