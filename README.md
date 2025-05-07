# CompanyDB

A simple MySQL database for managing employees, departments, and projects for a company.

## Database Schema

The database contains the following tables:
- Employee: Stores employee information
- Department: Stores department information
- Project: Stores project information
- Works_On: Junction table for employees working on projects

## Setup Instructions

### Prerequisites
- MySQL Server (5.7+ or 8.0+)
- MySQL client or GUI tool like MySQL Workbench

### Installation Steps

1. Clone this repository:
```bash
git clone https://github.com/marcdejesus/CompanyDB.git
cd CompanyDB
```

2. Log in to MySQL:
```bash
mysql -u root -p
```

3. Create the database:
```sql
CREATE DATABASE company_db;
USE company_db;
```

4. Run the setup script:
```bash
mysql -u root -p company_db < sql/setup.sql
```

5. Verify installation:
```bash
mysql -u root -p company_db -e "SHOW TABLES;"
```

## Sample Queries

This repository includes four SQL query files you can use to explore the database:

1. [sample_queries.sql](sql/sample_queries.sql) - Contains analytical queries demonstrating SQL capabilities.
2. [common_queries.sql](sql/common_queries.sql) - Contains practical, everyday queries for common business needs.
3. [advanced_queries.sql](sql/advanced_queries.sql) - Contains complex queries demonstrating advanced SQL techniques.
4. [plsql_and_joins.sql](sql/plsql_and_joins.sql) - Contains PL/SQL procedures and various JOIN query examples.

You can run these queries directly in MySQL:

```bash
mysql -u root -p company_db < sql/sample_queries.sql
mysql -u root -p company_db < sql/common_queries.sql
mysql -u root -p company_db < sql/advanced_queries.sql
mysql -u root -p company_db < sql/plsql_and_joins.sql
```

## Database Structure

- **Employee**: Contains employee records with ID, name, salary
- **Department**: Contains department information
- **Project**: Contains project details
- **Works_On**: Tracks which employees work on which projects

## License

MIT 