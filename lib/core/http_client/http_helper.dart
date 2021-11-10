import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HttpHelper {
  static String baseUrl = "https://injuggle.com/admin/webservice";

/* static Future<http.Client> getInstance()async {
    if (client == null) {
      client = await new http.Client();
    }
    return client;
  }*/

  static Future<ApiResponse> postForm({@required String path,Map<String, dynamic> body}) async {

    http.Response response;
    try {

       response = await new http.Client().post(
        Uri.parse('${baseUrl}$path'),
        body: body,
      );



      final responseData = json.decode(response.body) as Map<String, dynamic>;

      if (response?.statusCode == 200) {
        String resstr = await response.body;

        ApiResponse apiResponse = ApiResponse(
            completeResponse: responseData,
            status: response.statusCode,
            message: responseData["message"] ?? "Api Hit Successfully ");

        return apiResponse;
      } else {
        ApiResponse apiResponse = ApiResponse(
            completeResponse: responseData,
            status: response.statusCode,
            message: responseData["message"] ?? "Api Failed");

        return apiResponse;
      }


    }  on Error catch (e) {
      print(" HTTP RESPONSE CATCH EXCEPTION=================>${e}");
      ApiResponse apiResponse = ApiResponse(
          completeResponse: e??"",
          status: response.statusCode,
          message: e.toString());

      return apiResponse;
    } on TimeoutException catch (e) {
      print(" HTTP RESPONSE TIMEOUT EXCEPTION=================>${e}");
      ApiResponse apiResponse = ApiResponse(
          completeResponse: e??"",
          status: response.statusCode,
          message: e.toString());

      return apiResponse;
    }on SocketException catch (e) {
      print(" HTTP RESPONSE SOCKET EXCEPTION=================>${e}");
      ApiResponse apiResponse = ApiResponse(
          completeResponse: e??"",
          status: 500,
          message: e.toString());

      return apiResponse;
    }
  }
}

class ApiResponse<T> {
  int status;
  String message;
  T completeResponse;

  ApiResponse({this.status, this.message, this.completeResponse});
}
