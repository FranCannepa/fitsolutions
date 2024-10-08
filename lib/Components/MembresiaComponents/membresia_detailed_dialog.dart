import 'package:fitsolutions/Utilities/modal_utils.dart';
import 'package:fitsolutions/Utilities/shared_prefs_helper.dart';
import 'package:fitsolutions/components/CommonComponents/result_dialog.dart';
import 'package:fitsolutions/components/MembresiaComponents/membresia_payment_service.dart';
import 'package:fitsolutions/modelo/Membresia.dart';
import 'package:fitsolutions/components/components.dart';
import 'package:fitsolutions/providers/membresia_provider.dart';
import 'package:fitsolutions/providers/user_data.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class MembresiaDetailed extends StatefulWidget {
  final Membresia membresia;
  final UserData userProvider;
  final MembresiaProvider membresiaProvider;
  final VoidCallback onClose;
  const MembresiaDetailed(
      {super.key,
      required this.membresia,
      required this.membresiaProvider,
      required this.userProvider,
      required this.onClose});

  @override
  State<MembresiaDetailed> createState() => _MembresiaDetailedState();
}

class _MembresiaDetailedState extends State<MembresiaDetailed> {
  @override
  Widget build(BuildContext context) {
    final Membresia membresia = widget.membresia;
    final UserData userProvider = widget.userProvider;
    final PaymentService paymentService = PaymentService();
    final prefs = SharedPrefsHelper();
    context.watch<MembresiaProvider>();
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      color: Colors.black,
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        membresia.nombreMembresia,
                        style: const TextStyle(
                            fontSize: 25.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                        overflow: TextOverflow.fade,
                        softWrap: false,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: widget.onClose,
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              IntrinsicHeight(
                child: Container(
                  width: 250.0,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 50.0, vertical: 15),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                      width: 3.0,
                    ),
                  ),
                  child: membresia.descripcion.isNotEmpty
                      ? SingleChildScrollView(
                        child: Text(
                            membresia.descripcion,
                            style: const TextStyle(fontSize: 20.0),
                          ),
                      )
                      : const ScreenSubTitle(text: 'No hay descripcion'),
                ),
              ),
              const SizedBox(height: 20.0),
              Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 10.0),
                color: Colors.black,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (userProvider.esBasico())
                      Text(
                        "\$${membresia.costo.toString()}",
                        style: const TextStyle(
                            fontSize: 30.0, color: Colors.white),
                      ),
                    if (userProvider.esBasico())
                      SubmitButton(
                        text: "Suscribirse",
                        onPressed: () async {
                          final costo = double.tryParse(membresia.costo);
                          final asociadoId = userProvider.origenAdministrador;
                          final email = await prefs.getEmail() as String;
                          try {
                            if (context.mounted) {
                              await paymentService.createPayment(context, costo!,
                                  email, membresia.id, asociadoId);
                              widget.onClose;
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            }
                          } catch (error) {
                            if (context.mounted) {
                              Logger().e('Error creating payment: $error');
                              ModalUtils.showSuccessModal(context, 'Error al realizar pago', ResultType.error, () => Navigator.pop(context));
                            }
                          }
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }
}

class WidgetBindingsObserverSample extends NavigatorObserver {
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('App resumed after launching URL');
    }
  }
}
