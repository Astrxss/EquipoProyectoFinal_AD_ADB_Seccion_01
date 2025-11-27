/* ==========================================================================
   GESTIÓN DE RESERVAS DE UN GIMNASIO - - GYMDB
   PROYECTO DE CÁTEDRA 
   Estructura Completa, Optimizada y con Esquemas
   ==========================================================================
   Integrantes:
	- ANDREA PAMELA ALVAREZ LOPEZ - 00073824
	- WILBER STANLEY CALDERON SANCHEZ - 00042623
	- CESAR ALEJANDRO CHIQUILLO VIDES - 00225424
	- JULIO ALEJANDRO FLORES DIAZ - 00018824
	- RENE ALEJANDRO TREJO MORALES - 00360524
   ========================================================================== */

-- 1. CREACIÓN DE LA BASE DE DATOS
USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'GymDB')
BEGIN
    ALTER DATABASE GymDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE GymDB;
END
GO

CREATE DATABASE GymDB;
GO

USE GymDB;
GO

ALTER DATABASE GymDB SET RECOVERY FULL;
GO

-- 2. CREACIÓN DE ESQUEMAS (Punto vital de la rúbrica)
-- Organizamos las tablas lógicamente
GO
CREATE SCHEMA Membresia AUTHORIZATION dbo;
GO
CREATE SCHEMA RRHH AUTHORIZATION dbo;
GO
CREATE SCHEMA Ventas AUTHORIZATION dbo;
GO
CREATE SCHEMA Seguridad AUTHORIZATION dbo;
GO

-- 3. TABLAS DEL SISTEMA

-- [RRHH] Entrenadores
CREATE TABLE RRHH.Entrenador (
    EntrenadorID INT IDENTITY(1,1) PRIMARY KEY,
    Nombres VARCHAR(100) NOT NULL,
    Apellidos VARCHAR(100) NOT NULL,
    Telefono VARCHAR(20),
    Email VARCHAR(120) UNIQUE NOT NULL,
    Especialidad VARCHAR(100) NOT NULL,
    FechaContratacion DATE NOT NULL DEFAULT GETDATE()
);

-- [Membresia] Socios
CREATE TABLE Membresia.Socio (
    SocioID INT IDENTITY(1,1) PRIMARY KEY,
    Nombres VARCHAR(100) NOT NULL,
    Apellidos VARCHAR(100) NOT NULL,
    FechaNacimiento DATE NOT NULL,
    Telefono VARCHAR(20),
    Email VARCHAR(120) UNIQUE NOT NULL,
    FechaIngreso DATE NOT NULL DEFAULT GETDATE(),
    TipoMembresia VARCHAR(50) NOT NULL,
    Estado VARCHAR(20) NOT NULL DEFAULT 'Activo'
);

-- [Membresia] Clases
CREATE TABLE Membresia.Clase (
    ClaseID INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Descripcion VARCHAR(200),
    Capacidad INT NOT NULL,
    DuracionMinutos INT NOT NULL,
    Dificultad VARCHAR(50)
);

-- [Membresia] Horarios (Relaciona Clase y Entrenador)
CREATE TABLE Membresia.HorarioClase (
    HorarioID INT IDENTITY(1,1) PRIMARY KEY,
    ClaseID INT NOT NULL,
    EntrenadorID INT NOT NULL,
    FechaHoraInicio DATETIME2 NOT NULL,
    FechaHoraFin DATETIME2 NOT NULL,
    Ubicacion VARCHAR(100) NOT NULL,
    FOREIGN KEY (ClaseID) REFERENCES Membresia.Clase(ClaseID),
    FOREIGN KEY (EntrenadorID) REFERENCES RRHH.Entrenador(EntrenadorID)
);

-- [Membresia] Reservas
CREATE TABLE Membresia.Reserva (
    ReservaID INT IDENTITY(1,1) PRIMARY KEY,
    SocioID INT NOT NULL,
    HorarioID INT NOT NULL,
    FechaReserva DATETIME2 NOT NULL DEFAULT GETDATE(),
    Estado VARCHAR(20) NOT NULL DEFAULT 'Activa',
    FOREIGN KEY (SocioID) REFERENCES Membresia.Socio(SocioID),
    FOREIGN KEY (HorarioID) REFERENCES Membresia.HorarioClase(HorarioID)
);

-- [Ventas] Pagos de Membresía
CREATE TABLE Ventas.Pago (
    PagoID INT IDENTITY(1,1) PRIMARY KEY,
    SocioID INT NOT NULL,
    Monto DECIMAL(10,2) NOT NULL,
    Moneda VARCHAR(10) NOT NULL DEFAULT 'USD',
    FechaPago DATETIME2 NOT NULL DEFAULT GETDATE(),
    MetodoPago VARCHAR(50) NOT NULL,
    Referencia VARCHAR(100) NULL,
    CONSTRAINT FK_Pago_Socio FOREIGN KEY (SocioID) REFERENCES Membresia.Socio(SocioID)
);

-- [Ventas] Productos
CREATE TABLE Ventas.Producto (
    ProductoID INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Precio DECIMAL(10,2) NOT NULL,
    Stock INT NOT NULL,
    Categoria VARCHAR(100)
);

-- [Ventas] Cabecera de Venta
CREATE TABLE Ventas.Venta (
    VentaID INT IDENTITY(1,1) PRIMARY KEY,
    SocioID INT NULL,
    FechaVenta DATETIME2 NOT NULL DEFAULT GETDATE(),
    Total DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (SocioID) REFERENCES Membresia.Socio(SocioID)
);

-- [Ventas] Pagos de Venta (Productos)
CREATE TABLE Ventas.PagoVenta (
    PagoVentaID INT IDENTITY(1,1) PRIMARY KEY,
    VentaID INT NOT NULL,
    Monto DECIMAL(10,2) NOT NULL,
    MetodoPago VARCHAR(50) NOT NULL,
    FechaPago DATETIME2 NOT NULL DEFAULT GETDATE(),
    Referencia VARCHAR(100) NULL,
    CONSTRAINT FK_PagoVenta_Venta FOREIGN KEY (VentaID) REFERENCES Ventas.Venta(VentaID)
);

-- [Ventas] Detalle de Venta
CREATE TABLE Ventas.DetalleVenta (
    DetalleID INT IDENTITY(1,1) PRIMARY KEY,
    VentaID INT NOT NULL,
    ProductoID INT NOT NULL,
    Cantidad INT NOT NULL,
    PrecioUnitario DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (VentaID) REFERENCES Ventas.Venta(VentaID),
    FOREIGN KEY (ProductoID) REFERENCES Ventas.Producto(ProductoID)
);

-- [Seguridad] Tabla de Auditoría (Requisito Rúbrica)
CREATE TABLE Seguridad.Bitacora (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    FechaHora DATETIME DEFAULT GETDATE(),
    Usuario VARCHAR(100),
    Accion VARCHAR(50),
    TablaAfectada VARCHAR(50),
    Descripcion VARCHAR(MAX)
);

-- [Membresia] Tabla Temporal para Bulk Insert
CREATE TABLE Membresia.SocioTemporal (
    Nombres VARCHAR(100),
    Apellidos VARCHAR(100),
    FechaNacimiento DATE,
    Telefono VARCHAR(20),
    Email VARCHAR(120),
    TipoMembresia VARCHAR(50),
    Estado VARCHAR(20)
);
GO

-- 4. INSERCIÓN DE DATOS DE EJEMPLO (SEED DATA)

SELECT * FROM Membresia.Socio

-- Socios
INSERT INTO Membresia.Socio (Nombres, Apellidos, FechaNacimiento, Telefono, Email, TipoMembresia, Estado) VALUES
('Miguel', 'Francisco', '2000-01-09', '7045-9987', 'F_miguel@example.com', 'Premium', 'Inactivo'),
('Carlos', 'Hernandez', '1998-04-12', '7890-1111', 'carlos.h@example.com', 'Premium', 'Activo'),
('Ana', 'Martinez', '2000-02-01', '7777-2222', 'ana.m@example.com', 'Estandar', 'Activo'),
('Luis', 'Gomez', '1995-11-30', '7444-3333', 'luis.g@example.com', 'Premium', 'Activo'),
('Maria', 'Lopez', '1999-07-21', '7000-4444', 'maria.l@example.com', 'Basica', 'Activo'),
('Jose', 'Castro', '1990-01-09', '7011-5555', 'jose.c@example.com', 'Estandar', 'Inactivo'),
('Sofia', 'Diaz', '1997-05-18', '7022-6666', 'sofia.d@example.com', 'Premium', 'Activo'), 
('Andres', 'Vega', '1988-10-10', '7033-7777', 'andres.v@example.com', 'Estandar', 'Activo'), 
('Paula', 'Santos', '1996-03-03', '7044-8888', 'paula.s@example.com', 'Basica', 'Activo'), 
('Diego', 'Ramires', '1992-12-12', '7055-9999', 'diego.r@example.com', 'Premium', 'Activo'), 
('Laura', 'Molina', '1994-06-06', '7066-0000', 'laura.m@example.com', 'Estandar', 'Activo'); 
GO


-- Entrenadores
INSERT INTO RRHH.Entrenador (Nombres, Apellidos, Telefono, Email, Especialidad) VALUES
('David', 'Rojas', '7800-1000', 'david.r@example.com', 'CrossFit'),
('Karla', 'Ramirez', '7800-2000', 'karla.r@example.com', 'Yoga'),
('Miguel', 'Salinas', '7800-3000', 'miguel.s@example.com', 'Spinning');

-- Clases
INSERT INTO Membresia.Clase (Nombre, Descripcion, Capacidad, DuracionMinutos, Dificultad) VALUES
('CrossFit','Entrenamiento funcional intenso', 20, 60, 'Alta'),
('Yoga','Yoga relajante', 15, 50, 'Media'),
('Spinning','Bicicleta indoor', 25, 45, 'Alta');

-- Horarios
INSERT INTO Membresia.HorarioClase (ClaseID, EntrenadorID, FechaHoraInicio, FechaHoraFin, Ubicacion) VALUES
(1, 1, '2025-11-05 07:00', '2025-11-05 08:00', 'Salón A'),
(2, 2, '2025-11-05 09:00', '2025-11-05 09:50', 'Salón B'),
(3, 3, '2025-11-05 17:00', '2025-11-05 17:45', 'Salón C');

-- Reservas
INSERT INTO Membresia.Reserva (SocioID, HorarioID, FechaReserva, Estado) VALUES
(1, 1, GETDATE(), 'Activa'),
(2, 2, GETDATE(), 'Activa'),
(3, 3, GETDATE(), 'Activa');

insert into Membresia.Reserva (SocioID, HorarioID, FechaReserva , Estado) values (3, 1, '2025-10-21 05:57:42', 'Inactiva');
insert into Membresia.Reserva (SocioID, HorarioID, FechaReserva , Estado) values (1, 3, '2025-05-13 13:11:35', 'Inactiva');
insert into Membresia.Reserva (SocioID, HorarioID, FechaReserva , Estado) values (2, 2, '2025-04-09 12:29:03', 'Inactiva');
insert into Membresia.Reserva (SocioID, HorarioID, FechaReserva , Estado) values (10, 2, '2025-03-24 13:54:25', 'Inactiva');
insert into Membresia.Reserva (SocioID, HorarioID, FechaReserva , Estado) values (5, 3, '2025-07-09 06:45:03', 'Inactiva');
insert into Membresia.Reserva (SocioID, HorarioID, FechaReserva , Estado) values (7, 1, '2025-02-21 05:17:32', 'Inactiva');
insert into Membresia.Reserva (SocioID, HorarioID, FechaReserva , Estado) values (1, 1, '2025-09-27 21:26:21', 'Inactiva');
insert into Membresia.Reserva (SocioID, HorarioID, FechaReserva , Estado) values (6, 1, '2025-08-15 04:06:45', 'Inactiva');
insert into Membresia.Reserva (SocioID, HorarioID, FechaReserva , Estado) values (1, 3, '2025-04-15 23:13:01', 'Inactiva');
insert into Membresia.Reserva (SocioID, HorarioID, FechaReserva , Estado) values (1, 1, '2025-11-19 08:25:18', 'Activa');
insert into Membresia.Reserva (SocioID, HorarioID, FechaReserva , Estado) values (5, 1, '2025-11-02 11:56:38', 'Activa');
insert into Membresia.Reserva (SocioID, HorarioID, FechaReserva , Estado) values (2, 1, '2025-11-10 06:14:40', 'Activa');
insert into Membresia.Reserva (SocioID, HorarioID, FechaReserva , Estado) values (7, 1, '2025-11-15 11:04:06', 'Activa');
insert into Membresia.Reserva (SocioID, HorarioID, FechaReserva , Estado) values (4, 2, '2025-11-01 18:08:04', 'Activa');
insert into Membresia.Reserva (SocioID, HorarioID, FechaReserva , Estado) values (4, 3, '2025-11-05 15:29:46', 'Activa');
insert into Membresia.Reserva (SocioID, HorarioID, FechaReserva , Estado) values (9, 2, '2025-11-09 16:45:53', 'Activa');
insert into Membresia.Reserva (SocioID, HorarioID, FechaReserva , Estado) values (9, 1, '2025-11-20 23:52:25', 'Activa');
insert into Membresia.Reserva (SocioID, HorarioID, FechaReserva , Estado) values (10, 1, '2025-11-15 01:33:02', 'Activa');
insert into Membresia.Reserva (SocioID, HorarioID, FechaReserva , Estado) values (8, 1, '2025-11-15 19:20:42', 'Activa');
insert into Membresia.Reserva (SocioID, HorarioID, FechaReserva , Estado) values (10, 3, '2025-08-15 05:23:57', 'Activa');
insert into Membresia.Reserva (SocioID, HorarioID, FechaReserva , Estado) values (10, 2, '2025-08-19 12:02:23', 'Activa');
insert into Membresia.Reserva (SocioID, HorarioID, FechaReserva , Estado) values (6, 3, '2025-08-27 17:19:49', 'Activa');
insert into Membresia.Reserva (SocioID, HorarioID, FechaReserva , Estado) values (10, 2, '2025-01-30 22:44:46', 'Activa');
insert into Membresia.Reserva (SocioID, HorarioID, FechaReserva , Estado) values (8, 1, '2025-02-14 19:53:46', 'Activa');
insert into Membresia.Reserva (SocioID, HorarioID, FechaReserva , Estado) values (1, 2, '2025-02-10 09:05:32', 'Activa');
insert into Membresia.Reserva (SocioID, HorarioID, FechaReserva , Estado) values (1, 2, '2025-02-13 13:49:07', 'Activa');

-- Productos
INSERT INTO Ventas.Producto (Nombre, Precio, Stock, Categoria) VALUES
('Proteina 1kg', 25.00, 50, 'Suplemento'),
('Guantes Gym', 10.00, 30, 'Accesorio');

-- Ventas
INSERT INTO Ventas.Venta (SocioID, FechaVenta, Total) VALUES
(1, '2025-10-11 14:30', 35.00);

-- Detalle
INSERT INTO Ventas.DetalleVenta (VentaID, ProductoID, Cantidad, PrecioUnitario) VALUES
(1, 1, 1, 25.00), -- Proteina
(1, 2, 1, 10.00); -- Guantes

-- Pagos
INSERT INTO Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) VALUES
(1, 30.00, 'USD', '2025-10-01 10:00', 'Efectivo', 'EF123');

---Insercion masiva de datos
--TABLA  PAGO

insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 482.99, 'USD', '2025-11-01 22:52:07', 'Efectivo', 'F3Z70');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 199.9, 'USD', '2025-11-17 11:19:18', 'Efectivo', 'M8W61');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 406.53, 'USD', '2025-10-24 13:02:04', 'Efectivo', 'I7E52');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 174.83, 'USD', '2025-07-06 04:27:01', 'Efectivo', 'I0M89');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 682.94, 'USD', '2025-08-06 03:27:19', 'Efectivo', 'T0E01');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 581.65, 'USD', '2025-06-08 04:40:34', 'Efectivo', 'O3M48');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 154.96, 'USD', '2025-05-01 10:43:03', 'Efectivo', 'A6W13');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 212.29, 'USD', '2025-01-12 14:13:29', 'Efectivo', 'M2J00');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 771.44, 'USD', '2025-03-09 01:02:13', 'Efectivo', 'U7K85');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 517.74, 'USD', '2025-09-11 19:32:23', 'Efectivo', 'D6P52');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 875.24, 'USD', '2025-01-07 07:26:50', 'Efectivo', 'T4X96');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 641.54, 'USD', '2025-01-31 21:01:14', 'Efectivo', 'I6W34');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 373.61, 'USD', '2025-07-12 08:38:41', 'Efectivo', 'Q3Y55');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 919.34, 'USD', '2025-04-07 14:39:49', 'Efectivo', 'W3X39');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 769.98, 'USD', '2025-03-19 14:33:52', 'Efectivo', 'W4X32');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 77.61, 'USD', '2025-11-17 03:59:13', 'Efectivo', 'R1B85');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 983.22, 'USD', '2025-03-03 13:25:11', 'Efectivo', 'X5Q11');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 181.22, 'USD', '2025-08-22 13:44:19', 'Efectivo', 'S8Q42');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 977.28, 'USD', '2025-08-14 23:55:03', 'Efectivo', 'X9R76');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 283.34, 'USD', '2025-11-17 06:41:50', 'Efectivo', 'Z1T80');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 237.18, 'USD', '2025-11-11 06:47:35', 'Efectivo', 'O9Y25');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 177.01, 'USD', '2025-04-24 16:41:24', 'Efectivo', 'G2B61');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 324.3, 'USD', '2025-07-16 15:41:15', 'Efectivo', 'A9J10');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 891.42, 'USD', '2025-08-10 07:32:26', 'Efectivo', 'C0Y14');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 967.08, 'USD', '2025-03-28 18:29:36', 'Efectivo', 'F2X43');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 385.45, 'USD', '2025-01-04 18:22:30', 'Efectivo', 'U3A12');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 898.14, 'USD', '2025-11-10 23:05:17', 'Efectivo', 'A8Z23');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 456.16, 'USD', '2025-07-03 06:31:16', 'Efectivo', 'S2K76');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 669.65, 'USD', '2025-11-13 17:37:19', 'Efectivo', 'P2G39');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 83.96, 'USD', '2025-07-06 13:19:03', 'Efectivo', 'G5V21');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 972.87, 'USD', '2025-07-13 04:01:56', 'Efectivo', 'V0I88');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 929.33, 'USD', '2025-05-10 17:29:45', 'Efectivo', 'M1V02');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 264.94, 'USD', '2025-10-04 09:26:31', 'Efectivo', 'P9B90');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 551.82, 'USD', '2025-10-09 04:21:13', 'Efectivo', 'X0K33');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 480.55, 'USD', '2025-06-21 09:46:11', 'Efectivo', 'P3C51');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 325.08, 'USD', '2025-02-09 18:16:10', 'Efectivo', 'Y0E71');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 635.75, 'USD', '2025-05-06 22:42:44', 'Efectivo', 'G6A35');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 359.26, 'USD', '2025-09-09 10:57:04', 'Efectivo', 'X6V56');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 185.21, 'USD', '2025-08-06 17:35:22', 'Efectivo', 'A5U13');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 696.04, 'USD', '2025-11-01 15:36:40', 'Efectivo', 'K6U98');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 365.6, 'USD', '2025-03-27 00:52:00', 'Efectivo', 'Y9I71');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 804.41, 'USD', '2025-06-02 23:47:12', 'Efectivo', 'H7R54');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 361.91, 'USD', '2025-06-09 06:10:37', 'Efectivo', 'J6R35');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 246.48, 'USD', '2025-06-27 22:19:01', 'Efectivo', 'I5H36');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 810.89, 'USD', '2025-10-15 11:19:30', 'Efectivo', 'K3H40');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 243.49, 'USD', '2025-07-07 11:15:30', 'Efectivo', 'D5M05');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 59.39, 'USD', '2025-07-31 23:17:27', 'Efectivo', 'G5R20');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 16.1, 'USD', '2025-02-06 07:03:50', 'Efectivo', 'E0C40');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 966.17, 'USD', '2025-06-30 21:04:41', 'Efectivo', 'U3J72');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 163.54, 'USD', '2025-03-25 15:36:09', 'Efectivo', 'H9Q08');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 413.5, 'USD', '2025-05-06 10:02:46', 'Efectivo', 'R1B41');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 54.77, 'USD', '2025-07-14 16:16:10', 'Efectivo', 'Y9V80');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 494.65, 'USD', '2025-07-03 01:45:18', 'Efectivo', 'M5C51');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 635.7, 'USD', '2025-09-05 14:31:06', 'Efectivo', 'P1L97');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 864.8, 'USD', '2025-07-20 20:27:51', 'Efectivo', 'U3F08');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 941.08, 'USD', '2025-11-15 15:09:44', 'Efectivo', 'X3I11');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 243.77, 'USD', '2025-05-15 18:20:53', 'Efectivo', 'X4Z31');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 280.58, 'USD', '2025-09-15 18:21:46', 'Efectivo', 'N3X26');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 560.13, 'USD', '2025-11-05 17:22:26', 'Efectivo', 'Y4K70');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 907.68, 'USD', '2025-03-09 03:51:18', 'Efectivo', 'I9T74');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 263.35, 'USD', '2025-03-06 16:30:49', 'Efectivo', 'U9G11');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 532.4, 'USD', '2025-02-22 18:54:18', 'Efectivo', 'N5Q45');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 983.56, 'USD', '2025-03-04 00:10:59', 'Efectivo', 'R2V59');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 984.65, 'USD', '2025-05-14 18:22:37', 'Efectivo', 'J5E47');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 255.22, 'USD', '2025-11-09 21:37:58', 'Efectivo', 'X5G39');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 813.61, 'USD', '2025-03-31 02:39:03', 'Efectivo', 'K0N94');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 97.7, 'USD', '2025-03-12 22:22:47', 'Efectivo', 'Q7T90');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 202.89, 'USD', '2025-11-24 02:52:16', 'Efectivo', 'E1H75');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 505.69, 'USD', '2025-11-20 14:18:28', 'Efectivo', 'T7W50');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 190.5, 'USD', '2025-03-06 22:16:44', 'Efectivo', 'N6H87');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 540.19, 'USD', '2025-08-10 03:32:08', 'Efectivo', 'U4L09');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 416.51, 'USD', '2025-09-26 02:01:17', 'Efectivo', 'W7H09');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 762.17, 'USD', '2025-08-14 02:25:26', 'Efectivo', 'C1T26');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 478.62, 'USD', '2025-11-02 07:31:28', 'Efectivo', 'M6I07');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 968.3, 'USD', '2025-07-16 00:22:12', 'Efectivo', 'F8J68');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 447.08, 'USD', '2025-06-12 14:10:38', 'Efectivo', 'I3T15');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 430.02, 'USD', '2025-06-17 00:43:50', 'Efectivo', 'M7Q63');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 978.12, 'USD', '2025-02-06 23:05:40', 'Efectivo', 'K1R88');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 486.3, 'USD', '2025-03-08 00:34:37', 'Efectivo', 'G2M61');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 628.73, 'USD', '2025-01-26 03:10:57', 'Efectivo', 'L2G02');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 16.64, 'USD', '2025-09-16 09:48:09', 'Efectivo', 'H4Z28');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 733.86, 'USD', '2025-09-11 06:47:17', 'Efectivo', 'C1B73');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 389.08, 'USD', '2025-09-24 16:05:20', 'Efectivo', 'N4Z69');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 598.0, 'USD', '2025-05-03 13:31:11', 'Efectivo', 'G1O03');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 840.04, 'USD', '2025-11-08 16:43:53', 'Efectivo', 'G3V31');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 73.18, 'USD', '2025-04-17 05:22:02', 'Efectivo', 'Q4R23');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 492.42, 'USD', '2025-07-05 08:09:57', 'Efectivo', 'B6W60');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 403.6, 'USD', '2025-07-07 13:40:30', 'Efectivo', 'N5W78');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 638.59, 'USD', '2025-07-23 00:40:23', 'Efectivo', 'Q8J94');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 632.84, 'USD', '2025-09-10 18:19:45', 'Efectivo', 'R3W29');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 107.35, 'USD', '2025-03-23 08:56:50', 'Efectivo', 'M1B84');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 991.26, 'USD', '2025-04-27 11:20:48', 'Efectivo', 'Y6I77');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 112.87, 'USD', '2025-03-26 17:51:08', 'Efectivo', 'A9M43');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 526.99, 'USD', '2025-11-17 02:18:08', 'Efectivo', 'K2X48');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 521.63, 'USD', '2025-09-22 12:42:10', 'Efectivo', 'E0V31');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 957.36, 'USD', '2025-03-10 06:24:21', 'Efectivo', 'P2O71');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 402.5, 'USD', '2025-04-11 06:44:00', 'Efectivo', 'R6J39');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 607.43, 'USD', '2025-11-01 17:58:09', 'Efectivo', 'X6W64');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 715.58, 'USD', '2025-02-27 05:45:06', 'Efectivo', 'G0V01');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 914.5, 'USD', '2025-04-15 12:56:27', 'Efectivo', 'L1G46');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 92.5, 'USD', '2025-03-02 09:20:39', 'Efectivo', 'L1L58');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 200.98, 'USD', '2025-11-10 11:34:40', 'Efectivo', 'M6C61');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 680.76, 'USD', '2025-07-13 09:12:35', 'Efectivo', 'I2L39');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 482.63, 'USD', '2025-05-13 08:29:04', 'Efectivo', 'M5G66');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 73.66, 'USD', '2025-01-18 19:20:23', 'Efectivo', 'J3U52');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 727.06, 'USD', '2025-03-19 03:59:15', 'Efectivo', 'J9Y89');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 4.92, 'USD', '2025-03-03 13:48:36', 'Efectivo', 'G4P87');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 190.32, 'USD', '2025-04-25 00:37:35', 'Efectivo', 'E0J46');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 282.71, 'USD', '2025-02-07 04:51:34', 'Efectivo', 'I8L03');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 481.35, 'USD', '2025-08-14 05:25:24', 'Efectivo', 'W2Y31');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 493.48, 'USD', '2025-04-20 05:41:59', 'Efectivo', 'V9H45');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 633.79, 'USD', '2025-10-03 22:05:51', 'Efectivo', 'J9I96');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 82.39, 'USD', '2025-07-01 13:29:30', 'Efectivo', 'P0F19');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 17.48, 'USD', '2025-09-08 05:03:07', 'Efectivo', 'C4B16');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 88.4, 'USD', '2025-09-24 08:48:51', 'Efectivo', 'I4Z39');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 621.13, 'USD', '2025-10-30 02:34:22', 'Efectivo', 'P2M39');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 788.18, 'USD', '2025-02-26 20:02:13', 'Efectivo', 'D4D61');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 544.43, 'USD', '2025-05-21 06:47:24', 'Efectivo', 'H2Z11');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 24.93, 'USD', '2025-08-07 20:00:12', 'Efectivo', 'F7T44');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 870.39, 'USD', '2025-05-29 00:50:41', 'Efectivo', 'A0I38');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 802.26, 'USD', '2025-11-08 08:34:11', 'Efectivo', 'W7T51');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 685.61, 'USD', '2025-02-11 10:32:03', 'Efectivo', 'L2B42');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 47.07, 'USD', '2025-08-06 00:16:27', 'Efectivo', 'Y5K82');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 756.38, 'USD', '2025-04-12 19:01:24', 'Efectivo', 'G5P29');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 302.58, 'USD', '2025-01-28 19:14:45', 'Efectivo', 'X7F41');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 545.93, 'USD', '2025-09-26 19:37:59', 'Efectivo', 'C0P16');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 863.87, 'USD', '2025-02-27 10:56:53', 'Efectivo', 'Y7W81');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 714.43, 'USD', '2025-05-08 09:10:50', 'Efectivo', 'U1R88');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 348.2, 'USD', '2025-06-28 17:36:16', 'Efectivo', 'B6C84');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 207.65, 'USD', '2025-03-21 05:54:17', 'Efectivo', 'V7D82');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 329.7, 'USD', '2025-06-23 19:50:52', 'Efectivo', 'Q8Q41');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 901.22, 'USD', '2025-08-24 22:27:17', 'Efectivo', 'V4J80');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 583.09, 'USD', '2025-03-18 11:13:50', 'Efectivo', 'H2Z51');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 200.43, 'USD', '2025-11-12 04:46:51', 'Efectivo', 'E2O17');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 187.54, 'USD', '2025-06-03 03:14:33', 'Efectivo', 'V4M69');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 944.7, 'USD', '2025-07-03 03:45:57', 'Efectivo', 'D5S42');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 2.81, 'USD', '2025-06-24 12:35:08', 'Efectivo', 'Y4B58');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 991.1, 'USD', '2025-06-23 23:37:18', 'Efectivo', 'F9C60');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 382.86, 'USD', '2025-11-19 22:40:56', 'Efectivo', 'P7W60');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 368.54, 'USD', '2025-01-11 08:27:26', 'Efectivo', 'J0O48');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 318.63, 'USD', '2025-10-24 04:56:35', 'Efectivo', 'C4M96');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 876.18, 'USD', '2025-06-12 08:07:22', 'Efectivo', 'S9Y03');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 804.28, 'USD', '2025-07-14 17:35:10', 'Efectivo', 'A0N36');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 776.17, 'USD', '2025-01-22 00:42:04', 'Efectivo', 'O0C26');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 715.58, 'USD', '2025-03-09 15:11:28', 'Efectivo', 'Y9E76');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 666.01, 'USD', '2025-04-07 05:07:03', 'Efectivo', 'L0P64');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 555.78, 'USD', '2025-02-11 22:05:29', 'Efectivo', 'N6J33');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 262.67, 'USD', '2025-04-14 13:40:46', 'Efectivo', 'P1N16');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 981.93, 'USD', '2025-10-20 18:05:22', 'Efectivo', 'Y6X02');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 210.15, 'USD', '2025-03-22 06:51:33', 'Efectivo', 'A8B62');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 124.18, 'USD', '2025-09-25 20:49:01', 'Efectivo', 'Z1M80');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 51.57, 'USD', '2025-01-24 03:21:20', 'Efectivo', 'I5U95');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 109.58, 'USD', '2025-03-11 15:32:22', 'Efectivo', 'X3O89');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 252.64, 'USD', '2025-01-28 01:00:41', 'Efectivo', 'A5M27');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 807.18, 'USD', '2025-05-17 02:24:47', 'Efectivo', 'F6F25');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 614.81, 'USD', '2025-02-10 18:24:46', 'Efectivo', 'D0S77');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 76.66, 'USD', '2025-09-23 22:32:36', 'Efectivo', 'F1V33');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 497.7, 'USD', '2025-07-21 08:55:07', 'Efectivo', 'E2I50');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 797.41, 'USD', '2025-06-06 05:43:25', 'Efectivo', 'S6L47');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 736.85, 'USD', '2025-07-19 04:02:17', 'Efectivo', 'O4R85');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 185.83, 'USD', '2025-10-25 13:33:59', 'Efectivo', 'S0G90');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 394.02, 'USD', '2025-01-31 14:04:47', 'Efectivo', 'H9U36');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 54.14, 'USD', '2025-05-21 16:04:17', 'Efectivo', 'V7D60');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 187.14, 'USD', '2025-01-06 17:35:00', 'Efectivo', 'L8U44');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 62.16, 'USD', '2025-05-23 08:36:16', 'Efectivo', 'G6B78');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 18.41, 'USD', '2025-07-02 00:55:58', 'Efectivo', 'P6L02');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 846.5, 'USD', '2025-06-05 01:14:21', 'Efectivo', 'E3K01');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 403.09, 'USD', '2025-09-07 10:11:54', 'Efectivo', 'X2U22');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 78.96, 'USD', '2025-02-12 15:54:51', 'Efectivo', 'C1E89');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 770.17, 'USD', '2025-02-13 19:29:31', 'Efectivo', 'V9U73');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 828.01, 'USD', '2025-07-11 22:31:45', 'Efectivo', 'O1Z59');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 511.92, 'USD', '2025-06-07 15:42:31', 'Efectivo', 'C0O56');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 467.27, 'USD', '2025-02-07 12:24:54', 'Efectivo', 'F7A22');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 593.07, 'USD', '2025-07-18 08:30:05', 'Efectivo', 'G4P68');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 924.56, 'USD', '2025-06-02 17:00:34', 'Efectivo', 'K0H93');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 727.23, 'USD', '2025-08-17 20:04:24', 'Efectivo', 'M8H63');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 895.03, 'USD', '2025-07-07 07:22:09', 'Efectivo', 'L5K35');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 947.76, 'USD', '2025-05-23 13:24:19', 'Efectivo', 'Y5K32');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 973.34, 'USD', '2025-11-13 02:43:13', 'Efectivo', 'F9Q46');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 643.35, 'USD', '2025-06-21 04:34:01', 'Efectivo', 'E0S07');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 224.95, 'USD', '2025-01-25 18:46:26', 'Efectivo', 'W0D33');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 726.49, 'USD', '2025-03-22 12:44:54', 'Efectivo', 'S1R83');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 880.78, 'USD', '2025-06-09 14:13:45', 'Efectivo', 'B0V49');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 334.38, 'USD', '2025-10-13 22:59:58', 'Efectivo', 'D8R03');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 575.33, 'USD', '2025-08-01 04:33:20', 'Efectivo', 'C2A08');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 622.13, 'USD', '2025-08-16 03:04:11', 'Efectivo', 'P3J41');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 532.29, 'USD', '2025-08-31 01:51:51', 'Efectivo', 'Q2B75');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 215.89, 'USD', '2025-02-07 18:06:01', 'Efectivo', 'M3U33');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 745.55, 'USD', '2025-11-17 17:43:54', 'Efectivo', 'C7S33');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 732.14, 'USD', '2025-02-27 13:07:58', 'Efectivo', 'T1R32');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 218.01, 'USD', '2025-04-30 22:40:29', 'Efectivo', 'N8I08');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 57.19, 'USD', '2025-03-31 12:13:34', 'Efectivo', 'A3Q58');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 352.28, 'USD', '2025-09-11 21:20:36', 'Efectivo', 'L1E00');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 685.49, 'USD', '2025-03-24 05:01:13', 'Efectivo', 'U1H54');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 674.21, 'USD', '2025-10-07 00:35:54', 'Efectivo', 'Y9U44');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 341.74, 'USD', '2025-05-03 10:58:19', 'Efectivo', 'W2Q86');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 723.9, 'USD', '2025-08-24 08:12:42', 'Efectivo', 'L7L85');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 531.54, 'USD', '2025-07-21 16:09:11', 'Efectivo', 'L8O70');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 561.18, 'USD', '2025-02-17 16:11:48', 'Efectivo', 'A5F67');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 266.08, 'USD', '2025-03-28 14:41:20', 'Efectivo', 'T9U23');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 490.99, 'USD', '2025-08-17 02:53:08', 'Efectivo', 'E7X81');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 187.71, 'USD', '2025-04-14 08:32:47', 'Efectivo', 'O2Q98');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 941.72, 'USD', '2025-02-27 08:30:45', 'Efectivo', 'N9B57');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 255.32, 'USD', '2025-04-22 00:19:54', 'Efectivo', 'B2D61');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 753.24, 'USD', '2025-05-18 15:07:58', 'Efectivo', 'Z5P39');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 379.14, 'USD', '2025-07-31 21:14:40', 'Efectivo', 'F5R11');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 126.48, 'USD', '2025-06-10 11:09:22', 'Efectivo', 'Z5N29');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 886.14, 'USD', '2025-08-17 02:01:53', 'Efectivo', 'T7B69');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 495.76, 'USD', '2025-07-26 04:25:32', 'Efectivo', 'K4Q84');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 218.11, 'USD', '2025-06-03 19:45:48', 'Efectivo', 'O3W49');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 790.65, 'USD', '2025-09-06 06:08:14', 'Efectivo', 'J7H34');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 408.97, 'USD', '2025-08-23 03:51:12', 'Efectivo', 'K9G69');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 602.23, 'USD', '2025-03-10 07:10:43', 'Efectivo', 'J6R35');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 749.48, 'USD', '2025-06-20 20:34:26', 'Efectivo', 'L7M23');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 721.48, 'USD', '2025-05-11 23:33:23', 'Efectivo', 'M0I72');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 264.56, 'USD', '2025-10-29 09:03:45', 'Efectivo', 'R9O83');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 689.92, 'USD', '2025-03-29 21:52:17', 'Efectivo', 'C7Y89');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 6.25, 'USD', '2025-08-06 22:24:59', 'Efectivo', 'M2L27');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 687.82, 'USD', '2025-08-21 07:07:43', 'Efectivo', 'A1Q51');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 610.87, 'USD', '2025-08-01 08:48:33', 'Efectivo', 'P2C49');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 247.82, 'USD', '2025-06-13 11:17:22', 'Efectivo', 'W5Q04');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 695.64, 'USD', '2025-07-12 19:49:44', 'Efectivo', 'A5Q79');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 779.67, 'USD', '2025-11-11 05:48:04', 'Efectivo', 'M5P61');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 509.21, 'USD', '2025-02-08 11:35:18', 'Efectivo', 'C9Q90');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 508.46, 'USD', '2025-01-30 20:26:33', 'Efectivo', 'O9U83');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 218.55, 'USD', '2025-02-25 04:33:29', 'Efectivo', 'U9H60');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 816.31, 'USD', '2025-11-23 20:15:30', 'Efectivo', 'B6W82');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 670.77, 'USD', '2025-03-07 00:57:27', 'Efectivo', 'D3Q92');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 235.63, 'USD', '2025-01-26 15:29:46', 'Efectivo', 'F4D28');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 544.15, 'USD', '2025-11-26 06:16:16', 'Efectivo', 'E7K50');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 260.03, 'USD', '2025-01-23 02:46:36', 'Efectivo', 'F6P59');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 820.44, 'USD', '2025-01-13 21:25:23', 'Efectivo', 'H0X35');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 462.79, 'USD', '2025-01-04 20:53:06', 'Efectivo', 'N2H30');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 174.67, 'USD', '2025-02-27 07:01:38', 'Efectivo', 'F8C84');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 953.65, 'USD', '2025-07-17 03:54:36', 'Efectivo', 'R2V73');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 895.42, 'USD', '2025-10-03 05:25:24', 'Efectivo', 'D5N25');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 4.26, 'USD', '2025-05-19 11:30:37', 'Efectivo', 'J1V48');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 220.69, 'USD', '2025-02-10 16:47:41', 'Efectivo', 'Q1V73');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 815.23, 'USD', '2025-09-27 12:52:06', 'Efectivo', 'F7R97');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 696.74, 'USD', '2025-07-11 20:36:05', 'Efectivo', 'A8J29');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 745.46, 'USD', '2025-11-03 06:53:23', 'Efectivo', 'Y4J52');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 941.81, 'USD', '2025-10-31 21:46:00', 'Efectivo', 'C8I61');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 669.68, 'USD', '2025-05-08 07:51:33', 'Efectivo', 'U6B91');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 239.6, 'USD', '2025-04-02 14:06:02', 'Efectivo', 'W2F36');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 206.42, 'USD', '2025-04-09 10:43:22', 'Efectivo', 'P0E99');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 441.34, 'USD', '2025-03-08 14:45:50', 'Efectivo', 'K7B59');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 227.98, 'USD', '2025-11-18 22:43:58', 'Efectivo', 'F5F94');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 886.39, 'USD', '2025-10-26 15:28:30', 'Efectivo', 'X9L29');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 311.75, 'USD', '2025-07-31 22:27:05', 'Efectivo', 'X3P89');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 871.25, 'USD', '2025-06-30 12:10:57', 'Efectivo', 'O4W91');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 148.63, 'USD', '2025-07-25 13:10:49', 'Efectivo', 'Z0E09');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 791.21, 'USD', '2025-09-08 06:31:12', 'Efectivo', 'K2U52');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 39.23, 'USD', '2025-02-09 03:02:14', 'Efectivo', 'A6A80');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 986.1, 'USD', '2025-05-16 03:18:29', 'Efectivo', 'U6J67');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 257.73, 'USD', '2025-07-19 00:22:17', 'Efectivo', 'P0N17');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 605.04, 'USD', '2025-07-14 05:25:59', 'Efectivo', 'I0W04');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 564.38, 'USD', '2025-01-03 12:33:16', 'Efectivo', 'C6X49');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 233.64, 'USD', '2025-08-28 10:17:31', 'Efectivo', 'Z2F24');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 69.34, 'USD', '2025-07-27 17:17:30', 'Efectivo', 'A0C54');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 879.23, 'USD', '2025-06-29 18:37:27', 'Efectivo', 'Q8V39');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 733.69, 'USD', '2025-05-16 16:01:51', 'Efectivo', 'U1T57');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 982.77, 'USD', '2025-06-02 06:03:44', 'Efectivo', 'G8U20');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 58.89, 'USD', '2025-06-09 14:21:12', 'Efectivo', 'T9Q89');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 519.59, 'USD', '2025-05-23 18:06:11', 'Efectivo', 'I4X89');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 75.5, 'USD', '2025-05-31 11:34:16', 'Efectivo', 'O6W83');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 925.27, 'USD', '2025-06-30 16:40:13', 'Efectivo', 'N8Y66');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 768.97, 'USD', '2025-11-19 00:18:29', 'Efectivo', 'I1S42');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 659.62, 'USD', '2025-07-19 16:23:25', 'Efectivo', 'D3K34');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 654.12, 'USD', '2025-03-17 01:24:22', 'Efectivo', 'R9Z90');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 84.15, 'USD', '2025-06-22 20:29:14', 'Efectivo', 'D4Q30');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 172.05, 'USD', '2025-02-27 05:14:37', 'Efectivo', 'R3B94');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 222.33, 'USD', '2025-11-01 16:48:53', 'Efectivo', 'A4P11');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 6.86, 'USD', '2025-09-08 22:06:21', 'Efectivo', 'H4V08');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 60.24, 'USD', '2025-08-30 12:28:03', 'Efectivo', 'Z6Z94');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 549.86, 'USD', '2025-04-11 22:27:49', 'Efectivo', 'V5T62');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 748.17, 'USD', '2025-07-26 18:21:12', 'Efectivo', 'G8O58');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 276.25, 'USD', '2025-11-06 08:08:03', 'Efectivo', 'P9J25');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 142.21, 'USD', '2025-10-25 16:48:46', 'Efectivo', 'X1S93');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 816.24, 'USD', '2025-10-25 03:23:43', 'Efectivo', 'E4N27');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 917.79, 'USD', '2025-05-10 00:32:06', 'Efectivo', 'O6E55');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 182.12, 'USD', '2025-04-19 19:59:25', 'Efectivo', 'H6U52');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 519.16, 'USD', '2025-02-15 07:01:39', 'Efectivo', 'N5U62');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 513.67, 'USD', '2025-01-03 23:23:40', 'Efectivo', 'W5K36');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 387.28, 'USD', '2025-09-09 08:35:16', 'Efectivo', 'N8L30');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 981.09, 'USD', '2025-05-21 04:52:44', 'Efectivo', 'C7U36');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 708.41, 'USD', '2025-04-04 00:20:05', 'Efectivo', 'A7D83');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 109.84, 'USD', '2025-09-29 09:41:41', 'Efectivo', 'Y5Q16');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 275.61, 'USD', '2025-04-11 03:28:48', 'Efectivo', 'M5Q72');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 431.02, 'USD', '2025-08-09 10:38:07', 'Efectivo', 'T6Z94');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 562.85, 'USD', '2025-09-25 14:21:59', 'Efectivo', 'U5E93');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 606.29, 'USD', '2025-08-02 02:12:40', 'Efectivo', 'B2Z94');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 281.22, 'USD', '2025-10-04 16:55:16', 'Efectivo', 'W6E33');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 328.03, 'USD', '2025-01-31 15:31:45', 'Efectivo', 'E9A42');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 49.83, 'USD', '2025-10-19 09:21:04', 'Efectivo', 'J3M31');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 289.19, 'USD', '2025-08-21 18:22:10', 'Efectivo', 'S8A60');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 584.02, 'USD', '2025-02-21 17:23:12', 'Efectivo', 'A4G41');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 517.3, 'USD', '2025-04-11 01:08:20', 'Efectivo', 'T2R29');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 904.86, 'USD', '2025-10-11 01:01:24', 'Efectivo', 'P3F22');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 462.93, 'USD', '2025-03-08 00:58:28', 'Efectivo', 'M6I49');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 85.88, 'USD', '2025-11-22 07:27:20', 'Efectivo', 'E3H62');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 181.48, 'USD', '2025-03-06 18:41:57', 'Efectivo', 'X1L04');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 810.33, 'USD', '2025-04-14 18:12:36', 'Efectivo', 'P9T81');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 39.46, 'USD', '2025-05-02 15:44:33', 'Efectivo', 'F8D61');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 954.11, 'USD', '2025-01-24 16:23:16', 'Efectivo', 'M5K01');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 512.2, 'USD', '2025-04-03 04:05:13', 'Efectivo', 'B1H03');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 734.61, 'USD', '2025-09-07 10:36:59', 'Efectivo', 'O9B89');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 250.8, 'USD', '2025-06-25 03:12:45', 'Efectivo', 'S3V56');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 658.67, 'USD', '2025-09-18 20:13:14', 'Efectivo', 'V5R69');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 601.01, 'USD', '2025-07-05 19:25:04', 'Efectivo', 'K1V84');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 918.61, 'USD', '2025-11-13 14:16:09', 'Efectivo', 'I7V21');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 561.23, 'USD', '2025-03-26 19:07:45', 'Efectivo', 'F8L37');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 599.22, 'USD', '2025-06-11 18:55:53', 'Efectivo', 'A5N37');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 411.48, 'USD', '2025-07-30 00:05:44', 'Efectivo', 'D0P24');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 978.45, 'USD', '2025-04-19 16:42:06', 'Efectivo', 'C9N03');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 457.45, 'USD', '2025-08-25 23:40:06', 'Efectivo', 'B3N26');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 627.71, 'USD', '2025-04-15 08:04:20', 'Efectivo', 'E0N69');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 746.41, 'USD', '2025-08-04 21:50:10', 'Efectivo', 'W2I95');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 873.84, 'USD', '2025-07-13 13:48:47', 'Efectivo', 'R3I81');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 687.19, 'USD', '2025-10-15 13:32:20', 'Efectivo', 'T9M21');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 878.98, 'USD', '2025-09-24 22:42:55', 'Efectivo', 'F6O19');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 916.15, 'USD', '2025-05-28 17:09:17', 'Efectivo', 'K2K60');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 573.44, 'USD', '2025-04-26 04:16:42', 'Efectivo', 'F0H96');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 46.35, 'USD', '2025-07-14 05:37:09', 'Efectivo', 'R8U75');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 710.06, 'USD', '2025-11-26 04:55:02', 'Efectivo', 'H4T83');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 456.54, 'USD', '2025-11-14 17:01:27', 'Efectivo', 'Z1J22');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 471.54, 'USD', '2025-06-06 06:34:10', 'Efectivo', 'M6O16');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 453.89, 'USD', '2025-03-29 23:47:07', 'Efectivo', 'G5W86');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 227.76, 'USD', '2025-05-08 03:32:07', 'Efectivo', 'F1S15');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 62.07, 'USD', '2025-04-17 00:48:57', 'Efectivo', 'R6M30');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 681.16, 'USD', '2025-05-16 01:51:09', 'Efectivo', 'L6N79');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 20.68, 'USD', '2025-01-05 17:17:43', 'Efectivo', 'K1P37');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 888.46, 'USD', '2025-04-30 07:10:16', 'Efectivo', 'K2B15');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 526.25, 'USD', '2025-06-27 04:06:50', 'Efectivo', 'J9B90');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 2.75, 'USD', '2025-10-21 15:50:24', 'Efectivo', 'M3E87');

insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 755.7, 'USD', '2025-08-30 19:27:12', 'Transferencia', 'A0V38');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 214.23, 'USD', '2025-10-02 07:45:24', 'Transferencia', 'D7O42');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 429.39, 'USD', '2025-05-06 09:26:08', 'Transferencia', 'P6F29');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 326.92, 'USD', '2025-03-03 17:00:56', 'Transferencia', 'K1G94');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 423.43, 'USD', '2025-03-27 10:43:56', 'Transferencia', 'G9I73');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 204.17, 'USD', '2025-08-21 00:46:30', 'Transferencia', 'O6C97');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 283.82, 'USD', '2025-08-22 11:40:54', 'Transferencia', 'R1Y29');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 528.67, 'USD', '2025-10-16 11:29:34', 'Transferencia', 'M1Y44');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 816.68, 'USD', '2025-10-19 15:23:41', 'Transferencia', 'J5H20');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 807.09, 'USD', '2025-07-31 08:09:14', 'Transferencia', 'B6D56');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 575.84, 'USD', '2025-01-14 07:12:03', 'Transferencia', 'N0Y69');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 311.7, 'USD', '2025-07-07 08:11:41', 'Transferencia', 'S8A15');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 998.26, 'USD', '2025-07-30 22:57:44', 'Transferencia', 'S9X81');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 559.55, 'USD', '2025-06-25 07:08:24', 'Transferencia', 'V1H05');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 720.79, 'USD', '2025-05-20 17:53:21', 'Transferencia', 'O5T68');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 925.36, 'USD', '2025-02-24 08:58:07', 'Transferencia', 'F5F90');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 495.82, 'USD', '2025-11-17 08:33:10', 'Transferencia', 'P0P38');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 369.51, 'USD', '2025-04-07 02:04:52', 'Transferencia', 'H6F23');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 841.34, 'USD', '2025-04-19 13:49:26', 'Transferencia', 'D8V47');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 806.75, 'USD', '2025-06-28 18:24:55', 'Transferencia', 'R1R55');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 56.06, 'USD', '2025-11-17 12:43:47', 'Transferencia', 'N0F92');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 430.63, 'USD', '2025-10-11 13:14:11', 'Transferencia', 'T8C78');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 98.88, 'USD', '2025-03-15 20:06:25', 'Transferencia', 'B8M77');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 522.78, 'USD', '2025-06-02 17:25:34', 'Transferencia', 'P4F25');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 904.69, 'USD', '2025-11-12 17:30:11', 'Transferencia', 'S7H34');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 311.09, 'USD', '2025-04-22 08:23:04', 'Transferencia', 'M1Y08');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 887.42, 'USD', '2025-11-06 19:08:57', 'Transferencia', 'Q4B42');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 433.1, 'USD', '2025-04-05 04:32:43', 'Transferencia', 'G6I57');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 112.76, 'USD', '2025-09-15 08:26:38', 'Transferencia', 'P9K84');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 986.52, 'USD', '2025-02-10 08:32:59', 'Transferencia', 'A1P99');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 689.1, 'USD', '2025-02-02 16:19:22', 'Transferencia', 'R4Y01');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 37.02, 'USD', '2025-05-05 06:32:04', 'Transferencia', 'E2U75');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 496.37, 'USD', '2025-07-10 11:14:25', 'Transferencia', 'C9F83');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 451.28, 'USD', '2025-05-19 16:10:58', 'Transferencia', 'E1S12');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 198.21, 'USD', '2025-09-08 08:54:57', 'Transferencia', 'O4P40');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 484.63, 'USD', '2025-11-26 00:11:41', 'Transferencia', 'A8T60');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 860.25, 'USD', '2025-04-29 16:45:01', 'Transferencia', 'P1M14');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 442.1, 'USD', '2025-07-31 20:46:22', 'Transferencia', 'Z8K87');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 931.42, 'USD', '2025-04-30 13:22:37', 'Transferencia', 'X1F27');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 238.2, 'USD', '2025-07-25 09:40:13', 'Transferencia', 'W9Y41');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 125.96, 'USD', '2025-07-22 06:40:19', 'Transferencia', 'T2Y29');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 275.12, 'USD', '2025-08-29 22:35:07', 'Transferencia', 'L2G26');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 150.46, 'USD', '2025-07-06 15:24:18', 'Transferencia', 'G0M72');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 174.43, 'USD', '2025-05-14 19:20:42', 'Transferencia', 'H1V77');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 612.09, 'USD', '2025-06-28 03:29:38', 'Transferencia', 'C7L95');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 411.21, 'USD', '2025-06-07 21:53:46', 'Transferencia', 'P8X31');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 433.67, 'USD', '2025-03-19 17:50:02', 'Transferencia', 'T0X74');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 737.46, 'USD', '2025-05-22 06:46:50', 'Transferencia', 'R0A54');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 553.24, 'USD', '2025-05-11 06:24:53', 'Transferencia', 'J9S74');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 661.33, 'USD', '2025-06-27 03:14:16', 'Transferencia', 'X5Z73');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 161.38, 'USD', '2025-07-14 22:02:09', 'Transferencia', 'X8Z18');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 189.82, 'USD', '2025-01-30 18:59:32', 'Transferencia', 'G4M59');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 715.78, 'USD', '2025-07-04 22:42:27', 'Transferencia', 'X3A12');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 649.58, 'USD', '2025-10-29 11:01:42', 'Transferencia', 'N9H27');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 202.02, 'USD', '2025-01-09 14:59:18', 'Transferencia', 'K1I87');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 168.33, 'USD', '2025-05-04 04:18:02', 'Transferencia', 'P9N70');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 145.49, 'USD', '2025-06-26 19:40:05', 'Transferencia', 'F4C78');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 508.25, 'USD', '2025-03-27 19:14:43', 'Transferencia', 'I8H99');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 35.29, 'USD', '2025-07-07 20:36:45', 'Transferencia', 'O2T55');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 260.71, 'USD', '2025-01-08 12:39:46', 'Transferencia', 'F1O66');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 157.1, 'USD', '2025-08-29 09:53:18', 'Transferencia', 'G0E33');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 110.94, 'USD', '2025-06-03 01:28:48', 'Transferencia', 'W6A73');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 268.98, 'USD', '2025-03-16 17:51:46', 'Transferencia', 'K0W85');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 444.32, 'USD', '2025-01-01 07:01:38', 'Transferencia', 'P9R33');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 477.7, 'USD', '2025-04-06 12:28:50', 'Transferencia', 'M2E36');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 831.47, 'USD', '2025-10-24 15:07:26', 'Transferencia', 'R3O60');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 425.41, 'USD', '2025-05-27 02:11:02', 'Transferencia', 'X4Q55');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 15.89, 'USD', '2025-08-10 19:21:17', 'Transferencia', 'S4D74');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 831.0, 'USD', '2025-08-07 03:35:49', 'Transferencia', 'B7L79');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 314.52, 'USD', '2025-02-28 18:25:30', 'Transferencia', 'H3P41');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 219.33, 'USD', '2025-06-20 11:57:30', 'Transferencia', 'W8W90');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 917.91, 'USD', '2025-07-02 02:16:32', 'Transferencia', 'A4A23');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 72.87, 'USD', '2025-11-14 11:58:14', 'Transferencia', 'W7Y72');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 179.12, 'USD', '2025-02-08 15:39:53', 'Transferencia', 'L6U05');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 189.48, 'USD', '2025-01-26 03:16:50', 'Transferencia', 'M2G96');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 431.75, 'USD', '2025-04-01 03:49:03', 'Transferencia', 'G4S00');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 20.61, 'USD', '2025-04-16 09:26:53', 'Transferencia', 'I0J85');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 699.95, 'USD', '2025-09-22 11:13:47', 'Transferencia', 'X2N25');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 737.28, 'USD', '2025-02-12 09:46:36', 'Transferencia', 'T0N15');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 806.26, 'USD', '2025-03-09 14:28:59', 'Transferencia', 'M2I39');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 213.18, 'USD', '2025-06-02 07:21:48', 'Transferencia', 'T9U88');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 221.37, 'USD', '2025-10-30 12:05:22', 'Transferencia', 'Z2Z18');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 841.58, 'USD', '2025-05-11 04:08:26', 'Transferencia', 'Q4X50');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 333.59, 'USD', '2025-03-09 09:41:02', 'Transferencia', 'X6M29');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 1.77, 'USD', '2025-08-05 02:29:23', 'Transferencia', 'I3G87');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 54.63, 'USD', '2025-07-20 16:56:01', 'Transferencia', 'W9C89');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 293.13, 'USD', '2025-02-11 11:25:29', 'Transferencia', 'I7L14');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 365.77, 'USD', '2025-10-15 03:53:45', 'Transferencia', 'D1W08');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 533.33, 'USD', '2025-09-10 00:17:40', 'Transferencia', 'V5T64');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 472.74, 'USD', '2025-03-27 06:17:59', 'Transferencia', 'P4B97');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 5.94, 'USD', '2025-03-16 03:09:17', 'Transferencia', 'M0S04');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 696.48, 'USD', '2025-10-29 02:12:14', 'Transferencia', 'Y1I29');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 770.37, 'USD', '2025-04-28 21:16:48', 'Transferencia', 'B7Y69');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 772.79, 'USD', '2025-10-04 15:00:29', 'Transferencia', 'O8O84');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 908.39, 'USD', '2025-06-14 20:09:11', 'Transferencia', 'I0W58');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 271.58, 'USD', '2025-10-31 12:48:50', 'Transferencia', 'Y7A43');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 130.12, 'USD', '2025-10-15 16:15:58', 'Transferencia', 'L1R80');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 569.68, 'USD', '2025-08-28 01:26:32', 'Transferencia', 'E9G32');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 55.52, 'USD', '2025-04-08 02:04:58', 'Transferencia', 'O6T52');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 379.84, 'USD', '2025-08-16 06:35:52', 'Transferencia', 'D9Z80');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 18.13, 'USD', '2025-11-11 22:23:25', 'Transferencia', 'F3T06');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 4.27, 'USD', '2025-10-02 18:09:32', 'Transferencia', 'B4N17');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 167.48, 'USD', '2025-11-21 01:59:30', 'Transferencia', 'S8T90');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 526.7, 'USD', '2025-06-22 10:21:48', 'Transferencia', 'X8Y08');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 512.77, 'USD', '2025-07-08 16:06:21', 'Transferencia', 'Z5U99');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 602.4, 'USD', '2025-01-28 08:21:58', 'Transferencia', 'L3S74');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 174.26, 'USD', '2025-02-26 05:26:00', 'Transferencia', 'W1N61');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 146.37, 'USD', '2025-03-14 05:17:43', 'Transferencia', 'E8I17');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 415.66, 'USD', '2025-04-12 03:15:06', 'Transferencia', 'Q7U60');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 332.33, 'USD', '2025-07-29 03:13:56', 'Transferencia', 'D2V91');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 950.25, 'USD', '2025-09-27 07:10:42', 'Transferencia', 'L0L91');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 580.6, 'USD', '2025-11-12 22:03:03', 'Transferencia', 'X8O11');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 842.15, 'USD', '2025-01-10 12:20:00', 'Transferencia', 'S3W60');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 850.76, 'USD', '2025-04-30 08:41:33', 'Transferencia', 'V2Z92');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 940.62, 'USD', '2025-03-01 12:54:59', 'Transferencia', 'W1Y11');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 165.21, 'USD', '2025-09-17 16:35:24', 'Transferencia', 'D8X60');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 905.62, 'USD', '2025-05-30 15:12:20', 'Transferencia', 'D6G18');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 193.93, 'USD', '2025-05-04 11:30:02', 'Transferencia', 'B3D70');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 455.8, 'USD', '2025-04-21 10:47:46', 'Transferencia', 'F3M75');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 824.14, 'USD', '2025-06-24 05:39:53', 'Transferencia', 'E4Z00');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 26.22, 'USD', '2025-07-28 01:58:57', 'Transferencia', 'S8G46');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 804.02, 'USD', '2025-04-20 06:32:57', 'Transferencia', 'L1V38');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 756.48, 'USD', '2025-08-30 02:02:27', 'Transferencia', 'W2D63');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 2.78, 'USD', '2025-07-03 06:52:50', 'Transferencia', 'Q3U24');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 4.49, 'USD', '2025-01-26 20:22:15', 'Transferencia', 'G3Q66');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 479.87, 'USD', '2025-08-12 19:33:36', 'Transferencia', 'Q7B14');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 547.26, 'USD', '2025-06-10 03:56:35', 'Transferencia', 'N2T12');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 210.51, 'USD', '2025-03-10 11:17:31', 'Transferencia', 'J9Q40');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 9.85, 'USD', '2025-04-09 02:44:16', 'Transferencia', 'N6P36');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 54.07, 'USD', '2025-05-08 16:02:05', 'Transferencia', 'Y4I14');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 288.39, 'USD', '2025-01-25 10:10:11', 'Transferencia', 'G5S05');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 199.57, 'USD', '2025-07-06 06:34:03', 'Transferencia', 'W7W19');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 473.72, 'USD', '2025-02-06 11:22:41', 'Transferencia', 'I1B31');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 298.37, 'USD', '2025-04-09 23:36:19', 'Transferencia', 'V5H05');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 580.11, 'USD', '2025-10-26 03:11:24', 'Transferencia', 'O0Q08');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 3.31, 'USD', '2025-06-20 04:30:05', 'Transferencia', 'X5E80');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 748.79, 'USD', '2025-07-05 13:40:16', 'Transferencia', 'T1X46');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 486.97, 'USD', '2025-07-11 09:09:58', 'Transferencia', 'D1U73');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 51.19, 'USD', '2025-05-02 23:39:53', 'Transferencia', 'E1E73');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 909.34, 'USD', '2025-08-08 14:17:28', 'Transferencia', 'F3Z22');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 32.6, 'USD', '2025-01-28 03:42:21', 'Transferencia', 'V5Y40');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 792.57, 'USD', '2025-10-09 13:02:56', 'Transferencia', 'B1D69');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 685.47, 'USD', '2025-07-02 22:19:29', 'Transferencia', 'A6U98');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 488.61, 'USD', '2025-04-26 17:20:26', 'Transferencia', 'S7F51');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 670.38, 'USD', '2025-05-09 03:10:39', 'Transferencia', 'X1S23');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 464.56, 'USD', '2025-05-23 01:41:48', 'Transferencia', 'F8Z64');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 969.51, 'USD', '2025-06-22 12:57:20', 'Transferencia', 'R1A33');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 165.56, 'USD', '2025-02-27 14:36:23', 'Transferencia', 'T1W39');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 241.17, 'USD', '2025-08-20 04:50:25', 'Transferencia', 'X8U03');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 695.92, 'USD', '2025-06-05 23:06:16', 'Transferencia', 'R5H89');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 823.9, 'USD', '2025-07-12 07:35:47', 'Transferencia', 'N6N13');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 311.86, 'USD', '2025-09-28 22:08:58', 'Transferencia', 'V3T10');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 908.66, 'USD', '2025-03-21 22:08:02', 'Transferencia', 'M8U58');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 814.71, 'USD', '2025-10-10 07:03:55', 'Transferencia', 'O9F97');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 322.67, 'USD', '2025-01-24 20:37:10', 'Transferencia', 'P4P90');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 283.09, 'USD', '2025-01-15 16:58:48', 'Transferencia', 'X8C27');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 327.1, 'USD', '2025-03-02 23:52:32', 'Transferencia', 'A8B46');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 42.33, 'USD', '2025-10-21 23:27:35', 'Transferencia', 'S5Z61');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 657.06, 'USD', '2025-06-20 02:39:32', 'Transferencia', 'L4K72');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 500.02, 'USD', '2025-01-20 11:28:32', 'Transferencia', 'K8W82');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 604.75, 'USD', '2025-04-23 19:35:23', 'Transferencia', 'Q2D86');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 408.82, 'USD', '2025-04-07 20:14:36', 'Transferencia', 'H4V27');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 600.73, 'USD', '2025-07-16 19:46:40', 'Transferencia', 'Q6W25');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 403.2, 'USD', '2025-06-27 11:56:45', 'Transferencia', 'D5K77');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 35.06, 'USD', '2025-09-16 03:06:19', 'Transferencia', 'T8M40');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 390.3, 'USD', '2025-02-24 05:04:28', 'Transferencia', 'X0J82');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 624.19, 'USD', '2025-09-12 14:41:17', 'Transferencia', 'F6J88');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 788.9, 'USD', '2025-04-24 13:58:48', 'Transferencia', 'I8T59');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 156.88, 'USD', '2025-07-15 03:57:00', 'Transferencia', 'E5E79');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 395.36, 'USD', '2025-10-22 16:38:20', 'Transferencia', 'X5J40');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 556.16, 'USD', '2025-10-22 09:52:37', 'Transferencia', 'P1G97');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 387.96, 'USD', '2025-07-29 10:13:25', 'Transferencia', 'N5J28');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 683.91, 'USD', '2025-10-25 04:48:44', 'Transferencia', 'D8T73');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 183.92, 'USD', '2025-04-30 05:43:45', 'Transferencia', 'W6S86');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 951.33, 'USD', '2025-01-31 18:56:13', 'Transferencia', 'U7A09');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 657.61, 'USD', '2025-05-10 06:18:14', 'Transferencia', 'G9F98');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 304.36, 'USD', '2025-07-11 07:06:18', 'Transferencia', 'D6Y76');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 972.81, 'USD', '2025-09-14 14:08:51', 'Transferencia', 'S8H25');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 873.06, 'USD', '2025-03-20 19:02:15', 'Transferencia', 'D0E05');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 105.91, 'USD', '2025-01-18 01:57:44', 'Transferencia', 'T6H42');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 402.95, 'USD', '2025-07-10 19:20:05', 'Transferencia', 'D8G52');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 782.88, 'USD', '2025-09-20 02:56:49', 'Transferencia', 'C6N57');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 915.85, 'USD', '2025-03-10 10:53:16', 'Transferencia', 'F3W29');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 632.14, 'USD', '2025-08-06 07:36:50', 'Transferencia', 'L9I98');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 447.38, 'USD', '2025-10-23 02:27:54', 'Transferencia', 'V3D13');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 51.1, 'USD', '2025-10-06 04:51:30', 'Transferencia', 'C4M92');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 892.54, 'USD', '2025-04-30 22:46:47', 'Transferencia', 'B5J21');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 197.71, 'USD', '2025-04-09 16:30:54', 'Transferencia', 'S3S08');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 97.21, 'USD', '2025-09-19 11:50:40', 'Transferencia', 'F9X70');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 208.68, 'USD', '2025-07-24 08:23:51', 'Transferencia', 'D7T38');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 423.1, 'USD', '2025-06-17 03:54:11', 'Transferencia', 'O0W29');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 597.48, 'USD', '2025-11-19 21:37:46', 'Transferencia', 'D3A00');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 882.81, 'USD', '2025-10-05 19:57:00', 'Transferencia', 'U3O88');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 343.37, 'USD', '2025-03-13 14:26:51', 'Transferencia', 'T9B47');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 298.29, 'USD', '2025-01-16 16:45:46', 'Transferencia', 'G1G80');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 146.87, 'USD', '2025-03-10 21:34:23', 'Transferencia', 'S3M75');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 946.61, 'USD', '2025-06-04 08:51:25', 'Transferencia', 'W4V34');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 425.26, 'USD', '2025-06-11 09:58:57', 'Transferencia', 'L4L58');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 696.07, 'USD', '2025-02-01 22:00:56', 'Transferencia', 'N3H94');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 131.99, 'USD', '2025-11-19 20:37:13', 'Transferencia', 'L9A56');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 71.84, 'USD', '2025-10-05 18:12:46', 'Transferencia', 'S5K10');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 0.39, 'USD', '2025-08-04 05:17:34', 'Transferencia', 'T1A15');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 812.17, 'USD', '2025-10-22 12:21:06', 'Transferencia', 'G8Z91');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 366.9, 'USD', '2025-04-07 17:34:08', 'Transferencia', 'I4L84');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 92.33, 'USD', '2025-08-21 05:52:51', 'Transferencia', 'W5R89');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 846.88, 'USD', '2025-09-01 04:14:43', 'Transferencia', 'I9T56');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 768.43, 'USD', '2025-04-13 06:00:34', 'Transferencia', 'Z1F10');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 533.82, 'USD', '2025-10-02 10:26:42', 'Transferencia', 'J1G45');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 32.34, 'USD', '2025-09-05 10:04:48', 'Transferencia', 'C0P37');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 210.66, 'USD', '2025-05-24 08:51:32', 'Transferencia', 'T4J37');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 136.19, 'USD', '2025-02-20 18:24:41', 'Transferencia', 'N7D56');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 882.43, 'USD', '2025-02-28 08:46:38', 'Transferencia', 'N5A13');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 540.47, 'USD', '2025-11-05 12:44:50', 'Transferencia', 'H4Z52');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 754.68, 'USD', '2025-06-05 08:18:14', 'Transferencia', 'P6X58');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 29.37, 'USD', '2025-09-18 16:33:22', 'Transferencia', 'Q6P65');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 558.04, 'USD', '2025-06-20 20:50:45', 'Transferencia', 'O5C90');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 199.32, 'USD', '2025-05-26 19:20:28', 'Transferencia', 'U3N43');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 582.48, 'USD', '2025-02-14 00:14:05', 'Transferencia', 'M8B64');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 141.1, 'USD', '2025-03-27 07:55:52', 'Transferencia', 'N2G74');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 288.12, 'USD', '2025-01-09 21:53:32', 'Transferencia', 'D9G03');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 21.6, 'USD', '2025-03-07 23:09:47', 'Transferencia', 'O4I64');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 436.26, 'USD', '2025-06-08 17:35:36', 'Transferencia', 'R7Z24');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 980.54, 'USD', '2025-10-22 07:41:51', 'Transferencia', 'R7X42');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 304.84, 'USD', '2025-01-21 08:47:30', 'Transferencia', 'V7W44');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 43.03, 'USD', '2025-03-04 06:31:22', 'Transferencia', 'M9P40');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 56.23, 'USD', '2025-03-04 04:54:11', 'Transferencia', 'Q9R52');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 310.62, 'USD', '2025-09-22 16:14:34', 'Transferencia', 'M6G88');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 804.06, 'USD', '2025-10-29 17:13:42', 'Transferencia', 'T0K91');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 189.57, 'USD', '2025-10-25 02:20:13', 'Transferencia', 'I5P34');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 965.66, 'USD', '2025-04-22 06:43:10', 'Transferencia', 'O0R36');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 610.3, 'USD', '2025-02-02 02:02:39', 'Transferencia', 'X1J94');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 137.04, 'USD', '2025-09-11 03:42:47', 'Transferencia', 'Y4R47');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 706.82, 'USD', '2025-06-14 17:25:42', 'Transferencia', 'R9L78');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 590.14, 'USD', '2025-10-17 04:40:12', 'Transferencia', 'O1H37');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 977.35, 'USD', '2025-04-18 16:30:18', 'Transferencia', 'M5C27');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 873.94, 'USD', '2025-11-03 21:42:58', 'Transferencia', 'B9B19');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 401.57, 'USD', '2025-05-25 11:40:34', 'Transferencia', 'J6J21');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 66.96, 'USD', '2025-06-09 07:40:34', 'Transferencia', 'F9W56');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 101.43, 'USD', '2025-03-01 06:09:58', 'Transferencia', 'F1Y23');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 128.27, 'USD', '2025-10-20 04:10:41', 'Transferencia', 'J8K02');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 104.6, 'USD', '2025-08-21 19:40:44', 'Transferencia', 'D6T68');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 901.0, 'USD', '2025-03-30 17:25:38', 'Transferencia', 'Q7E02');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 900.68, 'USD', '2025-03-08 02:51:49', 'Transferencia', 'H6Y28');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 51.31, 'USD', '2025-05-23 10:48:44', 'Transferencia', 'T4M38');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 717.9, 'USD', '2025-02-26 22:20:39', 'Transferencia', 'L7S98');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 651.93, 'USD', '2025-07-03 07:17:36', 'Transferencia', 'B8X06');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 641.45, 'USD', '2025-03-05 00:11:47', 'Transferencia', 'Q7S34');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 831.43, 'USD', '2025-01-01 23:29:44', 'Transferencia', 'G6X57');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 104.21, 'USD', '2025-03-27 14:01:59', 'Transferencia', 'J5P51');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 498.98, 'USD', '2025-11-03 23:37:39', 'Transferencia', 'B5Y72');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 918.25, 'USD', '2025-11-18 01:09:38', 'Transferencia', 'W1E92');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 395.42, 'USD', '2025-09-25 16:19:48', 'Transferencia', 'L3P90');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 463.83, 'USD', '2025-05-03 11:50:59', 'Transferencia', 'A9A25');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 381.37, 'USD', '2025-05-13 22:01:35', 'Transferencia', 'D9N57');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 49.76, 'USD', '2025-10-10 20:49:04', 'Transferencia', 'E8T94');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 634.88, 'USD', '2025-04-11 11:11:21', 'Transferencia', 'X3L07');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 842.19, 'USD', '2025-08-22 16:58:14', 'Transferencia', 'K1Y50');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 928.03, 'USD', '2025-09-19 00:16:38', 'Transferencia', 'R4Z08');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 723.22, 'USD', '2025-04-20 23:08:33', 'Transferencia', 'W5U29');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 704.65, 'USD', '2025-11-07 03:41:31', 'Transferencia', 'Q1L97');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 418.28, 'USD', '2025-09-30 13:21:29', 'Transferencia', 'V7X01');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 453.7, 'USD', '2025-03-11 14:50:48', 'Transferencia', 'Z4T48');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 284.63, 'USD', '2025-11-25 15:33:55', 'Transferencia', 'G6F12');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 296.81, 'USD', '2025-05-01 16:38:30', 'Transferencia', 'S8C56');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 642.37, 'USD', '2025-10-04 00:29:39', 'Transferencia', 'U7H55');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 86.25, 'USD', '2025-11-21 00:03:33', 'Transferencia', 'F0A13');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 865.78, 'USD', '2025-09-21 00:30:46', 'Transferencia', 'C9K82');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 865.66, 'USD', '2025-05-29 22:08:15', 'Transferencia', 'G3A65');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 788.6, 'USD', '2025-02-24 23:25:27', 'Transferencia', 'A2L09');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 130.72, 'USD', '2025-04-05 05:28:21', 'Transferencia', 'D7D40');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 184.38, 'USD', '2025-02-02 10:10:01', 'Transferencia', 'D4J98');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 189.58, 'USD', '2025-04-27 06:03:55', 'Transferencia', 'E5I18');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 139.02, 'USD', '2025-02-25 00:01:27', 'Transferencia', 'N6E46');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 520.56, 'USD', '2025-05-21 18:32:44', 'Transferencia', 'F2A22');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 535.36, 'USD', '2025-05-30 10:18:37', 'Transferencia', 'C8Z08');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 349.51, 'USD', '2025-10-27 14:38:14', 'Transferencia', 'F3Q85');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 271.2, 'USD', '2025-07-25 22:03:15', 'Transferencia', 'W1H42');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 197.0, 'USD', '2025-02-23 19:23:08', 'Transferencia', 'V2W03');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 244.2, 'USD', '2025-10-16 21:06:49', 'Transferencia', 'Z1V72');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 916.25, 'USD', '2025-08-20 14:25:29', 'Transferencia', 'W2Q95');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 985.27, 'USD', '2025-08-20 08:40:43', 'Transferencia', 'C9Z24');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 943.28, 'USD', '2025-03-15 02:24:51', 'Transferencia', 'A8E75');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 568.75, 'USD', '2025-08-28 00:58:16', 'Transferencia', 'N8V73');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 396.36, 'USD', '2025-04-27 22:39:35', 'Transferencia', 'W9L98');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 312.74, 'USD', '2025-10-10 14:33:08', 'Transferencia', 'X0Z48');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 76.77, 'USD', '2025-03-28 06:31:12', 'Transferencia', 'C9K75');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 468.63, 'USD', '2025-06-19 14:21:47', 'Transferencia', 'A4N27');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 395.61, 'USD', '2025-05-12 03:01:38', 'Transferencia', 'I5T73');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 575.91, 'USD', '2025-06-16 16:33:47', 'Transferencia', 'R6Q83');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 584.48, 'USD', '2025-03-22 05:38:12', 'Transferencia', 'G2W84');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 947.68, 'USD', '2025-04-23 02:08:39', 'Transferencia', 'N3K77');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 742.32, 'USD', '2025-02-19 22:04:39', 'Transferencia', 'V0C77');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 768.96, 'USD', '2025-01-07 17:25:10', 'Transferencia', 'H2V05');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 393.92, 'USD', '2025-07-21 00:08:02', 'Transferencia', 'C5M85');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 150.14, 'USD', '2025-01-29 04:57:44', 'Transferencia', 'Z4D25');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 591.56, 'USD', '2025-01-24 22:07:13', 'Transferencia', 'U8A08');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 291.09, 'USD', '2025-11-19 20:44:26', 'Transferencia', 'D1X82');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 544.65, 'USD', '2025-11-02 16:56:17', 'Transferencia', 'H6V09');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 143.76, 'USD', '2025-04-08 22:02:59', 'Transferencia', 'D0X87');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 643.77, 'USD', '2025-02-07 05:25:48', 'Transferencia', 'S4G99');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 365.91, 'USD', '2025-08-04 18:31:43', 'Transferencia', 'J7P08');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 477.02, 'USD', '2025-11-26 21:51:11', 'Transferencia', 'M9V92');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 622.31, 'USD', '2025-04-03 06:39:49', 'Transferencia', 'T4X51');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 144.81, 'USD', '2025-04-14 21:23:36', 'Transferencia', 'J2I04');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 294.92, 'USD', '2025-09-13 00:08:04', 'Transferencia', 'W9S60');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 759.86, 'USD', '2025-04-06 17:01:24', 'Transferencia', 'K8C26');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 51.75, 'USD', '2025-04-04 01:18:38', 'Transferencia', 'N0Z94');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 127.66, 'USD', '2025-10-03 00:07:19', 'Transferencia', 'A7P61');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 591.28, 'USD', '2025-09-19 11:32:19', 'Transferencia', 'H7Z00');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 781.77, 'USD', '2025-01-09 02:24:39', 'Transferencia', 'K7S07');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 646.32, 'USD', '2025-09-29 14:08:19', 'Transferencia', 'F1M57');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 303.01, 'USD', '2025-02-20 08:13:48', 'Transferencia', 'Z9H41');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 458.76, 'USD', '2025-02-12 10:17:28', 'Transferencia', 'N7J08');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 125.1, 'USD', '2025-10-12 08:47:35', 'Transferencia', 'I2N40');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 240.1, 'USD', '2025-03-16 01:10:30', 'Transferencia', 'V2B54');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 216.24, 'USD', '2025-01-26 13:56:01', 'Transferencia', 'G3U70');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 452.7, 'USD', '2025-09-22 21:53:20', 'Transferencia', 'U1V00');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 511.62, 'USD', '2025-06-12 09:09:42', 'Transferencia', 'S1M37');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 713.48, 'USD', '2025-08-03 10:23:16', 'Transferencia', 'S8G90');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 152.73, 'USD', '2025-03-17 22:59:36', 'Transferencia', 'Q2V98');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 717.09, 'USD', '2025-01-28 07:34:35', 'Transferencia', 'Q6M48');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 637.46, 'USD', '2025-01-22 13:17:42', 'Transferencia', 'M1B24');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 169.73, 'USD', '2025-02-15 01:33:49', 'Transferencia', 'M2Z21');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 167.32, 'USD', '2025-08-06 07:29:03', 'Transferencia', 'B5A45');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 573.72, 'USD', '2025-05-19 07:32:38', 'Transferencia', 'F5O85');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 125.51, 'USD', '2025-09-17 22:44:10', 'Transferencia', 'E6Q16');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 773.55, 'USD', '2025-11-05 10:48:27', 'Transferencia', 'L1C13');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 789.72, 'USD', '2025-10-14 09:51:43', 'Transferencia', 'H4L49');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 788.96, 'USD', '2025-04-01 03:32:46', 'Transferencia', 'I8V68');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 826.74, 'USD', '2025-07-02 03:35:52', 'Transferencia', 'F3C80');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 978.9, 'USD', '2025-09-08 12:05:59', 'Transferencia', 'H0Z63');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 798.87, 'USD', '2025-02-27 05:15:28', 'Transferencia', 'P7G01');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 720.58, 'USD', '2025-08-17 02:17:28', 'Transferencia', 'S6K15');

insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 604.1, 'USD', '2025-04-26 05:28:40', 'Tarjeta', 'N7B86');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 643.43, 'USD', '2025-08-08 14:30:11', 'Tarjeta', 'R4R59');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 537.94, 'USD', '2025-03-04 04:22:08', 'Tarjeta', 'P8I43');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 876.37, 'USD', '2025-08-05 06:51:11', 'Tarjeta', 'J9D68');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 512.75, 'USD', '2025-10-13 22:21:24', 'Tarjeta', 'P0L85');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 547.1, 'USD', '2025-07-02 11:50:55', 'Tarjeta', 'V4U67');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 37.51, 'USD', '2025-09-07 06:32:27', 'Tarjeta', 'C2U55');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 154.68, 'USD', '2025-04-14 13:30:47', 'Tarjeta', 'U1Q05');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 341.35, 'USD', '2025-07-09 08:56:33', 'Tarjeta', 'U5O22');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 691.39, 'USD', '2025-04-23 09:38:42', 'Tarjeta', 'D8S64');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 197.3, 'USD', '2025-03-26 20:34:47', 'Tarjeta', 'P4Q45');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 670.12, 'USD', '2025-06-11 21:59:51', 'Tarjeta', 'V1A45');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 932.41, 'USD', '2025-04-25 12:26:43', 'Tarjeta', 'S2Y97');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 998.98, 'USD', '2025-05-05 02:39:26', 'Tarjeta', 'D8T27');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 962.23, 'USD', '2025-10-29 04:33:20', 'Tarjeta', 'X8X37');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 837.75, 'USD', '2025-07-21 05:54:25', 'Tarjeta', 'Z1M90');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 111.35, 'USD', '2025-02-26 03:51:12', 'Tarjeta', 'V9L41');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 644.89, 'USD', '2025-01-05 08:07:37', 'Tarjeta', 'D5A56');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 444.82, 'USD', '2025-05-25 15:31:25', 'Tarjeta', 'Q0V28');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 812.28, 'USD', '2025-02-09 00:43:45', 'Tarjeta', 'H0Y38');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 502.45, 'USD', '2025-03-13 12:01:56', 'Tarjeta', 'I8P75');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 610.67, 'USD', '2025-06-18 15:24:27', 'Tarjeta', 'O7F08');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 742.94, 'USD', '2025-09-15 18:43:20', 'Tarjeta', 'D5X13');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 417.61, 'USD', '2025-04-14 18:01:41', 'Tarjeta', 'H7Z43');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 78.5, 'USD', '2025-02-11 21:15:03', 'Tarjeta', 'T3W83');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 71.49, 'USD', '2025-08-16 17:55:33', 'Tarjeta', 'P9Z96');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 698.78, 'USD', '2025-10-13 23:29:56', 'Tarjeta', 'P3O56');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 806.93, 'USD', '2025-11-04 02:11:13', 'Tarjeta', 'B7M41');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 541.38, 'USD', '2025-08-04 17:02:31', 'Tarjeta', 'S0B56');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 563.78, 'USD', '2025-08-31 06:22:09', 'Tarjeta', 'S2W79');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 235.57, 'USD', '2025-05-09 22:01:48', 'Tarjeta', 'K4U13');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 185.08, 'USD', '2025-04-16 22:51:07', 'Tarjeta', 'Z5E40');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 88.27, 'USD', '2025-04-01 09:22:56', 'Tarjeta', 'N5M36');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 562.64, 'USD', '2025-08-26 16:44:18', 'Tarjeta', 'I9V48');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 17.91, 'USD', '2025-10-10 18:58:42', 'Tarjeta', 'S5K15');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 444.7, 'USD', '2025-09-23 10:44:54', 'Tarjeta', 'D2V86');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 199.58, 'USD', '2025-10-23 04:10:01', 'Tarjeta', 'M8V05');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 735.79, 'USD', '2025-10-13 22:57:08', 'Tarjeta', 'O2F63');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 842.26, 'USD', '2025-03-16 13:55:16', 'Tarjeta', 'V8V79');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 290.57, 'USD', '2025-04-18 04:12:34', 'Tarjeta', 'I1V00');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 173.83, 'USD', '2025-08-07 02:19:40', 'Tarjeta', 'E7Z70');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 18.02, 'USD', '2025-06-29 06:08:26', 'Tarjeta', 'T0Z78');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 453.84, 'USD', '2025-04-25 19:30:19', 'Tarjeta', 'D2D62');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 860.56, 'USD', '2025-10-27 01:34:50', 'Tarjeta', 'D5T35');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 596.89, 'USD', '2025-10-26 12:03:02', 'Tarjeta', 'R9P89');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 288.25, 'USD', '2025-09-03 07:23:19', 'Tarjeta', 'P8I25');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 830.58, 'USD', '2025-11-20 10:42:27', 'Tarjeta', 'O5Y14');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 34.21, 'USD', '2025-11-20 05:06:21', 'Tarjeta', 'R7P63');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 15.22, 'USD', '2025-05-12 00:03:01', 'Tarjeta', 'Q1W42');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 222.6, 'USD', '2025-03-22 14:30:51', 'Tarjeta', 'A3Z59');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 988.29, 'USD', '2025-08-17 12:35:09', 'Tarjeta', 'M0D16');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 410.08, 'USD', '2025-01-26 08:34:31', 'Tarjeta', 'Z9C71');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 840.27, 'USD', '2025-08-16 17:02:25', 'Tarjeta', 'F8Y34');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 632.47, 'USD', '2025-02-24 06:42:46', 'Tarjeta', 'F3R89');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 368.68, 'USD', '2025-11-09 00:14:12', 'Tarjeta', 'M4I57');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 641.92, 'USD', '2025-10-02 22:04:26', 'Tarjeta', 'B6N34');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 525.42, 'USD', '2025-01-01 18:43:21', 'Tarjeta', 'J6X73');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 304.51, 'USD', '2025-07-11 06:25:38', 'Tarjeta', 'C7G13');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 174.82, 'USD', '2025-01-01 17:51:33', 'Tarjeta', 'I5Z39');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 891.04, 'USD', '2025-11-02 00:19:14', 'Tarjeta', 'E7W28');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 337.94, 'USD', '2025-05-13 18:29:14', 'Tarjeta', 'K2Z28');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 192.2, 'USD', '2025-02-12 04:38:00', 'Tarjeta', 'G2X35');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 722.12, 'USD', '2025-07-08 08:33:22', 'Tarjeta', 'Y8G38');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 71.08, 'USD', '2025-03-12 01:51:42', 'Tarjeta', 'Q2X27');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 205.51, 'USD', '2025-08-17 13:44:50', 'Tarjeta', 'Y6K10');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 883.11, 'USD', '2025-06-09 22:00:40', 'Tarjeta', 'U6X00');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 743.68, 'USD', '2025-06-12 20:04:10', 'Tarjeta', 'V6K72');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 278.38, 'USD', '2025-11-11 00:57:37', 'Tarjeta', 'F8Y78');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 249.67, 'USD', '2025-05-24 11:52:56', 'Tarjeta', 'E4S61');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 686.98, 'USD', '2025-07-21 09:44:57', 'Tarjeta', 'E8H90');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 4.25, 'USD', '2025-10-13 22:42:37', 'Tarjeta', 'S9H88');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 120.07, 'USD', '2025-06-26 14:04:11', 'Tarjeta', 'G8G53');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 965.99, 'USD', '2025-03-30 15:51:13', 'Tarjeta', 'P0X32');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 649.3, 'USD', '2025-01-30 07:29:54', 'Tarjeta', 'R7U69');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 776.78, 'USD', '2025-10-26 07:39:58', 'Tarjeta', 'R2E23');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 871.7, 'USD', '2025-05-03 14:25:25', 'Tarjeta', 'U8O44');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 615.51, 'USD', '2025-02-05 23:48:09', 'Tarjeta', 'P3V96');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 885.5, 'USD', '2025-07-21 02:24:07', 'Tarjeta', 'G8N73');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 923.02, 'USD', '2025-02-23 21:33:54', 'Tarjeta', 'C1N92');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 255.84, 'USD', '2025-05-27 13:22:15', 'Tarjeta', 'Y9R56');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 156.27, 'USD', '2025-08-12 12:36:24', 'Tarjeta', 'E8Y13');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 764.39, 'USD', '2025-07-17 19:57:52', 'Tarjeta', 'F8C76');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 327.36, 'USD', '2025-03-18 15:41:47', 'Tarjeta', 'A2C64');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 491.06, 'USD', '2025-07-04 17:09:14', 'Tarjeta', 'W2D27');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 873.95, 'USD', '2025-11-19 19:02:45', 'Tarjeta', 'P5D97');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 610.66, 'USD', '2025-09-12 03:21:52', 'Tarjeta', 'C3Y32');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 375.17, 'USD', '2025-02-23 17:14:18', 'Tarjeta', 'A4F26');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 858.96, 'USD', '2025-08-27 23:24:05', 'Tarjeta', 'S3E72');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 752.75, 'USD', '2025-09-30 21:13:19', 'Tarjeta', 'F6X16');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 792.18, 'USD', '2025-03-02 01:32:31', 'Tarjeta', 'S9O47');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 735.58, 'USD', '2025-01-27 09:05:12', 'Tarjeta', 'C7W04');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 662.0, 'USD', '2025-07-14 09:44:05', 'Tarjeta', 'E1N60');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 576.3, 'USD', '2025-08-29 03:43:39', 'Tarjeta', 'E5W80');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 602.68, 'USD', '2025-07-02 13:54:18', 'Tarjeta', 'N2V84');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 363.17, 'USD', '2025-05-03 17:58:53', 'Tarjeta', 'U0M65');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 157.7, 'USD', '2025-04-02 19:21:24', 'Tarjeta', 'X9G37');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 424.08, 'USD', '2025-02-01 00:12:17', 'Tarjeta', 'D7T28');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 871.73, 'USD', '2025-01-27 09:08:31', 'Tarjeta', 'B4Z47');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 594.98, 'USD', '2025-10-20 18:24:06', 'Tarjeta', 'F0Y59');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 139.36, 'USD', '2025-02-12 18:54:23', 'Tarjeta', 'M6A98');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 703.23, 'USD', '2025-11-08 19:12:32', 'Tarjeta', 'G9K81');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 756.61, 'USD', '2025-03-07 06:05:27', 'Tarjeta', 'C5D43');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 870.29, 'USD', '2025-06-27 16:41:52', 'Tarjeta', 'U2U91');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 18.3, 'USD', '2025-05-11 22:14:42', 'Tarjeta', 'P6I52');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 809.15, 'USD', '2025-02-23 10:19:35', 'Tarjeta', 'Y2Z05');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 28.84, 'USD', '2025-03-14 18:18:01', 'Tarjeta', 'G7Y98');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 568.96, 'USD', '2025-09-29 08:07:43', 'Tarjeta', 'T6O06');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 380.92, 'USD', '2025-03-30 13:46:49', 'Tarjeta', 'I6B46');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 565.18, 'USD', '2025-08-28 18:11:51', 'Tarjeta', 'P6A57');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 625.98, 'USD', '2025-02-14 05:29:20', 'Tarjeta', 'M9S41');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 654.89, 'USD', '2025-10-11 01:47:49', 'Tarjeta', 'Q1B73');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 115.17, 'USD', '2025-07-15 04:04:09', 'Tarjeta', 'Q0B80');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 71.8, 'USD', '2025-04-18 18:57:13', 'Tarjeta', 'K7K68');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 131.07, 'USD', '2025-02-07 18:08:53', 'Tarjeta', 'L7V49');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 610.76, 'USD', '2025-09-19 05:29:54', 'Tarjeta', 'Z0F07');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 54.57, 'USD', '2025-04-02 05:30:38', 'Tarjeta', 'I3E83');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 361.18, 'USD', '2025-06-09 23:20:23', 'Tarjeta', 'L0D24');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 235.14, 'USD', '2025-05-27 01:39:36', 'Tarjeta', 'B9Q30');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 187.27, 'USD', '2025-05-13 22:34:53', 'Tarjeta', 'H6K78');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 574.0, 'USD', '2025-05-08 03:02:23', 'Tarjeta', 'J2M80');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 578.52, 'USD', '2025-03-31 16:23:33', 'Tarjeta', 'J0S41');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 597.62, 'USD', '2025-05-16 20:38:49', 'Tarjeta', 'J7R61');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 40.27, 'USD', '2025-05-03 11:14:07', 'Tarjeta', 'Q3E12');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 897.67, 'USD', '2025-08-31 02:00:49', 'Tarjeta', 'J8M43');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 773.0, 'USD', '2025-02-20 04:54:01', 'Tarjeta', 'Y9Y56');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 782.89, 'USD', '2025-03-16 22:59:15', 'Tarjeta', 'C2M75');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 986.55, 'USD', '2025-06-05 12:37:08', 'Tarjeta', 'X7C86');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 822.39, 'USD', '2025-07-24 21:57:38', 'Tarjeta', 'Q3U54');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 336.64, 'USD', '2025-06-15 05:47:33', 'Tarjeta', 'L7S35');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 988.33, 'USD', '2025-06-01 15:44:25', 'Tarjeta', 'D7O00');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 335.24, 'USD', '2025-03-25 00:49:52', 'Tarjeta', 'U1I46');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 300.05, 'USD', '2025-07-07 16:45:20', 'Tarjeta', 'E8H87');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 813.44, 'USD', '2025-09-29 12:22:29', 'Tarjeta', 'N3G22');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 891.07, 'USD', '2025-06-27 02:19:02', 'Tarjeta', 'Z7K59');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 650.35, 'USD', '2025-04-06 16:53:02', 'Tarjeta', 'V7N73');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 443.14, 'USD', '2025-07-11 01:19:30', 'Tarjeta', 'Q9H31');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 870.6, 'USD', '2025-03-07 21:13:31', 'Tarjeta', 'W6G97');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 162.44, 'USD', '2025-04-16 18:06:57', 'Tarjeta', 'A1C91');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 710.34, 'USD', '2025-09-24 08:39:19', 'Tarjeta', 'X2R40');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 13.97, 'USD', '2025-05-30 02:21:05', 'Tarjeta', 'B0O07');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 371.21, 'USD', '2025-06-29 10:24:04', 'Tarjeta', 'F0Z83');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 103.93, 'USD', '2025-07-10 19:48:33', 'Tarjeta', 'B4I36');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 615.85, 'USD', '2025-06-18 01:46:03', 'Tarjeta', 'X2V82');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 4.53, 'USD', '2025-10-16 09:11:41', 'Tarjeta', 'D9V02');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 841.28, 'USD', '2025-07-27 16:43:57', 'Tarjeta', 'R2I85');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 87.89, 'USD', '2025-08-10 11:57:56', 'Tarjeta', 'Q4A29');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 841.83, 'USD', '2025-08-17 18:16:45', 'Tarjeta', 'M2R97');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 12.66, 'USD', '2025-11-14 10:39:05', 'Tarjeta', 'F7O54');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 522.99, 'USD', '2025-06-05 10:24:39', 'Tarjeta', 'W9Z72');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 467.57, 'USD', '2025-07-31 17:04:56', 'Tarjeta', 'B9M16');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 114.47, 'USD', '2025-07-17 10:10:30', 'Tarjeta', 'U3D62');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 711.55, 'USD', '2025-01-25 01:41:05', 'Tarjeta', 'Y1H38');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 640.65, 'USD', '2025-09-04 23:13:16', 'Tarjeta', 'L9Y39');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 88.98, 'USD', '2025-05-07 10:14:59', 'Tarjeta', 'B0E53');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 195.54, 'USD', '2025-09-22 14:09:11', 'Tarjeta', 'L6I74');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 373.45, 'USD', '2025-07-29 05:18:00', 'Tarjeta', 'A7S41');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 233.61, 'USD', '2025-01-28 13:22:46', 'Tarjeta', 'I0P44');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 507.32, 'USD', '2025-07-22 06:59:41', 'Tarjeta', 'W1K30');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 347.53, 'USD', '2025-06-06 19:16:08', 'Tarjeta', 'V4A60');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 237.38, 'USD', '2025-02-25 04:07:58', 'Tarjeta', 'X7I46');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 296.82, 'USD', '2025-02-26 13:28:42', 'Tarjeta', 'N3U99');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 988.23, 'USD', '2025-10-20 22:15:47', 'Tarjeta', 'R5G82');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 112.46, 'USD', '2025-07-05 04:51:48', 'Tarjeta', 'B8C28');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 132.77, 'USD', '2025-05-15 02:43:15', 'Tarjeta', 'F4M41');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 151.75, 'USD', '2025-05-03 15:13:59', 'Tarjeta', 'Q1J33');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 96.3, 'USD', '2025-11-13 12:15:22', 'Tarjeta', 'M3H12');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 250.7, 'USD', '2025-11-07 21:23:53', 'Tarjeta', 'D0L32');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 95.67, 'USD', '2025-05-09 02:36:27', 'Tarjeta', 'F6A31');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 651.07, 'USD', '2025-01-20 05:00:34', 'Tarjeta', 'W5F90');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 518.37, 'USD', '2025-04-12 07:04:11', 'Tarjeta', 'O1D67');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 873.87, 'USD', '2025-10-06 03:45:24', 'Tarjeta', 'Q8A20');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 262.08, 'USD', '2025-01-06 09:33:55', 'Tarjeta', 'K7Y23');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 874.5, 'USD', '2025-08-13 04:36:58', 'Tarjeta', 'T6Y10');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 841.84, 'USD', '2025-07-17 06:05:24', 'Tarjeta', 'S3S99');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 686.17, 'USD', '2025-01-30 21:12:17', 'Tarjeta', 'N5G15');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 413.64, 'USD', '2025-01-29 03:36:00', 'Tarjeta', 'I9C36');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 385.02, 'USD', '2025-06-18 17:40:55', 'Tarjeta', 'A2O80');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 277.07, 'USD', '2025-01-04 23:26:03', 'Tarjeta', 'V8P54');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 705.82, 'USD', '2025-04-01 00:58:15', 'Tarjeta', 'B1P53');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 479.4, 'USD', '2025-02-04 07:21:51', 'Tarjeta', 'W0C76');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 102.26, 'USD', '2025-07-13 12:24:48', 'Tarjeta', 'A3A01');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 588.39, 'USD', '2025-09-03 22:05:27', 'Tarjeta', 'I6S35');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 645.88, 'USD', '2025-03-11 08:31:11', 'Tarjeta', 'H0V10');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 122.92, 'USD', '2025-11-24 20:03:31', 'Tarjeta', 'W1T63');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 496.74, 'USD', '2025-09-07 00:37:12', 'Tarjeta', 'O5N19');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 139.76, 'USD', '2025-07-07 22:05:17', 'Tarjeta', 'A7P79');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 470.47, 'USD', '2025-06-18 07:08:38', 'Tarjeta', 'X1H58');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 218.54, 'USD', '2025-08-31 14:24:10', 'Tarjeta', 'P7I85');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 92.83, 'USD', '2025-04-17 06:59:48', 'Tarjeta', 'Q0T07');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 689.11, 'USD', '2025-11-12 09:49:20', 'Tarjeta', 'P6O49');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 120.58, 'USD', '2025-09-22 07:41:02', 'Tarjeta', 'H4Y69');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 642.1, 'USD', '2025-08-04 19:37:14', 'Tarjeta', 'C6W86');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 286.12, 'USD', '2025-11-25 23:12:03', 'Tarjeta', 'F5V07');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 740.08, 'USD', '2025-03-09 07:41:08', 'Tarjeta', 'C0U57');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 864.06, 'USD', '2025-11-23 19:21:48', 'Tarjeta', 'G1D27');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 662.78, 'USD', '2025-09-23 03:58:10', 'Tarjeta', 'K9E06');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 500.5, 'USD', '2025-09-08 18:55:46', 'Tarjeta', 'N1S95');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 113.42, 'USD', '2025-04-27 17:37:03', 'Tarjeta', 'U5P11');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 122.68, 'USD', '2025-05-02 06:27:49', 'Tarjeta', 'O4U14');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 240.44, 'USD', '2025-02-20 07:43:40', 'Tarjeta', 'B8O93');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 219.48, 'USD', '2025-03-21 17:12:16', 'Tarjeta', 'M0L47');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 918.97, 'USD', '2025-07-14 17:55:42', 'Tarjeta', 'Y5I31');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 58.97, 'USD', '2025-08-03 00:13:32', 'Tarjeta', 'T7I78');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 580.53, 'USD', '2025-01-27 09:52:33', 'Tarjeta', 'N9R72');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 930.02, 'USD', '2025-06-27 07:14:00', 'Tarjeta', 'W0K48');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 70.25, 'USD', '2025-11-10 04:15:23', 'Tarjeta', 'P7I25');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 63.91, 'USD', '2025-03-02 21:48:39', 'Tarjeta', 'O6A32');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 668.75, 'USD', '2025-07-26 12:23:34', 'Tarjeta', 'K9V18');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 179.07, 'USD', '2025-01-22 15:08:58', 'Tarjeta', 'T1V62');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 914.75, 'USD', '2025-03-14 06:17:51', 'Tarjeta', 'V8X93');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 730.66, 'USD', '2025-02-08 23:51:27', 'Tarjeta', 'E1K83');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 629.66, 'USD', '2025-06-01 02:21:26', 'Tarjeta', 'B4Y76');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 205.97, 'USD', '2025-05-27 13:50:40', 'Tarjeta', 'D4Y04');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 696.93, 'USD', '2025-09-27 02:14:13', 'Tarjeta', 'A0M24');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 642.94, 'USD', '2025-06-06 15:49:31', 'Tarjeta', 'K6J69');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 642.08, 'USD', '2025-11-18 08:32:57', 'Tarjeta', 'A4I31');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 454.36, 'USD', '2025-10-27 10:40:39', 'Tarjeta', 'C9P30');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 635.93, 'USD', '2025-09-05 04:46:53', 'Tarjeta', 'C8L03');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 787.64, 'USD', '2025-05-23 20:43:44', 'Tarjeta', 'S2S06');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 115.76, 'USD', '2025-08-10 00:09:16', 'Tarjeta', 'W5H73');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 63.4, 'USD', '2025-06-19 17:23:48', 'Tarjeta', 'Q1V83');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 834.93, 'USD', '2025-07-25 00:42:28', 'Tarjeta', 'M6G26');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 875.19, 'USD', '2025-03-25 02:53:00', 'Tarjeta', 'L9O10');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 779.72, 'USD', '2025-08-21 04:43:13', 'Tarjeta', 'R8J90');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 896.12, 'USD', '2025-02-08 18:33:39', 'Tarjeta', 'W3P16');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 715.93, 'USD', '2025-03-04 11:30:58', 'Tarjeta', 'I3Z42');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 925.18, 'USD', '2025-03-14 18:42:15', 'Tarjeta', 'C8K66');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 936.05, 'USD', '2025-10-11 13:52:52', 'Tarjeta', 'N3V17');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 855.83, 'USD', '2025-06-01 09:01:08', 'Tarjeta', 'Y9I86');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 861.88, 'USD', '2025-04-25 04:30:15', 'Tarjeta', 'V0Z88');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 343.58, 'USD', '2025-08-18 20:12:49', 'Tarjeta', 'K0M53');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 70.08, 'USD', '2025-08-13 20:36:48', 'Tarjeta', 'J4R98');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 936.08, 'USD', '2025-04-15 07:08:55', 'Tarjeta', 'Q3Y20');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 215.34, 'USD', '2025-11-13 00:50:01', 'Tarjeta', 'N1Z92');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 979.37, 'USD', '2025-11-02 09:12:17', 'Tarjeta', 'S1X83');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 41.67, 'USD', '2025-01-08 15:15:03', 'Tarjeta', 'R7T66');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 711.84, 'USD', '2025-04-28 18:31:27', 'Tarjeta', 'Q5O55');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 610.1, 'USD', '2025-09-16 01:47:42', 'Tarjeta', 'O4G52');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 825.58, 'USD', '2025-09-30 20:29:47', 'Tarjeta', 'V9N19');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 622.55, 'USD', '2025-07-02 15:37:07', 'Tarjeta', 'D2E48');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 683.13, 'USD', '2025-06-21 06:04:49', 'Tarjeta', 'U0G69');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 221.8, 'USD', '2025-03-12 06:57:54', 'Tarjeta', 'V4J55');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 74.37, 'USD', '2025-11-05 23:16:20', 'Tarjeta', 'X7C82');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 235.27, 'USD', '2025-03-17 05:47:57', 'Tarjeta', 'T4U39');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 417.87, 'USD', '2025-03-17 05:20:40', 'Tarjeta', 'H4M49');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 916.94, 'USD', '2025-04-30 03:02:25', 'Tarjeta', 'S5L08');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 467.95, 'USD', '2025-06-18 15:01:35', 'Tarjeta', 'J0V90');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 265.06, 'USD', '2025-08-24 19:25:04', 'Tarjeta', 'G1L34');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 797.06, 'USD', '2025-02-16 09:31:15', 'Tarjeta', 'L7I95');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 921.77, 'USD', '2025-04-21 00:21:39', 'Tarjeta', 'E9B08');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 532.39, 'USD', '2025-09-21 13:10:17', 'Tarjeta', 'S6V13');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 52.05, 'USD', '2025-04-13 13:04:11', 'Tarjeta', 'A2F00');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 162.29, 'USD', '2025-01-20 02:20:20', 'Tarjeta', 'D9L25');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 932.66, 'USD', '2025-05-07 23:10:44', 'Tarjeta', 'H7O86');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 958.1, 'USD', '2025-04-28 01:36:07', 'Tarjeta', 'P5G66');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 429.48, 'USD', '2025-08-17 03:26:11', 'Tarjeta', 'F8B11');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 35.03, 'USD', '2025-10-09 17:01:04', 'Tarjeta', 'G1A56');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 122.87, 'USD', '2025-01-18 17:58:24', 'Tarjeta', 'N6S44');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 388.12, 'USD', '2025-08-15 04:44:10', 'Tarjeta', 'R1K79');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 223.49, 'USD', '2025-07-22 02:14:28', 'Tarjeta', 'W0C57');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 81.67, 'USD', '2025-03-17 21:25:17', 'Tarjeta', 'Q9E00');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 720.57, 'USD', '2025-03-20 15:15:00', 'Tarjeta', 'F4R25');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 146.23, 'USD', '2025-11-06 22:16:11', 'Tarjeta', 'R0D68');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 708.14, 'USD', '2025-08-30 20:06:32', 'Tarjeta', 'H3D50');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 732.01, 'USD', '2025-03-08 21:01:52', 'Tarjeta', 'U9F10');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 761.92, 'USD', '2025-09-11 16:17:12', 'Tarjeta', 'D9S63');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 180.56, 'USD', '2025-10-22 12:45:43', 'Tarjeta', 'W4R17');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 842.94, 'USD', '2025-08-24 11:48:40', 'Tarjeta', 'M6O65');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 774.15, 'USD', '2025-01-21 13:07:02', 'Tarjeta', 'B9R52');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 655.05, 'USD', '2025-02-24 14:08:32', 'Tarjeta', 'E5N68');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 328.94, 'USD', '2025-07-05 02:56:46', 'Tarjeta', 'N9D58');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 907.35, 'USD', '2025-05-05 03:45:43', 'Tarjeta', 'G0W18');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 803.99, 'USD', '2025-09-19 14:34:05', 'Tarjeta', 'E4K54');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 341.59, 'USD', '2025-02-03 00:42:20', 'Tarjeta', 'A6Q38');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 887.92, 'USD', '2025-08-03 06:52:01', 'Tarjeta', 'D4H51');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 242.94, 'USD', '2025-08-08 11:36:49', 'Tarjeta', 'G7J93');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 994.45, 'USD', '2025-06-20 19:28:10', 'Tarjeta', 'J5I44');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 833.31, 'USD', '2025-01-08 06:05:51', 'Tarjeta', 'C7T23');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 361.56, 'USD', '2025-10-07 04:10:19', 'Tarjeta', 'O6G66');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 908.27, 'USD', '2025-09-30 02:49:13', 'Tarjeta', 'G5H31');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 94.72, 'USD', '2025-04-07 16:23:14', 'Tarjeta', 'M1K66');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 18.11, 'USD', '2025-02-27 06:01:45', 'Tarjeta', 'A2I81');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 953.61, 'USD', '2025-05-26 22:35:08', 'Tarjeta', 'J4E46');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 702.91, 'USD', '2025-06-06 09:13:39', 'Tarjeta', 'M8F66');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 236.11, 'USD', '2025-06-06 18:11:57', 'Tarjeta', 'B9A20');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 499.86, 'USD', '2025-07-07 01:02:31', 'Tarjeta', 'Q5B25');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 784.37, 'USD', '2025-10-23 09:31:19', 'Tarjeta', 'O5R69');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 476.28, 'USD', '2025-01-20 14:34:09', 'Tarjeta', 'L0N59');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 860.43, 'USD', '2025-09-27 17:26:35', 'Tarjeta', 'H9T15');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 144.37, 'USD', '2025-09-21 02:46:14', 'Tarjeta', 'T8E85');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 934.62, 'USD', '2025-02-19 09:48:07', 'Tarjeta', 'D9C37');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 97.25, 'USD', '2025-06-30 11:48:37', 'Tarjeta', 'N2X82');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 858.56, 'USD', '2025-08-04 01:10:17', 'Tarjeta', 'F9B27');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 100.27, 'USD', '2025-09-24 03:54:48', 'Tarjeta', 'P8W37');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 640.54, 'USD', '2025-08-16 13:32:58', 'Tarjeta', 'Y8T06');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 284.9, 'USD', '2025-05-04 22:13:32', 'Tarjeta', 'Y6D91');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 952.94, 'USD', '2025-07-03 00:10:51', 'Tarjeta', 'B9G15');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 993.72, 'USD', '2025-11-22 10:28:18', 'Tarjeta', 'F8K78');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 906.32, 'USD', '2025-06-13 08:32:04', 'Tarjeta', 'W0S04');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 739.17, 'USD', '2025-01-15 14:03:59', 'Tarjeta', 'D4D03');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 286.29, 'USD', '2025-04-26 15:57:03', 'Tarjeta', 'E9I33');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 927.21, 'USD', '2025-03-05 04:06:19', 'Tarjeta', 'F8V22');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 769.86, 'USD', '2025-10-03 05:39:38', 'Tarjeta', 'D4C62');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 951.76, 'USD', '2025-06-23 18:12:04', 'Tarjeta', 'V9K40');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 749.69, 'USD', '2025-10-10 21:07:59', 'Tarjeta', 'V4D04');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 917.32, 'USD', '2025-07-17 14:39:15', 'Tarjeta', 'Q0B96');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 579.63, 'USD', '2025-11-07 22:30:17', 'Tarjeta', 'C1T82');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 595.0, 'USD', '2025-10-31 03:08:19', 'Tarjeta', 'B4I55');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 488.22, 'USD', '2025-01-08 20:20:42', 'Tarjeta', 'E9Q35');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 835.15, 'USD', '2025-07-30 22:13:58', 'Tarjeta', 'N5R91');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 142.7, 'USD', '2025-10-30 21:09:20', 'Tarjeta', 'S3O34');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 72.66, 'USD', '2025-05-06 13:39:36', 'Tarjeta', 'O7K50');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 48.49, 'USD', '2025-05-20 17:38:23', 'Tarjeta', 'I4B41');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 909.02, 'USD', '2025-09-14 01:59:22', 'Tarjeta', 'Y9G90');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 826.14, 'USD', '2025-03-26 19:24:07', 'Tarjeta', 'H4Y51');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 336.81, 'USD', '2025-05-23 04:30:54', 'Tarjeta', 'D4A94');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 226.69, 'USD', '2025-05-27 23:40:01', 'Tarjeta', 'L5V70');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (9, 121.42, 'USD', '2025-04-11 07:38:11', 'Tarjeta', 'E0I61');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (2, 996.95, 'USD', '2025-01-17 01:37:31', 'Tarjeta', 'F9O98');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (3, 411.71, 'USD', '2025-04-27 00:19:24', 'Tarjeta', 'Q4O58');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (4, 909.57, 'USD', '2025-01-29 08:54:42', 'Tarjeta', 'Z2V34');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 142.87, 'USD', '2025-05-30 06:03:34', 'Tarjeta', 'O3J16');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 670.01, 'USD', '2025-09-17 02:08:22', 'Tarjeta', 'J4M94');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 503.83, 'USD', '2025-11-08 13:13:36', 'Tarjeta', 'D4I17');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 765.46, 'USD', '2025-09-03 18:58:59', 'Tarjeta', 'R1Y87');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 689.33, 'USD', '2025-02-16 21:22:54', 'Tarjeta', 'L2G86');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 766.59, 'USD', '2025-06-02 20:18:19', 'Tarjeta', 'S0K81');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (8, 385.31, 'USD', '2025-10-11 15:22:40', 'Tarjeta', 'V5Z55');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (6, 672.0, 'USD', '2025-11-26 18:51:52', 'Tarjeta', 'S4H60');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (1, 199.73, 'USD', '2025-04-04 13:13:32', 'Tarjeta', 'G6H67');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (5, 873.33, 'USD', '2025-05-18 22:49:18', 'Tarjeta', 'J5H37');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (10, 642.08, 'USD', '2025-02-27 19:56:32', 'Tarjeta', 'L4X14');
insert into Ventas.Pago (SocioID, Monto, Moneda, FechaPago, MetodoPago, Referencia) values (7, 963.52, 'USD', '2025-01-26 04:03:36', 'Tarjeta', 'U6I64');






