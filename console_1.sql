--Especificación CRUD Empleados
CREATE OR REPLACE PACKAGE pkg_employees AS --SPEC
    --CREATE (PROCEDURE)
    PROCEDURE add_employee (
        p_first_name     IN EMPLOYEES.FIRST_NAME%TYPE,
        p_last_name      IN EMPLOYEES.LAST_NAME%TYPE,
        p_email          IN EMPLOYEES.EMAIL%TYPE,
        p_phone_number   IN EMPLOYEES.PHONE_NUMBER%TYPE DEFAULT NULL,
        p_hire_date      IN EMPLOYEES.HIRE_DATE%TYPE DEFAULT SYSDATE,
        p_job_id         IN EMPLOYEES.JOB_ID%TYPE,
        p_salary         IN employees.salary%TYPE,
        p_commission_pct IN employees.commission_pct%TYPE DEFAULT NULL,
        p_manager_id     IN employees.manager_id%TYPE DEFAULT NULL,
        p_department_id  IN employees.department_id%TYPE DEFAULT NULL
    );

    --READ (FUNCTION)
    FUNCTION get_employee_by_id (
        p_employee_id   IN EMPLOYEES.EMPLOYEE_ID%TYPE
    )RETURN SYS_REFCURSOR;

    --UPDATE (PROCEDURE)
    PROCEDURE update_employee_salary (
        p_employee_id   IN EMPLOYEES.EMPLOYEE_ID%TYPE,
        p_new_salary    IN EMPLOYEES.SALARY%TYPE
    );

    --DELETE (PROCEDURE)
    PROCEDURE delete_employee (
        p_employee_id   IN EMPLOYEES.EMPLOYEE_ID%TYPE
    );

    --Mostrar los 4 empleados con más rotación de puesto
    PROCEDURE show_top_rotating_employees;

    --Resumen promedio de contrataciones por mes
    FUNCTION show_avg_hires_per_month RETURN NUMBER;

    --Gastos en salario y estdísticas a nivel regional
    PROCEDURE show_regional_salary_stats;

    --Calcular tiempo de servicio (vacaciones)
    --1. Devuelve los meses de vacaciones que le tocan al empleado
    FUNCTION calculate_vacation_months (
        p_employee_id IN employees.employee_id%TYPE
    ) RETURN NUMBER;
    --2. Retornar monto total de tiempo de servicios (costo de vacaciones)
    FUNCTION get_total_vacation_cost RETURN NUMBER;

    --Calcular horas laborales en un mes/año
    FUNCTION calculate_hours_worked (
        p_employee_id IN employees.employee_id%TYPE,
        p_month       IN NUMBER,
        p_year        IN NUMBER
    ) RETURN NUMBER;

    --Calcular horas de falta en un mes/año
    FUNCTION calculate_hours_missed (
        p_employee_id IN employees.employee_id%TYPE,
        p_month       IN NUMBER,
        p_year        IN NUMBER
    ) RETURN NUMBER;

    --Reporte de sueldo correspondiente (después de descuentos)
    PROCEDURE calculate_monthly_payroll (
        p_month       IN NUMBER,
        p_year        IN NUMBER
    );

    --Horas totales de capacitación por empleado
    FUNCTION get_employee_training_hours (
        p_employee_id   IN EMPLOYEES.EMPLOYEE_ID%TYPE
    )RETURN NUMBER;

    --Listar capacitaciones y horas por empleado
    PROCEDURE show_training_report;

END pkg_employees;
/

