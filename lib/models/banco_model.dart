// To parse this JSON data, do
//
//     final bankModel = bankModelFromMap(jsonString);

import 'dart:convert';

class BancoModel {
  int banco;
  String nombre;
  int? orden;

  BancoModel({
    required this.banco,
    required this.nombre,
    this.orden,
  });

  factory BancoModel.fromJson(String str) =>
      BancoModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory BancoModel.fromMap(Map<String, dynamic> json) => BancoModel(
        banco: json["banco"],
        nombre: json["nombre"],
        orden: json["orden"],
      );

  Map<String, dynamic> toMap() => {
        "banco": banco,
        "nombre": nombre,
        "orden": orden,
      };
}

class RadioBancoModel {
  RadioBancoModel({
    required this.bank,
    required this.isSelected,
  });

  BancoModel bank;
  bool isSelected;
}
