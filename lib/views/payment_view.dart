import 'package:fl_pagos_demo/models/forma_pago_model.dart';
import 'package:fl_pagos_demo/models/monto_model.dart';
import 'package:fl_pagos_demo/view_models/payment_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PaymentView extends StatefulWidget {
  const PaymentView({Key? key}) : super(key: key);

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  @override
  void initState() {
    super.initState();

    final vm = Provider.of<PaymentViewModel>(context, listen: false);

    WidgetsBinding.instance
        .addPostFrameCallback((_) => vm.loadPayments(context));
  }

  @override
  Widget build(BuildContext context) {
    final PaymentViewModel vm = Provider.of<PaymentViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.orange.shade50,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => vm.loadPayments(context),
                child: ListView(
                  children: [
                    const Text("Agregar Pago"),
                    const SizedBox(height: 10),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: vm.formasPago.length,
                      itemBuilder: (BuildContext context, int index) {
                        final FormaPagoModel forma = vm.formasPago[index];

                        return GestureDetector(
                          onTap: () => vm.navigateAmountView(context, forma),
                          child: Card(
                            elevation: 2.0,
                            child: ListTile(
                              trailing: const Icon(Icons.arrow_right),
                              title: Text(
                                forma.descripcion,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    if (vm.montos.isNotEmpty)
                      Column(
                        children: [
                          const SizedBox(height: 20),
                          const Divider(),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const SizedBox(width: 20),
                              Checkbox(
                                value: vm.selectAllMontos,
                                onChanged: (value) => vm.selectAll(value),
                              ),
                              Text("Pagos agregados (${vm.montos.length})"),
                              const Spacer(),
                              IconButton(
                                onPressed: () => vm.deleteAmount(context),
                                icon: const Icon(Icons.delete_outline),
                              )
                            ],
                          ),
                        ],
                      ),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: vm.montos.length,
                      itemBuilder: (BuildContext context, int index) {
                        final MontoModel amount = vm.montos[index];

                        return Card(
                          elevation: 2.0,
                          child: ListTile(
                            leading: Checkbox(
                              value: amount.checked,
                              onChanged: (value) => vm.changeCheckedamount(
                                value,
                                index,
                              ),
                            ),
                            title: Text(
                              amount.payment.descripcion,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (amount.payment.autorizacion)
                                  Text(
                                    'Autorización: ${amount.authorization}',
                                  ),
                                if (amount.payment.referencia)
                                  Text(
                                    'Referencia: ${amount.reference}',
                                  ),
                                if (amount.payment.banco)
                                  Text(
                                    'Banco: ${amount.bank?.nombre}',
                                  ),
                                if (amount.account != null)
                                  Text(
                                    'Cuenta: ${amount.account!.descripcion}',
                                  ),
                                Text(
                                  'Monto: ${amount.amount}',
                                ),
                                if (amount.difference > 0)
                                  Text(
                                    'Diferencia: ${amount.difference}',
                                  ),
                                if (amount.difference > 0)
                                  Text(
                                    'Pago Total: ${amount.difference + amount.amount}',
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total:"),
                Text("${vm.total}"),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Saldo:"),
                Text("${vm.saldo}"),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Cambio:"),
                Text("${vm.cambio}"),
              ],
            )
          ],
        ),
      ),
    );
  }
}
