import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
import 'package:firebase_auth_ui/firebase_auth_ui.dart';
import 'package:firebase_auth_ui/providers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:service_app/models/artist.dart';
import 'package:service_app/models/user.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import '../models/http_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:service_app/Global.dart';

// const String base_url = 'https://project.cander.in/flutter_service/webservice';
const String base_url = 'https://injuggle.com/admin/webservice';

class Auth with ChangeNotifier {
  final String _loginApi = 'signIn';
  final String _registerApi = 'SignUp';
  User _currentUser;
  Artist _artist = Artist();

  bool get isAuth {
    return currentUser != null;
  }

  User get currentUser {
    return _currentUser;
  }

  Artist get artist {
    return _artist;
  }

  Future<void> addFavouriteArtist(String artistId) async {
    _artist.favStatus = '1';
    notifyListeners();
    var url = Uri.parse('$base_url/add_favorites');
    try {
      final response = await http.post(
        url,
        body: {
          'user_id': _currentUser.id,
          'artist_id': artistId,
        },
      );
      final responseData = json.decode(response.body) as Map<String, dynamic>;
      if (responseData['message'] != 'Add Favorites Successfully.') {
        print('error: ${responseData['message']}');
        _artist.favStatus = '0';
        notifyListeners();
        return;
      }
    } catch (err) {
      throw err;
    }
  }

  Future<void> removeFavouriteArtist(String artistId) async {
    _artist.favStatus = '0';
    notifyListeners();
    var url = Uri.parse('$base_url/remove_favorites');
    try {
      final response = await http.post(
        url,
        body: {
          'user_id': _currentUser.id,
          'artist_id': artistId,
        },
      );
      final responseData = json.decode(response.body) as Map<String, dynamic>;
      if (responseData['message'] != 'Remove Favorites Successfully.') {
        print('error: ${responseData['message']}');
        _artist.favStatus = '1';
        notifyListeners();
        return;
      }
    } catch (err) {
      throw err;
    }
  }

  Future<String> addMoney(String amount) async {
    var url = Uri.parse('$base_url/addMoney');
    try {
      final response = await http.post(
        url,
        body: {
          'user_id': _currentUser.id,
          'is_online': amount,
        },
      );
      final responseData = json.decode(response.body) as Map<String, dynamic>;
      if (!responseData['message'].toString().contains('successfully')) {
        print('error: ${responseData['message']}');
        return responseData['message'];
      }
      return responseData['message'];
    } catch (err) {
      return err.toString();
    }
  }

