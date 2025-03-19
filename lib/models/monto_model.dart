import 'dart:convert';

import 'package:fl_pagos_demo/models/banco_model.dart';
import 'package:fl_pagos_demo/models/cuenta_banco_model.dart';
import 'package:fl_pagos_demo/models/forma_pago_model.dart';

class MontoModel {
  MontoModel({
    required this.checked,
    required this.amount,
    required this.difference,
    required this.authorization,
    required this.reference,
    required this.payment,
    this.account,
    this.bank,
  });

  bool checked;
  FormaPagoModel payment;
  double amount;
  double difference;
  String authorization;
  String reference;
  CuentaBancoModel? account;
  BancoModel? bank;

  factory MontoModel.fromJson(String str) =>
      MontoModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory MontoModel.fromMap(Map<String, dynamic> json) => MontoModel(
        checked: json["checked"],
        payment: FormaPagoModel.fromMap(json["payment"]),
        amount: json["amount"],
        difference: json["diference"],
        authorization: json["authorization"],
        reference: json["reference"],
        account: json["account"] == null
            ? null
            : CuentaBancoModel.fromMap(json["account"]),
        bank: json["bank"] == null ? null : BancoModel.fromMap(json["bank"]),
      );

  Map<String, dynamic> toMap() => {
        "checked": checked,
        "payment": payment.toMap(),
        "amount": amount,
        "diference": difference,
        "authorization": authorization,
        "reference": reference,
        "account": account?.toMap(),
        "bank": bank?.toMap(),
      };
}
