# Proceso cargo abono 

## 1. Descripción
El Widget `PaymentViewModel` es responsable de gestionar el flujo de pagos en la aplicación. Permite seleccionar formas de pago, ingresar montos, validar datos y calcular totales.

# Requisitos previos
- Dart
- Flutter
- provider

- Interfaces:
  - `BancoModel`
  - `CuentaBancoModel`
  - `FormaPagoModel`
  - `MontoModel`
- Proveedores de datos:
  - `bancos` (lista de bancos disponibles) *(Remplazar por consumo en api)*
  - `cuentas` (lista de cuentas bancarias disponibles) *(Remplazar por consumo en api)*
  - `formas` (lista de formas de pago disponibles) *(Remplazar por consumo en api)*

## 3. Propiedades
### Variables de Estado
- `formasPago`: Lista de formas de pago disponibles.
- `forms`: Controla la visibilidad del formulario de montos.
- `pago`: Forma de pago seleccionada.
- `banco`: Banco seleccionado.
- `bancos`: Lista de bancos disponibles.
- `cuentas`: Lista de cuentas bancarias disponibles.
- `monto`: Monto ingresado por el usuario.
- `cuentaSelect`: Cuenta bancaria seleccionada.
- `autorizacion`: Código de autorización ingresado.
- `referencia`: Referencia del pago.
- `montos`: Lista de pagos agregados.
- `selectAllMontos`: Indica si se seleccionan todos los montos agregados.
- `isLoading`: Indica si hay una operación en curso.

### Variables de Totales
- `total`: Total a pagar. *(Modifica este valor para hacer pruebas con montos distitntos)*
- `saldo`: Saldo restante.
- `cambio`: Cambio en caso de sobrepago.
- `pagado`: Total pagado hasta el momento.

## 4. Métodos
### `openSnackbar(message: string)`
Muestra un mensaje emergente con `MatSnackBar`.

### `strToNum(texto: string): number | null`
Convierte un string en un número flotante, devolviendo `null` si el string no es un número válido.

### `async viewForms(payment: FormaPagoInterface)`
Gestiona la visibilidad del formulario según la forma de pago seleccionada.
- Valida que haya saldo pendiente.
- Carga bancos si la forma de pago lo requiere *(Agregar consumo de apis)*.
- Muestra el formulario si es necesario.

### `addAmount()`
Añade un monto a la lista de pagos:
- Valida que el monto sea numérico.
- Valida que el monto sea positivo mayor a 0.
- Verifica la necesidad de autorización, referencia y banco.
- Ajusta el monto si excede el saldo.
- Agrega el pago a la lista y recalcula totales.

### `viewPayments()`
Restablece los valores del formulario y marca la primera forma de pago como seleccionada (Estilos).

### `async changeBanco()`
Carga cuentas bancarias asociadas al banco seleccionado.

### `selectAll()`
Marca o desmarca todas las formas de pago en la lista de montos.

### `async deleteAmount()`
Elimina los pagos seleccionados y recalcula totales.

### `calculateTotal()`
Recalcula los totales de pago:
- Suma montos pagados.
- Calcula saldo pendiente o cambio si el pago excede el total.

### `openDialogActions()`
Abre un dialogo de confirmación, retorna true o false segun la opcion seleccionada por el usuario.

## 5. Flujo de Uso
1. Se selecciona una forma de pago.
2. Se ingresa el monto y datos adicionales si son requeridos.
3. Se agrega el pago a la lista.
4. Se recalculan totales.
5. Se pueden modificar, eliminar o agregar más pagos hasta completar la transacción.

## 6. Consideraciones
- Se debe validar que el usuario seleccione un banco y cuenta si la forma de pago lo requiere.
- El saldo debe actualizarse correctamente tras cada operación.
- Se debe manejar correctamente el caso en que el monto pagado supere el total.
- No se usan servicios REST para esta demostracion, consume tus servicios correspondientes.

#DEMO en vivo
* [Puedes ver una demo en vivo aquí.](https://lsurec.github.io/ng-pagos-demo/)
