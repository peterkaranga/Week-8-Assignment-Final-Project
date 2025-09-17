-- Library Management System Database
-- Created by: [PETER MWANGI]
-- Date: [9/17/2025]

-- Create the database
CREATE DATABASE IF NOT EXISTS LibraryManagementSystem;
USE LibraryManagementSystem;

-- Table 1: Members - Stores library member information
CREATE TABLE Members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    address VARCHAR(255),
    date_of_birth DATE NOT NULL,
    membership_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    membership_status ENUM('Active', 'Suspended', 'Expired') DEFAULT 'Active',
    CONSTRAINT chk_email_format CHECK (email LIKE '%@%.%'),
    CONSTRAINT chk_adult_member CHECK (DATEDIFF(CURRENT_DATE, date_of_birth) >= 365*16) -- Must be at least 16 years old
);

-- Table 2: Authors - Stores author information
CREATE TABLE Authors (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    birth_date DATE,
    death_date DATE,
    nationality VARCHAR(50),
    biography TEXT,
    CONSTRAINT chk_dates CHECK (death_date IS NULL OR birth_date < death_date)
);

-- Table 3: Publishers - Stores publisher information
CREATE TABLE Publishers (
    publisher_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    address VARCHAR(255),
    phone VARCHAR(20),
    email VARCHAR(100),
    website VARCHAR(100),
    CONSTRAINT chk_publisher_email CHECK (email LIKE '%@%.%')
);

-- Table 4: Books - Stores book information
CREATE TABLE Books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    isbn VARCHAR(17) UNIQUE NOT NULL,
    title VARCHAR(255) NOT NULL,
    publication_year YEAR,
    edition VARCHAR(20),
    genre VARCHAR(50) NOT NULL,
    language VARCHAR(30) DEFAULT 'English',
    page_count INT,
    publisher_id INT,
    shelf_location VARCHAR(20) NOT NULL,
    total_copies INT NOT NULL DEFAULT 1,
    available_copies INT NOT NULL DEFAULT 1,
    CONSTRAINT fk_book_publisher FOREIGN KEY (publisher_id) REFERENCES Publishers(publisher_id),
    CONSTRAINT chk_isbn_format CHECK (LENGTH(isbn) = 13 OR LENGTH(isbn) = 17),
    CONSTRAINT chk_publication_year CHECK (publication_year BETWEEN 1450 AND YEAR(CURRENT_DATE)),
    CONSTRAINT chk_copies CHECK (available_copies <= total_copies AND available_copies >= 0)
);

-- Table 5: Book_Authors - Many-to-Many relationship between Books and Authors
CREATE TABLE Book_Authors (
    book_id INT,
    author_id INT,
    PRIMARY KEY (book_id, author_id),
    CONSTRAINT fk_book_author_book FOREIGN KEY (book_id) REFERENCES Books(book_id) ON DELETE CASCADE,
    CONSTRAINT fk_book_author_author FOREIGN KEY (author_id) REFERENCES Authors(author_id) ON DELETE CASCADE
);

-- Table 6: Loans - Tracks book loans to members
CREATE TABLE Loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    loan_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    due_date DATE NOT NULL,
    return_date DATE NULL,
    status ENUM('Active', 'Returned', 'Overdue') DEFAULT 'Active',
    CONSTRAINT fk_loan_book FOREIGN KEY (book_id) REFERENCES Books(book_id),
    CONSTRAINT fk_loan_member FOREIGN KEY (member_id) REFERENCES Members(member_id),
    CONSTRAINT chk_due_date CHECK (due_date > loan_date),
    CONSTRAINT chk_return_date CHECK (return_date IS NULL OR return_date >= loan_date)
);

-- Table 7: Fines - Tracks fines for overdue books
CREATE TABLE Fines (
    fine_id INT AUTO_INCREMENT PRIMARY KEY,
    loan_id INT NOT NULL,
    amount DECIMAL(8,2) NOT NULL,
    issue_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    paid_date DATE NULL,
    status ENUM('Pending', 'Paid', 'Waived') DEFAULT 'Pending',
    CONSTRAINT fk_fine_loan FOREIGN KEY (loan_id) REFERENCES Loans(loan_id),
    CONSTRAINT chk_fine_amount CHECK (amount >= 0),
    CONSTRAINT chk_paid_date CHECK (paid_date IS NULL OR paid_date >= issue_date)
);

