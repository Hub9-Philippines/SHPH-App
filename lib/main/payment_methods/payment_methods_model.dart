import 'package:flutter/material.dart';

import '/auth/supabase_auth/auth_util.dart';
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
      queryFn: (q) => q.eq('user_id', currentUserUid),
    );
  }

  Future<void> setAsDefault(String paymentMethodId) async {
    await PaymentMethodsTable().update(
      data: {'is_default': true},
      matchingRows: (f) => f.eq('id', paymentMethodId),
    );
  }

  Future<void> deletePaymentMethod(String paymentMethodId) async {
    await PaymentMethodsTable().delete(
      matchingRows: (f) => f.eq('id', paymentMethodId),
    );
  }
}