---TABLA VENTA
insert into Ventas.Venta (SocioID, FechaVenta, Total) values (4,(CAST('2025-07-24 14:10:25' AS DATETIME)), 444.05);
insert into Ventas.Venta (SocioID, FechaVenta, Total) values (4,(CAST('2025-09-26 00:45:36' AS DATETIME)), 990.4);
insert into Ventas.Venta (SocioID, FechaVenta, Total) values (9,(CAST('2025-08-07 14:39:19' AS DATETIME)), 571.79);
insert into Ventas.Venta (SocioID, FechaVenta, Total) values (3,(CAST('2025-06-05 03:41:15' AS DATETIME)), 643.97);
insert into Ventas.Venta (SocioID, FechaVenta, Total) values (8,(CAST('2025-04-15 22:41:33' AS DATETIME)), 18.95);
insert into Ventas.Venta (SocioID, FechaVenta, Total) values (7,(CAST('2025-08-30 13:34:30' AS DATETIME)), 849.73);
insert into Ventas.Venta (SocioID, FechaVenta, Total) values (6,(CAST('2025-08-16 09:33:24' AS DATETIME)), 864.0);
insert into Ventas.Venta (SocioID, FechaVenta, Total) values (9,(CAST('2025-05-15 20:31:46' AS DATETIME)), 547.14);
insert into Ventas.Venta (SocioID, FechaVenta, Total) values (7,(CAST('2025-01-25 07:02:39' AS DATETIME)), 191.88);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-10-13 11:56:25' AS DATETIME)), 874.86);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-09-28 18:04:03' AS DATETIME)), 944.34);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-03-26 07:32:05' AS DATETIME)), 751.21);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-04-07 18:54:25' AS DATETIME)), 71.48);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-04-06 12:35:32' AS DATETIME)), 600.51);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-09-06 06:32:03' AS DATETIME)), 736.34);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-07-24 10:38:06' AS DATETIME)), 265.44);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-06-11 08:23:22' AS DATETIME)), 759.97);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-11-05 08:00:44' AS DATETIME)), 372.41);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-11-13 21:50:11' AS DATETIME)), 892.44);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-01-27 09:40:34' AS DATETIME)), 186.23);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-10-20 10:43:55' AS DATETIME)), 948.99);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-02-28 14:13:44' AS DATETIME)), 748.13);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-08-10 03:12:07' AS DATETIME)), 990.18);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-05-19 23:22:34' AS DATETIME)), 200.58);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-01-10 02:03:52' AS DATETIME)), 39.54);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-04-16 09:57:29' AS DATETIME)), 475.29);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-03-20 09:03:40' AS DATETIME)), 454.58);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-11-05 13:46:45' AS DATETIME)), 542.88);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-08-03 17:17:47' AS DATETIME)), 347.59);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-01-08 23:59:26' AS DATETIME)), 378.49);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-07-24 07:12:46' AS DATETIME)), 181.24);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-06-05 20:15:26' AS DATETIME)), 436.13);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-02-24 03:22:23' AS DATETIME)), 527.26);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-11-11 14:06:17' AS DATETIME)), 712.37);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-02-28 08:50:54' AS DATETIME)), 464.87);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-04-07 15:56:21' AS DATETIME)), 877.23);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-05-12 19:12:38' AS DATETIME)), 395.77);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-10-15 16:52:09' AS DATETIME)), 605.82);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-11-03 03:40:37' AS DATETIME)), 92.8);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-06-08 07:19:44' AS DATETIME)), 362.33);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-06-04 14:46:55' AS DATETIME)), 535.69);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-09-11 21:22:22' AS DATETIME)), 847.65);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-07-13 01:12:01' AS DATETIME)), 267.05);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-03-31 16:13:31' AS DATETIME)), 129.45);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-11-15 19:24:48' AS DATETIME)), 331.25);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-08-30 05:00:46' AS DATETIME)), 932.74);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-05-29 16:53:11' AS DATETIME)), 562.06);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-01-24 02:23:35' AS DATETIME)), 972.56);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-01-25 04:58:24' AS DATETIME)), 814.3);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-03-24 05:04:53' AS DATETIME)), 992.66);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-06-26 01:36:11' AS DATETIME)), 555.39);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-11-06 06:31:31' AS DATETIME)), 304.82);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-01-19 16:36:48' AS DATETIME)), 598.71);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-09-13 04:13:17' AS DATETIME)), 699.81);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-06-30 14:58:10' AS DATETIME)), 761.56);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-04-03 23:25:03' AS DATETIME)), 408.27);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-07-06 05:22:59' AS DATETIME)), 388.65);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-02-08 03:13:45' AS DATETIME)), 12.01);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-07-31 19:26:44' AS DATETIME)), 262.25);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-01-18 06:05:23' AS DATETIME)), 395.27);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-06-29 07:59:22' AS DATETIME)), 425.68);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-06-20 13:08:03' AS DATETIME)), 121.98);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-09-05 16:37:44' AS DATETIME)), 176.98);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-06-16 19:40:44' AS DATETIME)), 289.96);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-08-30 00:53:24' AS DATETIME)), 520.5);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-02-21 19:22:19' AS DATETIME)), 457.25);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-04-22 21:56:38' AS DATETIME)), 807.39);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-04-19 17:43:00' AS DATETIME)), 775.77);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-07-10 18:39:22' AS DATETIME)), 624.53);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-06-13 00:43:19' AS DATETIME)), 159.4);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-10-27 13:13:39' AS DATETIME)), 295.27);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-02-07 12:20:13' AS DATETIME)), 77.48);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-08-06 23:46:07' AS DATETIME)), 355.73);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-02-17 03:23:22' AS DATETIME)), 630.67);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-06-01 21:03:07' AS DATETIME)), 19.96);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-01-19 11:56:13' AS DATETIME)), 573.35);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-01-25 10:34:41' AS DATETIME)), 399.47);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-11-23 19:24:07' AS DATETIME)), 277.11);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-07-20 09:32:15' AS DATETIME)), 840.57);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-07-10 01:17:37' AS DATETIME)), 745.65);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-01-09 16:12:17' AS DATETIME)), 542.02);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-06-24 03:46:51' AS DATETIME)), 967.75);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-03-12 05:41:59' AS DATETIME)), 759.02);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-11-22 22:58:51' AS DATETIME)), 963.49);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-01-01 09:17:27' AS DATETIME)), 127.13);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-09-25 01:32:33' AS DATETIME)), 829.44);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-03-25 08:29:14' AS DATETIME)), 24.89);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-10-22 04:19:53' AS DATETIME)), 81.48);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-04-03 13:41:30' AS DATETIME)), 251.65);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-10-25 10:52:16' AS DATETIME)), 690.64);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-08-08 13:10:33' AS DATETIME)), 273.83);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-05-23 05:31:44' AS DATETIME)), 708.21);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-04-21 09:10:46' AS DATETIME)), 871.38);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-06-15 23:48:03' AS DATETIME)), 354.76);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-01-17 18:33:08' AS DATETIME)), 775.34);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-10-17 22:56:52' AS DATETIME)), 607.25);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-03-15 15:28:04' AS DATETIME)), 738.29);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-01-12 05:01:08' AS DATETIME)), 356.0);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-07-05 09:27:10' AS DATETIME)), 547.68);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-03-08 16:59:21' AS DATETIME)), 124.6);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-07-02 22:15:15' AS DATETIME)), 436.45);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-11-10 01:04:11' AS DATETIME)), 366.78);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-04-20 05:33:26' AS DATETIME)), 44.3);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-08-25 06:13:03' AS DATETIME)), 600.31);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-09-12 20:38:24' AS DATETIME)), 261.2);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-03-05 18:47:42' AS DATETIME)), 530.38);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-03-31 02:05:06' AS DATETIME)), 267.7);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-06-16 08:40:09' AS DATETIME)), 322.34);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-10-18 10:47:52' AS DATETIME)), 650.38);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-07-16 12:48:38' AS DATETIME)), 589.15);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-01-16 11:18:43' AS DATETIME)), 809.2);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-06-13 04:54:31' AS DATETIME)), 384.0);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-06-03 04:36:27' AS DATETIME)), 336.77);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-03-17 04:39:44' AS DATETIME)), 764.3);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-07-02 01:21:39' AS DATETIME)), 843.64);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-04-15 00:56:20' AS DATETIME)), 707.18);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-02-15 20:35:53' AS DATETIME)), 513.67);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-10-14 18:28:34' AS DATETIME)), 185.17);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-10-06 06:03:17' AS DATETIME)), 641.8);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-04-27 04:13:00' AS DATETIME)), 276.4);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-10-09 00:26:37' AS DATETIME)), 313.16);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-08-27 01:11:31' AS DATETIME)), 147.4);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-06-21 06:41:39' AS DATETIME)), 963.93);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-04-03 05:47:08' AS DATETIME)), 204.04);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-04-19 16:45:51' AS DATETIME)), 590.84);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-03-24 13:46:23' AS DATETIME)), 482.72);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-10-24 08:49:10' AS DATETIME)), 613.78);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-04-11 21:42:53' AS DATETIME)), 257.17);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-01-17 00:24:38' AS DATETIME)), 763.5);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-06-07 16:07:58' AS DATETIME)), 586.83);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-04-19 06:29:22' AS DATETIME)), 287.39);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-10-24 01:39:45' AS DATETIME)), 709.37);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-07-02 16:52:33' AS DATETIME)), 282.09);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-10-17 01:57:49' AS DATETIME)), 126.38);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-09-05 08:28:43' AS DATETIME)), 863.34);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-01-21 03:29:16' AS DATETIME)), 914.42);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-06-05 10:15:22' AS DATETIME)), 919.47);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-11-24 18:05:48' AS DATETIME)), 737.34);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-04-07 13:29:16' AS DATETIME)), 184.53);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-10-31 19:25:13' AS DATETIME)), 491.95);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-11-08 23:03:34' AS DATETIME)), 512.39);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-03-12 21:41:56' AS DATETIME)), 56.54);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-02-20 18:03:48' AS DATETIME)), 420.86);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-04-24 20:56:49' AS DATETIME)), 15.1);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-08-28 21:14:08' AS DATETIME)), 596.98);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-02-27 23:31:56' AS DATETIME)), 971.09);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-10-23 20:30:00' AS DATETIME)), 231.36);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-07-12 20:13:05' AS DATETIME)), 547.35);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-05-30 02:52:59' AS DATETIME)), 676.86);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-03-12 23:04:50' AS DATETIME)), 353.55);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-10-09 12:55:52' AS DATETIME)), 740.88);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-03-10 17:19:31' AS DATETIME)), 677.82);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-10-24 07:42:41' AS DATETIME)), 219.87);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-05-02 07:32:39' AS DATETIME)), 518.7);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-01-10 13:13:13' AS DATETIME)), 495.65);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-07-08 17:29:53' AS DATETIME)), 167.08);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-05-07 21:59:46' AS DATETIME)), 293.41);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-11-24 14:57:29' AS DATETIME)), 924.42);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-07-10 19:18:07' AS DATETIME)), 91.91);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-04-27 21:40:31' AS DATETIME)), 311.35);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-10-09 13:51:32' AS DATETIME)), 995.79);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-08-15 20:16:52' AS DATETIME)), 181.66);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-04-12 02:30:14' AS DATETIME)), 513.78);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-10-21 09:24:01' AS DATETIME)), 887.52);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-11-19 17:00:45' AS DATETIME)), 720.22);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-10-25 19:06:01' AS DATETIME)), 919.98);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-04-13 04:22:32' AS DATETIME)), 265.25);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-07-24 03:17:21' AS DATETIME)), 962.04);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-09-08 06:49:17' AS DATETIME)), 530.74);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-02-12 08:23:38' AS DATETIME)), 318.06);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-02-27 03:24:04' AS DATETIME)), 750.37);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-01-25 05:32:02' AS DATETIME)), 183.55);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-05-16 22:09:29' AS DATETIME)), 476.83);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-07-07 09:18:25' AS DATETIME)), 214.07);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-02-08 14:09:26' AS DATETIME)), 182.84);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-06-19 22:29:19' AS DATETIME)), 174.08);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-04-05 11:50:09' AS DATETIME)), 867.06);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-11-04 13:50:22' AS DATETIME)), 193.52);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-01-08 10:49:32' AS DATETIME)), 235.82);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-10-01 16:25:29' AS DATETIME)), 237.02);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-10-14 16:38:20' AS DATETIME)), 807.87);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-10-20 15:40:34' AS DATETIME)), 240.14);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-02-09 16:15:19' AS DATETIME)), 143.12);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-07-17 19:02:00' AS DATETIME)), 695.14);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-02-03 19:17:59' AS DATETIME)), 658.97);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-09-14 15:25:48' AS DATETIME)), 19.7);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-01-31 09:58:50' AS DATETIME)), 461.23);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-02-09 16:47:49' AS DATETIME)), 745.29);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-09-08 06:53:27' AS DATETIME)), 379.19);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-08-04 23:14:20' AS DATETIME)), 806.84);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-06-03 06:59:54' AS DATETIME)), 200.64);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-01-07 14:49:21' AS DATETIME)), 109.15);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-09-26 18:54:56' AS DATETIME)), 677.05);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-07-05 18:19:35' AS DATETIME)), 709.09);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-02-10 06:18:35' AS DATETIME)), 661.1);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-05-22 07:42:43' AS DATETIME)), 654.02);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-05-10 14:49:57' AS DATETIME)), 941.43);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-06-07 23:32:38' AS DATETIME)), 505.67);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-08-14 17:45:06' AS DATETIME)), 143.99);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-05-12 22:43:39' AS DATETIME)), 347.15);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-06-30 16:10:59' AS DATETIME)), 321.68);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-03-03 11:55:56' AS DATETIME)), 38.18);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-10-04 01:57:22' AS DATETIME)), 638.03);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-04-03 22:07:54' AS DATETIME)), 944.48);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-09-03 15:12:31' AS DATETIME)), 894.26);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-07-05 13:46:34' AS DATETIME)), 366.4);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-08-14 06:45:29' AS DATETIME)), 823.01);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-02-03 00:13:55' AS DATETIME)), 845.59);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-06-09 10:49:35' AS DATETIME)), 623.23);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-03-23 19:05:16' AS DATETIME)), 369.18);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-04-22 01:20:01' AS DATETIME)), 95.61);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-01-12 16:38:00' AS DATETIME)), 372.06);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-05-03 03:19:12' AS DATETIME)), 453.35);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-05-14 10:51:42' AS DATETIME)), 463.94);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-03-05 21:26:38' AS DATETIME)), 338.27);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-03-26 15:34:12' AS DATETIME)), 860.39);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-11-07 19:02:56' AS DATETIME)), 368.86);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-06-26 15:27:47' AS DATETIME)), 712.83);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-09-17 02:34:56' AS DATETIME)), 320.72);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-06-26 15:14:32' AS DATETIME)), 207.46);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-05-14 17:29:14' AS DATETIME)), 371.05);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-08-19 22:44:28' AS DATETIME)), 598.87);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-05-19 03:19:59' AS DATETIME)), 181.23);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-02-21 08:52:36' AS DATETIME)), 620.58);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-11-06 05:14:50' AS DATETIME)), 515.87);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-11-09 21:53:01' AS DATETIME)), 20.81);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-09-11 09:00:04' AS DATETIME)), 567.7);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-02-19 23:14:22' AS DATETIME)), 20.08);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-01-27 14:54:20' AS DATETIME)), 139.32);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-10-10 20:31:44' AS DATETIME)), 650.29);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-11-20 22:57:36' AS DATETIME)), 513.12);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-05-04 09:31:35' AS DATETIME)), 264.58);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-07-15 04:13:17' AS DATETIME)), 854.37);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-09-14 21:55:28' AS DATETIME)), 697.75);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-06-27 15:14:51' AS DATETIME)), 190.24);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-10-11 18:08:53' AS DATETIME)), 32.15);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-06-19 06:46:08' AS DATETIME)), 823.89);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-07-29 20:16:02' AS DATETIME)), 664.54);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-04-09 05:25:19' AS DATETIME)), 174.18);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-01-29 16:39:33' AS DATETIME)), 439.57);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-06-16 21:45:11' AS DATETIME)), 735.52);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-07-28 14:55:09' AS DATETIME)), 947.21);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-10-06 18:20:46' AS DATETIME)), 17.14);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-08-15 01:04:05' AS DATETIME)), 315.05);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-02-28 21:27:41' AS DATETIME)), 722.61);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-06-24 17:12:50' AS DATETIME)), 215.12);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-10-14 12:09:17' AS DATETIME)), 120.33);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-04-05 14:19:20' AS DATETIME)), 978.33);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-09-21 09:30:59' AS DATETIME)), 40.62);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-06-01 06:38:23' AS DATETIME)), 471.13);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-10-03 02:41:22' AS DATETIME)), 35.39);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-05-20 16:55:19' AS DATETIME)), 17.35);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-05-30 16:32:31' AS DATETIME)), 94.99);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-02-02 08:11:43' AS DATETIME)), 726.75);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-07-09 08:52:57' AS DATETIME)), 117.42);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-11-12 09:07:22' AS DATETIME)), 874.81);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-02-19 01:07:37' AS DATETIME)), 660.9);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-03-09 03:00:47' AS DATETIME)), 699.79);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-10-12 14:54:47' AS DATETIME)), 739.15);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-10-26 15:10:54' AS DATETIME)), 638.17);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-09-15 18:59:10' AS DATETIME)), 365.99);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-11-26 00:45:00' AS DATETIME)), 326.24);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-09-22 00:30:20' AS DATETIME)), 502.22);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-03-24 16:45:57' AS DATETIME)), 553.05);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-06-23 13:36:08' AS DATETIME)), 114.02);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-08-16 10:47:32' AS DATETIME)), 390.68);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-10-08 00:48:42' AS DATETIME)), 390.41);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-02-16 14:21:51' AS DATETIME)), 959.29);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-07-29 06:26:25' AS DATETIME)), 53.02);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-04-23 03:11:40' AS DATETIME)), 907.79);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-10-24 09:40:51' AS DATETIME)), 656.92);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-03-22 07:30:42' AS DATETIME)), 352.17);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-03-20 09:02:11' AS DATETIME)), 96.59);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-04-02 02:48:48' AS DATETIME)), 249.5);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-04-22 01:50:37' AS DATETIME)), 959.55);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-06-20 23:06:13' AS DATETIME)), 693.73);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-08-22 17:33:21' AS DATETIME)), 887.91);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-08-08 11:26:16' AS DATETIME)), 347.92);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-09-06 03:12:07' AS DATETIME)), 473.2);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-10-11 21:46:45' AS DATETIME)), 7.95);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-09-22 11:30:26' AS DATETIME)), 605.69);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-09-03 05:01:48' AS DATETIME)), 229.56);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-02-18 14:33:34' AS DATETIME)), 345.33);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-03-16 11:34:02' AS DATETIME)), 859.99);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-05-23 22:16:32' AS DATETIME)), 980.57);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-02-19 01:27:24' AS DATETIME)), 76.37);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-05-21 09:31:36' AS DATETIME)), 199.75);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-08-19 10:32:25' AS DATETIME)), 548.94);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-05-14 14:18:06' AS DATETIME)), 188.01);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-06-19 17:27:00' AS DATETIME)), 958.94);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-08-11 07:58:40' AS DATETIME)), 946.09);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-05-16 19:44:44' AS DATETIME)), 794.93);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-07-23 07:54:30' AS DATETIME)), 258.05);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-10-30 08:10:06' AS DATETIME)), 153.18);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-01-12 00:41:30' AS DATETIME)), 978.5);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-08-25 22:08:07' AS DATETIME)), 517.51);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-09-07 09:04:54' AS DATETIME)), 394.44);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-04-28 02:59:43' AS DATETIME)), 778.74);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-03-29 11:21:16' AS DATETIME)), 236.98);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-01-13 15:30:11' AS DATETIME)), 770.18);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-07-11 07:06:07' AS DATETIME)), 976.06);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-06-30 20:28:45' AS DATETIME)), 823.92);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-08-27 23:54:09' AS DATETIME)), 43.88);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-07-19 03:12:24' AS DATETIME)), 859.97);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-03-25 09:38:34' AS DATETIME)), 404.35);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-05-04 05:32:09' AS DATETIME)), 10.68);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-06-06 23:21:50' AS DATETIME)), 527.23);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-09-16 02:59:15' AS DATETIME)), 708.09);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-05-13 22:05:58' AS DATETIME)), 246.77);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-04-17 19:30:33' AS DATETIME)), 305.02);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-07-05 00:33:18' AS DATETIME)), 366.25);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-11-12 22:21:32' AS DATETIME)), 970.53);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-09-04 20:37:53' AS DATETIME)), 71.44);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-09-13 05:23:35' AS DATETIME)), 489.62);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-01-27 07:21:42' AS DATETIME)), 442.63);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-09-28 17:23:46' AS DATETIME)), 909.7);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-06-24 07:17:20' AS DATETIME)), 274.47);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-01-04 03:57:31' AS DATETIME)), 128.08);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-04-27 09:47:57' AS DATETIME)), 456.72);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-04-25 18:22:26' AS DATETIME)), 12.05);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-04-25 10:08:03' AS DATETIME)), 541.4);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-07-15 05:06:39' AS DATETIME)), 338.15);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-02-10 18:24:27' AS DATETIME)), 318.31);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-11-17 10:54:22' AS DATETIME)), 212.32);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-09-25 06:19:30' AS DATETIME)), 256.05);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-01-05 16:21:13' AS DATETIME)), 183.67);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-08-22 23:27:56' AS DATETIME)), 428.58);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-02-01 07:35:12' AS DATETIME)), 660.28);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-07-07 19:49:43' AS DATETIME)), 993.03);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-11-03 05:10:27' AS DATETIME)), 288.39);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-05-06 14:16:24' AS DATETIME)), 606.76);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-01-31 03:09:59' AS DATETIME)), 693.1);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-10-06 18:44:16' AS DATETIME)), 14.94);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-03-31 12:23:25' AS DATETIME)), 354.93);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-01-14 16:34:47' AS DATETIME)), 687.0);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-03-05 12:03:17' AS DATETIME)), 691.28);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-01-12 01:15:40' AS DATETIME)), 128.05);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-04-07 06:09:39' AS DATETIME)), 235.77);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-09-15 06:12:38' AS DATETIME)), 707.69);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-06-30 05:34:32' AS DATETIME)), 914.1);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-06-17 17:04:31' AS DATETIME)), 757.39);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-10-08 01:02:11' AS DATETIME)), 730.53);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-04-27 12:41:37' AS DATETIME)), 673.4);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-08-22 02:13:28' AS DATETIME)), 470.28);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-10-16 18:46:48' AS DATETIME)), 452.9);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-09-14 13:31:24' AS DATETIME)), 579.82);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-01-26 08:41:53' AS DATETIME)), 512.43);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-11-16 05:25:27' AS DATETIME)), 832.88);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-08-08 00:46:49' AS DATETIME)), 917.61);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-02-22 06:25:43' AS DATETIME)), 158.46);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-03-07 23:53:10' AS DATETIME)), 722.66);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-01-26 18:22:04' AS DATETIME)), 682.04);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-04-05 09:53:24' AS DATETIME)), 351.5);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-03-08 17:28:09' AS DATETIME)), 450.01);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-02-14 23:23:19' AS DATETIME)), 221.94);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-02-10 14:10:26' AS DATETIME)), 457.62);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-10-18 03:21:01' AS DATETIME)), 943.69);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-06-05 02:28:54' AS DATETIME)), 632.81);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-11-04 07:44:17' AS DATETIME)), 894.61);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-06-01 19:49:03' AS DATETIME)), 807.76);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-06-12 09:36:29' AS DATETIME)), 366.36);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-05-18 09:17:34' AS DATETIME)), 727.82);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-05-03 17:37:06' AS DATETIME)), 798.94);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-05-05 11:08:29' AS DATETIME)), 37.47);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-05-29 23:58:44' AS DATETIME)), 406.91);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-04-25 05:27:49' AS DATETIME)), 708.76);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-09-24 15:38:38' AS DATETIME)), 652.33);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-04-17 21:01:24' AS DATETIME)), 647.23);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-07-27 18:44:54' AS DATETIME)), 658.58);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-06-15 15:16:33' AS DATETIME)), 48.18);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-07-13 10:13:10' AS DATETIME)), 349.58);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-03-04 23:30:47' AS DATETIME)), 670.44);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-08-06 06:28:32' AS DATETIME)), 879.09);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-07-02 08:24:43' AS DATETIME)), 122.64);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-04-20 21:52:15' AS DATETIME)), 466.6);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-11-14 01:15:27' AS DATETIME)), 865.31);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-07-02 18:08:36' AS DATETIME)), 144.18);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-05-16 09:59:24' AS DATETIME)), 473.05);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-10-30 16:51:50' AS DATETIME)), 333.83);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-05-27 05:50:33' AS DATETIME)), 241.73);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-02-01 10:50:33' AS DATETIME)), 421.78);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-11-18 12:24:05' AS DATETIME)), 45.36);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-10-02 14:40:16' AS DATETIME)), 99.93);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-06-25 06:53:41' AS DATETIME)), 263.53);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-04-11 14:24:47' AS DATETIME)), 261.38);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-05-31 19:47:42' AS DATETIME)), 612.67);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-08-24 08:44:46' AS DATETIME)), 860.69);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-03-24 04:28:08' AS DATETIME)), 771.52);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-06-15 06:17:51' AS DATETIME)), 232.57);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-02-25 20:43:46' AS DATETIME)), 811.07);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-02-10 00:56:09' AS DATETIME)), 165.24);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-09-11 13:02:20' AS DATETIME)), 933.17);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-05-11 18:11:52' AS DATETIME)), 766.77);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-05-12 17:03:28' AS DATETIME)), 927.27);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-01-18 21:18:53' AS DATETIME)), 644.49);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-05-22 00:40:54' AS DATETIME)), 834.2);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-04-08 19:13:01' AS DATETIME)), 506.84);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-08-19 00:51:34' AS DATETIME)), 392.2);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-06-12 10:42:56' AS DATETIME)), 930.29);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-04-23 03:20:46' AS DATETIME)), 844.17);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-04-06 09:13:22' AS DATETIME)), 104.89);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-05-24 20:40:31' AS DATETIME)), 379.26);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-04-29 15:03:49' AS DATETIME)), 718.58);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-07-05 11:12:34' AS DATETIME)), 87.9);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-06-25 10:05:03' AS DATETIME)), 793.57);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-06-24 10:00:18' AS DATETIME)), 358.28);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-08-24 00:15:29' AS DATETIME)), 273.58);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-05-07 15:05:40' AS DATETIME)), 283.89);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-02-09 12:47:58' AS DATETIME)), 29.06);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-11-17 15:37:31' AS DATETIME)), 198.84);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-01-28 14:22:04' AS DATETIME)), 26.79);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-07-17 16:47:36' AS DATETIME)), 487.17);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-06-21 05:52:39' AS DATETIME)), 586.51);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-02-10 05:11:41' AS DATETIME)), 187.03);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-09-18 17:11:22' AS DATETIME)), 717.73);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-04-24 01:10:43' AS DATETIME)), 441.1);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-10-29 10:50:23' AS DATETIME)), 120.97);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-11-19 21:12:09' AS DATETIME)), 598.41);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-03-26 13:49:46' AS DATETIME)), 893.84);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-10-14 07:39:15' AS DATETIME)), 639.92);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-06-06 15:25:17' AS DATETIME)), 45.04);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-02-22 06:13:30' AS DATETIME)), 605.49);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-07-11 19:33:56' AS DATETIME)), 25.95);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-09-23 01:14:40' AS DATETIME)), 868.23);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-02-18 03:58:08' AS DATETIME)), 239.92);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-07-18 21:32:26' AS DATETIME)), 100.88);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-07-31 17:17:13' AS DATETIME)), 519.04);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-08-08 06:27:55' AS DATETIME)), 686.54);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-05-18 04:18:14' AS DATETIME)), 896.88);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-11-12 03:52:22' AS DATETIME)), 234.25);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-09-17 20:38:55' AS DATETIME)), 736.47);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-03-17 05:12:30' AS DATETIME)), 706.75);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-04-07 01:22:54' AS DATETIME)), 356.33);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-10-27 23:56:59' AS DATETIME)), 547.31);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-07-23 04:17:12' AS DATETIME)), 655.62);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-07-26 00:57:17' AS DATETIME)), 398.95);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-03-07 23:03:13' AS DATETIME)), 431.32);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-07-09 04:40:02' AS DATETIME)), 411.41);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-07-19 05:15:35' AS DATETIME)), 605.25);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-08-06 20:42:05' AS DATETIME)), 968.48);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-04-01 02:01:30' AS DATETIME)), 875.43);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-11-23 12:16:03' AS DATETIME)), 124.05);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-02-10 10:35:08' AS DATETIME)), 696.36);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-01-05 06:48:52' AS DATETIME)), 683.9);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-01-16 18:05:37' AS DATETIME)), 325.93);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-07-18 21:07:52' AS DATETIME)), 45.43);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-04-25 02:03:19' AS DATETIME)), 943.87);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-11-26 23:53:54' AS DATETIME)), 787.78);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-09-10 09:14:32' AS DATETIME)), 345.59);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-08-08 12:40:09' AS DATETIME)), 397.95);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-04-14 10:57:13' AS DATETIME)), 384.92);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-02-06 06:38:00' AS DATETIME)), 679.4);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-09-06 23:52:29' AS DATETIME)), 999.17);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-05-26 06:39:48' AS DATETIME)), 875.92);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-03-28 22:55:40' AS DATETIME)), 859.26);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-07-21 20:13:06' AS DATETIME)), 994.74);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-01-22 23:40:41' AS DATETIME)), 570.19);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-06-11 09:25:33' AS DATETIME)), 827.52);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-11-14 19:43:46' AS DATETIME)), 752.44);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-01-08 17:53:22' AS DATETIME)), 354.29);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-05-05 02:55:38' AS DATETIME)), 463.08);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-10-10 14:06:51' AS DATETIME)), 90.26);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-07-29 07:56:42' AS DATETIME)), 150.64);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-02-07 20:27:11' AS DATETIME)), 720.79);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-08-05 12:13:26' AS DATETIME)), 462.99);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-05-12 10:31:57' AS DATETIME)), 274.85);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-08-24 09:11:04' AS DATETIME)), 546.47);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-07-27 07:39:49' AS DATETIME)), 109.81);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-10-22 20:12:30' AS DATETIME)), 112.83);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-07-01 14:49:35' AS DATETIME)), 603.34);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-07-07 09:04:53' AS DATETIME)), 176.34);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-06-14 10:37:41' AS DATETIME)), 332.99);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-02-02 12:46:22' AS DATETIME)), 586.49);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-06-21 08:47:24' AS DATETIME)), 530.54);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-09-22 07:23:54' AS DATETIME)), 72.16);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-01-23 07:49:24' AS DATETIME)), 947.1);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-01-19 10:28:16' AS DATETIME)), 228.1);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-09-29 21:41:11' AS DATETIME)), 767.16);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-07-20 06:23:03' AS DATETIME)), 395.96);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-01-06 03:48:23' AS DATETIME)), 976.46);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-07-21 10:54:39' AS DATETIME)), 558.76);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-09-22 09:15:13' AS DATETIME)), 181.73);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-03-07 08:50:53' AS DATETIME)), 679.6);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-06-26 06:34:10' AS DATETIME)), 130.89);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-05-12 13:20:07' AS DATETIME)), 965.7);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-02-26 07:39:53' AS DATETIME)), 594.29);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-10-28 10:02:21' AS DATETIME)), 284.16);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-04-12 08:13:20' AS DATETIME)), 927.32);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-03-16 03:25:25' AS DATETIME)), 932.0);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-10-08 05:20:31' AS DATETIME)), 50.22);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-05-30 02:02:21' AS DATETIME)), 857.82);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-03-21 05:24:01' AS DATETIME)), 760.91);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-10-04 04:07:18' AS DATETIME)), 344.16);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-07-17 07:16:12' AS DATETIME)), 94.92);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-06-15 13:21:01' AS DATETIME)), 56.94);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-03-06 04:37:15' AS DATETIME)), 923.31);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-06-09 17:38:11' AS DATETIME)), 30.92);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-07-20 06:05:59' AS DATETIME)), 304.22);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-05-06 13:06:04' AS DATETIME)), 194.69);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-07-27 14:33:15' AS DATETIME)), 286.49);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-06-21 05:08:11' AS DATETIME)), 241.32);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-10-05 03:02:36' AS DATETIME)), 442.92);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-11-10 14:24:37' AS DATETIME)), 446.93);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-04-02 19:48:53' AS DATETIME)), 929.94);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-01-13 04:09:29' AS DATETIME)), 887.88);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-04-29 00:12:29' AS DATETIME)), 937.22);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-09-13 13:10:39' AS DATETIME)), 667.91);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-08-12 18:56:17' AS DATETIME)), 544.81);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-03-03 18:24:04' AS DATETIME)), 450.2);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-03-03 19:04:10' AS DATETIME)), 3.52);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-02-25 07:40:25' AS DATETIME)), 570.8);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-01-16 18:52:39' AS DATETIME)), 448.79);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-01-11 08:24:21' AS DATETIME)), 585.82);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-06-26 16:12:45' AS DATETIME)), 748.08);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-04-16 19:07:29' AS DATETIME)), 539.35);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-03-23 02:54:45' AS DATETIME)), 501.53);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-09-04 15:08:38' AS DATETIME)), 53.58);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-07-26 04:17:20' AS DATETIME)), 723.92);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-01-11 16:09:13' AS DATETIME)), 325.28);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-03-03 11:29:34' AS DATETIME)), 207.57);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-09-08 16:40:38' AS DATETIME)), 949.23);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-01-08 09:15:11' AS DATETIME)), 674.71);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-04-09 23:26:37' AS DATETIME)), 885.04);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-03-04 17:28:25' AS DATETIME)), 509.67);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-01-01 21:49:27' AS DATETIME)), 939.84);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-11-02 15:39:08' AS DATETIME)), 924.58);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-02-05 18:16:03' AS DATETIME)), 234.98);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-03-04 13:08:33' AS DATETIME)), 295.9);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-09-19 06:31:42' AS DATETIME)), 996.1);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-05-30 04:13:52' AS DATETIME)), 231.23);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-03-01 10:55:43' AS DATETIME)), 570.94);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-09-23 11:34:33' AS DATETIME)), 464.85);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-08-08 01:54:09' AS DATETIME)), 297.42);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-10-29 08:15:10' AS DATETIME)), 794.7);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-06-01 03:48:26' AS DATETIME)), 760.67);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-04-11 22:57:26' AS DATETIME)), 928.89);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-09-15 06:02:44' AS DATETIME)), 359.75);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-11-19 01:29:07' AS DATETIME)), 349.22);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-08-14 11:12:16' AS DATETIME)), 657.76);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-11-08 06:57:04' AS DATETIME)), 995.89);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-03-31 06:43:41' AS DATETIME)), 157.79);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-02-28 08:55:56' AS DATETIME)), 8.05);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-07-11 14:16:53' AS DATETIME)), 798.14);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-03-24 22:49:44' AS DATETIME)), 721.31);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-05-07 20:22:49' AS DATETIME)), 896.05);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-06-06 15:43:40' AS DATETIME)), 746.9);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-02-19 03:05:52' AS DATETIME)), 196.53);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-11-05 11:38:39' AS DATETIME)), 864.99);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-08-01 14:16:31' AS DATETIME)), 958.98);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-10-19 04:41:04' AS DATETIME)), 951.85);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-09-24 17:39:30' AS DATETIME)), 443.39);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-10-21 01:04:46' AS DATETIME)), 589.09);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-08-08 04:16:53' AS DATETIME)), 358.91);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-11-15 02:24:27' AS DATETIME)), 671.09);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-07-06 03:02:13' AS DATETIME)), 441.26);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-05-01 18:48:23' AS DATETIME)), 974.53);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-03-15 16:43:10' AS DATETIME)), 565.54);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-09-15 09:05:03' AS DATETIME)), 520.51);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-07-20 11:07:03' AS DATETIME)), 781.62);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-07-02 06:16:08' AS DATETIME)), 324.65);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-05-17 01:26:27' AS DATETIME)), 897.76);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-03-20 04:17:30' AS DATETIME)), 862.09);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-01-15 06:20:39' AS DATETIME)), 748.98);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-08-20 18:48:06' AS DATETIME)), 38.34);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-08-17 09:30:03' AS DATETIME)), 309.68);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-07-17 00:00:53' AS DATETIME)), 206.24);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-01-22 18:39:05' AS DATETIME)), 72.91);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-10-10 10:02:33' AS DATETIME)), 18.29);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-11-10 02:08:36' AS DATETIME)), 127.44);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-02-20 19:25:22' AS DATETIME)), 116.72);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-06-01 19:51:53' AS DATETIME)), 682.37);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-10-21 17:09:50' AS DATETIME)), 570.27);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-01-23 13:58:51' AS DATETIME)), 33.22);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-09-25 21:56:05' AS DATETIME)), 125.86);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-06-07 07:49:33' AS DATETIME)), 127.23);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-06-10 23:08:10' AS DATETIME)), 798.26);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-09-04 23:50:01' AS DATETIME)), 844.93);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-02-15 03:42:38' AS DATETIME)), 389.19);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-07-30 09:49:25' AS DATETIME)), 781.17);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-05-12 12:05:48' AS DATETIME)), 44.8);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-04-22 07:34:38' AS DATETIME)), 794.96);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-07-28 03:31:32' AS DATETIME)), 873.46);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-08-20 22:15:05' AS DATETIME)), 346.47);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-06-10 02:30:30' AS DATETIME)), 981.47);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-03-19 06:44:34' AS DATETIME)), 772.07);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-10-17 01:18:12' AS DATETIME)), 731.37);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-04-05 18:20:50' AS DATETIME)), 23.05);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-08-22 13:38:02' AS DATETIME)), 93.26);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-06-20 19:57:17' AS DATETIME)), 332.82);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-09-20 05:33:33' AS DATETIME)), 4.09);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-10-19 04:04:36' AS DATETIME)), 907.24);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-03-02 09:02:12' AS DATETIME)), 495.65);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-07-10 16:07:38' AS DATETIME)), 198.55);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-03-07 17:56:08' AS DATETIME)), 940.72);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-09-25 05:43:39' AS DATETIME)), 982.71);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-02-16 03:46:45' AS DATETIME)), 21.51);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-10-31 00:06:12' AS DATETIME)), 709.78);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-08-01 19:33:50' AS DATETIME)), 647.57);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-04-05 07:37:42' AS DATETIME)), 210.66);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-08-12 12:04:26' AS DATETIME)), 465.32);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-03-22 22:02:05' AS DATETIME)), 22.79);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-10-06 13:04:12' AS DATETIME)), 59.75);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-06-07 06:56:47' AS DATETIME)), 402.41);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-01-18 21:19:23' AS DATETIME)), 656.86);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-03-04 16:08:06' AS DATETIME)), 712.57);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-09-08 09:58:02' AS DATETIME)), 304.87);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-01-18 05:52:19' AS DATETIME)), 91.83);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-10-31 22:17:06' AS DATETIME)), 213.86);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-11-07 11:30:57' AS DATETIME)), 73.98);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-07-12 16:19:01' AS DATETIME)), 910.23);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-04-09 15:11:59' AS DATETIME)), 237.61);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-08-19 23:26:54' AS DATETIME)), 42.21);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-04-24 16:02:23' AS DATETIME)), 347.17);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-10-19 18:29:06' AS DATETIME)), 209.24);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-04-22 03:34:39' AS DATETIME)), 979.79);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-10-01 18:34:23' AS DATETIME)), 425.51);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-05-27 21:45:52' AS DATETIME)), 549.1);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-06-08 11:34:37' AS DATETIME)), 3.5);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-02-06 01:58:51' AS DATETIME)), 319.38);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-11-10 17:00:13' AS DATETIME)), 280.19);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-05-12 17:25:40' AS DATETIME)), 767.01);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-07-06 19:38:29' AS DATETIME)), 633.24);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-10-04 04:41:41' AS DATETIME)), 355.33);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-02-10 06:25:19' AS DATETIME)), 204.35);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-08-13 17:42:54' AS DATETIME)), 336.85);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-07-31 14:48:25' AS DATETIME)), 111.08);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-01-15 19:11:56' AS DATETIME)), 300.54);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-02-08 12:57:34' AS DATETIME)), 838.37);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-08-02 12:48:44' AS DATETIME)), 373.71);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-05-10 02:40:19' AS DATETIME)), 447.77);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-08-13 17:24:26' AS DATETIME)), 911.4);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-10-31 05:18:15' AS DATETIME)), 691.51);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-01-08 21:05:03' AS DATETIME)), 908.14);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-11-13 21:06:59' AS DATETIME)), 559.38);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-09-05 23:50:28' AS DATETIME)), 844.94);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-05-10 00:24:34' AS DATETIME)), 28.81);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-03-26 21:41:32' AS DATETIME)), 50.33);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-09-03 10:37:37' AS DATETIME)), 705.89);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-07-28 12:54:24' AS DATETIME)), 184.68);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-11-03 09:37:07' AS DATETIME)), 564.59);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-10-23 03:30:40' AS DATETIME)), 396.18);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-06-17 03:35:04' AS DATETIME)), 487.28);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-03-31 18:50:05' AS DATETIME)), 481.0);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-06-24 13:11:25' AS DATETIME)), 997.61);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-11-01 07:25:08' AS DATETIME)), 590.08);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-04-30 11:37:17' AS DATETIME)), 359.7);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-07-14 08:16:17' AS DATETIME)), 170.49);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-05-31 00:24:30' AS DATETIME)), 505.07);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-11-12 22:35:48' AS DATETIME)), 623.73);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-04-02 15:43:26' AS DATETIME)), 73.25);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-01-15 13:22:21' AS DATETIME)), 893.4);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-06-28 06:38:33' AS DATETIME)), 885.03);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-10-25 06:37:28' AS DATETIME)), 70.06);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-03-31 09:08:36' AS DATETIME)), 253.12);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-09-27 20:52:20' AS DATETIME)), 8.34);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-11-12 08:51:57' AS DATETIME)), 939.72);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-02-26 17:35:05' AS DATETIME)), 146.09);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-02-02 11:50:09' AS DATETIME)), 444.23);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-10-31 17:29:52' AS DATETIME)), 884.58);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-07-22 16:40:06' AS DATETIME)), 697.0);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-05-01 09:05:01' AS DATETIME)), 340.33);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-03-03 05:47:16' AS DATETIME)), 709.81);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-09-19 21:06:28' AS DATETIME)), 165.46);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-01-10 10:24:17' AS DATETIME)), 823.16);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-02-03 18:15:25' AS DATETIME)), 247.08);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-02-25 08:29:17' AS DATETIME)), 271.42);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-05-04 08:27:24' AS DATETIME)), 342.68);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-01-27 16:20:59' AS DATETIME)), 992.92);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-04-13 00:09:44' AS DATETIME)), 16.58);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-05-04 21:19:59' AS DATETIME)), 22.12);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-10-26 15:25:18' AS DATETIME)), 211.95);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-01-05 05:21:31' AS DATETIME)), 926.52);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-10-21 08:04:51' AS DATETIME)), 409.92);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-09-10 23:53:11' AS DATETIME)), 930.94);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-09-01 10:51:02' AS DATETIME)), 949.73);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-07-09 23:12:41' AS DATETIME)), 43.32);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-09-20 00:55:55' AS DATETIME)), 911.47);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-07-16 00:28:56' AS DATETIME)), 312.9);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-11-08 06:19:07' AS DATETIME)), 488.98);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-10-30 04:20:00' AS DATETIME)), 467.16);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-04-19 22:02:15' AS DATETIME)), 622.02);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-05-31 15:09:37' AS DATETIME)), 904.72);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-01-23 05:51:54' AS DATETIME)), 352.97);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-07-17 14:47:11' AS DATETIME)), 413.2);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-02-10 15:40:05' AS DATETIME)), 48.51);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-11-13 15:28:13' AS DATETIME)), 654.76);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-05-03 22:28:32' AS DATETIME)), 408.09);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-08-10 23:08:24' AS DATETIME)), 832.46);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-05-10 20:04:38' AS DATETIME)), 910.22);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-02-21 21:58:46' AS DATETIME)), 600.27);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-10-07 16:35:20' AS DATETIME)), 987.59);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-08-25 22:12:33' AS DATETIME)), 247.24);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-10-27 15:35:41' AS DATETIME)), 785.22);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-01-24 23:02:16' AS DATETIME)), 513.35);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-10-22 05:40:03' AS DATETIME)), 297.13);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-01-21 06:55:17' AS DATETIME)), 89.99);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-02-14 22:22:55' AS DATETIME)), 690.67);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-04-10 23:32:17' AS DATETIME)), 935.1);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-04-23 18:54:25' AS DATETIME)), 909.91);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-11-12 19:38:21' AS DATETIME)), 785.74);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-07-04 23:54:20' AS DATETIME)), 985.99);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-11-18 09:06:25' AS DATETIME)), 936.21);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-08-28 15:51:32' AS DATETIME)), 92.5);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-03-12 02:58:25' AS DATETIME)), 368.73);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-10-15 07:23:16' AS DATETIME)), 725.98);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-08-29 09:25:38' AS DATETIME)), 533.7);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-01-28 06:53:22' AS DATETIME)), 775.76);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-09-25 03:17:58' AS DATETIME)), 556.64);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-07-04 18:35:51' AS DATETIME)), 47.75);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-08-29 21:09:48' AS DATETIME)), 401.17);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-04-11 00:21:31' AS DATETIME)), 674.6);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-07-11 17:38:46' AS DATETIME)), 467.95);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-04-15 17:56:29' AS DATETIME)), 224.64);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-07-02 02:36:11' AS DATETIME)), 876.61);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-10-06 12:39:22' AS DATETIME)), 959.68);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-09-09 14:07:40' AS DATETIME)), 595.03);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-03-27 19:22:08' AS DATETIME)), 23.99);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-07-01 15:18:16' AS DATETIME)), 746.31);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-01-25 00:55:13' AS DATETIME)), 191.98);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-07-16 15:16:41' AS DATETIME)), 345.75);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-07-20 06:00:46' AS DATETIME)), 766.44);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-08-27 14:07:49' AS DATETIME)), 900.83);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-05-13 05:23:30' AS DATETIME)), 996.94);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-07-08 07:07:15' AS DATETIME)), 571.38);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-09-15 23:49:33' AS DATETIME)), 856.09);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-05-23 22:17:22' AS DATETIME)), 619.48);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-04-24 06:18:39' AS DATETIME)), 772.19);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-07-24 19:20:59' AS DATETIME)), 688.97);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-10-06 20:38:49' AS DATETIME)), 250.26);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-08-12 04:58:10' AS DATETIME)), 444.89);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-05-30 18:53:36' AS DATETIME)), 968.73);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-06-05 10:57:40' AS DATETIME)), 532.44);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-01-04 00:43:09' AS DATETIME)), 2.86);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-10-02 14:33:19' AS DATETIME)), 112.59);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-06-10 13:40:12' AS DATETIME)), 297.9);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-06-06 15:37:58' AS DATETIME)), 269.0);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-04-19 07:15:39' AS DATETIME)), 83.63);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-11-16 20:36:32' AS DATETIME)), 751.74);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-08-30 08:00:15' AS DATETIME)), 356.33);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-09-18 22:26:20' AS DATETIME)), 736.64);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-09-24 10:04:23' AS DATETIME)), 564.72);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-03-23 04:26:25' AS DATETIME)), 202.3);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-03-24 06:19:33' AS DATETIME)), 764.83);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-02-06 19:47:09' AS DATETIME)), 490.05);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-01-07 00:27:13' AS DATETIME)), 45.86);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-09-23 15:44:04' AS DATETIME)), 218.12);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-02-09 02:43:09' AS DATETIME)), 31.85);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-09-12 07:45:40' AS DATETIME)), 178.96);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-07-12 15:27:22' AS DATETIME)), 720.12);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-03-27 18:17:10' AS DATETIME)), 747.72);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-05-24 04:13:46' AS DATETIME)), 696.55);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-05-10 20:33:31' AS DATETIME)), 783.66);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-05-18 13:17:08' AS DATETIME)), 255.34);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-05-31 09:12:06' AS DATETIME)), 258.14);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-04-20 01:29:25' AS DATETIME)), 636.53);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-08-15 14:50:24' AS DATETIME)), 696.6);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-08-15 17:42:55' AS DATETIME)), 29.28);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-08-26 01:26:02' AS DATETIME)), 61.71);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-08-01 23:42:44' AS DATETIME)), 953.77);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-05-29 02:59:02' AS DATETIME)), 825.57);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-02-10 13:57:40' AS DATETIME)), 935.99);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-04-24 16:08:59' AS DATETIME)), 505.92);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-01-05 21:03:30' AS DATETIME)), 560.42);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-07-15 21:03:56' AS DATETIME)), 827.87);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-09-28 04:14:58' AS DATETIME)), 557.1);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-09-27 19:54:29' AS DATETIME)), 425.83);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-02-05 06:02:27' AS DATETIME)), 481.06);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-07-16 22:17:47' AS DATETIME)), 557.72);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-08-31 18:39:46' AS DATETIME)), 262.55);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-11-10 13:21:07' AS DATETIME)), 337.76);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-04-14 05:07:05' AS DATETIME)), 751.06);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-07-15 19:11:40' AS DATETIME)), 665.77);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-07-22 21:14:35' AS DATETIME)), 270.78);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-07-09 22:28:52' AS DATETIME)), 218.26);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-08-04 12:41:01' AS DATETIME)), 893.0);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-05-01 22:19:48' AS DATETIME)), 7.18);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-09-05 21:05:19' AS DATETIME)), 841.82);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-06-01 15:25:55' AS DATETIME)), 184.33);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-04-21 16:19:24' AS DATETIME)), 597.06);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-07-29 01:51:23' AS DATETIME)), 323.75);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-03-23 00:32:34' AS DATETIME)), 951.47);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-01-25 23:14:00' AS DATETIME)), 976.24);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-07-15 10:48:45' AS DATETIME)), 823.58);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-10-18 17:17:47' AS DATETIME)), 210.34);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-10-13 21:43:32' AS DATETIME)), 964.33);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-04-14 19:25:54' AS DATETIME)), 973.53);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-09-11 20:35:57' AS DATETIME)), 711.64);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-10-17 12:50:35' AS DATETIME)), 624.57);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-10-16 07:20:37' AS DATETIME)), 414.04);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-11-06 02:39:21' AS DATETIME)), 335.8);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-05-31 22:30:52' AS DATETIME)), 976.36);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-07-30 13:03:28' AS DATETIME)), 23.17);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-03-19 20:30:00' AS DATETIME)), 425.77);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-06-08 19:28:17' AS DATETIME)), 862.66);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-02-19 04:28:15' AS DATETIME)), 967.95);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-02-23 13:57:08' AS DATETIME)), 723.39);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-10-17 06:05:01' AS DATETIME)), 983.49);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-08-28 08:34:38' AS DATETIME)), 957.98);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-10-19 12:12:06' AS DATETIME)), 999.11);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-03-16 09:11:03' AS DATETIME)), 211.6);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-01-26 20:51:58' AS DATETIME)), 138.84);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-09-13 10:52:17' AS DATETIME)), 319.71);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-08-27 07:42:29' AS DATETIME)), 758.77);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-04-28 01:50:30' AS DATETIME)), 300.94);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-03-04 19:50:24' AS DATETIME)), 25.44);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-08-27 08:18:51' AS DATETIME)), 653.61);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-10-18 09:27:50' AS DATETIME)), 865.39);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-07-24 00:12:03' AS DATETIME)), 742.24);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-03-08 03:46:01' AS DATETIME)), 312.39);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-03-05 08:52:33' AS DATETIME)), 81.77);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-07-12 10:08:01' AS DATETIME)), 279.33);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-08-23 01:36:32' AS DATETIME)), 310.16);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-06-03 18:45:49' AS DATETIME)), 870.68);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-07-26 09:23:14' AS DATETIME)), 177.39);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-08-19 17:10:17' AS DATETIME)), 397.27);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-02-27 23:22:49' AS DATETIME)), 43.78);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-10-03 14:07:58' AS DATETIME)), 334.85);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-06-17 20:24:27' AS DATETIME)), 497.65);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-10-01 19:24:00' AS DATETIME)), 917.01);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-08-25 13:40:00' AS DATETIME)), 226.78);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-09-04 17:34:04' AS DATETIME)), 965.28);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-11-08 02:01:37' AS DATETIME)), 793.66);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-03-14 02:00:15' AS DATETIME)), 643.34);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-10-24 23:39:20' AS DATETIME)), 389.14);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-02-08 16:39:01' AS DATETIME)), 62.81);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-02-08 16:58:27' AS DATETIME)), 387.69);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-06-19 15:44:39' AS DATETIME)), 632.01);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-02-21 05:56:18' AS DATETIME)), 182.96);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-08-07 22:59:27' AS DATETIME)), 674.92);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-02-12 13:24:44' AS DATETIME)), 62.82);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-05-07 05:17:42' AS DATETIME)), 682.88);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-10-11 01:16:28' AS DATETIME)), 219.68);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-07-26 04:46:09' AS DATETIME)), 693.81);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-02-14 08:46:12' AS DATETIME)), 15.08);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-02-16 20:06:06' AS DATETIME)), 415.45);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-08-14 05:53:31' AS DATETIME)), 642.53);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-02-16 22:30:11' AS DATETIME)), 982.43);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-10-10 07:06:18' AS DATETIME)), 407.68);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-02-15 01:49:05' AS DATETIME)), 471.38);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-06-18 14:15:47' AS DATETIME)), 910.38);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-07-29 10:41:03' AS DATETIME)), 847.19);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-11-23 15:25:09' AS DATETIME)), 752.6);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-07-09 20:59:33' AS DATETIME)), 739.92);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-01-26 09:51:13' AS DATETIME)), 243.67);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-09-10 06:01:52' AS DATETIME)), 804.23);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-10-17 14:43:48' AS DATETIME)), 972.33);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-01-26 13:46:08' AS DATETIME)), 447.08);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-09-24 01:38:34' AS DATETIME)), 645.51);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-06-20 07:01:23' AS DATETIME)), 424.85);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-10-11 09:13:54' AS DATETIME)), 288.84);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-07-14 22:15:10' AS DATETIME)), 42.13);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-11-21 03:56:54' AS DATETIME)), 891.78);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-02-09 08:07:40' AS DATETIME)), 830.43);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-04-21 16:57:50' AS DATETIME)), 389.34);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-09-14 05:40:29' AS DATETIME)), 199.57);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-06-05 08:12:35' AS DATETIME)), 19.14);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-09-13 09:57:15' AS DATETIME)), 161.05);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-10-06 04:28:54' AS DATETIME)), 161.39);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-04-22 19:20:09' AS DATETIME)), 988.31);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-11-24 13:01:54' AS DATETIME)), 480.67);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-10-07 10:58:03' AS DATETIME)), 95.18);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-07-17 19:43:27' AS DATETIME)), 735.07);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-09-10 05:08:32' AS DATETIME)), 537.28);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-05-08 21:43:40' AS DATETIME)), 713.86);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-03-06 22:41:42' AS DATETIME)), 509.46);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-11-19 11:34:19' AS DATETIME)), 285.85);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-03-22 18:30:21' AS DATETIME)), 286.42);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-11-05 00:02:48' AS DATETIME)), 711.96);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-07-28 06:50:55' AS DATETIME)), 256.81);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-04-15 16:09:57' AS DATETIME)), 698.96);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-10-27 20:38:20' AS DATETIME)), 623.31);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-02-15 03:48:20' AS DATETIME)), 491.0);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-10-09 09:18:06' AS DATETIME)), 822.38);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-10-26 16:22:34' AS DATETIME)), 552.52);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-07-19 13:53:08' AS DATETIME)), 882.55);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-07-13 13:26:42' AS DATETIME)), 643.76);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-03-21 12:42:17' AS DATETIME)), 967.16);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-09-05 10:15:47' AS DATETIME)), 56.0);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-11-20 22:30:01' AS DATETIME)), 161.41);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-06-16 22:59:00' AS DATETIME)), 425.18);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-09-12 19:48:01' AS DATETIME)), 485.52);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-03-12 07:07:43' AS DATETIME)), 282.62);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-09-22 21:28:01' AS DATETIME)), 671.01);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-09-22 16:50:59' AS DATETIME)), 856.09);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-07-23 14:00:57' AS DATETIME)), 308.51);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-03-17 18:48:56' AS DATETIME)), 178.83);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-10-02 08:00:22' AS DATETIME)), 496.48);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-02-22 01:58:51' AS DATETIME)), 279.04);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-02-03 23:23:46' AS DATETIME)), 900.79);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-08-09 19:11:42' AS DATETIME)), 437.92);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-01-12 15:00:34' AS DATETIME)), 146.73);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-06-02 11:36:21' AS DATETIME)), 34.97);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-03-03 21:15:34' AS DATETIME)), 960.75);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-01-16 15:05:16' AS DATETIME)), 558.41);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-08-15 18:22:40' AS DATETIME)), 278.46);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-06-07 16:03:11' AS DATETIME)), 612.69);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-10-06 23:33:29' AS DATETIME)), 283.34);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-07-09 04:07:32' AS DATETIME)), 93.48);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-10-07 08:24:47' AS DATETIME)), 848.05);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-08-25 07:55:50' AS DATETIME)), 865.72);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-05-31 22:24:16' AS DATETIME)), 703.48);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-04-15 04:15:26' AS DATETIME)), 530.4);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-08-24 04:26:26' AS DATETIME)), 154.46);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-01-01 04:47:44' AS DATETIME)), 844.34);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-11-01 18:17:01' AS DATETIME)), 236.96);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-05-05 21:40:41' AS DATETIME)), 883.94);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-10-12 07:56:36' AS DATETIME)), 581.42);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-10-11 03:39:32' AS DATETIME)), 881.5);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-03-10 08:16:00' AS DATETIME)), 437.95);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-09-19 03:34:30' AS DATETIME)), 554.01);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-05-05 02:42:16' AS DATETIME)), 348.95);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-09-07 20:27:36' AS DATETIME)), 654.82);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-08-15 15:57:35' AS DATETIME)), 986.68);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-10-10 07:42:12' AS DATETIME)), 431.33);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-08-30 13:28:04' AS DATETIME)), 177.84);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-01-04 20:17:37' AS DATETIME)), 694.35);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-10-15 23:18:42' AS DATETIME)), 572.76);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-03-05 07:42:50' AS DATETIME)), 677.51);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-04-08 16:39:04' AS DATETIME)), 356.53);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-05-19 10:51:22' AS DATETIME)), 968.88);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-09-25 08:35:31' AS DATETIME)), 319.7);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-03-02 18:34:19' AS DATETIME)), 468.92);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-04-26 04:19:06' AS DATETIME)), 175.38);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-10-18 12:12:30' AS DATETIME)), 957.91);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-03-02 19:37:28' AS DATETIME)), 183.45);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-11-17 00:44:41' AS DATETIME)), 788.89);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-09-25 11:16:37' AS DATETIME)), 694.63);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-06-13 04:38:18' AS DATETIME)), 539.53);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-01-12 05:08:41' AS DATETIME)), 12.47);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-11-05 06:25:40' AS DATETIME)), 463.82);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-08-18 02:04:12' AS DATETIME)), 684.18);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-07-07 07:38:10' AS DATETIME)), 642.76);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-06-02 23:28:02' AS DATETIME)), 674.15);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-10-12 15:28:03' AS DATETIME)), 727.86);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-01-28 18:06:07' AS DATETIME)), 220.9);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-08-25 23:13:26' AS DATETIME)), 636.83);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-11-16 04:20:15' AS DATETIME)), 659.6);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-05-23 18:43:12' AS DATETIME)), 854.41);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-09-19 21:42:41' AS DATETIME)), 906.89);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-01-19 07:07:05' AS DATETIME)), 358.9);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-07-05 19:26:32' AS DATETIME)), 655.36);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-10-12 02:15:28' AS DATETIME)), 779.69);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-01-25 15:18:25' AS DATETIME)), 497.77);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-03-23 04:09:35' AS DATETIME)), 123.34);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-04-08 23:46:12' AS DATETIME)), 42.14);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-06-26 08:10:56' AS DATETIME)), 706.41);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-09-10 22:36:57' AS DATETIME)), 144.07);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-07-26 06:47:38' AS DATETIME)), 76.7);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-05-22 19:19:51' AS DATETIME)), 89.33);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-02-18 12:43:33' AS DATETIME)), 134.87);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-11-15 17:51:03' AS DATETIME)), 685.41);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-07-05 21:35:15' AS DATETIME)), 374.11);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-08-15 17:39:34' AS DATETIME)), 630.64);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-03-11 23:07:25' AS DATETIME)), 229.48);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-09-23 04:37:22' AS DATETIME)), 857.18);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-05-04 18:45:41' AS DATETIME)), 305.36);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-11-05 08:39:12' AS DATETIME)), 165.11);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-09-01 20:29:28' AS DATETIME)), 201.26);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-07-17 12:12:06' AS DATETIME)), 537.74);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-10-08 10:16:40' AS DATETIME)), 121.14);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-07-22 21:56:43' AS DATETIME)), 901.57);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-07-02 02:56:08' AS DATETIME)), 403.87);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-06-15 01:33:40' AS DATETIME)), 379.96);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-11-09 11:28:30' AS DATETIME)), 459.07);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-06-05 01:57:17' AS DATETIME)), 351.85);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-07-26 15:11:07' AS DATETIME)), 466.14);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-10-24 19:26:29' AS DATETIME)), 881.67);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-04-17 04:55:51' AS DATETIME)), 827.56);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-09-18 14:19:59' AS DATETIME)), 220.57);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-03-24 15:27:01' AS DATETIME)), 846.32);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (3,(CAST('2025-02-17 08:11:55' AS DATETIME)), 112.6);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-08-13 17:24:48' AS DATETIME)), 63.66);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-06-01 08:49:51' AS DATETIME)), 93.23);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (8,(CAST('2025-06-21 10:39:59' AS DATETIME)), 490.35);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-06-30 01:17:24' AS DATETIME)), 176.19);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-03-22 16:55:12' AS DATETIME)), 177.97);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-03-02 00:03:33' AS DATETIME)), 260.29);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-06-16 21:35:00' AS DATETIME)), 691.66);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-10-25 17:56:01' AS DATETIME)), 153.51);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-09-25 14:13:47' AS DATETIME)), 307.83);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-06-12 07:53:20' AS DATETIME)), 88.21);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-05-14 07:22:16' AS DATETIME)), 203.2);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-04-17 18:12:09' AS DATETIME)), 966.65);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (4,(CAST('2025-05-13 14:50:12' AS DATETIME)), 833.12);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (7,(CAST('2025-05-20 01:41:21' AS DATETIME)), 164.48);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-08-17 13:33:48' AS DATETIME)), 872.28);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-07-25 20:34:25' AS DATETIME)), 740.11);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-06-13 15:12:59' AS DATETIME)), 122.59);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (2,(CAST('2025-09-19 04:03:15' AS DATETIME)), 915.02);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-04-16 18:28:13' AS DATETIME)), 75.6);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-09-29 05:57:25' AS DATETIME)), 406.37);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (6,(CAST('2025-08-27 16:49:28' AS DATETIME)), 364.24);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-02-10 12:39:46' AS DATETIME)), 466.91);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-06-20 14:32:41' AS DATETIME)), 660.39);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-06-19 19:44:34' AS DATETIME)), 168.13);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (10,(CAST('2025-10-29 00:07:39' AS DATETIME)), 253.27);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-03-03 13:40:14' AS DATETIME)), 467.44);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (5,(CAST('2025-01-02 05:07:59' AS DATETIME)), 617.65);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (9,(CAST('2025-07-10 02:32:54' AS DATETIME)), 414.86);
insert into Ventas.Venta(SocioID, FechaVenta, Total) values (1,(CAST('2025-04-21 08:47:17' AS DATETIME)), 894.9);



