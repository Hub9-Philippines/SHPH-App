import '/api/resources/support_api.dart';
import '/services/logging_service.dart';

class ReportProblemService {
  ReportProblemService._();
  static final ReportProblemService instance = ReportProblemService._();

  final _api = ShphSupportApi.instance;

  Future<bool> submitTicket({
    required String category,
    required String message,
    List<int>? attachmentBytes,
    String? attachmentFileName,
  }) async {
    try {
      final resp = await _api.createTicket(
        category: category,
        message: message,
        attachmentBytes: attachmentBytes,
        attachmentFileName: attachmentFileName,
      );
      return resp['id'] != null || resp['status'] == 'ok';
    } catch (e) {
      LoggingService.error('Error submitting ticket: $e',
          tag: 'ReportProblemService');
      return false;
    }
  }
}
