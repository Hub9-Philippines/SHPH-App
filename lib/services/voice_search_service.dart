import 'package:flutter/cupertino.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '/services/logging_service.dart';

/// Why a voice-search session produced no usable transcript.
enum VoiceSearchFailure {
  /// Speech recognition is unavailable on this device/build (e.g. a hot
  /// reload after adding the plugin, or no recognizer installed).
  unavailable,

  /// The user was inaudible or cancelled before speaking.
  noTranscript,
}

/// Result of a completed voice-search session.
@immutable
class VoiceSearchResult {
  const VoiceSearchResult({
    this.transcript = '',
    this.confidence = 0,
    this.failure,
  });

  /// Final recognized phrase, already trimmed. Empty when the user was
  /// inaudible, denied the mic, or the engine is unavailable.
  final String transcript;

  /// Engine confidence for [transcript] (0..1); 0 when there is no result.
  final double confidence;

  /// Why no transcript was produced; null on success.
  final VoiceSearchFailure? failure;

  bool get hasTranscript => transcript.isNotEmpty;
  bool get succeeded => hasTranscript;
}

/// Thin wrapper around `speech_to_text` for the search page: one-shot
/// listening sessions that resolve to a final transcript. Instantiated per
/// screen; not a singleton (the plugin itself is).
class VoiceSearchService {
  final _speech = SpeechToText();

  bool _available = false;
  bool _listening = false;
  String _transcript = '';
  double _confidence = 0;
  Locale? _resolvedLocale;

  /// True when the device reports speech recognition support. Check before
  /// offering the mic button.
  bool get isAvailable => _available;

  /// True while a listening session is in progress.
  bool get isListening => _listening;

  /// Prepares the recognizer. Safe to call multiple times; also probes the
  /// best matching locale for the app's en/fil/es set.
  Future<bool> initialize() async {
    if (_available) {
      return true;
    }
    try {
      _available = await _speech.initialize();
    } catch (e, stackTrace) {
      LoggingService.error(
        'Speech recognition init failed',
        tag: 'VoiceSearch',
        error: e,
        stackTrace: stackTrace,
      );
      _available = false;
    }
    return _available;
  }

  /// Locale id (e.g. `en_US`) matching the app locale when the device has it,
  /// otherwise the device default. Null when unavailable.
  Future<String?> resolveLocaleId(Locale appLocale) async {
    if (!_available) {
      return null;
    }
    if (_resolvedLocale != null) {
      return _resolvedLocale?.languageCode;
    }
    try {
      final locales = await _speech.locales();
      final wanted = appLocale.languageCode;
      for (final entry in locales) {
        if (entry.localeId.split('_').first == wanted) {
          _resolvedLocale = Locale(wanted);
          return entry.localeId;
        }
      }
      return null;
    } catch (e) {
      LoggingService.error(
        'Failed to list speech locales',
        tag: 'VoiceSearch',
        error: e,
      );
      return null;
    }
  }

  /// Starts a one-shot session. [onPartial] fires with the live transcript so
  /// the UI can animate; the returned future completes when listening ends
  /// (silence timeout, manual [stop], or error) with the final phrase.
  Future<VoiceSearchResult> listen({
    required Locale appLocale,
    ValueChanged<String>? onPartial,
  }) async {
    if (!await initialize()) {
      return const VoiceSearchResult(
        failure: VoiceSearchFailure.unavailable,
      );
    }

    _transcript = '';
    _confidence = 0.0;
    _listening = true;

    final localeId = await resolveLocaleId(appLocale);
    try {
      await _speech.listen(
        listenOptions: SpeechListenOptions(
          localeId: localeId,
          partialResults: true,
          cancelOnError: true,
          listenMode: ListenMode.dictation,
        ),
        onResult: (result) {
          _transcript = result.recognizedWords.trim();
          _confidence = result.confidence;
          if (onPartial != null && _transcript.isNotEmpty) {
            onPartial(_transcript);
          }
        },
      );
    } catch (e, stackTrace) {
      LoggingService.error(
        'Speech listen failed',
        tag: 'VoiceSearch',
        error: e,
        stackTrace: stackTrace,
      );
      _listening = false;
      return const VoiceSearchResult(
        failure: VoiceSearchFailure.unavailable,
      );
    }

    // The engine ends the session on its own after the user stops speaking;
    // stop() is only needed when the caller cancels early.
    while (_listening && _speech.isListening) {
      await Future<void>.delayed(const Duration(milliseconds: 150));
    }
    _listening = false;
    return VoiceSearchResult(
      transcript: _transcript,
      confidence: _confidence,
      failure: _transcript.isEmpty ? VoiceSearchFailure.noTranscript : null,
    );
  }

  /// Stops the in-flight session early; [listen] then completes with whatever
  /// has been recognized so far.
  Future<void> stop() async {
    _listening = false;
    try {
      await _speech.stop();
    } catch (e) {
      LoggingService.error('Speech stop failed', tag: 'VoiceSearch', error: e);
    }
  }

  /// Releases recognizer resources.
  Future<void> dispose() => _speech.cancel();
}
