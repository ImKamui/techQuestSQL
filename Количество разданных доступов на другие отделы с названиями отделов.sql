SELECT e.employee_id, e.employee_name, d.department_name, COUNT(ra.resource_id) AS access_count
FROM C##ADMIN.employees e
LEFT JOIN C##ADMIN.resource_access ra ON e.employee_id = ra.granted_by 
LEFT JOIN C##ADMIN.departments d on e.department_id = d.department_id
GROUP BY e.employee_id, e.employee_name, d.department_name;