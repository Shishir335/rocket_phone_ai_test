import 'dart:math';
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'mock_contacts_data.dart';

class MockContactsInterceptor extends Interceptor {
  bool simulateError = false;
  final Random random = Random();

  void setSimulateError(bool value) {
    simulateError = value;
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!options.path.contains(ApiConstants.contactsEndpoint)) {
      return handler.next(options);
    }

    // Simulate network latency between 500ms and 900ms
    final latency = random.nextInt(
          ApiConstants.mockNetworkLatencyMaxMs -
              ApiConstants.mockNetworkLatencyMinMs,
        ) +
        ApiConstants.mockNetworkLatencyMinMs;

    await Future.delayed(Duration(milliseconds: latency));

    if (options.cancelToken?.isCancelled ?? false) {
      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.cancel,
          error: 'Request was cancelled',
        ),
      );
    }

    final queryParams = options.queryParameters;
    final forceError =
        queryParams['simulate_error'] == true ||
        queryParams['simulate_error'] == 'true' ||
        simulateError;

    if (forceError) {
      return handler.reject(
        DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: 500,
            statusMessage: 'Internal Server Error (Simulated)',
          ),
          type: DioExceptionType.badResponse,
          error: 'Failed to fetch contacts: Simulated server failure',
        ),
      );
    }

    final page = int.tryParse(queryParams['page']?.toString() ?? '1') ?? 1;
    final limit =
        int.tryParse(queryParams['limit']?.toString() ?? '10') ??
        ApiConstants.defaultPageSize;
    final search = queryParams['search']?.toString().trim().toLowerCase();

    // Filter contacts case-insensitively
    List<Map<String, String>> filtered = MockContactsData.dataset;
    if (search != null && search.isNotEmpty) {
      filtered = filtered.where((contact) {
        final name = (contact['name'] ?? '').toLowerCase();
        final phone = (contact['phone'] ?? '').toLowerCase();
        return name.contains(search) || phone.contains(search);
      }).toList();
    }

    final total = filtered.length;
    final startIndex = (page - 1) * limit;

    List<Map<String, String>> pagedContacts = [];
    if (startIndex < total) {
      final endIndex = min(startIndex + limit, total);
      pagedContacts = filtered.sublist(startIndex, endIndex);
    }

    final hasMore = (startIndex + pagedContacts.length) < total;

    final responsePayload = {
      'contacts': pagedContacts,
      'page': page,
      'limit': limit,
      'total': total,
      'hasMore': hasMore,
    };

    return handler.resolve(
      Response(
        requestOptions: options,
        data: responsePayload,
        statusCode: 200,
      ),
    );
  }
}
