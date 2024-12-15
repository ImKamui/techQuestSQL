SELECT e.employee_id, e.employee_name, d.department_name, count(ra.resource_id) as access_count
FROM C##ADMIN.employees e
JOIN C##ADMIN.departments d ON d.manager_id = e.employee_id
LEFT JOIN C##ADMIN.resource_access ra ON e.employee_id = ra.employee_id
GROUP BY e.employee_id, e.employee_name, d.department_name;