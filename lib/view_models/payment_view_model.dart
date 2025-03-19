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
  final List<MontoModel> montos = [];
  final List<RadioCuentaBancoModel> cuentas =
      []; //cuentas bancarias disponibles
  final List<RadioBancoModel> bancos = [];
  FormaPagoModel? pago; //Pago seleccionado
  BancoModel? banco;
  CuentaBancoModel? cuenta;

  bool selectAllMontos = false;
  final TextEditingController montoController = TextEditingController();
  final TextEditingController autorizacionController = TextEditingController();
  final TextEditingController referecniaController = TextEditingController();

  //Totales globales

  double total = 3145.89;
  double saldo = 0;
  double cambio = 0;
  double pagado = 0;

  //Llave para el estado del formulario montos
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  //Valida si el forumario es correcto
  bool isValidForm() {
    return formKey.currentState?.validate() ?? false;
  }

  //Cargar formas de pago
  Future<void> loadPayments(BuildContext context) async {
    restartValues();
    montos.clear();
    formasPago.clear();
    //TODO:Cargar formas de pago de servicios rest
    formasPago.addAll(
      formasPagoProvider.map((item) => FormaPagoModel.fromMap(item)).toList(),
    );

    saldo = total;

    notifyListeners();
  }

  //Seleccionar una forma de pago agregada
  void changeCheckedamount(
    bool? value,
    int index,
  ) {
    //cambiar valor segun checkbox
    montos[index].checked = value!;
    notifyListeners();
  }

  //eliminar formas de pago seleccioandas
  void deleteAmount(BuildContext context) async {
    List<MontoModel> montosSeleccionados =
        montos.where((monto) => monto.checked).toList();

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

    //Agregar valores a los inputs
    montoController.text = saldo.toStringAsFixed(2);

    notifyListeners();
  }

  //seleccionar toas las formas de pago agregadas
  void selectAll(bool? value) {
    selectAllMontos = value!;

    //Cambiar todos los valores
    for (var element in montos) {
      element.checked = selectAllMontos;
    }
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

    cuenta = cuentas.firstWhere((check) => check.isSelected).account;

    notifyListeners();
  }

  Future<void> navigateAmountView(
    BuildContext context,
    FormaPagoModel forma,
  ) async {
    //limpiar cuentas
    pago = forma;
    cuentas.clear();
    cuenta = null;
    banco = null;
    bancos.clear();

    notifyListeners();

    //TODO:validar que haya una cuenta correntista seleccionada

    //TODO:validar si la forma de pago es cuenta corriente, si es así, la cuenta correntisra seleccionada debe permiti CxC

    //TODO:Si la forma de pago es cuenta corriente y la cuenta correntista permite CxC
    //TODO:Validar que el monto que se paga esté dentro del limite de credito de la cuenta correntista

    //validaciones para poder navegar a la pantalla
    if (total == 0) {
      showSnackbar(context, "El total a pagar es 0.");

      return;
    }

    if (saldo == 0) {
      showSnackbar(context, "El saldo a pagar es 0");
      return;
    }

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

    //Navegar a la pantalla siguiente
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AmountView()),
    );
  }

  showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void changeBanco(
    int value,
    BuildContext context,
  ) {
    cuenta = null;
    cuentas.clear();
    //Maracr todos en falso
    for (var bank in bancos) {
      bank.isSelected = false;
    }

    //marcar el selecccionado en verdadero
    bancos[value].isSelected = true;

    //Buscar el seleccionado
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

    notifyListeners();
  }

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
      difference: diference,
    );

    //Agregar monto a lista de montos
    montos.add(amount); //agregar a lista

    restartValues();
    calculateTotal(context);
    //mensaje usuario

    showSnackbar(context, "Pago agregado");

    //regresar pantalla anterior
    Navigator.pop(context);
  }

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