  Future<bool> uploadProfilePicture(String filePath) async {
    notifyListeners();
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$base_url/editPersonalInfo'),
    );
    var file = await http.MultipartFile.fromPath('image', filePath);
    request.files.add(file);
    request..fields['user_id'] = _currentUser.id;
    try {
      final response = await request.send();
      print('res headers: ${response.headers}');
      print('res statusCode: ${response.statusCode}');
      final body = await response.stream.bytesToString();
      final responseData = json.decode(body) as Map<String, dynamic>;
      if (responseData['message'] != 'Profile has been updated successfully') {
        return false;
      }
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('userData', json.encode(responseData['data'])).then(
        (value) {
          _currentUser.image = responseData['data']['image'];
          notifyListeners();
          print('resopnse ${responseData['message']}');
          print('new User:${responseData['data']}');
        },
      );
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<void> changeIsOnline(String isOnline) async {
    var url = Uri.parse('$base_url/onlineOffline');
    try {
      final response = await http.post(
        url,
        body: {
          'user_id': _currentUser.id,
          'is_online': isOnline,
        },
      );
      final responseData = json.decode(response.body) as Map<String, dynamic>;
      if (!responseData['message'].toString().contains('successfully')) {
        print('error: ${responseData['message']}');
        return;
      }
      _artist..isOnline = isOnline;
      notifyListeners();
    } catch (err) {
      throw err;
    }
  }

  Future<void> changeArtistRateType(String type) async {
    var url = Uri.parse('$base_url/changeCommissionArtist');
    try {
      final response = await http.post(
        url,
        body: {
          'artist_id': _currentUser.id,
          'artist_commission_type': type,
        },
      );
      final responseData = json.decode(response.body) as Map<String, dynamic>;
      if (!responseData['message'].toString().contains('successfully')) {
        print('error: ${responseData['message']}');
        return;
      }
      _artist..commissionType = type;
      notifyListeners();
      print('done: ${responseData['message']}');
    } catch (err) {
      throw err;
    }
  }

  Future<void> deleteGallery(String id) async {
    var url = Uri.parse('$base_url/deleteGallery');
    try {
      final response = await http.post(
        url,
        body: {
          'user_id': _currentUser.id,
          'id': id,
        },
      );
      final responseData = json.decode(response.body) as Map<String, dynamic>;
      if (!responseData['message'].toString().contains('successfully')) {
        print('error: ${responseData['message']}');
        return;
      }
      await getArtistInfo('');
      print('done: ${responseData['message']}');
    } catch (err) {
      throw err;
    }
  }

  Future<void> deleteProduct(String id) async {
    var url = Uri.parse('$base_url/deleteProduct');
    try {
      final response = await http.post(
        url,
        body: {
          'product_id': id,
        },
      );
      final responseData = json.decode(response.body) as Map<String, dynamic>;
      if (!responseData['message'].toString().contains('successfully')) {
        print('error: ${responseData['message']}');
        return;
      }
      await getArtistInfo('');
      print('done: ${responseData['message']}');
    } catch (err) {
      throw err;
    }
  }

  Future<void> deleteQualification(String id) async {
    var url = Uri.parse('$base_url/deleteQualification');
    try {
      final response = await http.post(
        url,
        body: {
          'qualification_id': id,
        },
      );
      final responseData = json.decode(response.body) as Map<String, dynamic>;
      if (!responseData['message'].toString().contains('successfully')) {
        print('error: ${responseData['message']}');
        return;
      }
      await getArtistInfo('');
      print('done: ${responseData['message']}');
    } catch (err) {
      throw err;
    }
  }

  Future<void> updateQualification(
      String id, String newTitle, String newDesc) async {
    var url = Uri.parse('$base_url/updateQualification');
    try {
      final response = await http.post(
        url,
        body: {
          'qualification_id': id,
          'title': newTitle,
          'description': newDesc,
        },
      );
      final responseData = json.decode(response.body) as Map<String, dynamic>;
      if (!responseData['message'].toString().contains('successfully')) {
        print('error: ${responseData['message']}');
        return;
      }
      await getArtistInfo('');
      print('done: ${responseData['message']}');
    } catch (err) {
      throw err;
    }
  }

  Future<void> addQualification(String title, String description) async {
    var url = Uri.parse('$base_url/addQualification');
    try {
      final response = await http.post(
        url,
        body: {
          'user_id': _currentUser.id,
          'title': title,
          'description': description,
        },
      );
      final responseData = json.decode(response.body) as Map<String, dynamic>;
      if (!responseData['message'].toString().contains('successfully')) {
        print('error: ${responseData['message']}');
        return;
      }
      await getArtistInfo('');
      print('done: ${responseData['message']}');
    } catch (err) {
      throw err;
    }
  }

  Future<void> getArtistInfo(String artistId) async {
    Global.currentUID = int.parse(_currentUser.id);
    var url = Uri.parse('$base_url/getArtistByid');
    try {
      final response = await http.post(
        url,
        body: {
          'user_id': _currentUser.id,
          'artist_id': artistId.isEmpty ? _currentUser.id : artistId,
        },
      );
      final responseData = json.decode(response.body) as Map<String, dynamic>;
      if (responseData['message'] != 'Get artist detail.') {
        print('error: ${responseData['message']}');
        return;
      }
      print('res artists: ${responseData['data']}');
      final data = Map<String, dynamic>.from(responseData['data']);
      print('data: $data');
      final artist = Artist(
        id: data['user_id'],
        name: data['name'],
        categoryId: data['category_id'],
        description: data['description'],
        aboutUs: data['about_us'],
        image: data['image'],
        completionRate: data['completion_rate'],
        featured: data['featured'],
        createdAt: data['created_at'],
        updatedAt: data['updated_at'],
        bio: data['bio'],
        longitude: data['longitude'],
        latitude: data['latitude'],
        location: data['location'],
        liveLat: data['live_lat'],
        liveLong: data['live_long'],
        city: data['city'],
        country: data['country'],
        videoUrl: data['video_url'],
        price: data['price'],
        bookingFlag: data['booking_flag'],
        artistCommissionType: data['artist_commission_type'],
        isOnline: data['is_online'],
        gender: data['gender'],
        preference: data['preference'],
        updateProfile: data['update_profile'],
        bannerImage: data['banner_image'],
        percentages: data['completePercentages'],
        jobDone: data['jobDone'],
        categoryName: data['category_name'],
        currencyType: data['currency_type'],
        commissionType: data['commission_type'],
        flatType: data['flat_type'],
        categoryPrice: data['category_price'],
        distance: data['distance'],
        avaRating: data['ava_rating'],
        products: List<Map<String, dynamic>>.from(data['products']),
        reviews: List<Map<String, dynamic>>.from(data['reviews']),
        gallery: List<Map<String, dynamic>>.from(data['gallery']),
        qualifications: List<Map<String, dynamic>>.from(data['qualifications']),
        artistBooking: List<Map<String, dynamic>>.from(data['artist_booking']),
        total: data['totalJob'],
        favStatus: data['fav_status'],
      );
      _artist = artist;
      notifyListeners();
    } catch (err) {
      print('artists error $err');
      throw err;
    }
  }

  Future<String> uploadGalleryImage({String filePath = ''}) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$base_url/addGallery'),
    );
    if (filePath != null && filePath.isNotEmpty) {
      var file = await http.MultipartFile.fromPath('image', filePath);
      request.files.add(file);
    }
    request..fields['user_id'] = _currentUser.id;

