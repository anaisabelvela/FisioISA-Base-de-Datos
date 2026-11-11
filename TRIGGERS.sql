USE FisioISA;
#            ///TRIGGERS///

DELIMITER //

CREATE OR REPLACE TRIGGER noCitasPasadas BEFORE INSERT ON gestioncita FOR EACH ROW BEGIN
IF NEW.FechaHora < NOW() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se pueden agendar citas en el pasado.';
    END IF;
END//

CREATE OR REPLACE TRIGGER MaxCitasPorDia BEFORE INSERT ON gestioncita FOR EACH ROW BEGIN
 DECLARE citas_count INT;
    SET citas_count = (
        SELECT COUNT(*)
        FROM GestionCita
        WHERE DNI_Fisioterapeuta = NEW.DNI_Fisioterapeuta
        AND DATE(FechaHora) = DATE(NEW.FechaHora)
    );

    IF citas_count >= 10 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El fisioterapeuta ya tiene el máximo de 10 citas para ese día.';
    END IF;
END//

CREATE OR REPLACE TRIGGER VerificarAutorizacion BEFORE INSERT ON gestioncita FOR EACH ROW BEGIN
  IF NOT EXISTS (
     SELECT 1 FROM Autorizacion 
     WHERE DNI_Paciente = NEW.DNI_Paciente
     AND FechaVencimiento >= DATE(NEW.FechaHora)
  ) THEN
     SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El paciente no tiene una autorización válida para esta cita.';
  END IF;
END//

CREATE OR REPLACE TRIGGER EvitarCitasFueraHorario BEFORE INSERT ON gestioncita FOR EACH ROW BEGIN
  IF (HOUR(NEW.FechaHora) < 8 OR HOUR(NEW.FechaHora) >= 20) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se pueden agendar citas fuera del horario de atención (08:00 - 20:00).';
    END IF;
END//

CREATE OR REPLACE TRIGGER ValidarEdadPaciente BEFORE INSERT ON paciente FOR EACH ROW BEGIN
    IF NEW.FechaNacimiento > CURDATE() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La fecha de nacimiento del paciente no puede ser en el futuro.';
    END IF;
END//

DELIMITER ;


