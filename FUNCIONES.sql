#              /// FUNCIONES///

DELIMITER //
 
 # Función que devuelve la cantidad de un producto determinado.
 
CREATE OR REPLACE FUNCTION cantidadProductos(p_nombre VARCHAR(50))
RETURNS int(11)
LANGUAGE SQL
NOT DETERMINISTIC
CONTAINS SQL
SQL SECURITY DEFINER
BEGIN

DECLARE cantidadTotal INT;

    SELECT SUM(ArticulosSolicitados) INTO cantidadTotal FROM Pedidos WHERE nombArticulo = p_nombre;

    RETURN IFNULL(cantidadTotal, 0); 
END //

#Función que me devuelve en Boolean 1 si existe el paciente en la base de datos.

CREATE OR REPLACE FUNCTION comprobarPaciente(p_DNI VARCHAR(9))
RETURNS tinyint(1)
LANGUAGE SQL
NOT DETERMINISTIC
CONTAINS SQL
SQL SECURITY DEFINER
BEGIN

DECLARE existe INT;

    SELECT COUNT(*) INTO existe FROM Paciente WHERE DNI = p_DNI;

    RETURN (existe > 0);
END//

#Función que devuelve el nuemero de pacientes que contiene la base de datos.

CREATE OR REPLACE FUNCTION contarNumPacientes()
RETURNS int(11)
LANGUAGE SQL
NOT DETERMINISTIC
CONTAINS SQL
SQL SECURITY DEFINER
BEGIN

  DECLARE total_num_pacientes INT;
  
  	 SELECT COUNT(*) INTO total_num_pacientes FROM paciente;
    RETURN total_num_pacientes;
END//

#Función que devuelve los ingresos totales en un mes concreto.

CREATE OR REPLACE FUNCTION ingresosPorMes(p_anio INT,p_mes INT)
RETURNS decimal(10,2)
LANGUAGE SQL
NOT DETERMINISTIC
CONTAINS SQL
SQL SECURITY DEFINER
BEGIN

DECLARE total_ingresos DECIMAL(10,2);

    SELECT IFNULL(SUM(Importe), 0) INTO total_ingresos FROM PagoFinanciacion
    WHERE YEAR(FechaPago) = p_anio AND MONTH(FechaPago) = p_mes;

    RETURN total_ingresos;
END//

#Función que devuelve el numero total de pacientes que tienen una compañía determianda.

CREATE OR REPLACE FUNCTION numPorCompañia(p_compania VARCHAR(50))
RETURNS int(11)
LANGUAGE SQL
NOT DETERMINISTIC
CONTAINS SQL
SQL SECURITY DEFINER
BEGIN

DECLARE total INT;

    SELECT COUNT(*) INTO total FROM Paciente WHERE CompañiaSeguros = p_compania;

    RETURN total;
END//

#Función que devuelve la próxima cita que tiene asiganada un paciente determinado.

CREATE OR REPLACE FUNCTION obtnerProxCita(p_DNI VARCHAR(9))
RETURNS datetime
LANGUAGE SQL
NOT DETERMINISTIC
CONTAINS SQL
SQL SECURITY DEFINER
BEGIN

    DECLARE proxima_cita DATETIME;

    SELECT FechaHora INTO proxima_cita FROM gestioncita WHERE DNI_Paciente = p_DNI
      AND FechaHora > NOW() ORDER BY FechaHora ASC LIMIT 1;

    RETURN proxima_cita;
END//

#Función que devuelve el impporte total que debe un paciente.

CREATE OR REPLACE FUNCTION pagosPendientes(p_dni VARCHAR(9))
RETURNS DECIMAL(10,2)
LANGUAGE SQL
NOT DETERMINISTIC
CONTAINS SQL
SQL SECURITY DEFINER
BEGIN

    DECLARE totalDeuda DECIMAL(10,2);

    SELECT SUM(Importe) INTO totalDeuda FROM PagoFinanciacion pf
    RIGHT JOIN GestionCita gc ON pf.ID_Cita = gc.ID_Cita WHERE gc.DNI_Paciente = p_dni
    AND pf.PagoPendiente = 'No pagado';

    RETURN IFNULL(totalDeuda, 0);
END//

#Función que devuelve la fecha de vencimiento de una autorización determinada.

CREATE OR REPLACE FUNCTION vencimientoAutorizacion(p_dni VARCHAR(9), p_NumAutorizacion INT)
RETURNS date
LANGUAGE SQL
NOT DETERMINISTIC
CONTAINS SQL
SQL SECURITY DEFINER
BEGIN

DECLARE fechaVencimiento DATE;

    SELECT FechaVencimiento INTO fechaVencimiento
    FROM autorizacion WHERE DNI_Paciente = p_dni AND NumAutorizacion = p_NumAutorizacion;

    RETURN fechaVencimiento;
END//

DELIMITER ;

SELECT contarNumPacientes();
SELECT cantidadProductos("Botes de Crema");
SELECT comprobarPaciente('48422496C');
SELECT ingresosPorMes(2025, 2);
SELECT numPorCompañia('Mapfre');
SELECT obtnerProxCita('48422496C');
SELECT pagosPendientes('48422496C');
SELECT vencimientoAutorizacion('48422496C', '10455698');
