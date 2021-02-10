import 'dart:convert';
import 'dart:developer';

import 'package:zayed/api/api_util.dart';
import 'package:zayed/controllers/AuthController.dart';
import 'package:zayed/models/Category.dart';
import 'package:zayed/models/MyResponse.dart';
import 'package:zayed/models/Product.dart';
import 'package:zayed/utils/InternetUtils.dart';

import 'package:http/http.dart' as http;

class CategoryController {
  //------------------------ Get all categories -----------------------------------------//
  static Future<MyResponse<List<Category>>> getAllCategory() async {
    //Getting User Api Token
    String token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL + ApiUtil.CATEGORIES;
    Map<String, String> headers =
        ApiUtil.getHeader(requestType: RequestType.GetWithAuth, token: token);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError<List<Category>>();
    }

    try {
      http.Response response = await http.get(url, headers: headers);
      MyResponse<List<Category>> myResponse = MyResponse(response.statusCode);
      if (response.statusCode == 200) {
        List<Category> list =
            Category.getListFromJson(json.decode(response.body));
        myResponse.success = true;
        myResponse.data = list;
      } else {
        myResponse.setError(json.decode(response.body));
      }

      return myResponse;
    } catch (e) {
      //If any server error...
      return MyResponse.makeServerProblemError<List<Category>>();
    }
  }

  //------------------------ Get category products -----------------------------------------//
  static Future<MyResponse<List<Product>>> getCategoryProducts(
      int categoryId) async {
    //Getting User Api Token
    String token = await AuthController.getApiToken();
    String url = ApiUtil.MAIN_API_URL +
        ApiUtil.CATEGORIES +
        categoryId.toString() +
        "/" +
        ApiUtil.PRODUCTS;
    Map<String, String> headers =
        ApiUtil.getHeader(requestType: RequestType.GetWithAuth, token: token);

    //Check Internet
    bool isConnected = await InternetUtils.checkConnection();
    if (!isConnected) {
      return MyResponse.makeInternetConnectionError<List<Product>>();
    }

    try {
      http.Response response = await http.get(url, headers: headers);
      MyResponse<List<Product>> myResponse = MyResponse(response.statusCode);
      if (response.statusCode == 200) {
        myResponse.success = true;
        myResponse.data = Product.getListFromJson(json.decode(response.body));
      } else {
        myResponse.setError(json.decode(response.body));
      }

      return myResponse;
    } catch (e) {
      //If any server error...
      return MyResponse.makeServerProblemError<List<Product>>();
    }
  }
}
