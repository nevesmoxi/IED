import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/access_provider.dart';
import '../theme/app_theme.dart';
import 'contact_screen.dart';

/// Shown instead of the reading content when the user has not yet
/// redeemed a valid access code. Explains the purchase flow (external
/// payment via WhatsApp / transfer / Multicaixa Express) and lets the
/// user enter the code the author sent them.
class AccessGateScreen extends StatefulWidget {
  const AccessGateScreen({super.key});

  @override
  State<AccessGateScreen> createState() => _AccessGateScreenState();
}

class _AccessGateScreenState extends State<AccessGateScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final access = context.read<AccessProvider>();
    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);
    final ok = await access.redeemCode(_controller.text);
    if (!mounted) return;
    setState(() => _submitting = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Código válido! Acesso desbloqueado.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final access = context.watch<AccessProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Desbloquear Leitura'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    color: AppColors.gold,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Este conteúdo é reservado a leitores que adquiriram o livro',
                textAlign: TextAlign.center,
                style: AppTheme.readingTextStyle(
                  fontSize: 19,
                  color: colorScheme.onSurface,
                  weight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Para desbloquear a leitura completa do Manual de Introdução ao '
                'Estudo do Direito, adquira o livro directamente com o autor e '
                'receberá um código de acesso pessoal.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.5,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(height: 28),

              Text(
                'CÓDIGO DE ACESSO',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                onChanged: (_) => access.clearError(),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
                decoration: InputDecoration(
                  hintText: 'Ex.: IED-XXXXXXX-XXXXXX',
                  filled: true,
                  fillColor: Theme.of(context).cardTheme.color,
                  errorText: access.lastError,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.vpn_key_outlined),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Desbloquear'),
                ),
              ),
              const SizedBox(height: 28),

              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Ainda não tem um código?',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Contacte o autor por WhatsApp ou email para adquirir o livro '
                'e receber o seu código de acesso pessoal.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Falar com o Autor'),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ContactScreen()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
