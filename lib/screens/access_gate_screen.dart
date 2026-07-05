import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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
  static const String _whatsappNumber = '244929990606';

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _submitting = false;
  bool _justSucceeded = false;

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
    setState(() {
      _submitting = false;
      _justSucceeded = ok;
    });
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && mounted) {
      _controller.text = data!.text!.trim();
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
      context.read<AccessProvider>().clearError();
    }
  }

  Future<void> _openWhatsApp(BuildContext context) async {
    const message =
        'Olá! Gostaria de comprar o livro "Manual de Introdução ao Estudo '
        'do Direito" e receber o meu código de acesso ao IED Reader.';
    final uri = Uri.parse(
      'https://wa.me/$_whatsappNumber?text=${Uri.encodeComponent(message)}',
    );
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) _fallbackToContact(context);
    } catch (_) {
      if (context.mounted) _fallbackToContact(context);
    }
  }

  void _fallbackToContact(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ContactScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final access = context.watch<AccessProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero header: book cover + lock badge
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 108,
                      height: 148,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            'assets/images/book_cover.png',
                            fit: BoxFit.cover,
                          ),
                          Container(
                            color: Colors.black.withValues(alpha: 0.45),
                          ),
                          const Center(
                            child: Icon(
                              Icons.lock_outline,
                              color: Colors.white,
                              size: 34,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Conteúdo Reservado',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Esta leitura pertence a quem já adquiriu o livro',
                textAlign: TextAlign.center,
                style: AppTheme.readingTextStyle(
                  fontSize: 19,
                  color: colorScheme.onSurface,
                  weight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Adquira o Manual de Introdução ao Estudo do Direito directamente '
                'com o autor e receberá, em poucos minutos, um código pessoal '
                'para desbloquear a leitura completa neste aparelho.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.5,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(height: 28),

              // Code entry card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(18),
                  border: _justSucceeded
                      ? Border.all(color: Colors.green, width: 1.4)
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.vpn_key_outlined,
                          size: 16,
                          color: AppColors.gold,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'JÁ TENHO UM CÓDIGO',
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      enabled: !_justSucceeded,
                      textCapitalization: TextCapitalization.characters,
                      textInputAction: TextInputAction.done,
                      textAlign: TextAlign.center,
                      onSubmitted: (_) => _submit(),
                      onChanged: (_) {
                        access.clearError();
                        if (_justSucceeded)
                          setState(() => _justSucceeded = false);
                      },
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.6,
                        fontSize: 15,
                      ),
                      decoration: InputDecoration(
                        hintText: 'IED-XXXXXXX-XXXXXX',
                        hintStyle: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.3),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.6,
                        ),
                        filled: true,
                        fillColor: isDark
                            ? Colors.white.withValues(alpha: 0.04)
                            : Colors.black.withValues(alpha: 0.03),
                        errorText: access.lastError,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: _controller.text.isEmpty && !_justSucceeded
                            ? IconButton(
                                tooltip: 'Colar',
                                icon: const Icon(Icons.content_paste, size: 18),
                                onPressed: _pasteFromClipboard,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: (_submitting || _justSucceeded)
                            ? null
                            : _submit,
                        icon: _submitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                _justSucceeded
                                    ? Icons.check_circle
                                    : Icons.lock_open_outlined,
                                size: 18,
                              ),
                        label: Text(
                          _justSucceeded
                              ? 'Acesso Desbloqueado'
                              : 'Desbloquear Leitura',
                        ),
                        style: _justSucceeded
                            ? ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              Row(
                children: [
                  Expanded(child: Divider(color: colorScheme.outlineVariant)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'AINDA NÃO TEM O LIVRO?',
                      style: TextStyle(
                        fontSize: 10.5,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: colorScheme.outlineVariant)),
                ],
              ),
              const SizedBox(height: 18),

              // Purchase steps
              _StepTile(
                number: '1',
                text:
                    'Contacte o autor pelo WhatsApp e combine o pagamento '
                    '(transferência, Multicaixa Express, etc.).',
              ),
              const SizedBox(height: 10),
              _StepTile(
                number: '2',
                text:
                    'Após a confirmação do pagamento, o autor envia-lhe '
                    'um código de acesso pessoal.',
              ),
              const SizedBox(height: 10),
              _StepTile(
                number: '3',
                text:
                    'Introduza o código acima e comece a ler — de forma '
                    'permanente, neste aparelho.',
              ),
              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Comprar pelo WhatsApp'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _openWhatsApp(context),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.mail_outline),
                  label: const Text('Ver Outros Contactos'),
                  onPressed: () => _fallbackToContact(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  final String number;
  final String text;

  const _StepTile({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: AppColors.gold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withValues(alpha: 0.85),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
