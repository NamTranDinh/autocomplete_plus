// import 'package:dio/dio.dart';
// import 'package:autocomplete_plus/models/mock_post_model.dart';
//
// class ApiService {
//   ApiService({required this.baseUrl});
//
//   final Dio _dio = Dio();
//   final String baseUrl;
//
//   Future<List<MockPostModel>> getPosts({int page = 1, int pageSize = 10, String? keyword}) async {
//     try {
//       final response = await _dio.get(
//         '$baseUrl/posts',
//         queryParameters: {
//           '_page': page,
//           '_limit': pageSize,
//           'keyword': keyword,
//         },
//       );
//
//       if (response.statusCode == 200) {
//         return (response.data is List)
//             ? response.data.map<MockPostModel>(MockPostModel.fromJson).toList()
//             : [];
//       } else {
//         throw Exception('Failed to load posts: Status code ${response.statusCode}');
//       }
//     } on DioException catch (e) {
//       throw Exception('Dio error: ${e.message}');
//     } catch (e) {
//       throw Exception('Error: $e');
//     }
//   }
// }