#             ///PRUEBA DE TRIGGERS///
/*
# no se puede coger citas fuera de horario
INSERT INTO GestionCita (ID_Cita, DNI_Fisioterapeuta, DNI_Paciente, TipoVisita, TratamientoRealizado, FechaHora)
VALUES (67, '27455699E', '37589214L', 'Traumatologica', 'El tratamiento consiste en masoterapia profunda aplicada en segmentos específicos, con técnicas complementarias de relajación y liberación muscular. Se mantiene el plan de siete sesiones en total.', '2025-09-05 22:00:00');
# no se puede coger citas fuera de horario ## este es el que no da el error
INSERT INTO GestionCita (ID_Cita, DNI_Fisioterapeuta, DNI_Paciente, TipoVisita, TratamientoRealizado, FechaHora)
VALUES (67, '27455699E', '37589214L', 'Traumatologica', 'El tratamiento consiste en masoterapia profunda aplicada en segmentos específicos, con técnicas complementarias de relajación y liberación muscular. Se mantiene el plan de siete sesiones en total.', '2025-09-05 19:00:00');


# no se puede agenciar citas en el pasado
INSERT INTO GestionCita (ID_Cita, DNI_Fisioterapeuta, DNI_Paciente, TipoVisita, TratamientoRealizado, FechaHora)
VALUES (12, '77868358K', '37589214L', 'Traumatologica', 'El tratamiento consiste en masoterapia profunda aplicada en segmentos específicos, con técnicas complementarias de relajación y liberación muscular. Se mantiene el plan de siete sesiones en total.', '2024-09-20 16:00:00');
# no se puede agenciar citas en el pasado ## este es el que no da error
INSERT INTO GestionCita (ID_Cita, DNI_Fisioterapeuta, DNI_Paciente, TipoVisita, TratamientoRealizado, FechaHora)
VALUES (12, '77868358K', '37589214L', 'Traumatologica', 'El tratamiento consiste en masoterapia profunda aplicada en segmentos específicos, con técnicas complementarias de relajación y liberación muscular. Se mantiene el plan de siete sesiones en total.', '2026-09-20 16:00:00');


# verificar que el paciente tiene edad>0
INSERT INTO Paciente (DNI, Nombre, Apellidos, FechaNacimiento, CompañiaSeguros, NumeroPoliza, Direccion, Telefono, CorreoElectronico, Documentos) VALUES
('45422496C', 'Manuel', 'Rodríguez Soler', '2027-08-13', 'Mapfre', '2234-5678-9012', 'Calle Tajo 12, Puerta 2, 1ºB', '635885411', 'mrsl@gmail.com', 'Prueba de Imagen');
# verificar que el paciente tiene edad>0  ## este es el que no da error
INSERT INTO Paciente (DNI, Nombre, Apellidos, FechaNacimiento, CompañiaSeguros, NumeroPoliza, Direccion, Telefono, CorreoElectronico, Documentos) VALUES
('45422496C', 'Manuel', 'Rodríguez Soler', '2005-08-13', 'Mapfre', '2234-5678-9012', 'Calle Tajo 12, Puerta 2, 1ºB', '635885411', 'mrsl@gmail.com', 'Prueba de Imagen');


# verificar que la autorizacion no ha caducado
INSERT INTO Paciente (DNI, Nombre, Apellidos, FechaNacimiento, CompañiaSeguros, NumeroPoliza, Direccion, Telefono, CorreoElectronico, Documentos) VALUES
('45422496C', 'Manuel', 'Rodríguez Soler', '2000-08-13', 'Mapfre', '2234-5678-9012', 'Calle Tajo 12, Puerta 2, 1ºB', '635885411', 'mrsl@gmail.com', 'Prueba de Imagen');
INSERT INTO Autorizacion (NumAutorizacion, DNI_Paciente, FechaVencimiento, TipoCobertura) VALUES
('00455698', '45422496C',  '2024-11-15', 'Tratamiento');
INSERT INTO GestionCita (ID_Cita, DNI_Fisioterapeuta, DNI_Paciente, TipoVisita, TratamientoRealizado, FechaHora)
VALUES (61, '27455699E', '45422496C', 'Traumatologica', 'El tratamiento consiste en masoterapia profunda aplicada en segmentos específicos, con técnicas complementarias de relajación y liberación muscular. Se mantiene el plan de siete sesiones en total.', '2025-11-05 12:00:00');
# verificar que la autorizacion no ha caducado ## este es el que no da error
INSERT INTO Paciente (DNI, Nombre, Apellidos, FechaNacimiento, CompañiaSeguros, NumeroPoliza, Direccion, Telefono, CorreoElectronico, Documentos) VALUES
('45422496C', 'Manuel', 'Rodríguez Soler', '2000-08-13', 'Mapfre', '2234-5678-9012', 'Calle Tajo 12, Puerta 2, 1ºB', '635885411', 'mrsl@gmail.com', 'Prueba de Imagen');
INSERT INTO Autorizacion (NumAutorizacion, DNI_Paciente, FechaVencimiento, TipoCobertura) VALUES
('00455698', '45422496C',  '2028-11-15', 'Tratamiento');
INSERT INTO GestionCita (ID_Cita, DNI_Fisioterapeuta, DNI_Paciente, TipoVisita, TratamientoRealizado, FechaHora)
VALUES (61, '27455699E', '45422496C', 'Traumatologica', 'El tratamiento consiste en masoterapia profunda aplicada en segmentos específicos, con técnicas complementarias de relajación y liberación muscular. Se mantiene el plan de siete sesiones en total.', '2025-11-05 12:00:00');



# verificar que para un mismo fisioterapeuta no tenga mas de 10 citas por dia 
INSERT INTO GestionCita (ID_Cita, DNI_Fisioterapeuta, DNI_Paciente, TipoVisita, TratamientoRealizado, FechaHora) VALUES
('60', '27455699E', '48422496C', 'Traumatologica', 'Terapia manual con movilización, liberación miofascial y estiramientos. Se han añadido ejercicios domiciliarios. Se prevé incorporar ejercicios activos en las sesiones restantes.', '2025-11-20 12:30:00'),
('61', '27455699E', '48422496C', 'Traumatologica', 'Terapia manual con movilización, liberación miofascial y estiramientos. Se han añadido ejercicios domiciliarios. Se prevé incorporar ejercicios activos en las sesiones restantes.', '2025-11-20 13:30:00'),
('62', '27455699E', '48422496C', 'Traumatologica', 'Terapia manual con movilización, liberación miofascial y estiramientos. Se han añadido ejercicios domiciliarios. Se prevé incorporar ejercicios activos en las sesiones restantes.', '2025-11-20 14:30:00'),
('63', '27455699E', '48422496C', 'Traumatologica', 'Terapia manual con movilización, liberación miofascial y estiramientos. Se han añadido ejercicios domiciliarios. Se prevé incorporar ejercicios activos en las sesiones restantes.', '2025-11-20 15:30:00'),
('64', '27455699E', '48422496C', 'Traumatologica', 'Terapia manual con movilización, liberación miofascial y estiramientos. Se han añadido ejercicios domiciliarios. Se prevé incorporar ejercicios activos en las sesiones restantes.', '2025-11-20 16:30:00'),
('65', '27455699E', '48422496C', 'Traumatologica', 'Terapia manual con movilización, liberación miofascial y estiramientos. Se han añadido ejercicios domiciliarios. Se prevé incorporar ejercicios activos en las sesiones restantes.', '2025-11-20 17:30:00'),
('66', '27455699E', '48422496C', 'Traumatologica', 'Terapia manual con movilización, liberación miofascial y estiramientos. Se han añadido ejercicios domiciliarios. Se prevé incorporar ejercicios activos en las sesiones restantes.', '2025-11-20 18:30:00'),
('67', '27455699E', '48422496C', 'Traumatologica', 'Terapia manual con movilización, liberación miofascial y estiramientos. Se han añadido ejercicios domiciliarios. Se prevé incorporar ejercicios activos en las sesiones restantes.', '2025-11-20 19:30:00'),
('68', '27455699E', '48422496C', 'Traumatologica', 'Terapia manual con movilización, liberación miofascial y estiramientos. Se han añadido ejercicios domiciliarios. Se prevé incorporar ejercicios activos en las sesiones restantes.', '2025-11-20 11:30:00'),
('69', '27455699E', '48422496C', 'Traumatologica', 'Terapia manual con movilización, liberación miofascial y estiramientos. Se han añadido ejercicios domiciliarios. Se prevé incorporar ejercicios activos en las sesiones restantes.', '2025-11-20 10:30:00');
INSERT INTO GestionCita (ID_Cita, DNI_Fisioterapeuta, DNI_Paciente, TipoVisita, TratamientoRealizado, FechaHora) VALUES
('70', '27455699E', '48422496C', 'Traumatologica', 'Terapia manual con movilización, liberación miofascial y estiramientos. Se han añadido ejercicios domiciliarios. Se prevé incorporar ejercicios activos en las sesiones restantes.', '2025-11-20 9:30:00');
*/

