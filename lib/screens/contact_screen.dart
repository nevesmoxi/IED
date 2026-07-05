import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

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
              value: '+244 900 000 000',
              color: const Color(0xFF25D366),
            ),
            _ContactTile(
              icon: Icons.mail_outline,
              label: 'Email',
              value: 'contacto@iedreader.ao',
              color: AppColors.gold,
            ),
            _ContactTile(
              icon: Icons.camera_alt_outlined,
              label: 'Instagram',
              value: '@nevesmoxi',
              color: const Color(0xFFE1306C),
            ),
            _ContactTile(
              icon: Icons.facebook,
              label: 'Facebook',
              value: 'Neves Moxi — Autor',
              color: const Color(0xFF1877F2),
            ),
            _ContactTile(
              icon: Icons.link,
              label: 'LinkedIn',
              value: 'Neves Moxi',
              color: const Color(0xFF0A66C2),
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

  const _ContactTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
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
        onTap: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Abrindo $label...')));
        },
      ),
    );
  }
}
