import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'model.dart';

class Geocoder {

  static const String host = "https://api.opencagedata.com/geocode/v1/json";

  final String _baseUrl;

  Geocoder(String apiKey) :
    this._baseUrl = "${host}?key=${apiKey}";

  Future<GeocoderResponse> geocode(String query, {String language = "en", String countryCode = null, Bounds bounds = null, bool abbrv = false, int limit = 10, int minConfidence = 0, bool noAnnotations = false, bool noDedupe = false, bool noRecord = false, bool addRequest = false}) {
    return _send({
      'q': query,
      'language': language,
      'countryCode': countryCode,
      'bounds': bounds,
      'limit': limit,
      'no_annotations': noAnnotations,
      'min_confidence': minConfidence,
      'add_request': addRequest,
      'no_dedupe': noDedupe,
      'no_record': noRecord,
      'abbrv': abbrv
    });
  }

  Future<GeocoderResponse> reverseGeocode(double latitude, double longitude, {String language = "en", String countryCode = null, Bounds bounds = null, bool abbrv = false, int limit = 10, int minConfidence = 0, bool noAnnotations = false, bool noDedupe = false, bool noRecord = false, bool addRequest = false}) {
    return geocode("${latitude}+${longitude}", language: language, countryCode: countryCode, bounds: bounds, abbrv: abbrv, limit: limit, minConfidence: minConfidence, noAnnotations: noAnnotations, noDedupe: noDedupe, noRecord: noRecord, addRequest: addRequest);
  }

  Future<GeocoderResponse> _send(Map args) async {
    var httpClient = new HttpClient();
    var uri = _createUrl(args);
    var request = await httpClient.getUrl(uri);
    var response = await request.close();
    var jsonString = await response.transform(UTF8.decoder).join();
    var data = JSON.decode(jsonString);
    return new GeocoderResponse.fromJson(data);
  }

  Uri _createUrl(Map queryArgs) {
    var result = new StringBuffer(this._baseUrl);
    queryArgs.forEach((key,value) {
      if(value != null && value != false) {
        var formattedValue = _formatQueryArgValue(value);
        result.write("&${key}=${formattedValue}");
      }
    });
    return Uri.parse(result.toString());
  }

  String _formatQueryArgValue(Object value) {
    if (value is bool) {
      return value ? "1" : "0";
    }
    if (value is Bounds) {
      return "${value.northeast.longitude}%2C${value.northeast.latitude}%2C${value.southwest.longitude}%2C${value.southwest.latitude}";
    }
    if (value is int || value is double) {
      return value.toString();
    }
    return Uri.encodeComponent(value.toString());
  }
}