    try {
      final response = await request.send();
      print('res headers: ${response.headers}');
      print('res statusCode: ${response.statusCode}');
      final body = await response.stream.bytesToString();
      final responseData = json.decode(body) as Map<String, dynamic>;
      print('artist response: $responseData');
      if (!responseData['message'].toString().contains('successfully')) {
        return responseData['message'].toString();
      }
      await getArtistInfo('');
      return responseData['message'].toString();
    } catch (e) {
      print(e);
      return e.toString();
    }
  }

  Future<String> uploadProductImage({
    String name,
    String price,
    String filePath = '',
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$base_url/addProduct'),
    );
    if (filePath != null && filePath.isNotEmpty) {
      var file = await http.MultipartFile.fromPath('product_image', filePath);
      request.files.add(file);
    }
    request..fields['user_id'] = _currentUser.id;
    request..fields['product_name'] = name;
    request..fields['price'] = price;

    try {
      final response = await request.send();
      print('res headers: ${response.headers}');
      print('res statusCode: ${response.statusCode}');
      final body = await response.stream.bytesToString();
      final responseData = json.decode(body) as Map<String, dynamic>;
      print('artist response: $responseData');
      if (!responseData['message'].toString().contains('successfully')) {
        return responseData['message'].toString();
      }
      await getArtistInfo('');
      return responseData['message'].toString();
    } catch (e) {
      print(e);
      return e.toString();
    }
  }

  Future<String> updateArtistHeadInfo(
      String newName, String newMobile, String newGender) async {
    var url = Uri.parse('$base_url/editPersonalInfo');
    final prefs = await SharedPreferences.getInstance();
    final oldArtist = _artist;
    final oldUser = _currentUser;
    _artist..name = newName;
    _artist..gender = newGender;
    _currentUser..name = newName;
    _currentUser..gender = newGender;
    _currentUser..mobile = newMobile;
    notifyListeners();
    try {
      final response = await http.post(
        url,
        body: {
          'user_id': _currentUser.id,
          'name': newName,
          'mobile': newMobile,
          'gender': newGender,
        },
      );
      final responseData = json.decode(response.body) as Map<String, dynamic>;
      if (!responseData['message'].toString().contains('successfully')) {
        print('error: ${responseData['message']}');
        _artist = oldArtist;
        _currentUser = oldUser;
        notifyListeners();
        return responseData['message'];
      }
      prefs.setString('userData', json.encode(responseData['data']));
      print('res artists: ${responseData['data']}');
      final data = Map<String, dynamic>.from(responseData['data']);
      print('data: $data');
      return responseData['message'];
    } catch (err) {
      print('artists error $err');
      return err;
    }
  }

  Future<void> updateArtistInfo(Artist newArtist) async {
    print('location ${newArtist.location}');
    var url = Uri.parse('$base_url/artistPrsonalInfo');
    try {
      final response = await http.post(
        url,
        body: {
          'user_id': _currentUser.id,
          'category_id': newArtist.categoryId,
          'name': newArtist.name,
          'bio': newArtist.bio,
          'about_us': newArtist.aboutUs,
          'city': newArtist.city,
          'country': newArtist.country,
          'location': newArtist.location,
          'price': newArtist.price,
          'latitude': newArtist.latitude,
          'longitude': newArtist.longitude,
        },
      );
      final responseData = json.decode(response.body) as Map<String, dynamic>;
      if (responseData['message'] != 'Vendor updates successfully.') {
        print('error: ${responseData['message']}');
        notifyListeners();
        return;
      }
      await getArtistInfo('');
      print('success: ${responseData['message']}');
    } catch (err) {
      print('artists error $err');
      throw err;
    }
  }

  Future<void> setAddress(Map<String, String> newData) async {
    final url = Uri.parse('$base_url/editPersonalInfo');
    final oldAddress = _currentUser.address;
    final oldOffice = _currentUser.officeAddress;
    final oldCity = _currentUser.city;
    final oldCountry = _currentUser.country;
    final oldLat = _currentUser.lat;
    final oldLong = _currentUser.long;
    _currentUser.address = newData['address'];
    _currentUser.officeAddress = newData['office_address'];
    _currentUser.city = newData['city'];
    _currentUser.country = newData['country'];
    _currentUser.lat = newData['lat'];
    _currentUser.long = newData['long'];
    notifyListeners();
    try {
      final response = await http.post(
        url,
        body: {
          'user_id': _currentUser.id,
          'address': newData['address'],
          'office_address': newData['office_address'],
          'city': newData['city'],
          'country': newData['country'],
          'latitude': newData['lat'],
          'longitude': newData['long'],
        },
      );
      final body = json.decode(response.body) as Map<String, dynamic>;
      if (response.statusCode >= 400 ||
          body['message'] != 'Profile has been updated successfully') {
        _currentUser.address = oldAddress;
        _currentUser.officeAddress = oldOffice;
        _currentUser.city = oldCity;
        _currentUser.country = oldCountry;
        _currentUser.lat = oldLat;
        _currentUser.long = oldLong;
        notifyListeners();
      } else {
        final prefs = await SharedPreferences.getInstance();
        prefs
            .setString('userData', json.encode(body['data']))
            .then((value) => print('new User:${body['data']}'));
      }
    } catch (err) {
      _currentUser.address = oldAddress;
      _currentUser.officeAddress = oldOffice;
      _currentUser.city = oldCity;
      _currentUser.country = oldCountry;
      _currentUser.lat = oldLat;
      _currentUser.long = oldLong;
      notifyListeners();
      throw err;
    }
  }

  Future<String> changePassword(String password, String newPassword) async {
    final url = Uri.parse('$base_url/editPersonalInfo');
    try {
      final response = await http.post(
        url,
        body: {
          'user_id': _currentUser.id,
          'password': password,
          'new_password': newPassword,
        },
      );
      final body = json.decode(response.body) as Map<String, dynamic>;
      return body['message'];
    } catch (err) {
      return err;
    }
  }

  Future<void> editPersonalInfo(
      String newName, String newMobile, String newGender) async {
    print('new name: $newName, new mobile:$newMobile, new gender:$newGender');
    final oldName = _currentUser.name;
    final oldMobile = _currentUser.mobile;
    final oldGender = _currentUser.gender;
    _currentUser.name = newName;
    _currentUser.mobile = newMobile;
    _currentUser.gender = newGender;
    notifyListeners();
    var url = Uri.parse('$base_url/editPersonalInfo');
    try {
      final response = await http.post(
        url,
        body: {
          'user_id': _currentUser.id,
          'name': newName,
          'mobile': newMobile,
          'gender': newGender,
        },
      );
      final body = json.decode(response.body) as Map<String, dynamic>;
      if (body['message'] != 'Profile has been updated successfully') {
        _currentUser.name = oldName;
        _currentUser.mobile = oldMobile;
        _currentUser.gender = oldGender;
        notifyListeners();
      } else {
        final prefs = await SharedPreferences.getInstance();
        prefs
            .setString('userData', json.encode(body['data']))
            .then((value) => print('new User:${body['data']}'));
      }
    } catch (err) {
      _currentUser.name = oldName;
      _currentUser.mobile = oldMobile;
      _currentUser.gender = oldGender;
      notifyListeners();
    }
  }

  Future<void> editNumberInfo(String newMobile) async {
    print('new mobile:$newMobile');
    final oldMobile = _currentUser.mobile;
    _currentUser.mobile = newMobile;
    notifyListeners();
    var url = Uri.parse('$base_url/editPersonalInfo');
    try {
      final response = await http.post(
        url,
        body: {
          'user_id': _currentUser.id,
          'mobile': newMobile,
        },
      );
      final body = json.decode(response.body) as Map<String, dynamic>;
      if (body['message'] != 'Profile has been updated successfully') {
        _currentUser.mobile = oldMobile;
        notifyListeners();
      } else {
        final prefs = await SharedPreferences.getInstance();
        prefs
            .setString('userData', json.encode(body['data']))
            .then((value) => print('new User:${body['data']}'));
      }
    } catch (err) {
      _currentUser.mobile = oldMobile;
      notifyListeners();
    }
  }

  Future<String> updatePassword(String email) async {
    final url = Uri.parse('$base_url/forgotPassword');
    try {
      final response = await http.post(
        url,
        body: {
          'email_id': email,
        },
      );
      final data = json.decode(response.body);
      print(data);
      return data['message'];
    } catch (err) {
      return err;
    }
  }

  Future<void> login(
      String email, String password, String deviceType, bool isCustomer) async {
    //await validatePhoneOrShowValidationScreen();
    final url = Uri.parse('$base_url/$_loginApi');
    final prefs = await SharedPreferences.getInstance();
    final firebaseToken = prefs.getString('token');
    try {
      final response = await http.post(
        url,
        body: {
          'email_id': email,
          'password': password,
          'device_type': deviceType,
          'device_token': firebaseToken,
          'device_id': '12345',
          'role': isCustomer ? '2' : '1',
        },
      );
      final responseData = json.decode(response.body);
      print('res type: $isCustomer');
      print('res email: $email');
      print(
          'res: $email $password $deviceType $firebaseToken, ${isCustomer ? '2' : '1'}');
      print('response: $responseData');
      if (responseData['message'] != null &&
          responseData['message'] == 'User login successfully') {
        prefs.setString('userData', json.encode(responseData['data']));
        final user = User(
          address: responseData['data']['address'] ?? '',
          city: responseData['data']['city'] ?? '',
          country: responseData['data']['country'] ?? '',
          createdAt: responseData['data']['created_at'] ?? '',
          deviceId: responseData['data']['device_id'] ?? '',
          deviceToken: responseData['data']['device_token'] ?? '',
          deviceType: responseData['data']['device_type'] ?? '',
          name: responseData['data']['name'] ?? '',
          email: responseData['data']['email_id'] ?? '',
          gender: responseData['data']['gender'] ?? '',
          iCardImage: responseData['data']['i_card'] ?? '',
          id: responseData['data']['user_id'] ?? '',
          image: responseData['data']['image'] ?? '',
          lat: responseData['data']['latitude'] ?? '',
          liveLat: responseData['data']['live_lat'] ?? '',
          liveLong: responseData['data']['live_long'] ?? '',
          long: responseData['data']['longitude'] ?? '',
          mobile: responseData['data']['mobile'] ?? '',
          officeAddress: responseData['data']['office_address'] ?? '',
          refCode: responseData['data']['referral_code'] ?? '',
          updatedAt: responseData['data']['updated_at'] ?? '',
          isCustomer: responseData['data']['role'] == '2',
        );
        if (isCustomer) {
          print('autologin of a customer');
          //|| user.city == '' || user.country == ''
          if (user.name == '' ||
              user.liveLat == '' ||
              user.liveLong == '' ||
              user.address == '') {
            Global.incompleteProfile = true;
            Global.user = user;
          }
        } else {
          print('autologin of a service provider');
          if (user.name == '' ||
              user.liveLat == '' ||
              user.liveLong == '' ||
              user.mobile == '') {
            Global.incompleteProfile = true;
            Global.user = user;
          }
        }
        _currentUser = user;
        Global.currentUID = int.parse(_currentUser.id);
        notifyListeners();
      } else {
        throw HttpException(responseData['message']);
      }

      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> signup(
      {String name,
      String email,
      String password,
      String deviceType,
      bool isCustomer,
      String referralCode = ''}) async {
    final url = Uri.parse('$base_url/$_registerApi');
    final prefs = await SharedPreferences.getInstance();
    final firebaseToken = prefs.getString('token');
    try {
      final response = await http.post(
        url,
        body: {
          'name': name,
          'email_id': email,
          'password': password,
          'role': isCustomer ? '2' : '1',
          'device_type': deviceType,
          'device_token': firebaseToken,
          'device_id': '12345',
          'referral_code': referralCode,
        },
      );
      final responseData = json.decode(response.body);
      print('res type: $isCustomer');
      print('res email: $email');
      print(
          'res: $email $password $deviceType $firebaseToken, ${isCustomer ? '2' : '1'}');
      print('response: $responseData');
      if (responseData['message'] != null) {
        if (responseData['message'].toString() ==
            'Please check your email and your verified account.') {
          print("User registered msg #1");
        } else if (responseData['message']
            .toString()
            .contains("registered successfully")) {
          print("User registered msg #2");
          // WHY DO WE HAVE TWO???
        }
      } else {
        throw HttpException(responseData['message']);
      }
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    final user = User(
      address: extractedUserData['address'] ?? '',
      city: extractedUserData['city'] ?? '',
      country: extractedUserData['country'] ?? '',
      createdAt: extractedUserData['created_at'] ?? '',
      deviceId: extractedUserData['device_id'] ?? '',
      deviceToken: extractedUserData['device_token'] ?? '',
      deviceType: extractedUserData['device_type'] ?? '',
      name: extractedUserData['name'] ?? '',
      email: extractedUserData['email_id'] ?? '',
      gender: extractedUserData['gender'] ?? '',
      iCardImage: extractedUserData['i_card'] ?? '',
      id: extractedUserData['user_id'] ?? '',
      image: extractedUserData['image'] ?? '',
      lat: extractedUserData['latitude'] ?? '',
      liveLat: extractedUserData['live_lat'] ?? '',
      liveLong: extractedUserData['live_long'] ?? '',
      long: extractedUserData['longitude'] ?? '',
      mobile: extractedUserData['mobile'] ?? '',
      officeAddress: extractedUserData['office_address'] ?? '',
      refCode: extractedUserData['referral_code'] ?? '',
      updatedAt: extractedUserData['updated_at'] ?? '',
      isCustomer: extractedUserData['role'] == '2',
    );
    if (extractedUserData['role'] == '2') {
      print('autologin of a customer');
      //|| user.city == '' || user.country == ''
      if (user.name == '' ||
          user.liveLat == '' ||
          user.liveLong == '' ||
          user.address == '') {
        Global.incompleteProfile = true;
        Global.user = user;
      }
    } else {
      print('autologin of a service provider');
      if (user.name == '' ||
          user.liveLat == '' ||
          user.liveLong == '' ||
          user.mobile == '') {
        Global.incompleteProfile = true;
        Global.user = user;
      }
    }
    _currentUser = user;
    Global.currentUID = int.parse(_currentUser.id);
    notifyListeners();
    //await validatePhoneOrShowValidationScreen();
    return true;
  }

  Future<void> logout() async {
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    // prefs.remove('userData');
    prefs.clear();
    _currentUser = null;
  }

  Future<FirebaseAuth.User> _checkLoginState() async {
    return FirebaseAuth.FirebaseAuth.instance.currentUser;
  }

  void _processLogin() async {
    String error = "";
    var user = FirebaseAuth.FirebaseAuth.instance.currentUser;
    if (user == null) {
      FirebaseAuthUi.instance().launchAuth([
        AuthProvider.phone(),
      ]).then((value) {
        error = "";
      }).catchError((e) {
        if (e is PlatformException) {
          if (e.code == FirebaseAuthUi.kUserCancelledError) {
            error = "User cancelled login";
          } else {
            error = e.message ?? 'Unknown error';
          }
        }
      });
    }
  }
/*
  Future<void> validatePhoneOrShowValidationScreen() async {
    await Firebase.initializeApp();
    await _checkLoginState().then((user) {
      //
      if(user != null){
        print("DEBUG: Current user phone number is: " + user.phoneNumber.toString());
        Global.userPhoneNumber = user.phoneNumber;
        //editNumberInfo(user.phoneNumber);
      }
    });
    _processLogin();
  }

  Future<void> logoutFromPhoneAuth() async {
    await _checkLoginState().then((user) {
      if(user != null){
        //just log out
        FirebaseAuthUi.instance().logout();
      }
    });
  }

 */
}