--BODY CRUD empleados
CREATE OR REPLACE PACKAGE BODY pkg_employees AS

    -- IMPLEMENTACIÓN CRUD: CREATE
    PROCEDURE add_employee (
        p_first_name      IN employees.first_name%TYPE,
        p_last_name       IN employees.last_name%TYPE,
        p_email           IN employees.email%TYPE,
        p_phone_number    IN employees.phone_number%TYPE DEFAULT NULL,
        p_hire_date       IN employees.hire_date%TYPE DEFAULT SYSDATE,
        p_job_id          IN employees.job_id%TYPE,
        p_salary          IN employees.salary%TYPE,
        p_commission_pct  IN employees.commission_pct%TYPE DEFAULT NULL,
        p_manager_id      IN employees.manager_id%TYPE DEFAULT NULL,
        p_department_id   IN employees.department_id%TYPE DEFAULT NULL
    ) IS
    BEGIN
        INSERT INTO employees (
            employee_id, first_name, last_name, email, phone_number,
            hire_date, job_id, salary, commission_pct, manager_id, department_id
        ) VALUES (
            (SELECT NVL(MAX(employee_id), 0) + 1 FROM employees), -- Genera un nuevo ID simple
            p_first_name, p_last_name, p_email, p_phone_number,
            p_hire_date, p_job_id, p_salary, p_commission_pct, p_manager_id, p_department_id
        );
        COMMIT;
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('Error: El email ''' || p_email || ''' ya existe.');
            ROLLBACK;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error inesperado al agregar empleado: ' || SQLERRM);
            ROLLBACK;
    END add_employee;

    -- IMPLEMENTACIÓN CRUD: READ
    FUNCTION get_employee_by_id (
        p_employee_id     IN employees.employee_id%TYPE
    ) RETURN SYS_REFCURSOR IS
        v_cursor SYS_REFCURSOR;
    BEGIN
        OPEN v_cursor FOR
            SELECT * FROM employees WHERE employee_id = p_employee_id;
        RETURN v_cursor;
    END get_employee_by_id;

    -- IMPLEMENTACIÓN CRUD: UPDATE
    PROCEDURE update_employee_salary (
        p_employee_id     IN employees.employee_id%TYPE,
        p_new_salary      IN employees.salary%TYPE
    ) IS
    BEGIN
        UPDATE employees
        SET salary = p_new_salary
        WHERE employee_id = p_employee_id;
        COMMIT;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Error: No se encontró el empleado con ID ' || p_employee_id);
            ROLLBACK;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error inesperado al actualizar salario: ' || SQLERRM);
            ROLLBACK;
    END update_employee_salary;

    -- IMPLEMENTACIÓN CRUD: DELETE
    PROCEDURE delete_employee (
        p_employee_id     IN employees.employee_id%TYPE
    ) IS
    BEGIN
        DELETE FROM employees
        WHERE employee_id = p_employee_id;
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error inesperado al eliminar empleado: ' || SQLERRM);
            ROLLBACK;
    END delete_employee;

    -- IMPLEMENTACIÓN TAREA 3.1.1
    PROCEDURE show_top_rotating_employees IS
    BEGIN
        FOR rec IN (
            SELECT
                e.employee_id, e.last_name, e.first_name, e.job_id AS current_job_id,
                j.job_title AS current_job_title, jh.job_changes
            FROM
                employees e
            JOIN
                jobs j ON e.job_id = j.job_id
            JOIN
                ( SELECT employee_id, COUNT(*) AS job_changes
                  FROM job_history
                  GROUP BY employee_id
                ) jh ON e.employee_id = jh.employee_id
            ORDER BY
                jh.job_changes DESC
            FETCH FIRST 4 ROWS ONLY
        )
        LOOP
            DBMS_OUTPUT.PUT_LINE(
                'Empleado: ' || rec.employee_id || ' - ' || rec.first_name || ' ' || rec.last_name ||
                ', Puesto Actual: (' || rec.current_job_id || ') ' || rec.current_job_title ||
                ', Cambios de Puesto: ' || rec.job_changes
            );
        END LOOP;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error al obtener el reporte de rotación: ' || SQLERRM);
    END show_top_rotating_employees;

    -- IMPLEMENTACIÓN TAREA 3.1.2
    FUNCTION show_avg_hires_per_month RETURN NUMBER IS
        v_total_anios           NUMBER;
        v_total_meses_listados  NUMBER := 0;
    BEGIN
        -- 1. Calcular el total de años distintos que hay en la BD
        SELECT COUNT(DISTINCT TO_CHAR(hire_date, 'YYYY'))
        INTO v_total_anios
        FROM employees;

        IF v_total_anios = 0 THEN
            DBMS_OUTPUT.PUT_LINE('No hay datos de empleados para calcular estadísticas.');
            RETURN 0;
        END IF;

        DBMS_OUTPUT.PUT_LINE('--- Resumen Estadístico de Contrataciones por Mes ---');
        DBMS_OUTPUT.PUT_LINE('(Promedio basado en ' || v_total_anios || ' años de data)');
        DBMS_OUTPUT.PUT_LINE('---------------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE(RPAD('Nombre del Mes', 25) || 'Promedio de Contrataciones');
        DBMS_OUTPUT.PUT_LINE('---------------------------------------------------------');

        -- 2. Recorrer los meses, contar contrataciones y dividir por el total de años
        FOR rec IN (
            SELECT
                -- Usamos TRIM para quitar espacios extra que 'Month' puede dejar
                TRIM(TO_CHAR(hire_date, 'Month', 'NLS_DATE_LANGUAGE=SPANISH')) AS nombre_mes,
                COUNT(*) / v_total_anios AS promedio_contrataciones,
                TO_CHAR(hire_date, 'MM') AS mes_num -- Para ordenar
            FROM employees
            GROUP BY TRIM(TO_CHAR(hire_date, 'Month', 'NLS_DATE_LANGUAGE=SPANISH')), TO_CHAR(hire_date, 'MM')
            ORDER BY mes_num
        )
        LOOP
            -- Imprimir la fila formateada
            DBMS_OUTPUT.PUT_LINE(
                RPAD(INITCAP(rec.nombre_mes), 25) || -- INITCAP pone la 1ra letra en Mayúscula
                TO_CHAR(rec.promedio_contrataciones, '990.00')
            );
            v_total_meses_listados := v_total_meses_listados + 1;
        END LOOP;

        DBMS_OUTPUT.PUT_LINE('---------------------------------------------------------');

        -- 3. Retornar el total de meses
        RETURN v_total_meses_listados;

    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error en la función: ' || SQLERRM);
            RETURN -1; -- Indicar error
    END show_avg_hires_per_month;

    -- TAREA 3.1.3: Gastos en salario y estadística a nivel regional
    PROCEDURE show_regional_salary_stats IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('--- Estadísticas de Salarios por Región ---');
        DBMS_OUTPUT.PUT_LINE(
            RPAD('Región', 25) ||
            RPAD('Suma Salarios', 18) ||
            RPAD('Cant. Empleados', 18) ||
            'Empleado Más Antiguo'
        );
        DBMS_OUTPUT.PUT_LINE(REPLACE(LPAD('-', 80, '-'), '-', '-'));

        FOR rec IN (
            SELECT
                r.region_name,
                SUM(e.salary) AS total_salarios,
                COUNT(e.employee_id) AS total_empleados,
                MIN(e.hire_date) AS fecha_mas_antigua
            FROM
                regions r
            JOIN
                countries c ON r.region_id = c.region_id
            JOIN
                locations l ON c.country_id = l.country_id
            JOIN
                departments d ON l.location_id = d.location_id
            JOIN
                employees e ON d.department_id = e.department_id
            GROUP BY
                r.region_name
            ORDER BY
                r.region_name
        )
        LOOP
            DBMS_OUTPUT.PUT_LINE(
                RPAD(rec.region_name, 25) ||
                RPAD(TO_CHAR(rec.total_salarios, 'FML999,999,990.00'), 18) ||
                RPAD(rec.total_empleados, 18) ||
                TO_CHAR(rec.fecha_mas_antigua, 'DD/MM/YYYY')
            );
        END LOOP;
        DBMS_OUTPUT.PUT_LINE(REPLACE(LPAD('-', 80, '-'), '-', '-'));
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error al generar reporte regional: ' || SQLERRM);
    END show_regional_salary_stats;

    -- TAREA 3.1.4: Calcular tiempo de servicio (vacaciones)
    FUNCTION calculate_vacation_months (
        p_employee_id IN employees.employee_id%TYPE
    ) RETURN NUMBER IS
        v_hire_date DATE;
        v_years_service NUMBER;
        v_vacation_months NUMBER;
    BEGIN
        SELECT hire_date
        INTO v_hire_date
        FROM employees
        WHERE employee_id = p_employee_id;

        -- Calculamos los años completos de servicio
        -- MONTHS_BETWEEN da los meses (incluyendo decimales)
        -- Dividimos por 12 para tener años
        -- TRUNC corta los decimales para tener solo años completos
        v_years_service := TRUNC(MONTHS_BETWEEN(SYSDATE, v_hire_date) / 12);

        -- Según la regla: 1 año = 1 mes de vacaciones
        v_vacation_months := v_years_service;

        RETURN v_vacation_months;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Error: No se encontró el empleado con ID ' || p_employee_id);
            RETURN -1;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error al calcular vacaciones: ' || SQLERRM);
            RETURN -1;
    END calculate_vacation_months;


    -- TAREA 3.1.4 (Segunda parte): Retornar monto total de tiempo de servicios (costo de vacaciones)
    FUNCTION get_total_vacation_cost RETURN NUMBER IS
        v_total_cost NUMBER := 0;
        v_vacation_months NUMBER;
        v_employee_cost NUMBER;
    BEGIN
        -- Recorremos todos los empleados
        FOR rec IN (
            SELECT employee_id, salary
            FROM employees
            WHERE salary IS NOT NULL AND salary > 0
        )
        LOOP
            -- Reutilizamos la función que acabamos de crear
            v_vacation_months := calculate_vacation_months(rec.employee_id);

            IF v_vacation_months > 0 THEN
                -- Calculamos el costo para este empleado
                v_employee_cost := v_vacation_months * rec.salary;

                -- Sumamos al total general
                v_total_cost := v_total_cost + v_employee_cost;
            END IF;

        END LOOP;

        RETURN v_total_cost;

    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error al calcular costo total de vacaciones: ' || SQLERRM);
            RETURN -1;
    END get_total_vacation_cost;

    -- TAREA 3.1.5: Calcular horas laboradas en un mes/año
    FUNCTION calculate_hours_worked (
        p_employee_id IN employees.employee_id%TYPE,
        p_month       IN NUMBER,
        p_year        IN NUMBER
    ) RETURN NUMBER IS
        v_total_hours NUMBER := 0;
        v_daily_hours NUMBER;
    BEGIN
        FOR rec IN (
            SELECT hora_inicio_real, hora_termino_real
            FROM asistencia_empleado
            WHERE codigo_empleado = p_employee_id
              AND TO_CHAR(fecha_real, 'MM') = TO_CHAR(p_month, '00') -- Formato '00' para asegurar 2 dígitos
              AND TO_CHAR(fecha_real, 'YYYY') = TO_CHAR(p_year)
              AND hora_inicio_real IS NOT NULL
              AND hora_termino_real IS NOT NULL
        )
        LOOP
            -- (TO_DATE('18:00', 'HH24:MI') - TO_DATE('09:00', 'HH24:MI')) * 24 = 9 horas
            -- Usamos TRY_TO_DATE en caso de mal formato, aunque VARCHAR2(5) es estricto
            v_daily_hours := (TO_DATE(rec.hora_termino_real, 'HH24:MI') - TO_DATE(rec.hora_inicio_real, 'HH24:MI')) * 24;
            v_total_hours := v_total_hours + v_daily_hours;
        END LOOP;

        RETURN v_total_hours;

    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error en calculate_hours_worked: ' || SQLERRM);
            RETURN -1;
    END calculate_hours_worked;

    -- TAREA 3.1.6: Calcular horas de falta en un mes/año
    FUNCTION calculate_hours_missed (
        p_employee_id IN employees.employee_id%TYPE,
        p_month       IN NUMBER,
        p_year        IN NUMBER
    ) RETURN NUMBER IS
        v_total_missed_hours NUMBER := 0;
        v_scheduled_hours NUMBER;
        v_shift_start VARCHAR2(5);
        v_shift_end   VARCHAR2(5);
        v_turno       empleado_horario.turno%TYPE;
    BEGIN
        -- Recorremos las ausencias registradas (donde las horas son NULL)
        FOR rec IN (
            SELECT dia_semana
            FROM asistencia_empleado
            WHERE codigo_empleado = p_employee_id
              AND TO_CHAR(fecha_real, 'MM') = TO_CHAR(p_month, '00')
              AND TO_CHAR(fecha_real, 'YYYY') = TO_CHAR(p_year)
              AND hora_inicio_real IS NULL
              AND hora_termino_real IS NULL
        )
        LOOP
            BEGIN
                -- 1. Encontrar el turno asignado al empleado para ese día de la semana
                SELECT turno
                INTO v_turno
                FROM empleado_horario
                WHERE codigo_empleado = p_employee_id
                  AND dia_semana = rec.dia_semana;

                -- 2. Encontrar las horas programadas para ese turno
                SELECT hora_inicio, hora_termino
                INTO v_shift_start, v_shift_end
                FROM horario
                WHERE dia_semana = rec.dia_semana
                  AND turno = v_turno;

                -- 3. Calcular la duración del turno que se perdió
                v_scheduled_hours := (TO_DATE(v_shift_end, 'HH24:MI') - TO_DATE(v_shift_start, 'HH24:MI')) * 24;

                v_total_missed_hours := v_total_missed_hours + v_scheduled_hours;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    -- El empleado tenía una ausencia marcada pero no tenía un horario asignado
                    DBMS_OUTPUT.PUT_LINE('Advertencia: Empleado ' || p_employee_id || ' con ausencia el ' || rec.dia_semana || ' sin horario asignado.');
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('Error buscando horario para ' || rec.dia_semana || ': ' || SQLERRM);
            END;
        END LOOP;

        RETURN v_total_missed_hours;

    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error en calculate_hours_missed: ' || SQLERRM);
            RETURN -1;
    END calculate_hours_missed;

    -- TAREA 3.1.7: Reporte de sueldo correspondiente (después de descuentos)
    PROCEDURE calculate_monthly_payroll (
        p_month       IN NUMBER,
        p_year        IN NUMBER
    ) IS
        v_start_date DATE := TO_DATE(p_year || '-' || LPAD(p_month, 2, '0') || '-01', 'YYYY-MM-DD');
        v_end_date   DATE := LAST_DAY(v_start_date);
        v_current_day DATE;
        v_day_name   VARCHAR2(20);
        v_total_month_scheduled_hours NUMBER;
        v_shift_duration NUMBER;

        v_missed_hours NUMBER;
        v_hourly_rate  NUMBER;
        v_deduction    NUMBER;
        v_final_salary NUMBER;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('--- Reporte de Planilla para ' || TO_CHAR(v_start_date, 'Month YYYY', 'NLS_DATE_LANGUAGE=SPANISH') || ' ---');
        DBMS_OUTPUT.PUT_LINE(RPAD('Empleado', 30) || RPAD('Salario Base', 15) || RPAD('Horas Faltadas', 18) || RPAD('Descuento', 15) || 'Salario Final');
        DBMS_OUTPUT.PUT_LINE(REPLACE(LPAD('-', 90, '-'), '-', '-'));

        -- Recorremos todos los empleados que tienen salario
        FOR rec IN (
            SELECT employee_id, first_name, last_name, salary
            FROM employees
            WHERE salary IS NOT NULL AND salary > 0
        )
        LOOP
            -- 1. Calcular el total de horas programadas para este empleado en el mes
            v_total_month_scheduled_hours := 0;
            v_current_day := v_start_date;

            WHILE v_current_day <= v_end_date LOOP
                v_day_name := TRIM(TO_CHAR(v_current_day, 'DAY', 'NLS_DATE_LANGUAGE=SPANISH'));
                v_shift_duration := 0;

                BEGIN
                    -- Busca la duración del turno para ese día de la semana
                    SELECT (TO_DATE(h.hora_termino, 'HH24:MI') - TO_DATE(h.hora_inicio, 'HH24:MI')) * 24
                    INTO v_shift_duration
                    FROM horario h
                    JOIN empleado_horario eh ON h.dia_semana = eh.dia_semana AND h.turno = eh.turno
                    WHERE eh.codigo_empleado = rec.employee_id AND h.dia_semana = UPPER(v_day_name);
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        v_shift_duration := 0; -- No trabaja ese día
                END;

                v_total_month_scheduled_hours := v_total_month_scheduled_hours + v_shift_duration;
                v_current_day := v_current_day + 1;
            END LOOP;

            -- 2. Calcular el salario final
            IF v_total_month_scheduled_hours > 0 THEN
                -- Calcular tarifa por hora
                v_hourly_rate := rec.salary / v_total_month_scheduled_hours;

                -- Llamar a la función de horas faltadas
                v_missed_hours := calculate_hours_missed(rec.employee_id, p_month, p_year);

                -- Calcular descuento y salario final
                v_deduction := v_missed_hours * v_hourly_rate;
                v_final_salary := rec.salary - v_deduction;
            ELSE
                -- No tiene horas programadas, no hay descuentos
                v_missed_hours := 0;
                v_deduction := 0;
                v_final_salary := rec.salary;
            END IF;

            -- 3. Imprimir el reporte
            DBMS_OUTPUT.PUT_LINE(
                RPAD(rec.first_name || ' ' || rec.last_name, 30) ||
                RPAD(TO_CHAR(rec.salary, 'FML999,990.00'), 15) ||
                RPAD(v_missed_hours, 18) ||
                RPAD(TO_CHAR(v_deduction, 'FML999,990.00'), 15) ||
                TO_CHAR(v_final_salary, 'FML999,990.00')
            );

        END LOOP;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error al generar planilla: ' || SQLERRM);
    END calculate_monthly_payroll;

    -- TAREA 3.1.1 (Página 5): Horas totales de capacitación por empleado
    FUNCTION get_employee_training_hours (
        p_employee_id IN employees.employee_id%TYPE
    ) RETURN NUMBER IS
        v_total_hours NUMBER := 0;
    BEGIN
        SELECT SUM(c.horas_capacitacion)
        INTO v_total_hours
        FROM capacitacion c
        JOIN empleadocapacitacion ec ON c.codigo_capacitacion = ec.codigo_capacitacion
        WHERE ec.codigo_empleado = p_employee_id;

        -- Si SUM devuelve NULL (porque no tiene cursos), lo convertimos a 0
        RETURN NVL(v_total_hours, 0);

    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error en get_employee_training_hours: ' || SQLERRM);
            RETURN -1;
    END get_employee_training_hours;


    -- TAREA 3.1.2 (Página 5): Listar capacitaciones y horas por empleado
    PROCEDURE show_training_report IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('--- Reporte de Capacitaciones y Horas por Empleado ---');

        -- 1. Loop principal por CURSO
        FOR course_rec IN (
            SELECT codigo_capacitacion, nombre_capacitacion, horas_capacitacion
            FROM capacitacion
            ORDER BY nombre_capacitacion
        )
        LOOP
            DBMS_OUTPUT.PUT_LINE('--------------------------------------------------');
            DBMS_OUTPUT.PUT_LINE('CURSO: ' || course_rec.nombre_capacitacion || ' (' || course_rec.horas_capacitacion || 'h)');
            DBMS_OUTPUT.PUT_LINE(RPAD('  -> Empleado', 30) || 'Horas Totales (en *todas* las capacitaciones)');

            -- 2. Loop anidado por EMPLEADO, ordenado por sus horas totales
            -- Usamos una subconsulta para obtener el total de horas de cada empleado
            -- y poder ordenar por ellas, como pide el ejercicio.
            FOR emp_rec IN (
                SELECT
                    e.first_name, e.last_name,
                    -- Re-usamos la lógica de la función anterior para ordenar
                    (SELECT SUM(c_inner.horas_capacitacion)
                     FROM capacitacion c_inner
                     JOIN empleadocapacitacion ec_inner ON c_inner.codigo_capacitacion = ec_inner.codigo_capacitacion
                     WHERE ec_inner.codigo_empleado = e.employee_id) AS total_training_hours
                FROM
                    employees e
                JOIN
                    empleadocapacitacion ec_outer ON e.employee_id = ec_outer.codigo_empleado
                WHERE
                    ec_outer.codigo_capacitacion = course_rec.codigo_capacitacion
                ORDER BY
                    total_training_hours DESC -- Ordenado por total de horas
            )
            LOOP
                DBMS_OUTPUT.PUT_LINE(
                    RPAD('     - ' || emp_rec.first_name || ' ' || emp_rec.last_name, 30) ||
                    emp_rec.total_training_hours || ' horas'
                );
            END LOOP;

        END LOOP;
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------------');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error en show_training_report: ' || SQLERRM);
    END show_training_report;

END pkg_employees;
/

--TRIGGERS
--Verificación de Asistencia
CREATE OR REPLACE TRIGGER trg_verify_asistencia_insert
BEFORE INSERT ON asistencia_empleado
FOR EACH ROW
DECLARE
    v_scheduled_start   horario.hora_inicio%TYPE;
    v_scheduled_end     horario.hora_termino%TYPE;
    v_actual_day_name   VARCHAR2(20);
BEGIN
    -- 1. Verificar la correspondencia entre la fecha y el día de la semana
    v_actual_day_name := TRIM(UPPER(TO_CHAR(:NEW.fecha_real, 'DAY', 'NLS_DATE_LANGUAGE=SPANISH')));

    IF v_actual_day_name != UPPER(:NEW.dia_semana) THEN
        RAISE_APPLICATION_ERROR(-20001, 'Error 3.2: El día (' || :NEW.dia_semana || ') no corresponde a la fecha (' || TO_CHAR(:NEW.fecha_real, 'DD/MM/YYYY') || ' es ' || v_actual_day_name || ').');
    END IF;

    -- Solo validamos las horas si se está registrando una asistencia (no una falta)
    IF :NEW.hora_inicio_real IS NOT NULL THEN

        -- 2. Obtener el horario programado para ese empleado, en ese día
        BEGIN
            SELECT h.hora_inicio, h.hora_termino
            INTO v_scheduled_start, v_scheduled_end
            FROM horario h
            JOIN empleado_horario eh ON h.dia_semana = eh.dia_semana AND h.turno = eh.turno
            WHERE eh.codigo_empleado = :NEW.codigo_empleado
              AND h.dia_semana = UPPER(:NEW.dia_semana);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20002, 'Error 3.2: El empleado ' || :NEW.codigo_empleado || ' no tiene un horario asignado para el día ' || :NEW.dia_semana || '.');
        END;

        -- 3. Verificar la correspondencia de la hora de inicio
        IF :NEW.hora_inicio_real != v_scheduled_start THEN
            RAISE_APPLICATION_ERROR(-20003, 'Error 3.2: La hora de inicio real (' || :NEW.hora_inicio_real || ') no coincide con la hora programada (' || v_scheduled_start || ').');
        END IF;

        -- 4. Verificar la correspondencia de la hora de término (si se provee)
        IF :NEW.hora_termino_real IS NOT NULL AND :NEW.hora_termino_real != v_scheduled_end THEN
            RAISE_APPLICATION_ERROR(-20004, 'Error 3.2: La hora de término real (' || :NEW.hora_termino_real || ') no coincide con la hora programada (' || v_scheduled_end || ').');
        END IF;

    END IF; -- Fin del check de horas

EXCEPTION
    WHEN OTHERS THEN
        RAISE; -- Relanza cualquier error que ocurra
END;
/

--Validar rango de salarios
CREATE OR REPLACE TRIGGER trg_validate_salary_range
BEFORE INSERT OR UPDATE OF salary ON employees -- Se activa solo en INSERT o si cambia la columna 'salary'
FOR EACH ROW
DECLARE
    v_min_salary   jobs.min_salary%TYPE;
    v_max_salary   jobs.max_salary%TYPE;
BEGIN
    -- 1. Obtener los rangos salariales para el puesto del empleado
    SELECT min_salary, max_salary
    INTO v_min_salary, v_max_salary
    FROM jobs
    WHERE job_id = :NEW.job_id;

    -- 2. Validar que el nuevo salario esté dentro del rango (inclusive)
    IF :NEW.salary NOT BETWEEN v_min_salary AND v_max_salary THEN
        RAISE_APPLICATION_ERROR(-20005, 'Error 3.3: El salario (' || :NEW.salary || ') está fuera del rango permitido (' || v_min_salary || ' - ' || v_max_salary || ') para el puesto ' || :NEW.job_id || '.');
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- Esto pasa si el :NEW.job_id no existe en la tabla JOBS.
        RAISE_APPLICATION_ERROR(-20006, 'Error 3.3: El puesto ' || :NEW.job_id || ' no existe. No se puede validar el salario.');
    WHEN OTHERS THEN
        RAISE;
END;
/

--Chequear asistencias
CREATE OR REPLACE TRIGGER trg_check_attendance_window
BEFORE INSERT ON asistencia_empleado
FOR EACH ROW
DECLARE
    v_scheduled_start   horario.hora_inicio%TYPE;
    v_scheduled_time    DATE;
    v_real_time         DATE;
    v_diff_minutes      NUMBER;
BEGIN
    -- Solo actuar si se está intentando registrar una hora de inicio
    IF :NEW.hora_inicio_real IS NOT NULL THEN

        -- 1. Obtener la hora de ingreso programada
        BEGIN
            SELECT h.hora_inicio
            INTO v_scheduled_start
            FROM horario h
            JOIN empleado_horario eh ON h.dia_semana = eh.dia_semana AND h.turno = eh.turno
            WHERE eh.codigo_empleado = :NEW.codigo_empleado
              AND h.dia_semana = UPPER(:NEW.dia_semana);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                -- No tiene horario, no podemos aplicar la regla.
                -- Dejamos pasar la inserción tal como viene.
                RETURN;
        END;

        -- 2. Convertir las horas (texto) a objetos DATE para compararlas
        v_scheduled_time := TO_DATE(v_scheduled_start, 'HH24:MI');
        v_real_time := TO_DATE(:NEW.hora_inicio_real, 'HH24:MI');

        -- 3. Calcular la diferencia en minutos
        v_diff_minutes := (v_real_time - v_scheduled_time) * 24 * 60;

        -- 4. Aplicar la regla: si está fuera de la ventana de +/- 30 minutos
        IF v_diff_minutes < -30 OR v_diff_minutes > 30 THEN
            -- Marcar como inasistencia "silenciosamente"
            :NEW.hora_inicio_real := NULL;
            :NEW.hora_termino_real := NULL;
        END IF;

    END IF; -- fin del check

EXCEPTION
    WHEN OTHERS THEN
        -- Si algo falla (ej. formato de hora incorrecto),
        -- marcamos como inasistencia por seguridad.
        :NEW.hora_inicio_real := NULL;
        :NEW.hora_termino_real := NULL;
END;
/