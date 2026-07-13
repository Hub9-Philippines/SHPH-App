import 'package:flutter/material.dart';

import '/api/shph_api.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PaymentMethodsModel extends FlutterFlowModel {
  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}

  Future<List<Map<String, dynamic>>> loadPaymentMethods() async {
    try {
      return await ShphUsersApi.instance.listPaymentMethods();
    } catch (e) {
      return [];
    }
  }

  Future<void> setAsDefault(String paymentMethodId) async {
    try {
      await ShphUsersApi.instance.setDefaultPaymentMethod(paymentMethodId);
    } catch (e) {
      // ignore
    }
  }

  Future<void> deletePaymentMethod(String paymentMethodId) async {
    try {
      await ShphUsersApi.instance.deletePaymentMethod(paymentMethodId);
    } catch (e) {
      // ignore
    }
  }

  Future<Map<String, dynamic>?> addPaymentMethod(Map<String, dynamic> payload) async {
    try {
      return await ShphUsersApi.instance.addPaymentMethod(payload);
    } catch (e) {
      return null;
    }
  }
}
