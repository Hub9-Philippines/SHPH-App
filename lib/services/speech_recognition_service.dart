import 'dart:async';

class SpeechRecognitionService {
  SpeechRecognitionService._();
  static final SpeechRecognitionService instance = SpeechRecognitionService._();

  bool _isListening = false;
  bool _isAvailable = false;
  final _resultController = StreamController<String>.broadcast();
  final _stateController = StreamController<bool>.broadcast();

  Stream<String> get onResult => _resultController.stream;
  Stream<bool> get onStateChanged => _stateController.stream;
  bool get isListening => _isListening;
  bool get isAvailable => _isAvailable;

  Future<void> initialize() async {
    // When speech_to_text package is added:
    // _speech = SpeechToText();
    // _isAvailable = await _speech.initialize(...)
    _isAvailable = false;
  }

  Future<void> startListening() async {
    if (!_isAvailable || _isListening) return;
    _isListening = true;
    _stateController.add(true);
    // When speech_to_text is added:
    // _speech.listen(
    //   onResult: (result) {
    //     _resultController.add(result.recognizedWords);
    //     if (result.finalResult) stopListening();
    //   },
    // );
  }

  Future<void> stopListening() async {
    if (!_isListening) return;
    _isListening = false;
    _stateController.add(false);
    // When speech_to_text is added: _speech.stop();
  }

  void dispose() {
    _resultController.close();
    _stateController.close();
  }
}
