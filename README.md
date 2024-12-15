Для работы с базой данных необходимо создать пользователя C##ADMIN в OTHER USERS.
Прежде, чем начать тестировать SQL-скрипты, необходимо загрузить БД путём запуска скрипта "database.sql".
Далее нужно запустить "Первая часть задания.sql" для формирования пакетов, функций и процедур.
В дальнейшем можно запускать любой SQL-скрипт по Вашему желанию для проверки работоспособности.
Чтобы протестировать функции из первой части задания можно использовать следующие скрипты:
Сотрудники:
  1. Добавление сотрудников: 
  BEGIN
      manage_employee.add_employee('Иван Иванов', 1, NULL); -- Сотрудник без начальника
      manage_employee.add_employee('Петр Петров', 1, 1); -- Сотрудник с ID 1 как его начальник
      manage_employee.add_employee('Светлана Светлова', 2, 1); -- Сотрудник с ID 1 как её начальник
      manage_employee.add_employee('Анна Аннова', 2, 2); -- Сотрудник с ID 2 как её начальник
  END;
  /
  
  2. Удаление сотрудника:
  BEGIN
      manage_employee.delete_employee(1); -- Удаление сотрудника с ID 1
  END;
  /
  
  3. Просмотр списка сотрудников: 
  BEGIN
      manage_employee.employee_list;
  END;
  /
  
  4. Детальная информация о сотруднике: 
  DECLARE
      emp_info VARCHAR2(500);
  BEGIN
      emp_info := manage_employee.detail_employee_info(1); -- Получение информации о сотруднике с ID 1
      DBMS_OUTPUT.PUT_LINE(emp_info);
  END;
  /
Ресурсы:
  1. Добавление ресурсов: 
  BEGIN
      manage_resources.add_resource('Ноутбук', 1); -- Ресурс для Ивана Иванова (ID 1)
      manage_resources.add_resource('Проектор', 2); -- Ресурс для Петра Петрова (ID 2)
      manage_resources.add_resource('Телефон', 1); -- Ресурс для Ивана Иванова (ID 1)
  END;
  /

  2. Удаление ресурса: 
  BEGIN
    manage_resources.delete_resource(1); -- Удаление ресурса с ID 1
  END;
  /

  3. Список ресурсов: 
  BEGIN
    manage_resources.resource_list(1);
  END;
  /

  4. Детальная информация о ресурсе: 
  DECLARE
    res_info VARCHAR2(500);
  BEGIN
    res_info := manage_resources.detail_employee_resource(1); -- Получение информации о ресурсе с ID 1
    DBMS_OUTPUT.PUT_LINE(res_info);
  END;
  /

Доступ:
  1. Предоставление доступа к ресурсам: 
  DECLARE 
      result VARCHAR2(100);
  BEGIN 
      result := resource_access.grant_access(1, 2, 1); -- Предоставление доступа к ресурсу с ID 1 сотруднику с ID 2 от Ивана Иванова (ID 1)
      DBMS_OUTPUT.PUT_LINE(result);
      result := resource_access.grant_access(2, 3, 2); -- Предоставление доступа к ресурсу с ID 2 сотруднику с ID 3 от Петра Петрова (ID 2)
      DBMS_OUTPUT.PUT_LINE(result);
  END; 
  /
  
  2. Отзыв доступа: 
  DECLARE 
      result VARCHAR2(100);
  BEGIN 
      result := resource_access.revoke_access(2, 1); -- Отзыв доступа у сотрудника с ID 2 к ресурсу с ID 1 
      DBMS_OUTPUT.PUT_LINE(result);
  END; 
  /

  3. Установка ограничений доступа: 
  DECLARE 
    result VARCHAR2(100);
  BEGIN 
    result := resource_access.set_access_restriction(2, 'DENY'); -- Установка ограничения доступа для сотрудника с ID 2 
    DBMS_OUTPUT.PUT_LINE(result);
  END; 
  /

