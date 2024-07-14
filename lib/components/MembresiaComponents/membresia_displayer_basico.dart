import 'dart:developer';

import 'package:fitsolutions/Components/MembresiaComponents/membresiaInfo.dart';
import 'package:fitsolutions/Components/MembresiaComponents/membresiaSeleccionador.dart';
import 'package:fitsolutions/components/CommonComponents/result_dialog.dart';
import 'package:fitsolutions/modelo/Membresia.dart';
import 'package:fitsolutions/providers/membresia_provider.dart';
import 'package:fitsolutions/providers/userData.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsolutions/Components/MembresiaComponents/membresia_payment_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';
import 'package:fitsolutions/providers/purchases_provider.dart';

class MembresiaDisplayerBasico extends StatefulWidget {
  final List<Membresia> membresias;
  const MembresiaDisplayerBasico({super.key, required this.membresias});

  @override
  State<MembresiaDisplayerBasico> createState() =>
      _MembresiaDisplayerBasicoState();
}

class _MembresiaDisplayerBasicoState extends State<MembresiaDisplayerBasico> {
  @override
  void initState() {
    super.initState();
    initUnitLinks();
  }

  Future<void> initUnitLinks() async {
    final initialLink = await getInitialLink();
    if (initialLink != null) {
      _handleDeepLink(initialLink);
    }

    linkStream.listen((String? link) {
      if (link != null) {
        _handleDeepLink(link);
      }
    }, onError: (err) {
      print('Error: $err');
    });
  }

  void _handleDeepLink(String link) async {
    final prefs = await SharedPreferences.getInstance();
    final String? lastHandledLink = prefs.getString('last_handled_link');
    if (lastHandledLink == link) {
      return;
    }

    Uri uri = Uri.parse(link);
    print(uri);

    String? status = uri.queryParameters['status'];
    String? payment_id = uri.queryParameters['payment_id'];
    await prefs.setString('last_handled_link', link);
    final String? membresiaId = prefs.getString('pending_membresia_id');
    final PurchasesProvider purchasesProvider = context.read<PurchasesProvider>();
    late ResultType result;
    late String resultMsg;
    int statusCode = 4;

    final DateTime purchaseDate = DateTime.now();
    final UserData userProvider = context.read<UserData>();

    final String? userId = await userProvider.getUserId();

    if (status == 'approved') {
      statusCode = 1;
      if (membresiaId != null) {
        await userProvider.updateMembresiaId(membresiaId);
      }
      await await prefs.remove('pending_membresia_id');
      await prefs.remove('pending_payment_id');
      result = ResultType.success;
      resultMsg = "Pago Satisfactorio";
    } else if (status == 'pending') {
      statusCode = 2;
      String? payment_id = uri.queryParameters['payment_id'];
      final prefs = await SharedPreferences.getInstance();
      if (payment_id != null) {
        await prefs.setString('pending_payment_id', payment_id);
      }
      result = ResultType.warning;
    } else if (status == 'failure' || status == 'rejected') {
      statusCode = 3;
      result = ResultType.error;
      resultMsg = "Pago Fallido!";
    }

    await purchasesProvider.addPurchase({
      'productId': membresiaId,
      'purchaseDate': purchaseDate,
      'status': statusCode,
      'transactionId': payment_id,
      'usuarioId': userId
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ResultDialog(text: resultMsg, resultType: result);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final UserData userProvider = context.watch<UserData>();
    final PaymentService paymentService = PaymentService();
    final MembresiaProvider membresiaProvider =
        context.watch<MembresiaProvider>();
    paymentService.verifyPayment(context);
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<Membresia?>(
              future: userProvider.getMembresia(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final membresia = snapshot.data;
                  return membresia != null
                      ? MembresiaInfo(membresia: membresia)
                      : SeleccionarMembresia(membresias: widget.membresias);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
