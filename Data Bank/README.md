# 📊💳Data Bank SQL Case Study

<img src= https://8weeksqlchallenge.com/images/case-study-designs/4.png >

This project explores a fictional **Data Bank** system using SQL.  
We have **three tables**: `regions`, `customers`, and `transactions`, with a variety of queries to extract insights about customer activities, transactions, and balances.

---

## 🗄 Database Structure

- **regions**: Contains the regions where customers are located.
- **customers**: Links each customer to a region and node, along with their active dates.
- **transactions**: Tracks all customer transactions (deposits, withdrawals, purchases).

---

## Entity Relationship Diagram

<img src= https://8weeksqlchallenge.com/images/case-study-4-erd.png >

***

### Database and Tables Setup

```sql
CREATE DATABASE IF NOT EXISTS Data_Bank;
USE Data_Bank;

-- Create regions table
CREATE TABLE regions (
    region_id INTEGER PRIMARY KEY,
    region_name VARCHAR(50)
);

-- Create customers table
CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    region_id INTEGER,
    node_id INTEGER,
    start_date DATE,
    end_date DATE,
    FOREIGN KEY (region_id) REFERENCES regions(region_id)
);

-- Create transactions table
CREATE TABLE transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    txn_date DATE,
    txn_type VARCHAR(20),
    txn_amount DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
```
---

## ❓ Business Questions Solved

### A. 🧑‍💻 Customer Nodes Exploration
1. **How many unique nodes are there on the Data Bank system?**
2. **What is the number of nodes per region?**
3. **How many customers are allocated to each region?**
4. **How many days on average are customers reallocated to a different node?**
5. **What is the median, 80th and 95th percentile for this same reallocation days metric for each region?**

### B. 💵 Customer Transactions
1. **What is the unique count and total amount for each transaction type?**
2. **What is the average total historical deposit counts and amounts for all customers?**
3. **For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?**
4. **What is the closing balance for each customer at the end of the month?**
5. **What is the percentage of customers who increase their closing balance by more than 5%?**

---

## 🧠 Skills Practiced
- SQL Joins
- Aggregations
- Sub Query
- CASE Statements
- Windows Functions
- Common Table Expression (CTE)

---



