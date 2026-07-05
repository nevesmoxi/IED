import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  static const String _phone = '+244929990606';
  static const String _emailPrimary = 'nevesmoxi01@gmail.com';
  static const String _emailSecondary = 'nevesmoxi@hotmail.com';

  Future<void> _launch(BuildContext context, Uri uri, String label) async {
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        _showError(context, label);
      }
    } catch (_) {
      if (context.mounted) _showError(context, label);
    }
  }

  void _showError(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Não foi possível abrir $label neste dispositivo.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contacto')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Entre em contacto',
              style: AppTheme.readingTextStyle(
                fontSize: 22,
                color: Theme.of(context).colorScheme.onSurface,
                weight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Dúvidas sobre o livro, formações ou parcerias académicas? Utilize um dos canais abaixo.',
              style: TextStyle(
                fontSize: 13.5,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 24),
            _ContactTile(
              icon: Icons.chat_bubble_outline,
              label: 'WhatsApp',
              value: '+244 929 990 606',
              color: const Color(0xFF25D366),
              onTap: () => _launch(
                context,
                Uri.parse('https://wa.me/${_phone.replaceAll('+', '')}'),
                'o WhatsApp',
              ),
            ),
            _ContactTile(
              icon: Icons.call_outlined,
              label: 'Telefone',
              value: '+244 929 990 606',
              color: AppColors.charcoalLight,
              onTap: () => _launch(
                context,
                Uri(scheme: 'tel', path: _phone),
                'o telefone',
              ),
            ),
            _ContactTile(
              icon: Icons.mail_outline,
              label: 'Email',
              value: _emailPrimary,
              color: AppColors.gold,
              onTap: () => _launch(
                context,
                Uri(scheme: 'mailto', path: _emailPrimary),
                'o email',
              ),
            ),
            _ContactTile(
              icon: Icons.alternate_email,
              label: 'Email (alternativo)',
              value: _emailSecondary,
              color: AppColors.gold,
              onTap: () => _launch(
                context,
                Uri(scheme: 'mailto', path: _emailSecondary),
                'o email',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _ContactTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(value, style: const TextStyle(fontSize: 13)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: onTap,
      ),
    );
  }
}
