import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AboutAuthorScreen extends StatelessWidget {
  const AboutAuthorScreen({super.key});

  static const String _bio =
      'Neves Moxi, natural de Malanje, fez os seus estudos médios no Seminário Maior '
      'de São José em Malanje. Licenciou-se em Direito pela Faculdade de Direito da '
      'Universidade Independente de Angola. Foi funcionário do Ministério da Justiça '
      'e dos Direitos Humanos, colocado no Tribunal Provincial de Malanje.\n\n'
      'Lecionou Língua Portuguesa, Filosofia do Direito e do Estado, Sociologia da '
      'Família, Introdução ao Estudo do Direito, Teoria Geral do Direito Civil, Latim '
      'Jurídico, Direito Romano, Hermenêutica e Interpretação de Textos Jurídicos, '
      'Direito Constitucional, Direito Processual Civil e Direito Processual Penal, no '
      'Seminário Maior de São José, Instituto Superior Politécnico Dom Alexandre '
      'Cardeal do Nascimento, Instituto Superior da Katepa e Universidade Rainha '
      'Njinga a Mbande.\n\n'
      'Ministra formações em matérias de Custas Judiciais, prática processual penal e '
      'cível e organização das secretarias judiciais.\n\n'
      'Mestre em Ciências Jurídico-Forenses pela Faculdade de Direito da Universidade '
      'José Eduardo dos Santos, em cooperação com o Instituto de Cooperação Jurídica '
      'da Faculdade de Direito da Universidade de Lisboa.\n\n'
      'Autor dos livros: "Legislação de Custas Judiciais com Anotações, Comentários e '
      'Remissões", "Word para Monografia, Dissertação e Tese", "Custas Judiciais e '
      'Assistência Judiciária em Angola" e "O Processo de Inventário Por Morte".\n\n'
      'Docente da Universidade Católica de Angola.';

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;
    return Scaffold(
      appBar: AppBar(title: const Text('Sobre o Autor')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).cardTheme.color,
                  border: Border.all(color: AppColors.gold, width: 2),
                ),
                child: const Icon(
                  Icons.person,
                  size: 60,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Neves Moxi',
                style: AppTheme.readingTextStyle(
                  fontSize: 24,
                  color: Theme.of(context).colorScheme.onSurface,
                  weight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Docente Universitário · Universidade Católica de Angola',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.gold,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 28),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _bio,
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: 15, height: 1.6, color: textColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
