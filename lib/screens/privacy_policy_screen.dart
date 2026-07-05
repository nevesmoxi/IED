import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Privacy Policy screen — required for Google Play Store publication.
/// Describes what data the app handles, since the app does not currently
/// have accounts/login/payments (deferred to a later phase), but does allow
/// contacting the author via WhatsApp/phone/email from the Contact screen.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;
    return Scaffold(
      appBar: AppBar(title: const Text('Política de Privacidade')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Política de Privacidade — IED Reader',
                style: AppTheme.readingTextStyle(
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.onSurface,
                  weight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Última actualização: 2025',
                style: TextStyle(fontSize: 12, color: AppColors.gold),
              ),
              const SizedBox(height: 20),
              _Section(
                title: '1. Introdução',
                body:
                    'O IED Reader ("o Aplicativo") é uma aplicação de leitura digital do '
                    'Manual de Introdução ao Estudo do Direito, da autoria de Neves Moxi. '
                    'Esta Política de Privacidade explica que dados o Aplicativo recolhe, '
                    'como são utilizados e quais os direitos do utilizador.',
                textColor: textColor,
              ),
              _Section(
                title: '2. Dados que Não Recolhemos',
                body:
                    'O Aplicativo não exige registo, conta de utilizador, nem recolhe dados '
                    'pessoais identificáveis para funcionar. A leitura do livro, marcadores, '
                    'preferências de tema e tamanho de letra são guardados apenas localmente '
                    'no seu dispositivo (armazenamento local), e nunca são enviados para '
                    'qualquer servidor.',
                textColor: textColor,
              ),
              _Section(
                title: '3. Contacto Directo com o Autor',
                body:
                    'O ecrã "Contacto" permite abrir o WhatsApp, a aplicação de telefone ou '
                    'o seu cliente de email para comunicar directamente com o autor. Estas '
                    'acções são realizadas através das aplicações nativas do seu dispositivo '
                    '(WhatsApp, Telefone, Email) e quaisquer dados partilhados nessas '
                    'conversas ficam sujeitos às políticas de privacidade dessas respectivas '
                    'aplicações, e não do IED Reader.',
                textColor: textColor,
              ),
              _Section(
                title: '4. Permissões do Dispositivo',
                body:
                    'O Aplicativo pode solicitar permissão de acesso à internet apenas para '
                    'abrir hiperligações externas (por exemplo, WhatsApp Web). Não são '
                    'solicitadas permissões de câmara, localização, contactos ou armazenamento '
                    'de ficheiros para o funcionamento principal de leitura.',
                textColor: textColor,
              ),
              _Section(
                title: '5. Protecção de Conteúdo',
                body:
                    'O conteúdo do livro é protegido por medidas técnicas (encriptação do '
                    'ficheiro de conteúdo e bloqueio de capturas de ecrã) destinadas a '
                    'proteger os direitos de autor da obra. Estas medidas não recolhem nem '
                    'transmitem quaisquer dados sobre o utilizador.',
                textColor: textColor,
              ),
              _Section(
                title: '6. Alterações a Esta Política',
                body:
                    'Esta política poderá ser actualizada em versões futuras do Aplicativo, '
                    'nomeadamente quando forem introduzidas funcionalidades de conta de '
                    'utilizador, pagamentos ou notificações. Qualquer alteração relevante '
                    'será reflectida nesta página.',
                textColor: textColor,
              ),
              _Section(
                title: '7. Contacto',
                body:
                    'Para questões sobre esta Política de Privacidade, contacte o autor '
                    'através do ecrã "Contacto" do Aplicativo, por telefone/WhatsApp '
                    '(+244 929 990 606) ou por email (nevesmoxi01@gmail.coom ou '
                    'nevesmoxi@hotmail.com).',
                textColor: textColor,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String body;
  final Color? textColor;

  const _Section({required this.title, required this.body, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            textAlign: TextAlign.justify,
            style: TextStyle(fontSize: 13.5, height: 1.6, color: textColor),
          ),
        ],
      ),
    );
  }
}
