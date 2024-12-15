SELECT d.department_id, d.department_name, count(e.employee_id) as Count_of_DENY_access
FROM C##ADMIN.departments d 
JOIN C##ADMIN.employees e ON d.department_id = e.department_id
WHERE e.access_restriction = 'DENY'
GROUP BY d.department_name, d.department_id;
