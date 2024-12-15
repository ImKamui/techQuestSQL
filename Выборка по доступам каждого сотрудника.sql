SELECT e.employee_id, e.employee_name, COUNT(ra.resource_id) AS access_count
FROM  C##ADMIN.employees e
LEFT JOIN C##ADMIN.resource_access ra ON e.employee_id = ra.granted_by
WHERE e.department_id = 1
GROUP BY e.employee_id, e.employee_name;
