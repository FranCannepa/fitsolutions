import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsolutions/providers/purchases_provider.dart';
import 'package:fitsolutions/providers/inscription_provider.dart';
import 'package:fitsolutions/providers/membresia_provider.dart';
import 'package:fitsolutions/providers/userData.dart';
import 'package:intl/intl.dart';

class ComprasScreen extends StatefulWidget {
  const ComprasScreen({super.key});

  @override
  _ComprasScreenState createState() => _ComprasScreenState();
}

class _ComprasScreenState extends State<ComprasScreen> {
  String? gymId;
  bool hasError = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchGymId();
  }

  Future<void> fetchGymId() async {
    try {
      final provider = Provider.of<InscriptionProvider>(context, listen: false);
      String? fetchedGymId = await provider.gymLoggedIn();
      if (fetchedGymId != null) {
        setState(() {
          gymId = fetchedGymId;
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _fetchPurchases(String gymId) async {
    final purchasesProvider = context.read<PurchasesProvider>();
    return await purchasesProvider.getPurchasesByGym(gymId);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Compras'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (hasError || gymId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Compras'),
        ),
        body: const Center(
          child: Text('Error fetching gym ID'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compras'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchPurchases(gymId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay compras'));
          } else {
            final purchases = snapshot.data!;
            return ListView.builder(
              itemCount: purchases.length,
              itemBuilder: (context, index) {
                final purchase = purchases[index];

                //Convierto Timestamp a DateTime
                DateTime purchaseDate = (purchase['purchaseDate']).toDate();
                //Formateo fecha
                String formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(purchaseDate);

                return Card(
                  margin: const EdgeInsets.all(10),
                  elevation: 4,
                  shadowColor: Colors.black54,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text('ID: ${purchase['transactionId']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        FutureBuilder<String?>(
                          future: context
                              .read<MembresiaProvider>()
                              .getMembershipName(purchase['productId']),
                          builder: (context, snapshot) =>
                              Text('Producto: ${snapshot.data ?? 'Cargando...'}'),
                        ),
                        Text('Fecha: ${formattedDate}'),
                        FutureBuilder<String?>(
                          future: context
                              .read<PurchasesProvider>()
                              .getStatusName(purchase['status'].toString()),
                          builder: (context, snapshot) =>
                              Text('Estado: ${snapshot.data ?? 'Cargando...'}'),
                        ),
                        FutureBuilder<String?>(
                          future: context
                              .read<UserData>()
                              .getUserNameById(purchase['usuarioId']),
                          builder: (context, snapshot) =>
                              Text('Usuario: ${snapshot.data ?? 'Cargando...'}'),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