-- Table 8: Reservations - Tracks book reservations by members
CREATE TABLE Reservations (
    reservation_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    reservation_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Pending', 'Fulfilled', 'Cancelled') DEFAULT 'Pending',
    priority INT DEFAULT 1,
    CONSTRAINT fk_reservation_book FOREIGN KEY (book_id) REFERENCES Books(book_id),
    CONSTRAINT fk_reservation_member FOREIGN KEY (member_id) REFERENCES Members(member_id),
    CONSTRAINT unique_active_reservation UNIQUE (book_id, member_id, status)
);

-- Table 9: LibraryStaff - Stores staff information
CREATE TABLE LibraryStaff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    position VARCHAR(50) NOT NULL,
    hire_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    salary DECIMAL(10,2),
    supervisor_id INT NULL,
    CONSTRAINT fk_staff_supervisor FOREIGN KEY (supervisor_id) REFERENCES LibraryStaff(staff_id),
    CONSTRAINT chk_staff_email CHECK (email LIKE '%@%.%'),
    CONSTRAINT chk_salary CHECK (salary >= 0)
);

-- Table 10: Transactions - Logs all library transactions
CREATE TABLE Transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL,
    staff_id INT NOT NULL,
    transaction_type ENUM('Loan', 'Return', 'Reservation', 'Fine Payment', 'Membership') NOT NULL,
    transaction_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    description TEXT,
    CONSTRAINT fk_transaction_member FOREIGN KEY (member_id) REFERENCES Members(member_id),
    CONSTRAINT fk_transaction_staff FOREIGN KEY (staff_id) REFERENCES LibraryStaff(staff_id)
);

-- Indexes for better performance
CREATE INDEX idx_books_title ON Books(title);
CREATE INDEX idx_books_genre ON Books(genre);
CREATE INDEX idx_members_name ON Members(last_name, first_name);
CREATE INDEX idx_loans_dates ON Loans(loan_date, due_date, return_date);
CREATE INDEX idx_loans_status ON Loans(status);
CREATE INDEX idx_fines_status ON Fines(status);
CREATE INDEX idx_reservations_status ON Reservations(status);

-- Insert sample data
INSERT INTO Members (first_name, last_name, email, phone, address, date_of_birth, membership_date) VALUES
('John', 'Smith', 'john.smith@email.com', '555-0101', '123 Main St, Anytown', '1985-03-15', '2023-01-15'),
('Sarah', 'Johnson', 'sarah.j@email.com', '555-0102', '456 Oak Ave, Somewhere', '1990-07-22', '2023-02-20'),
('Michael', 'Brown', 'm.brown@email.com', '555-0103', '789 Pine Rd, Nowhere', '1988-12-05', '2023-03-10');

INSERT INTO Publishers (name, address, phone, email, website) VALUES
('Penguin Random House', '1745 Broadway, New York, NY', '212-782-9000', 'info@penguinrandomhouse.com', 'www.penguinrandomhouse.com'),
('HarperCollins', '195 Broadway, New York, NY', '212-207-7000', 'contact@harpercollins.com', 'www.harpercollins.com'),
('Macmillan', '120 Broadway, New York, NY', '646-307-5151', 'support@macmillan.com', 'www.macmillan.com');

INSERT INTO Authors (first_name, last_name, birth_date, death_date, nationality, biography) VALUES
('George', 'Orwell', '1903-06-25', '1950-01-21', 'British', 'English novelist, essayist, journalist and critic.'),
('J.K.', 'Rowling', '1965-07-31', NULL, 'British', 'Author of the Harry Potter series.'),
('Stephen', 'King', '1947-09-21', NULL, 'American', 'Author of horror, supernatural fiction, suspense, and fantasy novels.');

INSERT INTO Books (isbn, title, publication_year, edition, genre, language, page_count, publisher_id, shelf_location, total_copies, available_copies) VALUES
('978-0451524935', '1984', 1949, '1st', 'Dystopian Fiction', 'English', 328, 1, 'Fiction-A', 5, 5),
('978-0439064866', 'Harry Potter and the Chamber of Secrets', 1998, '1st', 'Fantasy', 'English', 341, 2, 'Fantasy-B', 3, 3),
('978-1501142970', 'The Shining', 1977, 'Revised', 'Horror', 'English', 447, 3, 'Horror-C', 4, 4);

