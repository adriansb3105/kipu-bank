# KipuBank

KipuBank es un contrato inteligente desarrollado en Solidity que actúa como una bóveda descentralizada para depósitos y retiros de tokens nativos de Ethereum (ETH). Cada usuario registrado cuenta con una cuenta personal segura que mantiene su balance y el historial completo de sus transacciones.

---

## Características Principales 🚀

* ✅ Registro único de usuarios basado en dirección Ethereum.
* 💰 Depósitos en ETH con seguimiento de historial.
* 🏦 Retiros de ETH con un **umbral máximo por transacción**.
* 📉 Límite global de fondos totales (bankCap).
* 📊 Registro de número de depósitos y retiros por usuario.
* 📜 Eventos emitidos en cada transacción exitosa.
* 🔐 Validaciones seguras con errores personalizados.

---

## Estructura del Proyecto 📁

```
kipu-bank/
├── contracts/
│   └── KipuBank.sol
├── README.md
└── (opcional) scripts/, tests/, etc.
```

---

## Requisitos Técnicos ✅

* Solidity 0.8.30
---

## Cómo Interactuar con el Contrato 🧑‍💻

1. **Registrar un usuario:**

   ```solidity
   registrarUsuario()
   ```

   Debe ejecutarse antes de cualquier depósito o retiro.

2. **Depositar ETH:**

   ```solidity
   depositar()
   ```

   Se debe enviar ETH al llamar a esta función.

3. **Retirar ETH:**

   ```solidity
   retirar(uint256 monto)
   ```

   Retira el monto solicitado siempre que esté bajo el umbral permitido.

4. **Consultar balance actual:**

   ```solidity
   verBalance() → uint256
   ```

5. **Ver historial de transacciones:**

   ```solidity
   verHistorial() → Transaccion[]
   ```

6. **Contadores de operaciones:**

   ```solidity
   obtenerContadores() → (uint256 depositos, uint256 retiros)
   ```

---

## Seguridad 🛡️

* Patrón **Checks-Effects-Interactions** aplicado
* Uso de `call{value: monto}` para manejar transferencias nativas
* Validación de condiciones con errores personalizados
* No uso de `require(string)` para mantener eficiencia de gas

---

## Autor

José Adrián Serrano Brenes

---

## Explorer

**Transacción**
https://sepolia.etherscan.io/tx/0x003a64cc9fffb9b43c75fddb7c0501d3e73b9bad1d8f06367f86ed645e989b56

**Contrato**
0xcc4fda4d5f43ab9b7298081f0e36137680849989

**Address**
https://sepolia.etherscan.io/address/0xcc4fda4d5f43ab9b7298081f0e36137680849989

---