-- 5. SEGURIDAD (ROLES Y USUARIOS)
USE master;
GO
-- Eliminamos logins si ya existen para evitar errores al re-ejecutar
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'adminGym') DROP LOGIN adminGym;
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'recepcionGym') DROP LOGIN recepcionGym;
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'instructorGym') DROP LOGIN instructorGym;
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'lectorGym') DROP LOGIN lectorGym;

CREATE LOGIN adminGym WITH PASSWORD = 'Admin@123';
CREATE LOGIN recepcionGym WITH PASSWORD = 'Recep@123';
CREATE LOGIN instructorGym WITH PASSWORD = 'Inst@123';
CREATE LOGIN lectorGym WITH PASSWORD = 'Read@123';
GO

USE GymDB;
GO

CREATE USER adminGym FOR LOGIN adminGym;
CREATE USER recepcionGym FOR LOGIN recepcionGym;
CREATE USER instructorGym FOR LOGIN instructorGym;
CREATE USER lectorGym FOR LOGIN lectorGym;

-- Roles definidos
CREATE ROLE RolAdmin;
CREATE ROLE RolRecepcion;
CREATE ROLE RolInstructor;
CREATE ROLE RolLector;

-- Asignación
ALTER ROLE db_owner ADD MEMBER RolAdmin; -- Admin tiene todo
ALTER ROLE RolAdmin ADD MEMBER adminGym;

