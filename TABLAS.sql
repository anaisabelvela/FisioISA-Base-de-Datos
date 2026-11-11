CREATE DATABASE IF NOT EXISTS FisioISA;
USE FisioISA;

DROP TABLE IF EXISTS PagoFinanciacion;
DROP TABLE IF EXISTS HistorialClinico;
DROP TABLE IF EXISTS GestionCita;
DROP TABLE IF EXISTS Autorizacion;
DROP TABLE IF EXISTS Pedidos;
DROP TABLE IF EXISTS Tratamiento;
DROP TABLE IF EXISTS Paciente;
DROP TABLE IF EXISTS PersonalClinico;

CREATE TABLE IF NOT EXISTS PersonalClinico(
DNI						VARCHAR(9) PRIMARY KEY,
Nombre 					VARCHAR(50) NOT NULL,
Apellidos				VARCHAR(50) NOT NULL,
FechaNacimiento		DATE NOT NULL,
Telefono					VARCHAR(15) NOT NULL UNIQUE,
CorreoElectronico 	VARCHAR(50) NOT NULL UNIQUE,
Titulacion				VARCHAR(50) NOT NULL,
NSeguridadSocial 		VARCHAR(50) NOT NULL UNIQUE,
Departamento			ENUM('Fisioterapia','Administracion','Comercial','Directivo') NOT NULL);

CREATE TABLE IF NOT EXISTS Paciente(
DNI						VARCHAR(9) PRIMARY KEY,
Nombre					VARCHAR(50) NOT NULL,
Apellidos				VARCHAR(50) NOT NULL,
FechaNacimiento		DATE NOT NULL,
CompañiaSeguros		VARCHAR(50),
NumeroPoliza			VARCHAR(20) NOT NULL UNIQUE,
Direccion				VARCHAR(50) NOT NULL,
Telefono					VARCHAR(15) NOT NULL UNIQUE,
CorreoElectronico		VARCHAR(50) NOT NULL UNIQUE,
Documentos				ENUM('Informe Clinico','Prueba Diagnostica','Prueba de Imagen','Analitica') NOT NULL);

CREATE TABLE IF NOT EXISTS HistorialClinico(
DNI_Paciente         VARCHAR(9) PRIMARY KEY,
Evaluacion				VARCHAR(1000),
Diagnostico				VARCHAR(1000),
Tratamientos			VARCHAR(1000),
Informes					VARCHAR(1000),
CambiosFisicos			VARCHAR(1000),
Ajustes					VARCHAR(1000),
Recomendaciones		VARCHAR(1000),
FOREIGN KEY (DNI_Paciente) REFERENCES Paciente(DNI));

CREATE TABLE IF NOT EXISTS GestionCita(
ID_Cita              INT AUTO_INCREMENT PRIMARY KEY,
DNI_Fisioterapeuta   VARCHAR(9) NOT NULL,
DNI_Paciente         VARCHAR(9) NOT NULL,
TipoVisita				ENUM('Traumatologica','Pediatrica','Neurologia','Grupal', 'Bloqueo') NOT NULL,
TratamientoRealizado	VARCHAR(500) NOT NULL,
FechaHora				DATETIME NOT NULL,
FOREIGN KEY (DNI_Fisioterapeuta) REFERENCES PersonalClinico(DNI),
FOREIGN KEY (DNI_Paciente) REFERENCES Paciente(DNI),
UNIQUE (DNI_Fisioterapeuta, FechaHora));

CREATE TABLE IF NOT EXISTS PagoFinanciacion(
ID_Pago              INT AUTO_INCREMENT PRIMARY KEY,
ID_Cita              INT,
Importe              DECIMAL(7,2) NOT NULL,
ImportePlazos        DECIMAL(7,2) NOT NULL,
Metodo					ENUM('Efectivo','Tarjeta') NOT NULL,
FechaPago				DATETIME NOT NULL,
NumeroPlazos			INT DEFAULT 1,
FechaLimite				DATETIME NOT NULL,
BonoPromocion			ENUM('Bono','Promocion') DEFAULT NULL,
PagoPendiente			ENUM ('Pagado', 'No pagado') NOT NULL,
FOREIGN KEY (ID_Cita) REFERENCES GestionCita(ID_Cita));

CREATE TABLE IF NOT EXISTS Pedidos(
ID_Pedido               INT AUTO_INCREMENT PRIMARY KEY,
NombArticulo            VARCHAR(50) NOT NULL, 
ArticulosSolicitados    INT NOT NULL,
FechaSolicitud		   	DATETIME DEFAULT SYSDATE(),
FechaEntrega		   	DATE,
ReferenciaPedido		   VARCHAR(50) NOT NULL,
PrecioProducto			   DECIMAL(6,2) NOT NULL,
Proveedor				   VARCHAR(50));

CREATE TABLE IF NOT EXISTS Tratamiento(
ID_Tratamiento       INT AUTO_INCREMENT PRIMARY KEY,
TipoTratamiento      VARCHAR(50),
Coste           		DECIMAL(6,2) NOT NULL,
Duracion   	         VARCHAR(20) NOT NULL);

CREATE TABLE IF NOT EXISTS Autorizacion(
NumAutorizacion        		INT PRIMARY KEY,
DNI_Paciente 					VARCHAR(9) NOT NULL,
FechaVencimiento        	DATE NOT NULL,
TipoCobertura              ENUM('Tratamiento','Maquina') NOT NULL,
FOREIGN KEY (DNI_Paciente) REFERENCES Paciente(DNI));

# 					///CONSULTA A TABLAS///
#Fila con autorización cuya fecha de vencimiento sea superior a 2030.

SELECT *  FROM autorizacion  WHERE fechavencimiento > '2030-01-01';

#Fila con autorizaciones en la fecha dada.

SELECT * FROM gestioncita WHERE DATE(fechahora) = '2025-11-20';

#Fila con pacientes que tengan Adelas como compañía de seguros.

SELECT * FROM paciente WHERE compañiaseguros = 'Adeslas';

#Filas con pacientes que tengan pagos pendientes.

SELECT * FROM pagofinanciacion WHERE pagopendiente = 'No Pagado'; 

#Columnas con nombre de articulos y numero de articulos. 

SELECT nombarticulo, articulossolicitados FROM pedidos;

#Trabajadores que hayan nacido antes de 1999.

SELECT * FROM personalclinico WHERE fechanacimiento < '1999-01-01';

#Ordenar los tratamientos por coste.

SELECT * FROM tratamiento ORDER BY coste ASC;

#Tabla completa de Historial Clínico.

SELECT * FROM historialclinico;
