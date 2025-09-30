import 'package:test_app/data/dio_client.dart';
import 'package:test_app/data/models/user_model.dart';

class AuthRepository {
  final DioClient _dioClient = DioClient(baseUrl: 'https://url');
  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dioClient.executeQuery(
        resourceURL: '/auth/login',
        method: 'POST',
        body: {'email': email, 'password': password},
      );
      if (response?.statusCode == 200) {
        return UserModel.fromJson(response?.data);
      }
      return UserModel(email: email, name: "name", surname: "surname");
    } catch (e) {
      return UserModel(email: email, name: "name", surname: "surname");
    }
  }
}
