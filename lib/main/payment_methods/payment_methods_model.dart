import 'package:flutter/material.dart';

import '/auth/auth_util.dart';
import '/backend/supabase/database/tables/payment_methods.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PaymentMethodsModel extends FlutterFlowModel {
  /// Initialization and disposal methods.

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}

  Future<List<PaymentMethodsRow>> loadPaymentMethods() async {
    if (currentUserUid.isEmpty) {
      return [];
    }
    return PaymentMethodsTable().queryRows(
      queryFn: (q) => q
          .eq('user_id', currentUserUid)
          .order('is_default', ascending: false)
          .order('created_at', ascending: false),
    );
  }

  Future<void> setAsDefault(String paymentMethodId) async {
    if (currentUserUid.isEmpty) {
      return;
    }

    await PaymentMethodsTable().update(
      data: {'is_default': false},
      matchingRows: (f) => f.eq('user_id', currentUserUid),
    );
    await PaymentMethodsTable().update(
      data: {'is_default': true},
      matchingRows: (f) => f.eq('id', paymentMethodId),
    );
  }

  Future<void> deletePaymentMethod(String paymentMethodId) async {
    if (currentUserUid.isEmpty) {
      return;
    }

    final methods = await PaymentMethodsTable().queryRows(
      queryFn: (q) => q
          .eq('user_id', currentUserUid)
          .order('is_default', ascending: false)
          .order('created_at', ascending: false),
    );
    final target =
        methods.where((method) => method.id == paymentMethodId).firstOrNull;

    await PaymentMethodsTable().delete(
      matchingRows: (f) => f.eq('id', paymentMethodId),
    );

    if (target?.isDefault != true) {
      return;
    }

    final remaining =
        methods.where((method) => method.id != paymentMethodId).toList();
    if (remaining.isEmpty) {
      return;
    }

    await PaymentMethodsTable().update(
      data: {'is_default': true},
      matchingRows: (f) => f.eq('id', remaining.first.id),
    );
  }
}
