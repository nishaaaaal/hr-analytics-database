-- HR Analytics Database Schema
-- Database: hr_db

CREATE DATABASE hr_db;
\c hr_db;

-- Tables
CREATE TABLE department (
    department_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE position (
    position_id SERIAL PRIMARY KEY,
    title VARCHAR(50) NOT NULL,
    department_id INT REFERENCES department(department_id)
);

CREATE TABLE employee (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    gender VARCHAR(15),
    date_of_birth DATE,
    hire_date DATE NOT NULL,
    termination_date DATE,
    department_id INT REFERENCES department(department_id),
    position_id INT REFERENCES position(position_id),
    current_salary NUMERIC(12,2) CHECK (current_salary >= 0)
);

CREATE TABLE performance_review (
    review_id SERIAL PRIMARY KEY,
    employee_id INT REFERENCES employee(employee_id),
    review_date DATE,
    satisfaction_level NUMERIC(3,2),
    last_evaluation NUMERIC(3,2),
    number_project INT,
    average_monthly_hours INT,
    time_spend_company INT,
    work_accident INT,
    left_company INT,
    promotion_last_5years INT,
    score INT CHECK (score >= 1 AND score <= 5)
);

CREATE TABLE salary_history (
    salary_id SERIAL PRIMARY KEY,
    employee_id INT REFERENCES employee(employee_id),
    amount NUMERIC(12,2),
    effective_date DATE DEFAULT CURRENT_DATE
);

CREATE TABLE attendance (
    attendance_id SERIAL PRIMARY KEY,
    employee_id INT REFERENCES employee(employee_id),
    date DATE,
    status VARCHAR(20) CHECK (status IN ('Present', 'Absent', 'Leave'))
);

-- Indexes
CREATE INDEX idx_employee_department ON employee(department_id);
CREATE INDEX idx_employee_termination ON employee(termination_date);
CREATE INDEX idx_review_employee ON performance_review(employee_id);
CREATE INDEX idx_emp_dept_salary ON employee(department_id, current_salary);
CREATE INDEX idx_emp_hire_cover ON employee(hire_date) INCLUDE (employee_id);
CREATE INDEX idx_emp_only_terminated ON employee(termination_date) WHERE termination_date IS NOT NULL;

-- Materialized View
CREATE MATERIALIZED VIEW mv_high_performers AS
SELECT e.employee_id, e.first_name, e.last_name, e.current_salary, p.score
FROM employee e
JOIN performance_review p ON e.employee_id = p.employee_id
WHERE p.score >= 4;

-- Sample Data
INSERT INTO department (name) VALUES
('Sales'), ('HR'), ('IT'), ('Finance');

INSERT INTO position (title, department_id) VALUES
('Sales Executive', 1),
('HR Specialist', 2),
('Software Engineer', 3),
('Accountant', 4);

INSERT INTO employee (first_name, last_name, gender, date_of_birth, hire_date, department_id, position_id, current_salary)
VALUES
('Alice','Smith','Female','1990-02-14','2015-06-01',1,1,50000),
('Bob','Johnson','Male','1985-05-21','2010-04-15',3,3,70000),
('Clara','Adams','Female','1992-11-09','2018-01-20',2,2,45000),
('David','Brown','Male','1988-08-30','2012-09-10',4,4,60000);

INSERT INTO performance_review (employee_id, review_date, satisfaction_level, last_evaluation, number_project, average_monthly_hours, time_spend_company, work_accident, left_company, promotion_last_5years, score)
VALUES
(1,'2023-01-15',0.38,0.53,2,157,3,0,1,0,3),
(2,'2023-01-15',0.80,0.86,5,262,6,0,1,0,5),
(3,'2023-01-15',0.72,0.87,5,223,5,0,1,0,4),
(4,'2023-01-15',0.45,0.47,2,160,3,1,1,1,2);

-- Stored Procedure
CREATE OR REPLACE PROCEDURE give_raise(dept_id INT, percentage NUMERIC)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE employee
    SET current_salary = current_salary * (1 + percentage/100)
    WHERE department_id = dept_id
      AND employee_id IN (
          SELECT employee_id FROM performance_review WHERE score >= 4
      );
END;
$$;

-- Function
CREATE OR REPLACE FUNCTION years_worked(emp_id INT)
RETURNS INT AS $$
DECLARE
    yrs INT;
BEGIN
    SELECT EXTRACT(YEAR FROM age(COALESCE(termination_date, CURRENT_DATE), hire_date))
    INTO yrs
    FROM employee
    WHERE employee_id = emp_id;
    RETURN yrs;
END;
$$ LANGUAGE plpgsql;

-- Trigger
CREATE OR REPLACE FUNCTION log_salary_change()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO salary_history (employee_id, amount, effective_date)
    VALUES (NEW.employee_id, NEW.current_salary, CURRENT_DATE);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_salary_update
AFTER UPDATE OF current_salary ON employee
FOR EACH ROW
EXECUTE FUNCTION log_salary_change();

-- View
CREATE OR REPLACE VIEW hr_dashboard AS
SELECT d.name AS department,
       COUNT(e.employee_id) AS total_employees,
       ROUND(AVG(e.current_salary),2) AS avg_salary,
       ROUND(AVG(p.satisfaction_level),2) AS avg_satisfaction,
       SUM(CASE WHEN e.termination_date IS NOT NULL THEN 1 ELSE 0 END)::float /
       COUNT(e.employee_id) * 100 AS attrition_rate
FROM employee e
JOIN department d ON e.department_id = d.department_id
LEFT JOIN performance_review p ON e.employee_id = p.employee_id
GROUP BY d.name;
