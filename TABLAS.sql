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

INSERT INTO PersonalClinico (DNI, Nombre, Apellidos, FechaNacimiento, Telefono, CorreoElectronico, Titulacion, NSeguridadSocial, Departamento) VALUES
('77868358K', 'Eustaquio', 'Morón Sánchez', '1995-08-19', '606434798', 'emosa@gmail.com', 'Fisioterapeuta', '147852358145', 'Fisioterapia'), 
('48574312H', 'Guillermo', 'Gutiérrez Serantes', '1999-06-10', '667669778', 'serantes9@gmail.com', 'Fisioterapeuta', '28 3436567790', 'Fisioterapia'),
('27455699E', 'Carolina', 'López Ramírez', '1990-02-22', '632140382', 'carolop22@gmail.com', 'Fisioterapeuta', '34 4534557834', 'Fisioterapia');

INSERT INTO Paciente (DNI, Nombre, Apellidos, FechaNacimiento, CompañiaSeguros, NumeroPoliza, Direccion, Telefono, CorreoElectronico, Documentos) VALUES
('48422496C', 'Manuel', 'Rodríguez De Luque', '2005-05-13', 'Mapfre', '1234-5678-9012', 'Calle Tajo 12, Puerta 2, 1ºB', '635885417', 'mrl@gmail.com', 'Prueba de Imagen'),
('24168846M', 'Ana', 'Álvarez ', '1952-05-08', 'Asisa', '12/7451580', 'Calle Sierpes 41, Sevilla', '664573436', 'alg@gmail.com', 'Analitica'),
('37589214L', 'Javier', 'Muñoz Herrera', '2000-07-03', 'Adeslas', '41-3422710', 'Calle Juan de Mesa 22, Sevilla', '637321549', 'jmh@gmail.com', 'Informe Clinico');

INSERT INTO HistorialClinico (DNI_Paciente, Evaluacion, Diagnostico, Tratamientos, Informes, CambiosFisicos, Ajustes, Recomendaciones) VALUES
('48422496C', 'El paciente asistió a su tercera sesión de terapia manual el 20/02/2025 con el fisioterapeuta Eustaquio Morón Sánchez. Presenta mejoría en movilidad lumbar y reducción de la tensión muscular y el dolor.', 'Disfunción miofascial con restricción articular lumbar de origen postural. Evolución positiva sin signos de lesión aguda.', 'Terapia manual con movilización, liberación miofascial y estiramientos. Se han añadido ejercicios domiciliarios. Se prevé incorporar ejercicios activos en las sesiones restantes.', 'Ha completado 3 de 5 sesiones. Tratamiento abonado progresivamente. Evolución favorable, sin incidencias. Dos sesiones pendientes.', 'Mejora en movilidad, disminución del dolor y rigidez, y mejor postura funcional.', 'Transición hacia ejercicios activos y educación postural. Valoración final en la última sesión.', 'Finalizar las sesiones, continuar con ejercicios en casa, evitar sobreesfuerzos, hidratarse y revisar el entorno laboral si es necesario.'),
('24168846M','La paciente asistió el 08/12/2024 a su primera sesión de diatermia con el fisioterapeuta Guillermo Gutiérrez Serantes. Presenta sintomatología compatible con inflamación o sobrecarga muscular localizada, indicada para tratamiento con termoterapia profunda.', 'Se identifica un cuadro de dolor localizado, posiblemente relacionado con una lesión crónica o sobreuso. La diatermia está indicada para mejorar la circulación, reducir el dolor y facilitar la regeneración tisular.', 'Se ha iniciado un tratamiento con diatermia capacitiva y resistiva, ajustado a la zona afectada. El plan contempla siete sesiones en total, con frecuencia semanal. Se valorará la progresión para introducir otras técnicas si es necesario.', 'La paciente ha completado una de siete sesiones. El tratamiento ha sido abonado por sesión en efectivo (35€), con un coste total programado de 245€. Quedan pendientes seis sesiones.', 'Al tratarse de la primera sesión, aún no se observan cambios significativos, aunque la paciente refiere sensación de calor agradable y ligera disminución del dolor post-tratamiento.', 'No se requieren ajustes por el momento. Se mantendrá la frecuencia semanal y se reevaluará tras la tercera sesión.', 'Asistir regularmente a las sesiones, evitar exposición al frío en la zona tratada y seguir indicaciones del fisioterapeuta. Se sugiere reposo relativo si hay dolor post-terapia.'),
('37589214L', 'El paciente asistió el 05/04/2025 a su cuarta sesión de masoterapia con la fisioterapeuta Carolina López Ramírez. Presenta mejoría progresiva en la sintomatología muscular, con reducción de la tensión y aumento de la flexibilidad en las zonas tratadas.', 'Cuadro de sobrecarga muscular generalizada, especialmente en región cervical y dorsal, compatible con estrés postural. La evolución ha sido favorable con respuesta positiva a la terapia manual.', 'El tratamiento consiste en masoterapia profunda aplicada en segmentos específicos, con técnicas complementarias de relajación y liberación muscular. Se mantiene el plan de siete sesiones en total.', 'El paciente ha completado cuatro sesiones de las siete planificadas. El coste total del tratamiento es de 560€, abonado en cuatro plazos. En esta sesión se ha pagado en efectivo un importe de 140€. Restan tres sesiones por realizar.', 'Disminución evidente del tono muscular excesivo, mejor movilidad cervical y reducción del dolor referido. El paciente reporta sensación de alivio tras cada sesión.', 'No se requieren cambios en el tratamiento. Se continuará con la misma pauta en las siguientes sesiones y se evaluará la necesidad de tratamiento de mantenimiento una vez finalizado el ciclo.', 'Completar las sesiones restantes, mantener buena higiene postural, evitar el sedentarismo prolongado y aplicar calor local si aparece tensión entre sesiones.');

