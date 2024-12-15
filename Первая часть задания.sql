CREATE OR REPLACE PACKAGE C##ADMIN.manage_employee AS
    PROCEDURE add_employee(p_employee_name IN VARCHAR2, p_department_id IN NUMBER, p_manager_id IN NUMBER);
    PROCEDURE delete_employee(p_employee_id IN NUMBER);
    PROCEDURE employee_list;
    FUNCTION detail_employee_info(p_employee_id IN NUMBER) RETURN VARCHAR2;
END manage_employee;
/

CREATE OR REPLACE PACKAGE BODY manage_employee AS

    PROCEDURE log_action (p_action IN VARCHAR2) IS
    BEGIN
        INSERT INTO C##ADMIN.LOGS(ACTION, ACTION_TIME) VALUES (p_action, SYSTIMESTAMP);
        COMMIT;
    END log_action;

    PROCEDURE add_employee (p_employee_name IN VARCHAR2, p_department_id IN NUMBER, p_manager_id IN NUMBER) IS 
        v_employee_id NUMBER;
    BEGIN
        SELECT NVL(MAX(employee_id), 0) + 1 INTO v_employee_id FROM C##ADMIN.employees;
        INSERT INTO C##ADMIN.employees(employee_id, employee_name, department_id, manager_id) 
        VALUES (v_employee_id, p_employee_name, p_department_id, p_manager_id);
        log_action('Добавлен сотрудник: ' || p_employee_name);
    END add_employee;

    PROCEDURE delete_employee (p_employee_id IN NUMBER) IS
    BEGIN
        DELETE FROM C##ADMIN.employees WHERE employee_id = p_employee_id;
        log_action('Удалён сотрудник с ID: ' || p_employee_id);
    END delete_employee;

    PROCEDURE employee_list IS
        CURSOR emp_cursor IS SELECT * FROM C##ADMIN.employees;
        emp_record emp_cursor%ROWTYPE;
    BEGIN
        FOR emp_record IN emp_cursor LOOP
            DBMS_OUTPUT.PUT_LINE('ID сотрудника: ' || emp_record.employee_id || ', Имя сотрудника: ' || emp_record.employee_name);
        END LOOP;
    END employee_list;

    FUNCTION detail_employee_info(p_employee_id IN NUMBER) RETURN VARCHAR2 IS
        emp_details VARCHAR2(5000);
    BEGIN
        SELECT employee_name INTO emp_details FROM C##ADMIN.employees WHERE employee_id = p_employee_id;
        RETURN emp_details;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'Такого сотрудника нет';
    END detail_employee_info;

END manage_employee;
/

CREATE OR REPLACE PACKAGE manage_resources AS
    PROCEDURE add_resource(p_resource_name IN VARCHAR2, p_owner_id IN NUMBER);
    PROCEDURE delete_resource(p_resource_id IN NUMBER);
    PROCEDURE resource_list(p_owner_id IN NUMBER);
    FUNCTION detail_employee_resource(p_resource_id IN NUMBER) RETURN VARCHAR2;
END manage_resources;
/

CREATE OR REPLACE PACKAGE BODY manage_resources AS

    PROCEDURE log_action (p_action IN VARCHAR2) IS
    BEGIN
        INSERT INTO C##ADMIN.LOGS(ACTION, ACTION_TIME) VALUES (p_action, SYSTIMESTAMP);
        COMMIT;
    END log_action;

    PROCEDURE add_resource (p_resource_name IN VARCHAR2, p_owner_id IN NUMBER) IS 
        v_resource_id NUMBER;
    BEGIN
        SELECT NVL(MAX(resource_id), 0) + 1 INTO v_resource_id FROM C##ADMIN.resources;
        INSERT INTO C##ADMIN.resources(resource_id, resource_name, owner_id)
        VALUES (v_resource_id, p_resource_name, p_owner_id);
        log_action('Добавлен ресурс ' || p_resource_name || ' для сотрудника с ID ' || p_owner_id);
        UPDATE C##ADMIN.employees SET access_restriction = 'ALLOW' WHERE employee_id = p_owner_id;
    END add_resource;

    PROCEDURE delete_resource(p_resource_id IN NUMBER) IS
    BEGIN
        DELETE FROM C##ADMIN.resources WHERE resource_id = p_resource_id;
        log_action('Удалён ресурс с ID ' || p_resource_id);
    END delete_resource;

    PROCEDURE resource_list(p_owner_id IN NUMBER) IS
        CURSOR res_cursor IS SELECT * FROM C##ADMIN.resources WHERE owner_id = p_owner_id;
        res_record res_cursor%ROWTYPE;
    BEGIN
        FOR res_record IN res_cursor LOOP
            DBMS_OUTPUT.PUT_LINE('ID ресурса: ' || res_record.resource_id || ', Название ресурса: ' || res_record.resource_name || ', ID владельца ресурса: ' || res_record.owner_id);
        END LOOP;
    END resource_list;

    FUNCTION detail_employee_resource (p_resource_id IN NUMBER) RETURN VARCHAR2 IS
        res_details VARCHAR2(5000);
    BEGIN
        SELECT resource_name INTO res_details FROM C##ADMIN.resources WHERE resource_id = p_resource_id; 
        RETURN res_details; 
    EXCEPTION 
        WHEN NO_DATA_FOUND THEN 
            RETURN 'У сотрудника нет ресурса'; 
    END detail_employee_resource;

