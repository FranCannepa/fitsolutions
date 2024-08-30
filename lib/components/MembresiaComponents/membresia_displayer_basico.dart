import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsolutions/Components/MembresiaComponents/membresia_info.dart';
import 'package:fitsolutions/Components/MembresiaComponents/membresia_seleccionador.dart';
import 'package:fitsolutions/components/CommonComponents/result_dialog.dart';
import 'package:fitsolutions/modelo/Membresia.dart';
import 'package:fitsolutions/providers/membresia_provider.dart';
import 'package:fitsolutions/providers/user_data.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
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
  bool showMembresiaInfo = true;
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
      Logger().e('Error: $err');
    });
  }

  void _handleDeepLink(String link) async {
    final prefs = await SharedPreferences.getInstance();
    final String? lastHandledLink = prefs.getString('last_handled_link');
    if (lastHandledLink == link) {
      return;
    }

    Uri uri = Uri.parse(link);
    Logger().e(uri);

    String? status = uri.queryParameters['status'];
    String? paymentId = uri.queryParameters['payment_id'];
    await prefs.setString('last_handled_link', link);
    final String? membresiaId = prefs.getString('pending_membresia_id');
    final PurchasesProvider purchasesProvider =
        PurchasesProvider(FirebaseFirestore.instance);
    late ResultType result;
    late String resultMsg;
    int statusCode = 4;

    final DateTime purchaseDate = DateTime.now();
    if (mounted) {
      final UserData userProvider = context.read<UserData>();
      final String? userId = await userProvider.getUserId();

      if (status == 'approved') {
        statusCode = 1;
        if (membresiaId != null) {
          await userProvider.updateMembresiaId(membresiaId);
        }
        await prefs.remove('pending_membresia_id');
        await prefs.remove('pending_payment_id');
        result = ResultType.success;
        resultMsg = "Pago Satisfactorio";
      } else if (status == 'pending') {
        statusCode = 2;
        String? paymentId = uri.queryParameters['payment_id'];
        final prefs = await SharedPreferences.getInstance();
        if (paymentId != null) {
          await prefs.setString('pending_payment_id', paymentId);
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
        'transactionId': paymentId,
        'usuarioId': userId
      });

      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return ResultDialog(text: resultMsg, resultType: result);
          },
        );
      }
    }
  }

  void toggleMembresiaView() {
    setState(() {
      showMembresiaInfo = !showMembresiaInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    final UserData userProvider = context.watch<UserData>();
    final PaymentService paymentService = PaymentService();
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
                  if (showMembresiaInfo && membresia != null) {
                    return MembresiaInfo(
                        membresia: membresia,
                        onChangeMembresia: toggleMembresiaView);
                  } else {
                    return SeleccionarMembresia(
                        membresias: widget.membresias,
                        membresia: membresia,
                        showMembresiaInfo: showMembresiaInfo,
                        onBackToMembresiaInfo: toggleMembresiaView);
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
