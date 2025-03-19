import 'package:fl_pagos_demo/models/banco_model.dart';
import 'package:fl_pagos_demo/models/cuenta_banco_model.dart';
import 'package:fl_pagos_demo/view_models/payment_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

//Pantalla agregar monto
class AmountView extends StatelessWidget {
  const AmountView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<PaymentViewModel>(context);

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
              child: SingleChildScrollView(
                child: Form(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  key: vm.formKey,
                  //inputs
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vm.pago!.descripcion,
                      ),
                      const SizedBox(height: 20),
                      //monto
                      TextFormField(
                        controller: vm.montoController,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^(\d+)?\.?\d{0,2}'),
                          ),
                        ],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          //counter: const Text('Caracteres'),
                          labelText: "Monto",
                          hintText: "00.00",
                          suffixIcon: IconButton(
                            onPressed: () => vm.montoController.clear(),
                            icon: const Icon(
                              Icons.close,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Requerido";
                          }
                          if ((double.tryParse(value) ?? 0) == 0) {
                            return "El monto debe ser mayor a 0";
                          }
                          return null;
                        },
                      ),
                      if (vm.pago!.autorizacion)
                        Column(
                          children: [
                            const SizedBox(height: 5),
                            TextFormField(
                              controller: vm.autorizacionController,
                              decoration: const InputDecoration(
                                //counter: const Text('Caracteres'),
                                labelText: "Autorización",
                                hintText: "Autorización",
                              ),
                              validator: (value) {
                                if (vm.pago!.autorizacion == true) {
                                  if (value == null || value.isEmpty) {
                                    return "Requerido";
                                  }
                                }
                                return null;
                              },
                            ),
                          ],
                        ),

                      if (vm.pago!.referencia)
                        Column(
                          children: [
                            const SizedBox(height: 5),
                            TextFormField(
                              controller: vm.referecniaController,
                              decoration: const InputDecoration(
                                //counter: const Text('Caracteres'),
                                labelText: "Referencia",
                                hintText: "Referencia",
                              ),
                              validator: (value) {
                                if (vm.pago!.referencia == true) {
                                  if (value == null || value.isEmpty) {
                                    return "Requerido";
                                  }
                                }
                                return null;
                              },
                            ),
                          ],
                        ),

                      if (vm.pago!.banco)
                        Column(
                          children: [
                            const SizedBox(height: 10),
                            const Text("Bancos"),
                            const SizedBox(height: 10),
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: vm.bancos.length,
                              itemBuilder: (BuildContext context, int index) {
                                RadioBancoModel bank = vm.bancos[index];
                                return Card(
                                  elevation: 2.0,
                                  child: RadioListTile(
                                    title: Text(
                                      bank.bank.nombre,
                                    ),
                                    value: index,
                                    groupValue: vm.bancos.indexWhere(
                                      (bank) => bank.isSelected,
                                    ),
                                    onChanged: (int? value) => vm.changeBanco(
                                      value!,
                                      context,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      if ((vm.pago!.reqCuentaBancaria ?? false) == true)
                        Column(
                          children: [
                            const SizedBox(height: 10),
                            const Text("Cuentas"),
                            const SizedBox(height: 10),
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: vm.cuentas.length,
                              itemBuilder: (BuildContext context, int index) {
                                RadioCuentaBancoModel account =
                                    vm.cuentas[index];
                                return Card(
                                  elevation: 2.0,
                                  child: RadioListTile(
                                    title: Text(
                                      account.account.descripcion,
                                    ),
                                    value: index,
                                    groupValue: vm.cuentas.indexWhere(
                                      (acc) => acc.isSelected,
                                    ),
                                    onChanged: (int? value) =>
                                        vm.changeAccountSelect(
                                      value,
                                      context,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      const SizedBox(height: 20),
                      //boton confirmar
                      InkWell(
                        onTap: () => vm.addAmount(context),
                        child: Container(
                          color: Color(0xff134895),
                          height: 55,
                          child: const Center(
                            child: Text(
                              "Agregar pago",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            //totales
            _Footer(),
          ],
        ),
      ),
    );
  }
}

//totales (footer)
class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final PaymentViewModel vm = Provider.of<PaymentViewModel>(context);
    return Column(
      children: [
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
    );
  }
}
