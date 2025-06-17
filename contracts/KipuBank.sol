// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

/// @title KipuBank - Bóveda personal para depósitos y retiros de ETH
contract KipuBank {
    // ============ Tipos y Estructuras ============

    /// @notice Tipo de transacción: Depósito o Retiro
    enum TipoTransaccion {
        DEPOSITO,
        RETIRO
    }

    /// @notice Error personalizado para usuario no registrado
    error UsuarioNoRegistrado();
    error UsuarioYaExiste();
    error MontoInvalido();
    error ExcedeUmbralRetiro();
    error ExcedeBankCap();
    error FondosInsuficientes();
    error TransferenciaFallida();

    /// @notice Representa una transacción realizada por un usuario
    struct Transaccion {
        uint256 fecha;
        uint256 monto;
        TipoTransaccion tipoTransaccion;
    }

    /// @notice Representa un usuario registrado en el banco
    address public owner;

    struct Usuario {
        address wallet;
        uint256 balance;
        uint256 totalDepositos;
        uint256 totalRetiros;
        Transaccion[] historial;
        bool existe;
    }

    // ============ Variables de estado ============

    /// @notice Límite máximo por retiro (immutable)
    uint256 public immutable umbralRetiro;

    /// @notice Límite total de fondos que puede manejar el contrato
    uint256 public immutable bankCap;

    /// @notice Total depositado en el banco
    uint256 public totalDepositado;

    /// @notice Mapping de dirección => Usuario
    mapping(address => Usuario) private usuarios;

    // ============ Eventos ============

    /// @notice Emite cuando se realiza un depósito exitoso
    event Deposito(address indexed usuario, uint256 monto);

    /// @notice Emite cuando se realiza un retiro exitoso
    event Retiro(address indexed usuario, uint256 monto);

    // ============ Constructor ============

    /// @notice Constructor que define umbrales al desplegar
    constructor() payable {
        owner = msg.sender;
        umbralRetiro = 5 ether;
        bankCap = 1000 ether;
    }

    // ============ Modificadores ============

    modifier soloUsuarioRegistrado() {
        if (!usuarios[msg.sender].existe) revert UsuarioNoRegistrado();
        _;
    }

    modifier soloOwner() {
        require(msg.sender == owner, "Solo el owner puede realizar esta operacion");
        _;
    }

    // ============ Funciones ============

    /// @notice Registrar un nuevo usuario
    /// @dev No permite direcciones duplicadas
    function registrarUsuario() external {
        if (usuarios[msg.sender].existe) revert UsuarioYaExiste();
        usuarios[msg.sender].existe = true;
        usuarios[msg.sender].wallet = msg.sender;
    }

    /// @notice Realiza un depósito de ETH en la cuenta del usuario
    function depositar() external payable soloUsuarioRegistrado {
        if (msg.value == 0) revert MontoInvalido();
        if (totalDepositado + msg.value > bankCap) revert ExcedeBankCap();

        // Efectos
        Usuario storage u = usuarios[msg.sender];
        u.balance += msg.value;
        u.totalDepositos++;
        u.historial.push(Transaccion(block.timestamp, msg.value, TipoTransaccion.DEPOSITO));

        totalDepositado += msg.value;

        // Interacción
        emit Deposito(msg.sender, msg.value);
    }

    /// @notice Permite retirar ETH desde la bóveda personal
    /// @param monto Cantidad a retirar
    function retirar(uint256 monto) external soloUsuarioRegistrado {
        if (monto == 0) revert MontoInvalido();
        if (monto > umbralRetiro) revert ExcedeUmbralRetiro();

        Usuario storage u = usuarios[msg.sender];
        if (u.balance < monto) revert FondosInsuficientes();

        // Efectos
        u.balance -= monto;
        u.totalRetiros++;
        u.historial.push(Transaccion(block.timestamp, monto, TipoTransaccion.RETIRO));

        // Interacciones
        (bool exito, ) = payable(msg.sender).call{value: monto}("");
        if (!exito) revert TransferenciaFallida();

        emit Retiro(msg.sender, monto);
    }

    /// @notice Devuelve el balance actual del usuario
    function verBalance() external view soloUsuarioRegistrado returns (uint256) {
        return usuarios[msg.sender].balance;
    }

    /// @notice Devuelve el historial completo de transacciones del usuario
    function verHistorial() external view soloUsuarioRegistrado returns (Transaccion[] memory) {
        return usuarios[msg.sender].historial;
    }

    /// @notice Devuelve el número de depósitos y retiros del usuario
    function obtenerContadores() external view soloUsuarioRegistrado returns (uint256 depositos, uint256 retiros) {
        Usuario storage u = usuarios[msg.sender];
        return (u.totalDepositos, u.totalRetiros);
    }

    /// @notice Función privada de utilidad para verificar si el usuario existe
    function _esUsuario(address wallet) private view returns (bool) {
        return usuarios[wallet].existe;
    }
}
