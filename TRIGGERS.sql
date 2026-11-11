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