ALTER ROLE RolRecepcion ADD MEMBER recepcionGym;
ALTER ROLE RolInstructor ADD MEMBER instructorGym;
ALTER ROLE RolLector ADD MEMBER lectorGym;

-- Permisos Granulares (Principio de mínimo privilegio)
-- RECEPCION: Puede ver y cobrar, registrar socios
GRANT SELECT, INSERT, UPDATE ON SCHEMA::Membresia TO RolRecepcion;
GRANT SELECT, INSERT ON SCHEMA::Ventas TO RolRecepcion;

-- INSTRUCTOR: Solo ve sus clases y socios
GRANT SELECT ON SCHEMA::Membresia TO RolInstructor;
GRANT SELECT ON SCHEMA::RRHH TO RolInstructor;

-- LECTOR (BI): Solo lee todo
GRANT SELECT ON DATABASE::GymDB TO RolLector;
GO

-- 6. ÍNDICES Y OPTIMIZACIÓN
CREATE INDEX IX_Socio_Email ON Membresia.Socio(Email);
CREATE INDEX IX_Socio_TipoMembresia ON Membresia.Socio(TipoMembresia);
CREATE INDEX IX_HorarioClase_FechaInicio ON Membresia.HorarioClase(FechaHoraInicio);
CREATE INDEX IX_Producto_Nombre ON Ventas.Producto(Nombre);
GO

