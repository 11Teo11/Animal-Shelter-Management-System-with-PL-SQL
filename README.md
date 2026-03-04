# Animal Shelter Management System - PL/SQL Extension

## Project Overview
This project is an advanced continuation of the **Animal Shelter Management System**, specifically designed for the **Database Management Systems (SGBD)** course. It shifts the focus from basic schema design to procedural logic using **Oracle PL/SQL**, aiming to automate complex business rules and handle data processing within the database engine.

The system manages shelter operations such as medical history tracking, automated adoption workflows, and staff management through advanced programming constructs.

---

## Project Structure
* **`source_code.sql`**: The complete PL/SQL source code containing subprograms, triggers, collections, and the integrated package.
* **`Project.docx`**: Detailed documentation including the ERD and Conceptual Diagrams (in Romanian), along with the natural language descriptions of the implemented problems.

---

## Technical Features

### 1. Advanced Collections
Implemented a complex subprogram that utilizes all three types of PL/SQL collections:
* **Index-by Tables (Associative Arrays)**
* **Nested Tables**
* **Varrays**
Used for batch processing of animal records and temporary data management.

### 2. Cursor Management
Designed logic that combines different types of cursors:
* **Parameterized Cursors**: For flexible data retrieval based on specific shelter branches or animal types.
* **Nested Cursors**: Handling dependent data relationships (e.g., listing all medical procedures for each animal in a specific category).

### 3. Exception Handling & Stored Subprograms
* **Stored Functions**: Implemented a function joining 3 tables with robust error handling for `NO_DATA_FOUND` and `TOO_MANY_ROWS`.
* **Stored Procedures**: Created a procedure with multiple parameters using a 5-table join. It includes **custom user-defined exceptions** to handle business-specific edge cases (e.g., invalid adoption status).

### 4. Database Triggers
Automated the shelter's integrity rules through various trigger types:
* **Statement-level DML Triggers**: For auditing bulk changes to staff salaries or cage assignments.
* **Row-level DML Triggers**: To prevent inconsistent data entry during the adoption process.
* **DDL Triggers**: For monitoring and securing the database schema against unauthorized structural changes.

---

## Database Schema
The implementation is built upon an Oracle schema featuring:
* **Entities**: Employee, Animal, Client, Branch, Cage, etc.
* **Relationships**: Complex associative tables like `medical history` and `adoption history`.
* **Integrity**: Full implementation of PKs, FKs, and Check constraints.

## Integrated Business Logic (Package)
The core of the system is a **PL/SQL Package** that encapsulates the shelter's integrated workflow. It includes:
* **Complex Data Types**: Records and collections for internal processing.
* **Procedures & Functions**: Coordinated actions for checking animal availability, verifying client eligibility, and finalizing adoption contracts in a single transaction.
* **Weighted Adoption Scoring**: Implements a decision engine that ranks adoption readiness based on a weighted formula: 
  $$Score = (Medical \cdot 0.4) + (Promotion \cdot 0.3) + (Risk \cdot 0.3)$$
* **Medical Penalty Logic**: Automatically deducts 15 points from the medical score for every non-healthy diagnosis found in the clinical history.
* **Hierarchical Data Architecture**: Manages complex records through a 4-tier structure combining Associative Arrays (indexed by CIP), records for metadata, and Nested Tables for granular intervention logs.
* **Occupancy Monitoring**: The `f_ocupare_sediu` function calculates real-time capacity and generates warnings when a branch exceeds an 80% occupancy threshold.
* **Smart Adoption Routing**: Automates notary availability checks (Branch $\rightarrow$ City level) for animals identified with high adoption potential (score > 75).
* **Recovery Workflows**: For lower-scoring animals, the system automatically suggests medical checkups and checks for upcoming promotional slots.
* **Smart Promotion**: The `f_verificare_locuri_revista` function implements a "Cool-down" logic, ensuring magazines are published at least one week apart and never exceed capacity.
* **Nested Cursors**: The `p_populare` procedure uses nested cursors to efficiently map relational data into the complex hierarchical memory structures.
