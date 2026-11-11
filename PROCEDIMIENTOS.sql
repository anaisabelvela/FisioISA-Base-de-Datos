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
