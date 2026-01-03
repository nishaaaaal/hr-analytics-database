# HR Analytics Database Project

A comprehensive HR analytics system built with PostgreSQL featuring normalized database schema, advanced SQL operations, and data analysis capabilities.

## Project Overview

This project demonstrates database design and SQL proficiency through an HR analytics system that tracks employee information, performance reviews, salary history, and departmental metrics.

## Database Schema

### Tables
- **department**: Stores department information
- **position**: Job positions linked to departments
- **employee**: Core employee data including personal info and salary
- **performance_review**: Employee performance metrics and evaluations
- **salary_history**: Tracks salary changes over time
- **attendance**: Employee attendance records

### Key Features
- **Normalized schema** with proper foreign key relationships
- **Performance indexes** (composite, covering, partial)
- **Materialized views** for optimized queries
- **Stored procedures** for business logic (salary raises)
- **Functions** for calculations (years worked)
- **Triggers** for automatic logging
- **Views** for dashboard analytics

## Tech Stack

- **Database**: PostgreSQL
- **Languages**: SQL, Python
- **Libraries**: psycopg2, pandas, openpyxl

## Setup Instructions

### 1. Install PostgreSQL
```bash
# Mac (using Homebrew)
brew install postgresql

# Start PostgreSQL service
brew services start postgresql
```

### 2. Create Database
```bash
# Run the SQL script
psql -U postgres -f hr_db_clean.sql
```

### 3. Load Data (Optional)
The script includes sample data. To load the full IBM HR dataset:
```bash
# Use Python script to import Excel data
python load_data.py
```

## Project Structure

```
hr-analytics-db/
├── hr_db_clean.sql          # Complete database schema
├── HR_IBM_DataSet.xlsx      # Source dataset
├── load_data.py             # Python script to load data
├── analysis.py              # Data analysis scripts
├── README.md                # Project documentation
└── .gitignore              # Git ignore rules
```

## Usage Examples

### Query Dashboard
```sql
SELECT * FROM hr_dashboard;
```

### Give Raise to High Performers
```sql
CALL give_raise(1, 10);  -- 10% raise for Sales dept
```

### Calculate Employee Tenure
```sql
SELECT first_name, last_name, years_worked(employee_id) AS years 
FROM employee;
```

### View High Performers
```sql
SELECT * FROM mv_high_performers;
```

## Key SQL Concepts Demonstrated

- Normalized database design (3NF)
- Primary and foreign key constraints
- Check constraints for data validation
- Single-column and composite indexes
- Covering indexes for query optimization
- Partial indexes for selective queries
- Materialized views for performance
- Stored procedures with parameters
- User-defined functions
- Triggers for automatic operations
- Views for reporting
- Window functions and aggregations
- Complex JOINs and subqueries

## Dataset Information

The IBM HR Analytics dataset contains employee attributes including:
- Satisfaction level
- Last evaluation score
- Number of projects
- Average monthly hours
- Time spent at company
- Work accidents
- Attrition (left company)
- Promotions
- Department
- Salary level

## Future Enhancements

- [ ] Add data visualization dashboard
- [ ] Implement machine learning models for attrition prediction
- [ ] Create REST API for database access
- [ ] Add more advanced analytics queries
- [ ] Implement data warehouse design

## Author

Data Science Graduate Student | Database Engineering Enthusiast

## License

MIT License
