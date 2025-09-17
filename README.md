# Week-8-Assignment-Final-Project
Database Features:
Tables Created:
Members - Library members with personal details and membership status

Authors - Book authors with biographical information

Publishers - Publishing companies

Books - Book inventory with availability tracking

Book_Authors - Many-to-many relationship between books and authors

Loans - Book borrowing records

Fines - Overdue fine tracking

Reservations - Book reservation system

LibraryStaff - Staff management

Transactions - Audit log of all library activities

Key Features:
Data Integrity: Comprehensive constraints and foreign keys

Performance: Indexes on frequently queried columns

Automation: Triggers for maintaining data consistency

Business Logic: Stored procedures for common operations

Reporting: Views for common queries

Security: Data validation through constraints

Relationships:
One-to-Many: Publishers → Books, Members → Loans

Many-to-Many: Books ↔ Authors (via junction table)

Self-Referencing: LibraryStaff supervisor hierarchy

This database design follows normalization principles, ensures data integrity, and provides a solid foundation for a library management system with room for future expansion.
