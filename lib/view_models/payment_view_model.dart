// ignore_for_file: use_build_context_synchronously

import 'package:fl_pagos_demo/models/banco_model.dart';
import 'package:fl_pagos_demo/models/cuenta_banco_model.dart';
import 'package:fl_pagos_demo/models/forma_pago_model.dart';
import 'package:fl_pagos_demo/models/monto_model.dart';
import 'package:fl_pagos_demo/providers/bancos_provider.dart';
import 'package:fl_pagos_demo/providers/cuenta.provider.dart';
import 'package:fl_pagos_demo/providers/formas_pago_provider.dart';
import 'package:fl_pagos_demo/views/amount_view.dart';
import 'package:fl_pagos_demo/widgets/alert_widget.dart';
import 'package:flutter/material.dart';

class PaymentViewModel extends ChangeNotifier {
  final List<FormaPagoModel> formasPago = []; //formas de pago disponibles
  final List<MontoModel> montos = []; //Formas de pago agregadas
  final List<RadioCuentaBancoModel> cuentas =
      []; //cuentas bancarias disponibles
  final List<RadioBancoModel> bancos = []; //bancos disponibles
  FormaPagoModel? pago; //Pago seleccionado
  BancoModel? banco; //banco seleccionado
  CuentaBancoModel? cuenta; //cuenta bancaria seleciionada
  bool selectAllMontos =
      false; //seleccionar todas laas formas de pago agregadas
  final TextEditingController montoController =
      TextEditingController(); //contorllador input monto
  final TextEditingController autorizacionController =
      TextEditingController(); //controlador input autorizacion
  final TextEditingController referecniaController =
      TextEditingController(); //controlador input referencia

  //Totales globales
  double total =
      3145.89; //TODO:Total a pagar/Total documento, modificar para probar
  double saldo = 0; //Saldo por pagar
  double cambio = 0; //cambio por sobrepago
  double pagado = 0; //Monto pagado

  //Llave para el estado del formulario montos
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  //Valida si el forumario montos es correcto
  bool isValidForm() {
    return formKey.currentState?.validate() ?? false;
  }

  //Cargar formas de pago
  Future<void> loadPayments(BuildContext context) async {
    //Reestablecer valores en las pantallas
    restartValues();
    //Limmmpiar montos agregados
    montos.clear();
    //limpiar formas de pago disponibles
    formasPago.clear();
    //TODO:Cargar formas de pago de servicios rest
    formasPago.addAll(
      //asignar formas de pago encontradas
      formasPagoProvider.map((item) => FormaPagoModel.fromMap(item)).toList(),
    );

    //asignar el total a pagar al saldo pendiente de pago
    saldo = total;

    //ectualizar estado
    notifyListeners();
  }

  //Seleccionar o no un pago agregado
  void changeCheckedamount(
    bool? value, //nuevo valor
    int index, //indice de la lsita
  ) {
    //cambiar valor segun checkbox
    montos[index].checked = value!;
    //actualizar estado
    notifyListeners();
  }

  //eliminar formas de pago seleccioandas
  void deleteAmount(BuildContext context) async {
    //lista de montos seleccioandos
    List<MontoModel> montosSeleccionados =
        montos.where((monto) => monto.checked).toList();

    //validar si hay transacciones seleccionadas
    if (montosSeleccionados.isEmpty) {
      showSnackbar(context, "Selecciona por lo menos un monto.");
      return;
    }

    //mostrar dialogo de confirmacion
    bool result = await showDialog(
          context: context,
          builder: (context) => AlertWidget(
            title: "¿Estás seguro?",
            description: "Se eliminarán los elementos seleccionados.",
            onOk: () => Navigator.of(context).pop(true),
            onCancel: () => Navigator.of(context).pop(false),
          ),
        ) ??
        false;

    //cancelar
    if (!result) return;

    //eliminar los seleccionados
    montos.removeWhere((document) => document.checked == true);
    //calcular totales
    calculateTotal(context);
  }

  //Calcular totales
  void calculateTotal(BuildContext context) {
    //Reicniciar valores
    saldo = 0;
    cambio = 0;
    pagado = 0;

    //Buscar cuanto se ha pagado en la lista de pagos
    for (var element in montos) {
      pagado += element.amount; //sumar totales
    }

    //Buscar cuanto se ha pagado en la lista de pagos
    for (var element in montos) {
      pagado += element.difference; //sumar totales
    }

    //Calcular cambio y saldo pendiente de pagar
    if (pagado > total) {
      cambio = pagado - total;
    } else {
      saldo = total - pagado;
    }

    //Agregar nuevo monto al input onto
    montoController.text = saldo.toStringAsFixed(2);

    //actualizar estado
    notifyListeners();
  }

  //seleccionar toas las formas de pago agregadas
  void selectAll(bool? value) {
    selectAllMontos = value!;

    //Cambiar todos los valores
    for (var element in montos) {
      element.checked = selectAllMontos;
    }

    //actualizar estado
    notifyListeners();
  }

