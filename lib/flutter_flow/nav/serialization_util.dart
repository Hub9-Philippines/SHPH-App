import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:from_css_color/from_css_color.dart';

import '/backend/supabase/supabase.dart';

import '../../flutter_flow/place.dart';
import '../../flutter_flow/uploaded_file.dart';

/// SERIALIZATION HELPERS

String dateTimeRangeToString(DateTimeRange dateTimeRange) {
  final startStr = dateTimeRange.start.millisecondsSinceEpoch.toString();
  final endStr = dateTimeRange.end.millisecondsSinceEpoch.toString();
  return '$startStr|$endStr';
}

String placeToString(FFPlace place) => jsonEncode({
      'latLng': place.latLng.serialize(),
      'name': place.name,
      'address': place.address,
      'city': place.city,
      'state': place.state,
      'country': place.country,
      'zipCode': place.zipCode,
    });

String uploadedFileToString(FFUploadedFile uploadedFile) =>
    uploadedFile.serialize();

String? serializeParam(
  dynamic param,
  ParamType paramType, {
  bool isList = false,
}) {
  try {
    if (param == null) {
      return null;
    }
    if (isList) {
      final serializedValues = (param as Iterable)
          .map((p) => serializeParam(p, paramType, isList: false))
          .where((p) => p != null)
          .map((p) => p!)
          .toList();
      return json.encode(serializedValues);
    }
    String? data;
    switch (paramType) {
      case ParamType.int:
        data = param.toString();
      case ParamType.double:
        data = param.toString();
      case ParamType.string:
        data = param;
      case ParamType.bool:
        data = param ? 'true' : 'false';
      case ParamType.dateTime:
        data = (param as DateTime).millisecondsSinceEpoch.toString();
      case ParamType.dateTimeRange:
        data = dateTimeRangeToString(param as DateTimeRange);
      case ParamType.latLng:
        data = (param as LatLng).serialize();
      case ParamType.color:
        data = fromCssColor(param as String) as String?;
      case ParamType.ffPlace:
        data = placeToString(param as FFPlace);
      case ParamType.ffUploadedFile:
        data = uploadedFileToString(param as FFUploadedFile);
      case ParamType.json:
        data = json.encode(param);

      case ParamType.dataStruct:
        data = param is Struct ? param.toString() : null;

      case ParamType.supabaseRow:
        return json.encode((param as SupabaseDataRow).data);
      case ParamType.document:
        // TODO: Handle this case.
        throw UnimplementedError();
      case ParamType.documentReference:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
    return data;
  } catch (e) {
    debugPrint('Error serializing parameter: $e');
    return null;
  }
}

/// END SERIALIZATION HELPERS

/// DESERIALIZATION HELPERS

DateTimeRange? dateTimeRangeFromString(String dateTimeRangeStr) {
  final pieces = dateTimeRangeStr.split('|');
  if (pieces.length != 2) {
    return null;
  }
  return DateTimeRange(
    start: DateTime.fromMillisecondsSinceEpoch(int.parse(pieces.first)),
    end: DateTime.fromMillisecondsSinceEpoch(int.parse(pieces.last)),
  );
}

LatLng? latLngFromString(String? latLngStr) {
  final pieces = latLngStr?.split(',');
  if (pieces == null || pieces.length != 2) {
    return null;
  }
  return LatLng(
    double.parse(pieces.first.trim()),
    double.parse(pieces.last.trim()),
  );
}

FFPlace placeFromString(String placeStr) {
  final serializedData = jsonDecode(placeStr) as Map<String, dynamic>;
  final data = {
    'latLng': serializedData.containsKey('latLng')
        ? latLngFromString(serializedData['latLng'] as String)
        : const LatLng(0, 0),
    'name': serializedData['name'] ?? '',
    'address': serializedData['address'] ?? '',
    'city': serializedData['city'] ?? '',
    'state': serializedData['state'] ?? '',
    'country': serializedData['country'] ?? '',
    'zipCode': serializedData['zipCode'] ?? '',
  };
  return FFPlace(
    latLng: data['latLng'] as LatLng,
    name: data['name'] as String,
    address: data['address'] as String,
    city: data['city'] as String,
    state: data['state'] as String,
    country: data['country'] as String,
    zipCode: data['zipCode'] as String,
  );
}

FFUploadedFile uploadedFileFromString(String uploadedFileStr) =>
    FFUploadedFile.deserialize(uploadedFileStr);

enum ParamType {
  int,
  double,
  string,
  bool,
  dateTime,
  dateTimeRange,
  latLng,
  color,
  ffPlace,
  ffUploadedFile,
  json,

  document,
  documentReference,
  dataStruct,
  supabaseRow,
}

dynamic deserializeParam<T>(
  String? param,
  ParamType paramType,
  bool isList, {
  List<String>? collectionNamePath,
  Function(String)? structBuilder,
}) {
  try {
    if (param == null) {
      return null;
    }
    if (isList) {
      final paramValues = json.decode(param);
      if (paramValues is! Iterable || paramValues.isEmpty) {
        return null;
      }
      return paramValues
          .whereType<String>()
          .map((p) => p)
          .map((p) => deserializeParam<T>(
                p,
                paramType,
                false,
                collectionNamePath: collectionNamePath,
                structBuilder: structBuilder,
              ))
          .where((p) => p != null)
          .map((p) => p! as T)
          .toList();
    }
    switch (paramType) {
      case ParamType.int:
        return int.tryParse(param);
      case ParamType.double:
        return double.tryParse(param);
      case ParamType.string:
        return param;
      case ParamType.bool:
        return param == 'true';
      case ParamType.dateTime:
        final milliseconds = int.tryParse(param);
        return milliseconds != null
            ? DateTime.fromMillisecondsSinceEpoch(milliseconds)
            : null;
      case ParamType.dateTimeRange:
        return dateTimeRangeFromString(param);
      case ParamType.latLng:
        return latLngFromString(param);
      case ParamType.color:
        return fromCssColor(param);
      case ParamType.ffPlace:
        return placeFromString(param);
      case ParamType.ffUploadedFile:
        return uploadedFileFromString(param);
      case ParamType.json:
        return json.decode(param);

      case ParamType.supabaseRow:
        final data = json.decode(param) as Map<String, dynamic>;
        switch (T) {
          case ProfilesRow:
            return ProfilesRow(data);
          case AddressesRow:
            return AddressesRow(data);
          default:
            return null;
        }

      case ParamType.dataStruct:
        final data = json.decode(param) as Map<String, dynamic>? ?? {};
        return structBuilder != null ? structBuilder(data.toString()) : null;

      default:
        return null;
    }
  } catch (e) {
    debugPrint('Error deserializing parameter: $e');
    return null;
  }
}
