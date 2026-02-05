import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:thrivewithms/models/exercises.model.dart';
import 'package:thrivewithms/models/meals.model.dart';
import 'package:thrivewithms/models/supplements.model.dart';
import 'package:thrivewithms/models/symptom.model.dart';
import 'package:thrivewithms/models/treatment.model.dart';
import 'package:thrivewithms/models/event.model.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  static const _storage = FlutterSecureStorage();

  // Helper method to get the token
  static Future<String> _getToken() async {
    final token = await _storage.read(key: 'accessToken');
    if (token == null) {
      throw Exception("No access token found. Please log in.");
    }
    return token;
  }

  // Helper method to store the token
  static Future<void> _storeToken(String token) async {
    await _storage.write(key: 'accessToken', value: token);
  }

  static Future<void> logout() async {
    // Clear all stored tokens and user data
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'refreshToken');
    await _storage.delete(key: 'userId');
  }

  static Future<http.Response> registerUser({
    required String firstname,
    required String lastname,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/auth/register');
    final body = {
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'password': password,
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );
    return response;
  }

  static Future<http.Response> loginUser({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/auth/login");
    final body = {
      "email": email,
      "password": password,
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print(responseData);
      final accessToken = responseData['tokens']['access']['token'];
      final refreshToken = responseData['tokens']['refresh']['token'];
      final userId = responseData['user']['_id']; // Extract userId
      await _storeToken(accessToken); // Store the token after login
      await _storage.write(key: 'refreshToken', value: refreshToken);
      await _storage.write(key: 'userId', value: userId); // Store userId
    }
    return response;
  }

  static Future<Map<String, dynamic>> fetchUserData(String userId) async {
    final token = await _getToken();
    final url = Uri.parse("$baseUrl/users/$userId");
    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to fetch user data: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error fetching user data: $e");
    }
  }

  static Future<String> refreshAccessToken(String refreshToken) async {
    final url = Uri.parse("$baseUrl/auth/refresh");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'refreshToken': refreshToken}),
    );
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final newAccessToken = responseData['tokens']['access']['token'];
      await _storeToken(newAccessToken); // Update the stored token
      return newAccessToken;
    } else {
      throw Exception("Failed to refresh token: ${response.body}");
    }
  }

  static Future<List<Exercise>> fetchExercises({String? category}) async {
    final url = category != null
        ? Uri.parse("$baseUrl/exercise?category=$category")
        : Uri.parse("$baseUrl/exercise");

    final response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Exercise.fromJson(json)).toList();
    } else {
      throw Exception("Failed to fetch exercises: ${response.body}");
    }
  }

  static Future<List<Meals>> fetchMeals({String? category}) async {
    final url = category != null
        ? Uri.parse("$baseUrl/meals?category=$category")
        : Uri.parse("$baseUrl/meals");

    final response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Meals.fromJson(json)).toList();
    } else {
      throw Exception("failed to fetch meals: ${response.body}");
    }
  }

  static Future<List<Supplements>> fetchSupplements() async {
    final url = Uri.parse("$baseUrl/supplements");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Supplements.fromJson(json)).toList();
    } else {
      throw Exception("Failed to fetch supplements");
    }
  }

  static Future<List<Symptom>> fetchSymptomsByUser(String userId) async {
    final token = await _getToken(); // Retrieve token
    final authHeader = "Bearer $token"; // Explicitly use token in a variable
    final url = Uri.parse('$baseUrl/symptoms?userId=$userId');
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": authHeader, // Use the authHeader variable
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Symptom.fromJson(json)).toList();
    } else {
      throw Exception("Failed to fetch symptoms: ${response.body}");
    }
  }

  static Future<Symptom> createSymptom(Map<String, dynamic> symptomData) async {
    final token = await _getToken(); // Retrieve token
    final authHeader = "Bearer $token"; // Explicitly use token in a variable
    final url = Uri.parse('$baseUrl/symptoms');
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": authHeader, // Use the authHeader variable
      },
      body: jsonEncode(symptomData),
    );

    if (response.statusCode == 201) {
      return Symptom.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to create symptom: ${response.body}");
    }
  }

  static Future<Symptom> fetchSymptomById(String symptomId) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/symptoms/$symptomId');
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return Symptom.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to fetch symptom: ${response.body}");
    }
  }

  static Future<Symptom> updateSymptom(
      String symptomId, Map<String, dynamic> updateData) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/symptoms/$symptomId');
    final response = await http.patch(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(updateData),
    );

    if (response.statusCode == 200) {
      return Symptom.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to update symptom: ${response.body}");
    }
  }

  static Future<void> deleteSymptom(String symptomId) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/symptoms/$symptomId');
    final response = await http.delete(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 204) {
      throw Exception("Failed to delete symptom: ${response.body}");
    }
  }

  static Future<String> getUserId() async {
    final userId = await _storage.read(key: 'userId');
    if (userId == null) {
      throw Exception("No userId found. Please log in.");
    }
    return userId;
  }

  static Future<List<Treatment>> fetchTreatments() async {
    final token = await _getToken();
    final userId = await getUserId();
    final url = Uri.parse('$baseUrl/treatments?userId=$userId');

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Treatment.fromJson(json)).toList();
    } else {
      throw Exception("Failed to fetch treatments: ${response.body}");
    }
  }

  static Future<Treatment> addTreatment(
      Map<String, dynamic> treatmentData) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/treatments');

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(treatmentData),
    );

    if (response.statusCode == 201) {
      return Treatment.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to add treatment: ${response.body}");
    }
  }

  static Future<Treatment> updateTreatment(
      String treatmentId, Map<String, dynamic> updateData) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/treatments/$treatmentId');

    final response = await http.patch(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(updateData),
    );

    if (response.statusCode == 200) {
      return Treatment.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to update treatment: ${response.body}");
    }
  }

  static Future<void> deleteTreatment(String treatmentId) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/treatments/$treatmentId');

    final response = await http.delete(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 204) {
      throw Exception("Failed to delete treatment: ${response.body}");
    }
  }

  // Calendar Events API Methods
  static Future<List<Event>> fetchEvents(
      DateTime? startDate, DateTime? endDate) async {
    final token = await _getToken();
    final userId = await getUserId();

    String url = '$baseUrl/calendar';
    final queryParams = <String, String>{
      'userId': userId,
    };

    if (startDate != null && endDate != null) {
      queryParams['startDate'] = startDate.toIso8601String();
      queryParams['endDate'] = endDate.toIso8601String();
    }

    final uri = Uri.parse(url).replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Event.fromJson(json)).toList();
    } else {
      throw Exception("Failed to fetch events: ${response.body}");
    }
  }

  static Future<Event> createEvent(Map<String, dynamic> eventData) async {
    final userId = await getUserId();
    final url = Uri.parse('$baseUrl/calendar');

    // Add userId to eventData
    eventData = {
      ...eventData,
      'userId': userId,
    };

    try {
      final response = await http
          .post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(eventData),
      )
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception(
              "Request timed out. Please check your connection and try again.");
        },
      );

      if (response.statusCode == 201) {
        return Event.fromJson(jsonDecode(response.body));
      } else {
        String errorMessage;
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage = errorBody['message'] ??
              errorBody['error'] ??
              'Unknown error occurred';
        } catch (e) {
          errorMessage = response.body;
        }
        throw Exception(
            "Failed to create event (${response.statusCode}): $errorMessage");
      }
    } catch (e) {
      print('Error in createEvent: $e');
      rethrow;
    }
  }

  static Future<Event> updateEvent(
      String eventId, Map<String, dynamic> updateData) async {
    final url = Uri.parse('$baseUrl/calendar/$eventId');

    final response = await http.patch(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(updateData),
    );

    if (response.statusCode == 200) {
      return Event.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to update event: ${response.body}");
    }
  }

  static Future<void> deleteEvent(String eventId) async {
    final url = Uri.parse('$baseUrl/calendar/$eventId');

    final response = await http.delete(
      url,
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode != 204) {
      throw Exception("Failed to delete event: ${response.body}");
    }
  }

  static Future<void> updateUser(
      String userId, Map<String, dynamic> updateData) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/users/$userId');

    try {
      final response = await http
          .patch(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(updateData),
      )
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception(
              "Request timed out. Please check your connection and try again.");
        },
      );

      if (response.statusCode != 200) {
        String errorMessage;
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage = errorBody['message'] ??
              errorBody['error'] ??
              'Unknown error occurred';
        } catch (e) {
          errorMessage = response.body;
        }
        throw Exception(
            "Failed to update user (${response.statusCode}): $errorMessage");
      }
    } catch (e) {
      print('Error in updateUser: $e');
      rethrow;
    }
  }

  static Future<bool> verifyPassword(
      String userId, String currentPassword) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/users/$userId/verify-password');

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          'currentPassword': currentPassword,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to verify password');
      }
    } catch (e) {
      print('Error verifying password: $e');
      rethrow;
    }
  }

  static Future<void> changePassword(
      String currentPassword, String newPassword) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/auth/change-password');

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode != 204) {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to change password');
      }

      // After successful password change, clear tokens to force re-login
      await logout();
    } catch (e) {
      print('Error changing password: $e');
      rethrow;
    }
  }

  static Future<void> forgotPassword(String email) async {
    final url = Uri.parse('$baseUrl/auth/forgot-password');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'email': email,
        }),
      );

      if (response.statusCode != 204) {
        final errorBody = jsonDecode(response.body);
        throw Exception(
            errorBody['message'] ?? 'Failed to send reset instructions');
      }
    } catch (e) {
      print('Error in forgotPassword: $e');
      rethrow;
    }
  }

  static Future<void> resetPassword(String token, String newPassword) async {
    final url = Uri.parse('$baseUrl/auth/reset-password');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'token': token,
          'password': newPassword,
        }),
      );

      if (response.statusCode != 204) {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to reset password');
      }
    } catch (e) {
      print('Error in resetPassword: $e');
      rethrow;
    }
  }
}