END manage_resources;
/

CREATE OR REPLACE PACKAGE resource_access AS
    FUNCTION grant_access(p_resource_id IN NUMBER, p_employee_id IN NUMBER, p_granted_by IN NUMBER) RETURN VARCHAR2;
    FUNCTION revoke_access (p_employee_id IN NUMBER, p_resource_id IN NUMBER) RETURN VARCHAR2;
    FUNCTION set_access_restriction(p_employee_id IN NUMBER, p_access_restriction IN VARCHAR2) RETURN VARCHAR2;
END resource_access;
/ 

CREATE OR REPLACE PACKAGE BODY resource_access AS

    PROCEDURE log_action (p_action IN VARCHAR2) IS
    BEGIN
        INSERT INTO C##ADMIN.LOGS(ACTION, ACTION_TIME) VALUES (p_action, SYSTIMESTAMP);
        COMMIT;
    END log_action;

    FUNCTION grant_access(p_resource_id IN NUMBER, p_employee_id IN NUMBER, p_granted_by IN NUMBER) RETURN VARCHAR2 IS
        v_access_restriction VARCHAR2(100);
        v_manager_id NUMBER;
        v_existing_access_count NUMBER;
    BEGIN
            SELECT access_restriction INTO v_access_restriction FROM C##ADMIN.employees WHERE employee_id = p_employee_id; 
            IF v_access_restriction = 'DENY' THEN 
                RETURN 'Доступ запрещён: Доступ для сотрудника ' || p_employee_id || ' ограничен.'; 
            END IF; 
            IF v_access_restriction LIKE '%DENY_WITH_SPEC%' AND instr(v_access_restriction, TO_CHAR(p_granted_by)) > 0 THEN 
                RETURN 'Доступ запрещён: Доступ ограничен для этого пользователя'; 
            END IF;
            SELECT COUNT(*) INTO v_existing_access_count FROM C##ADMIN.resource_access WHERE resource_id = p_resource_id AND employee_id = p_employee_id;
            IF v_existing_access_count > 0 THEN
                RETURN 'Доступ уже существует.';
            END IF;
            SELECT manager_id INTO v_manager_id FROM C##ADMIN.employees WHERE employee_id = p_employee_id;
            IF p_granted_by != v_manager_id THEN 
                RETURN 'Доступ запрещён: Только начальник может выдать доступ'; 
            END IF; 
            INSERT INTO C##ADMIN.resource_access (resource_id, employee_id, granted_by) VALUES (p_resource_id, p_employee_id, p_granted_by); 
            log_action('Выдан доступ к ресурсу с ID ' || p_resource_id || ' сотруднику с ID ' || p_employee_id);
            UPDATE C##ADMIN.employees SET access_restriction = 'ALLOW' WHERE employee_id = p_employee_id;
            RETURN 'Доступ выдан'; 
     EXCEPTION WHEN DUP_VAL_ON_INDEX THEN 
         RETURN 'Доступ уже существует'; 
     END grant_access; 

     FUNCTION revoke_access (p_employee_id IN NUMBER, p_resource_id IN NUMBER) RETURN VARCHAR2 IS 
         v_granted_by NUMBER;
         v_manager_id NUMBER;
     BEGIN
         SELECT manager_id INTO v_manager_id FROM C##ADMIN.employees WHERE employee_id = p_employee_id;
         SELECT granted_by INTO v_granted_by FROM C##ADMIN.resource_access WHERE resource_id = p_resource_id AND employee_id = p_employee_id; 
         IF v_granted_by != v_manager_id THEN 
             RETURN 'Доступ запрещён: Только начальник может аннулировать доступ'; 
         END IF; 

         DELETE FROM C##ADMIN.resource_access WHERE resource_id = p_resource_id AND employee_id = p_employee_id; 
         log_action('Отозван доступ к ресурсу с ID ' || p_resource_id || ' у сотрудника с ID ' || p_employee_id); 
         RETURN 'Доступ отозван';
     EXCEPTION WHEN NO_DATA_FOUND THEN 
         RETURN 'Доступ не найден';
     END revoke_access; 
     
     FUNCTION set_access_restriction(p_employee_id IN NUMBER, p_access_restriction IN VARCHAR2) RETURN VARCHAR2 IS 
     BEGIN 
         UPDATE C##ADMIN.employees SET access_restriction = p_access_restriction WHERE employee_id = p_employee_id; 
         log_action('Уровень доступа сотрудника с ID ' || TO_CHAR(p_employee_id) || ' изменён на: ' || TO_CHAR(p_access_restriction));
         RETURN 'Изменение уровня доступа успешно';
     EXCEPTION WHEN OTHERS THEN 
         RETURN SQLERRM;
     END set_access_restriction; 

END resource_access;  
/