INSERT INTO Book_Authors (book_id, author_id) VALUES
(1, 1), -- 1984 by George Orwell
(2, 2), -- Harry Potter by J.K. Rowling
(3, 3); -- The Shining by Stephen King

INSERT INTO LibraryStaff (first_name, last_name, email, phone, position, hire_date, salary) VALUES
('Emily', 'Davis', 'emily.davis@library.org', '555-0201', 'Head Librarian', '2020-05-15', 65000.00),
('David', 'Wilson', 'david.wilson@library.org', '555-0202', 'Assistant Librarian', '2021-08-10', 48000.00);

-- Create views for common queries
CREATE VIEW ActiveLoans AS
SELECT l.loan_id, m.first_name, m.last_name, b.title, l.loan_date, l.due_date
FROM Loans l
JOIN Members m ON l.member_id = m.member_id
JOIN Books b ON l.book_id = b.book_id
WHERE l.status = 'Active';

CREATE VIEW AvailableBooks AS
SELECT b.book_id, b.title, b.author, b.genre, b.available_copies
FROM Books b
WHERE b.available_copies > 0;

CREATE VIEW OverdueBooks AS
SELECT l.loan_id, m.first_name, m.last_name, b.title, l.due_date, DATEDIFF(CURRENT_DATE, l.due_date) AS days_overdue
FROM Loans l
JOIN Members m ON l.member_id = m.member_id
JOIN Books b ON l.book_id = b.book_id
WHERE l.status = 'Active' AND l.due_date < CURRENT_DATE;

-- Create stored procedures for common operations
DELIMITER //

CREATE PROCEDURE BorrowBook(IN p_book_id INT, IN p_member_id INT)
BEGIN
    DECLARE available_count INT;
    DECLARE active_loans INT;
    
    -- Check if book is available
    SELECT available_copies INTO available_count FROM Books WHERE book_id = p_book_id;
    
    -- Check if member has too many active loans (max 5)
    SELECT COUNT(*) INTO active_loans FROM Loans WHERE member_id = p_member_id AND status = 'Active';
    
    IF available_count > 0 AND active_loans < 5 THEN
        -- Create loan
        INSERT INTO Loans (book_id, member_id, due_date)
        VALUES (p_book_id, p_member_id, DATE_ADD(CURRENT_DATE, INTERVAL 14 DAY));
        
        -- Update available copies
        UPDATE Books SET available_copies = available_copies - 1 WHERE book_id = p_book_id;
        
        -- Log transaction
        INSERT INTO Transactions (member_id, staff_id, transaction_type, description)
        VALUES (p_member_id, 1, 'Loan', CONCAT('Borrowed book ID: ', p_book_id));
        
        SELECT 'SUCCESS' AS result;
    ELSE
        SELECT 'FAILED' AS result;
    END IF;
END //

CREATE PROCEDURE ReturnBook(IN p_loan_id INT)
BEGIN
    DECLARE v_book_id INT;
    DECLARE v_due_date DATE;
    
    -- Get book ID and due date
    SELECT book_id, due_date INTO v_book_id, v_due_date FROM Loans WHERE loan_id = p_loan_id;
    
    -- Update loan status
    UPDATE Loans SET return_date = CURRENT_DATE, status = 'Returned' WHERE loan_id = p_loan_id;
    
    -- Update available copies
    UPDATE Books SET available_copies = available_copies + 1 WHERE book_id = v_book_id;
    
    -- Check for overdue and create fine if applicable
    IF v_due_date < CURRENT_DATE THEN
        INSERT INTO Fines (loan_id, amount)
        VALUES (p_loan_id, DATEDIFF(CURRENT_DATE, v_due_date) * 0.50); -- $0.50 per day
    END IF;
    
    SELECT 'SUCCESS' AS result;
END //

DELIMITER ;

-- Create triggers for automation
DELIMITER //

CREATE TRIGGER after_loan_insert
AFTER INSERT ON Loans
FOR EACH ROW
BEGIN
    -- Update book status when loan is created
    UPDATE Books SET available_copies = available_copies - 1 WHERE book_id = NEW.book_id;
END //

CREATE TRIGGER after_loan_update
AFTER UPDATE ON Loans
FOR EACH ROW
BEGIN
    IF NEW.status = 'Returned' AND OLD.status != 'Returned' THEN
        -- Update book status when loan is returned
        UPDATE Books SET available_copies = available_copies + 1 WHERE book_id = NEW.book_id;
    END IF;
END //

DELIMITER ;