package com.iedreader.reader

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity

/// MainActivity aplica FLAG_SECURE para protecção anti-cópia:
/// - Bloqueia screenshots e gravação de ecrã em todo o aplicativo.
/// - Oculta o conteúdo na pré-visualização do multitarefas (recent apps),
///   mostrando apenas um fundo em branco em vez do conteúdo do livro.
class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE
        )
    }
}