-- 7. VISTAS (Reporting)

-- Vista 1: Pagos por Socio
CREATE OR ALTER VIEW Ventas.vw_PagosPorSocio AS
SELECT 
    S.SocioID, S.Nombres + ' ' + S.Apellidos AS Socio,
    P.Monto, P.FechaPago,
    SUM(P.Monto) OVER(PARTITION BY P.SocioID) AS TotalPagado
FROM Ventas.Pago P
INNER JOIN Membresia.Socio S ON P.SocioID = S.SocioID;
GO

-- Vista 2: Ranking de Ingresos
CREATE OR ALTER VIEW Ventas.vw_RankingSociosPagos AS
SELECT 
    S.SocioID, S.Nombres + ' ' + S.Apellidos AS Socio,
    SUM(P.Monto) AS TotalPagado,
    RANK() OVER (ORDER BY SUM(P.Monto) DESC) AS Ranking
FROM Ventas.Pago P
INNER JOIN Membresia.Socio S ON P.SocioID = S.SocioID
GROUP BY S.SocioID, S.Nombres, S.Apellidos;
GO

-- Vista 3 — Última reserva por socio (CTE + Window Function)
GO
CREATE OR ALTER VIEW Membresia.vw_UltimaReservaSocio AS
WITH UltimasReservas AS (
    SELECT
        R.SocioID,
        S.Nombres + ' ' + S.Apellidos AS Socio,
        R.FechaReserva,
        ROW_NUMBER() OVER(PARTITION BY R.SocioID ORDER BY R.FechaReserva DESC) AS RN
    FROM Membresia.Reserva R
    JOIN Membresia.Socio S ON R.SocioID = S.SocioID
)
SELECT SocioID, Socio, FechaReserva AS UltimaReserva
FROM UltimasReservas
WHERE RN = 1;
GO

-- Vista 4 — Ventas y porcentaje del total global
GO
CREATE OR ALTER VIEW Ventas.vw_VentasPorcentaje AS
SELECT
    V.VentaID,
    V.SocioID,
    S.Nombres + ' ' + S.Apellidos AS Socio,
    V.Total,
    -- Uso de OVER() vacío para el total global
    ROUND(V.Total * 100.0 / SUM(V.Total) OVER(), 2) AS PorcentajeTotal
FROM Ventas.Venta V
LEFT JOIN Membresia.Socio S ON V.SocioID = S.SocioID;
GO

-- 8. TRIGGERS Y LÓGICA DE NEGOCIO

-- Trigger: Actualizar Stock tras venta
GO
CREATE OR ALTER TRIGGER Ventas.trg_ActualizarStock_DespuesVenta
ON Ventas.DetalleVenta
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE p
    SET p.Stock = p.Stock - i.Cantidad
    FROM Ventas.Producto p
    INNER JOIN inserted i ON p.ProductoID = i.ProductoID;
END;
GO

-- Trigger: Recalcular Total Venta

GO
CREATE OR ALTER TRIGGER Ventas.trg_ActualizarTotalVenta
ON Ventas.DetalleVenta
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE V
    SET V.Total = (
        SELECT ISNULL(SUM(D.Cantidad * D.PrecioUnitario), 0)
        FROM Ventas.DetalleVenta D
        WHERE D.VentaID = V.VentaID
    )
    FROM Ventas.Venta V
    WHERE V.VentaID IN (SELECT DISTINCT VentaID FROM inserted UNION SELECT DISTINCT VentaID FROM deleted);
END;
GO

-- Trigger: Auditoría de Borrado de Pagos (Cumple punto de auditoría)
GO
CREATE OR ALTER TRIGGER Ventas.trg_AuditoriaBorradoPago
ON Ventas.Pago
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Seguridad.Bitacora (Usuario, Accion, TablaAfectada, Descripcion)
    SELECT 
        SYSTEM_USER, 
        'DELETE', 
        'Ventas.Pago', 
        'Se eliminó el pago ID: ' + CAST(d.PagoID AS VARCHAR) + ' por monto: ' + CAST(d.Monto AS VARCHAR)
    FROM deleted d;
END;
GO

-----

-- Trigger: Bloquear reservas si el socio está inactivo
GO
CREATE OR ALTER TRIGGER Membresia.trg_BloquearReservaSocioInactivo
ON Membresia.Reserva
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar: Insertar solo si el socio está Activo
    INSERT INTO Membresia.Reserva (SocioID, HorarioID, FechaReserva, Estado)
    SELECT i.SocioID, i.HorarioID, i.FechaReserva, i.Estado
    FROM inserted i
    JOIN Membresia.Socio s ON i.SocioID = s.SocioID
    WHERE s.Estado = 'Activo';

    -- Advertencia si se ignoraron filas
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN Membresia.Socio s ON i.SocioID = s.SocioID
        WHERE s.Estado <> 'Activo'
    )
    BEGIN
        -- Usamos RAISERROR con nivel bajo para advertir sin romper la transacción si no se desea
        PRINT '⚠️ ADVERTENCIA: Se han omitido reservas para socios con estado INACTIVO.';
    END
END;
GO

-- Trigger: Vencimiento de Membresía al insertar Pago
-- Marca como “Inactivo” a los socios cuya fecha de ingreso + 365 días ya pasó al intentar pagar
GO
CREATE OR ALTER TRIGGER Ventas.trg_VencimientoMembresia
ON Ventas.Pago
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Lógica: Si ha pasado más de 1 año desde su ingreso, lo desactivamos 
    -- (Nota: Esto asume que el pago reactivaría, pero tu lógica original desactivaba. 
    --  La mantengo tal cual la tenías: detecta vencidos al pagar).
    UPDATE S
    SET Estado = 'Inactivo'
    FROM Membresia.Socio S
    INNER JOIN inserted i ON S.SocioID = i.SocioID
    WHERE DATEDIFF(DAY, S.FechaIngreso, GETDATE()) > 365
      AND S.Estado = 'Activo';
END;
GO

-----
-- 9. SCRIPT DE BACKUP y RESTORE (Para ejecutar manualmente)

-- Backup Full
-- BACKUP DATABASE GymDB TO DISK = 'C:\Backup\GymDB_Full.bak' WITH FORMAT, INIT;
-- Backup Diff
-- BACKUP DATABASE GymDB TO DISK = 'C:\Backup\GymDB_Diff.bak' WITH DIFFERENTIAL;

-- 10. BULK INSERT (Ejemplo)
-- Asegúrate de tener el archivo C:\Carga\SociosNuevos.csv
/*
BULK INSERT Membresia.SocioTemporal
FROM 'C:\Carga\SociosNuevos.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
*/

/* 10. CONSULTAS AVANZADAS */


-- 1) Total pagado por cada socio

SELECT 
    S.Nombres + ' ' + S.Apellidos AS Socio,
    P.Monto,
    DATEPART(YEAR, P.FechaPago) AS [Year],
    SUM(P.Monto) OVER (PARTITION BY P.SocioID) AS TotalPagadoPorSocio
FROM Ventas.Pago AS P
INNER JOIN Membresia.Socio AS S
    ON P.SocioID = S.SocioID;


-- 2) Ranking de Socios por monto de pagos dividido por año y trimestre
SELECT 
    S.Nombres + ' ' + S.Apellidos AS Socio,
    DATEPART(YEAR, P.FechaPago) AS Año,
    DATEPART(QUARTER, P.FechaPago) AS Trimestre,
    SUM(P.Monto) AS TotalPagado,
    RANK() OVER (
        PARTITION BY DATEPART(YEAR, P.FechaPago), DATEPART(QUARTER, P.FechaPago)
        ORDER BY SUM(P.Monto) DESC
    ) AS RankingPorTrimestre
FROM Ventas.Pago P
JOIN Membresia.Socio S ON P.SocioID = S.SocioID
GROUP BY 
    S.Nombres, 
    S.Apellidos,
    DATEPART(YEAR, P.FechaPago),
    DATEPART(QUARTER, P.FechaPago);
GO

-- 3) Última reserva por socio usando MAX() OVER y Agregaciones
SELECT DISTINCT
    S.Nombres + ' ' + S.Apellidos AS Socio,
    C.Nombre AS TipoClase,
    
    -- Primera reserva del socio
    MIN(R.FechaReserva) OVER (PARTITION BY R.SocioID) AS PrimeraReserva,

    -- Última reserva del socio
    MAX(R.FechaReserva) OVER (PARTITION BY R.SocioID) AS UltimaReserva,

    -- Total de reservas por socio
    COUNT(*) OVER (PARTITION BY R.SocioID) AS TotalReservas

FROM Membresia.Reserva R
JOIN Membresia.Socio S        ON R.SocioID = S.SocioID
JOIN Membresia.HorarioClase H ON R.HorarioID = H.HorarioID
JOIN Membresia.Clase C        ON H.ClaseID = C.ClaseID
ORDER BY Socio;
GO

-- 4) Ventas y porcentaje sobre el total (Análisis avanzado)
SELECT
    S.Nombres + ' ' + S.Apellidos AS Socio,
    DATEPART(YEAR, V.FechaVenta)  AS Año,
    DATEPART(MONTH, V.FechaVenta) AS Mes,
    V.VentaID,
    V.Total AS TotalVenta,

    -- Total mensual del socio
    SUM(V.Total) OVER (
        PARTITION BY V.SocioID, DATEPART(YEAR, V.FechaVenta), DATEPART(MONTH, V.FechaVenta)
    ) AS TotalMensualPorSocio,

    -- Porcentaje de la venta respecto al total del mes del socio
    ROUND(
        V.Total * 100.0 /
        NULLIF(SUM(V.Total) OVER (
            PARTITION BY V.SocioID, DATEPART(YEAR, V.FechaVenta), DATEPART(MONTH, V.FechaVenta)
        ), 0),
        2
    ) AS PorcentajeDelMesDelSocio,

    -- Ranking por socio dentro del mes
    RANK() OVER (
        PARTITION BY V.SocioID, DATEPART(YEAR, V.FechaVenta), DATEPART(MONTH, V.FechaVenta)
        ORDER BY V.Total DESC
    ) AS RankingMensualPorSocio

FROM Ventas.Venta V
JOIN Membresia.Socio S ON V.SocioID = S.SocioID
ORDER BY Año, Mes, Socio, RankingMensualPorSocio;
GO

-- ==============================================================================
-- ZONA DE PRUEBAS Y VERIFICACIÓN (Ejecutar para demostrar funcionamiento)
-- ==============================================================================

USE GymDB;
GO

-- 1. VERIFICACIÓN DE ROLES Y SEGURIDAD [Rubrica: Roles y Privilegios]
-- Muestra que los usuarios están asignados a sus roles correctamente
SELECT 
    dp.name AS Usuario, 
    rp.name AS RolAsignado
FROM sys.database_role_members drm
JOIN sys.database_principals rp ON drm.role_principal_id = rp.principal_id
JOIN sys.database_principals dp ON drm.member_principal_id = dp.principal_id
WHERE dp.name IN ('adminGym', 'recepcionGym', 'instructorGym', 'lectorGym');
GO

-- PRUEBA DE PERMISOS:
-- Intentar borrar algo con el usuario de recepción (Debería fallar o permitir según permisos)
EXECUTE AS USER = 'recepcionGym';
    SELECT TOP 1 * FROM Membresia.Socio; -- Debería funcionar
    -- DELETE FROM Ventas.Pago; -- Si intentas esto, debería dar error (o activar trigger auditoría si tiene permiso)
REVERT;
GO

-- 2. VERIFICACIÓN DE AUDITORÍA [Rubrica: Seguridad]
-- Borramos un pago intencionalmente para ver si se guarda en la bitácora
-- NOTA: Asegúrate de tener un pago para borrar (ID 1 creado en el Seed Data)
DELETE FROM Ventas.Pago WHERE PagoID = 1;

-- Consultamos la bitácora para demostrar que "alguien" lo borró
SELECT * FROM Seguridad.Bitacora ORDER BY FechaHora DESC;
GO

-- 3. VERIFICACIÓN DE TRIGGER DE STOCK [Rubrica: Rendimiento/Automatización]
-- Mostramos stock actual del producto 1
SELECT ProductoID, Nombre, Stock FROM Ventas.Producto WHERE ProductoID = 1;

-- Insertamos una venta nueva
INSERT INTO Ventas.Venta (SocioID, Total) VALUES (1, 0);
DECLARE @NuevaVentaID INT = SCOPE_IDENTITY();

-- Insertamos detalle (compra 2 unidades)
INSERT INTO Ventas.DetalleVenta (VentaID, ProductoID, Cantidad, PrecioUnitario)
VALUES (@NuevaVentaID, 1, 2, 25.00);

-- Volvemos a consultar stock (Debería haber bajado en 2)
SELECT ProductoID, Nombre, Stock FROM Ventas.Producto WHERE ProductoID = 1;
GO

-- 4. VERIFICACIÓN DE REGLA DE NEGOCIO (Socio Inactivo) [Rubrica: Definición]
-- Intentamos hacer una reserva con el Socio 5 (que en el Seed Data pusimos 'Inactivo')
-- Esto debe mostrar el mensaje de error/advertencia del trigger
INSERT INTO Membresia.Reserva (SocioID, HorarioID, FechaReserva, Estado)
VALUES (5, 2, GETDATE(), 'Activa');
GO

-- 5. VERIFICACIÓN DE FUNCIONES VENTANA [Rubrica: Rendimiento]
-- Ejecuta la vista de ranking para mostrar el cálculo complejo
SELECT * FROM Ventas.vw_RankingSociosPagos;
GO


--
