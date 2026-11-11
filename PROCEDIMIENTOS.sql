USE FisioISA;

#              ///PROCEDIMIENTOS///

DELIMITER //

#Procedimiento que me permite registrar un pago una vez se ha efectuado.

CREATE OR REPLACE PROCEDURE registrarPago(IN p_ID_Cita INT,IN p_Importe DECIMAL(7,2),IN p_ImportePlazos DECIMAL(7,2),IN p_Metodo ENUM('Efectivo','Tarjeta'),IN p_FechaPago DATETIME,
	IN p_NumeroPlazos INT,IN p_FechaLimite DATETIME,IN p_BonoPromocion ENUM('Bono','Promocion'))
LANGUAGE SQL
NOT DETERMINISTIC
CONTAINS SQL
SQL SECURITY DEFINER
BEGIN

INSERT INTO PagoFinanciacion(ID_Cita, Importe, ImportePlazos, Metodo, FechaPago, NumeroPlazos, FechaLimite, BonoPromocion, PagoPendiente)
    VALUES (p_ID_Cita, p_Importe, p_ImportePlazos, p_Metodo, p_FechaPago, p_NumeroPlazos, p_FechaLimite, p_BonoPromocion, 'Pagado');
END//

#Procedimiento que me permite modificar una cita agendada.

CREATE OR REPLACE PROCEDURE modificarCita(IN p_DNI_Fisioterapeuta VARCHAR(9),IN p_TipoVisita ENUM('Traumatologica','Pediatrica','Neurologia','Grupal','Bloqueo'),IN p_Tratamiento VARCHAR(500),
	IN p_FechaHora DATETIME,IN p_ID_Cita INT)
LANGUAGE SQL
NOT DETERMINISTIC
CONTAINS SQL
SQL SECURITY DEFINER
BEGIN

UPDATE GestionCita
    SET DNI_Fisioterapeuta = p_DNI_Fisioterapeuta,
        TipoVisita = p_TipoVisita,
        TratamientoRealizado = p_Tratamiento,
        FechaHora = p_FechaHora
    WHERE ID_Cita = p_ID_Cita;
END//

#Procedimiento que me permite eliminar una cita.

CREATE OR REPLACE PROCEDURE eliminarCita(IN p_ID_Cita INT)
LANGUAGE SQL
NOT DETERMINISTIC
CONTAINS SQL
SQL SECURITY DEFINER
BEGIN

 DELETE FROM PagoFinanciacion
    WHERE ID_Cita = p_ID_Cita;

DELETE FROM GestionCita
    WHERE ID_Cita = p_ID_Cita;
END//

#Procedimiento que me permite ver que citas hay entre dos fechas determinadas.

CREATE OR REPLACE PROCEDURE citasFisioEntreFechas(IN p_DNI_Fisio VARCHAR(50),IN p_fecha_inicio DATETIME,IN p_fecha_fin DATETIME)
LANGUAGE SQL
NOT DETERMINISTIC
CONTAINS SQL
SQL SECURITY DEFINER
BEGIN

SELECT FechaHora
    FROM GestionCita
    WHERE DNI_Fisioterapeuta = p_DNI_Fisio
      AND FechaHora BETWEEN p_fecha_inicio AND p_fecha_fin
    ORDER BY FechaHora;
END//

#Procedimiento que me permite bloquear el horario de un fisioterapeuta un tiempo determinado.

CREATE OR REPLACE PROCEDURE BloquearHorarioFisioterapeuta(IN DNI_Fisioterapeuta VARCHAR(9), IN FechaHoraInicio DATETIME, IN FechaHoraFin DATETIME)
LANGUAGE SQL
NOT DETERMINISTIC
CONTAINS SQL
SQL SECURITY DEFINER
BEGIN
DECLARE fechaActual DATETIME;

    SET fechaActual = FechaHoraInicio;

    WHILE fechaActual < FechaHoraFin DO
        
        DELETE FROM GestionCita
   	  WHERE DNI_Fisioterapeuta = DNI_Fisioterapeuta AND DNI_Paciente = 'BLOQUEO' AND FechaHora BETWEEN FechaHoraInicio AND FechaHoraFin;
   	 
        INSERT INTO GestionCita(DNI_Fisioterapeuta, DNI_Paciente, TipoVisita, TratamientoRealizado, FechaHora)
        VALUES (DNI_Fisioterapeuta, 'BLOQUEO', 'Bloqueo', 'Bloqueo', fechaActual);

        SET fechaActual = DATE_ADD(fechaActual, INTERVAL 30 MINUTE);
    END WHILE;
END//

#Procedimiento que me permite agendar una cita.

CREATE OR REPLACE PROCEDURE AgendarCita(IN p_DNI_Fisioterapeuta VARCHAR(9),IN p_DNI_Paciente VARCHAR(9), IN p_TipoVisita ENUM('Traumatologica','Pediatrica','Neurologia','Grupal'),
	IN p_TratamientoRealizado VARCHAR(500),IN p_FechaHora DATETIME)