INSERT INTO GestionCita (ID_Cita, DNI_Fisioterapeuta, DNI_Paciente, TipoVisita, TratamientoRealizado, FechaHora) VALUES
('1', '77868358K', '48422496C', 'Traumatologica', 'Terapia manual con movilización, liberación miofascial y estiramientos. Se han añadido ejercicios domiciliarios. Se prevé incorporar ejercicios activos en las sesiones restantes.', '2025-11-20 12:30:00'),
('2', '48574312H', '24168846M', 'Traumatologica', 'Se ha iniciado un tratamiento con diatermia capacitiva y resistiva, ajustado a la zona afectada. El plan contempla siete sesiones en total, con frecuencia semanal. Se valorará la progresión para introducir otras técnicas si es necesario.', '2025-12-08 09:15:00'),
('3', '27455699E', '37589214L', 'Traumatologica', 'El tratamiento consiste en masoterapia profunda aplicada en segmentos específicos, con técnicas complementarias de relajación y liberación muscular. Se mantiene el plan de siete sesiones en total.', '2025-09-05 16:45:00');

INSERT INTO PagoFinanciacion(ID_Pago, ID_Cita, Importe, ImportePlazos, Metodo, FechaPago, NumeroPlazos, FechaLimite, BonoPromocion, PagoPendiente) VALUES
('1', '1', '675.00', '45.00', 'Tarjeta', '2025-02-20 14:00:05', '5', '2025-03-20 23:59:59', 'Bono', 'No pagado'),
('2', '2', '245.00', '245.00', 'Efectivo', '2024-12-08 10:30:03', '1', '2025-01-08 23:59:59', 'Bono', 'No pagado'),
('3', '3', '560.00', '140.00', 'Efectivo', '2025-06-01 18:01:24', '4', '2025-07-01 23:59:59', 'Bono', 'Pagado');

INSERT INTO Pedidos (ID_Pedido, NombArticulo, ArticulosSolicitados, FechaSolicitud, FechaEntrega, ReferenciaPedido, PrecioProducto, Proveedor) VALUES
('1', 'Botes de Crema', '10', '2025-02-20 08:32:07', '2025-03-02','54117748484', '16.00', 'Fisaude'),
('2', 'Sábanas Desechables', '100', '2025-05-01 08:29:31', '2025-05-08', '54085124190','200.00', 'Fisiomarket'),
('3', 'Vendajes', '150', '2025-04-14 08:22:58', '2025-04-20', '53924005936', '70.00', 'Fisiomarket');

INSERT INTO Tratamiento (ID_Tratamiento, TipoTratamiento, Coste, Duracion) VALUES
('1', 'Terapia Manual', '675.00', '3 Semanas'),
('2', 'Diatermia', '245.00', '7 Semanas'),
('3', 'Masoterapia', '560.00', '2 Meses');

INSERT INTO Autorizacion (NumAutorizacion, DNI_Paciente, FechaVencimiento, TipoCobertura) VALUES
('10455698', '48422496C',  '2028-11-15', 'Tratamiento'),
('10355698', '24168846M',  '2030-10-12', 'Maquina'),
('24385699', '37589214L', '2040-01-14', 'Tratamiento');

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
