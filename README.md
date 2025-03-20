# **Documentación: Implementación de la Lógica de la Pantalla de Pagos en Flutter**

## **1. Introducción**
Este documento describe la implementación de la lógica de la pantalla de pagos en una aplicación Flutter. Se detalla la funcionalidad del `PaymentViewModel`, que gestiona la selección de formas de pago, cálculos de montos y navegación entre pantallas.

---

## **2. Estructura del ViewModel**
El `PaymentViewModel` extiende `ChangeNotifier` para manejar el estado y notificar cambios a la UI. Se encarga de:
- Cargar datos de formas de pago, bancos y cuentas.
- Manejar selección de pagos y cuentas bancarias.
- Realizar cálculos de montos pagados, saldo y cambio.
- Navegar entre pantallas.

---

## **3. Variables y Objetos Principales**
| Variable | Tipo | Descripción |
|----------|------|------------|
| `formasPago` | `List<FormaPagoModel>` | Lista de formas de pago disponibles. |
| `montos` | `List<MontoModel>` | Lista de montos agregados. |
| `cuentas` | `List<RadioCuentaBancoModel>` | Cuentas bancarias disponibles. |
| `bancos` | `List<RadioBancoModel>` | Bancos disponibles. |
| `total` | `double` | Monto total a pagar. |
| `saldo` | `double` | Saldo pendiente de pago. |
| `pagado` | `double` | Monto ya pagado. |
| `cambio` | `double` | Cambio si se paga de más. |
| `montoController` | `TextEditingController` | Controlador para el monto ingresado. |

---

## **4. Funcionalidades Principales**
### **4.1 Cargar Formas de Pago**
```dart
Future<void> loadPayments(BuildContext context) async {
  restartValues();
  montos.clear();
  formasPago.clear();
  
  formasPago.addAll(
    formasPagoProvider.map((item) => FormaPagoModel.fromMap(item)).toList(),
  );
  
  saldo = total;
  notifyListeners();
}
```
**Descripción:**  
- Restablece valores.
- Carga las formas de pago desde un proveedor.
- Inicializa el saldo pendiente.

---

### **4.2 Seleccionar y Eliminar Montos**
```dart
void changeCheckedamount(bool? value, int index) {
  montos[index].checked = value!;
  notifyListeners();
}

void deleteAmount(BuildContext context) async {
  List<MontoModel> montosSeleccionados = montos.where((monto) => monto.checked).toList();

  if (montosSeleccionados.isEmpty) {
    showSnackbar(context, "Selecciona por lo menos un monto.");
    return;
  }

  bool result = await showDialog(
    context: context,
    builder: (context) => AlertWidget(
      title: "¿Estás seguro?",
      description: "Se eliminarán los elementos seleccionados.",
      onOk: () => Navigator.of(context).pop(true),
      onCancel: () => Navigator.of(context).pop(false),
    ),
  ) ?? false;

  if (!result) return;

  montos.removeWhere((document) => document.checked);
  calculateTotal(context);
}
```
**Descripción:**  
- `changeCheckedamount` actualiza el estado de selección de un monto.
- `deleteAmount` permite eliminar los montos seleccionados tras una confirmación.

---

### **4.3 Cálculo de Totales**
```dart
void calculateTotal(BuildContext context) {
  saldo = 0;
  cambio = 0;
  pagado = 0;

  for (var element in montos) {
    pagado += element.amount;
  }

  if (pagado > total) {
    cambio = pagado - total;
  } else {
    saldo = total - pagado;
  }

  montoController.text = saldo.toStringAsFixed(2);
  notifyListeners();
}
```
**Descripción:**  
- Suma los montos pagados.
- Calcula saldo pendiente y cambio.
- Actualiza el `TextEditingController`.

---

### **4.4 Selección de Banco y Cuenta Bancaria**
```dart
void changeBanco(int value, BuildContext context) {
  cuenta = null;
  cuentas.clear();

  for (var bank in bancos) {
    bank.isSelected = false;
  }

  bancos[value].isSelected = true;
  banco = bancos.firstWhere((bank) => bank.isSelected).bank;

  if (pago!.reqCuentaBancaria ?? false) {
    cuentas.addAll(
      cuentasProvider.map((item) => RadioCuentaBancoModel(
        account: CuentaBancoModel.fromMap(item),
        isSelected: false,
      )).toList(),
    );
  }

  notifyListeners();
}
```
**Descripción:**  
- Marca un banco como seleccionado.
- Carga cuentas bancarias si son requeridas.

---

### **4.5 Navegación a la Pantalla de Montos**
```dart
Future<void> navigateAmountView(BuildContext context, FormaPagoModel forma) async {
  pago = forma;
  cuentas.clear();
  cuenta = null;
  banco = null;
  bancos.clear();
  
  notifyListeners();

  if (total == 0) {
    showSnackbar(context, "El total a pagar es 0.");
    return;
  }

  if (saldo == 0) {
    showSnackbar(context, "El saldo a pagar es 0");
    return;
  }

  if (forma.banco) {
    bancos.addAll(
      bancosProvider.map((item) => RadioBancoModel(
        bank: BancoModel.fromMap(item),
        isSelected: false,
      )).toList(),
    );
  }

  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const AmountView()),
  );
}
```
**Descripción:**  
- Prepara datos antes de navegar a la pantalla de montos.
- Carga bancos si son requeridos.
- Valida si hay saldo pendiente antes de continuar.

---

### **4.6 Mostrar Mensajes**
```dart
void showSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
    ),
  );
}
```
**Descripción:**  
- Muestra mensajes emergentes para alertar al usuario.

---

## **5. Conclusión**
Esta implementación proporciona una estructura organizada para la pantalla de pagos en Flutter. Se han cubierto:
- **Carga y gestión de datos**: Formas de pago, bancos y cuentas.
- **Interacción del usuario**: Selección de pagos, eliminación de montos.
- **Cálculos dinámicos**: Saldo, cambio y validaciones.
- **Navegación entre pantallas**: Pasar datos al formulario de montos.

Este enfoque modular facilita la escalabilidad y mantenimiento del código.