LANGUAGE SQL
NOT DETERMINISTIC
CONTAINS SQL
SQL SECURITY DEFINER
BEGIN
    INSERT INTO GestionCita(DNI_Fisioterapeuta, DNI_Paciente, TipoVisita, TratamientoRealizado, FechaHora)
    VALUES (p_DNI_Fisioterapeuta, p_DNI_Paciente, p_TipoVisita, p_TratamientoRealizado, p_FechaHora);
END//

#Procedimiento que me permite actualizar el historial clínico de un paciente determinado

CREATE OR REPLACE PROCEDURE actualizarHistorialClinico(IN p_dni VARCHAR(9),IN p_evaluacion TEXT,IN p_diagnostico TEXT,IN p_tratamiento TEXT,IN p_informe TEXT,IN p_cambio_Fisico TEXT,
IN p_ajustes_planes TEXT, IN p_recomendaciones TEXT)
LANGUAGE SQL
NOT DETERMINISTIC
CONTAINS SQL
SQL SECURITY DEFINER
BEGIN

 UPDATE HistorialClinico
  SET
    Evaluacion = p_evaluacion,
    Diagnostico = p_diagnostico,
    Tratamientos = p_tratamiento,
    Informes = p_informe,
    CambiosFisicos = p_cambio_Fisico,
    Ajustes = p_ajustes_planes,
    Recomendaciones = p_recomendaciones
  WHERE DNI_Paciente = p_dni;
END//

#Procedimiento que me permite registrar un nuevo paciente en la base de datos.

CREATE OR REPLACE PROCEDURE regristrarNuevoPaciente(IN DNI_Paciente VARCHAR(50),IN Nombre VARCHAR(50),IN Apellidos VARCHAR(50),IN FechaNaciemiento DATE,IN CompañiaSeguros VARCHAR(50),
IN NumeroPoliza VARCHAR(50),IN Direccion VARCHAR(50), IN Telefono VARCHAR(50), IN CorreoElectronico VARCHAR(50), IN Documentos VARCHAR(50))
LANGUAGE SQL
NOT DETERMINISTIC
CONTAINS SQL
SQL SECURITY DEFINER
BEGIN

INSERT INTO Paciente(DNI, Nombre, Apellidos, FechaNacimiento, CompañiaSeguros, NumeroPoliza, Direccion, Telefono, CorreoElectronico, Documentos)
    VALUES (DNI_Paciente, Nombre, Apellidos, FechaNacimiento, CompañiaSeguros, NumeroPoliza, Direccion, Telefono, CorreoElectronico, Documentos);
END//


DELIMITER ;

INSERT IGNORE INTO Paciente (DNI, Nombre, Apellidos)
VALUES ('BLOQUEO', 'Horario', 'Bloqueado');

CALL eliminarCita(1);
CALL BloquearHorarioFisioterapeuta('77868358K', '2025-09-20 14:00:05', '2025-09-21 14:00:05');
CALL actualizarHistorialClinico('48422496C', 'El paciente no asistió a su tercera sesión de terapia manual el 20/02/2025 con el fisioterapeuta Eustaquio Morón Sánchez. Presenta mejoría en movilidad lumbar y reducción de la tensión muscular y el dolor.', 'Disfunción miofascial con restricción articular lumbar de origen postural. Evolución positiva sin signos de lesión aguda.', 'Terapia manual con movilización, liberación miofascial y estiramientos. Se han añadido ejercicios domiciliarios. Se prevé incorporar ejercicios activos en las sesiones restantes.', 'Ha completado 3 de 5 sesiones. Tratamiento abonado progresivamente. Evolución favorable, sin incidencias. Dos sesiones pendientes.', 'Mejora en movilidad, disminución del dolor y rigidez, y mejor postura funcional.', 'Transición hacia ejercicios activos y educación postural. Valoración final en la última sesión.', 'Finalizar las sesiones, continuar con ejercicios en casa, evitar sobreesfuerzos, hidratarse y revisar el entorno laboral si es necesario.');
CALL citasFisioEntreFechas('48574312H','2025-10-20 12:30:00', '2025-12-21 12:30:00');
CALL regristrarNuevoPaciente('48422496M', 'Manolo', 'Rodríguez De Luque', '2005-05-13', 'Mapfre', '1234-5678-9013', 'Calle Tajo 12, Puerta 2, 1ºB', '635885437', 'mirl@gmail.com', 'Prueba de Imagen');
CALL modificarCita('48574312H', 'Traumatologica', '.', '2025-06-20 12:30:00', 2);
CALL registrarPago(2, 675.00, 45.00, 'Tarjeta', '2025-02-20 14:00:05', 5, '2025-03-20 23:59:59', 'Bono');
CALL AgendarCita('48574312H', '48422496C', 'Pediatrica', '.', '2025-10-21 12:30:00');
