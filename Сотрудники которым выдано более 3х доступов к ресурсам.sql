SELECT e.employee_id, e.employee_name, count(ra.resource_id) as quantity_access
FROM C##ADMIN.employees e
JOIN C##ADMIN.resource_access ra ON e.employee_id = ra.employee_id
GROUP BY e.employee_id, e.employee_name
HAVING count(ra.resource_id) > 1