  //cambiar cuenta bancaria seleccionada
  void changeAccountSelect(int? value, BuildContext context) {
    //Maracr todos en falso
    for (var account in cuentas) {
      account.isSelected = false;
    }
    //marcar el seleccionado en verdadero
    cuentas[value!].isSelected = true;

    //guardar cuenta seleccionada
    cuenta = cuentas.firstWhere((check) => check.isSelected).account;

    //actualizar estado
    notifyListeners();
  }

  //Ver formulario de pagos
  Future<void> navigateAmountView(
    BuildContext context,
    FormaPagoModel forma,
  ) async {
    //asignar forma de pago seleccionada
    pago = forma;
    //limpiar cuentas disponibles
    cuentas.clear();
    //limpiar cuenta seleccionada
    cuenta = null;
    //limpiar banco seleccionado
    banco = null;
    //limpiar bancos disponobles
    bancos.clear();

    //Actualizar estado
    notifyListeners();

    //TODO:validar que haya una cuenta correntista seleccionada

    //TODO:validar si la forma de pago es cuenta corriente, si es así, la cuenta correntisra seleccionada debe permiti CxC

    //TODO:Si la forma de pago es cuenta corriente y la cuenta correntista permite CxC
    //TODO:Validar que el monto que se paga esté dentro del limite de credito de la cuenta correntista

    //si no hay total que pagar mostrar mensjae
    if (total == 0) {
      showSnackbar(context, "El total a pagar es 0.");
      return;
    }

    //si no hay saldo pendiente de pago mostrar mensjae
    if (saldo == 0) {
      showSnackbar(context, "El saldo a pagar es 0");
      return;
    }

    //si la forma de pago requier banco , buscar bancos
    if (forma.banco) {
      //TODO:Cargar bancos de api rest
      bancos.clear();
      bancos.addAll(
        bancosProvider
            .map(
              (item) => RadioBancoModel(
                bank: BancoModel.fromMap(item),
                isSelected: false,
              ),
            )
            .toList(),
      );
      //agregar lista de bancos a lista de radios
    }

    //Navegar a la pantalla siguiente (fromualrio montos)
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AmountView()),
    );
  }

  //mostarr mensajes en snackBar
  showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  //Seleccionar banco
  void changeBanco(
    int value,
    BuildContext context,
  ) {
    //limpair cuentas selccionadas
    cuenta = null;
    //limpiar cuentas disponibles
    cuentas.clear();

    //marcar todos los bancos como no sleccionado
    for (var bank in bancos) {
      bank.isSelected = false;
    }

    //marcar el selecccionado en verdadero
    bancos[value].isSelected = true;

    //Buscar el seleccionado y guardar
    banco = bancos.firstWhere((bank) => bank.isSelected).bank;

    //verificar si cuenta bancario es null conevrtirlo en false
    pago!.reqCuentaBancaria = pago!.reqCuentaBancaria ?? false;

    //si la cuenta bancaria es requerida buscar cuenta bancaria
    if (pago!.reqCuentaBancaria) {
      //TODO:Cargar cuentas de api rest
      if (banco!.banco == 4) {
        cuentas.addAll(
          cuentasProvider
              .map(
                (item) => RadioCuentaBancoModel(
                  account: CuentaBancoModel.fromMap(item),
                  isSelected: false,
                ),
              )
              .toList(),
        );
      }
    }

    //actualizar estado
    notifyListeners();
  }

  //agregar una forma de pago
  void addAmount(
    BuildContext context,
  ) {
    //validar formulario
    if (!isValidForm()) return;

    //si la forma de pago requiere banco
    if (pago!.banco) {
      //si no hay bancos seleccionados mostrar mmensaje
      if (banco == null) {
        showSnackbar(context, "Por favor selcciona un banco.");
        return;
      }

      //si se rquiere cuenta bancaria pero no se selcciona mostrar mensjae
      if (pago!.reqCuentaBancaria) {
        if (cuenta == null) {
          showSnackbar(context, "Por favor selcciona una cuenta bancaria.");
          return;
        }
      }
    }

    //convertir monto string a double
    double monto = double.tryParse(montoController.text) ?? 0;
    double diference = 0;

    //Calcualar si hay diferencia (Cambio)
    if (monto > saldo) {
      diference = monto - saldo;
      monto = saldo;
    }

    //objeto monto que se va a agregar (asignar valores)
    MontoModel amount = MontoModel(
      checked: selectAllMontos,
      amount: monto,
      //si es requerido
      authorization: pago!.autorizacion ? autorizacionController.text : "",
      //si es requerido
      reference: pago!.referencia ? referecniaController.text : "",
      payment: pago!,
      //si es requerido
      bank: banco,
      //si es requerido
      account: cuenta,
      //cambio
      difference: diference,
    );

    //Agregar monto a lista de montos
    montos.add(amount); //agregar a lista

    //Limmpiar todos los valores de una forma de pago (reinciar flujo)
    restartValues();
    //calcular totales
    calculateTotal(context);

    //Mensaje
    showSnackbar(context, "Pago agregado");

    //regresar pantalla anterior (formas de pago)
    Navigator.pop(context);
  }

  //Limpiar valores
  restartValues() {
    montoController.text = "";
    referecniaController.text = "";
    autorizacionController.text = "";
    bancos.clear();
    cuenta = null;
    banco = null;
    bancos.clear();
  }
}
