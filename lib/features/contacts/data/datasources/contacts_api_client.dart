import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/contacts_response_model.dart';

part 'contacts_api_client.g.dart';

@RestApi(baseUrl: ApiConstants.baseUrl)
abstract class ContactsApiClient {
  factory ContactsApiClient(Dio dio, {String baseUrl}) = _ContactsApiClient;

  @GET(ApiConstants.contactsEndpoint)
  Future<ContactsResponseModel> getContacts({
    @Query('page') required int page,
    @Query('limit') required int limit,
    @Query('search') String? search,
    @CancelRequest() CancelToken? cancelToken,
  });
}
