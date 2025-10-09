-- Create the database
CREATE DATABASE IF NOT EXISTS librarydb;

-- Select the database
USE librarydb;

-- Create the authors table
CREATE TABLE authors (
  authorId INT AUTO_INCREMENT PRIMARY KEY,
  firstName VARCHAR(50) NOT NULL,
  lastName  VARCHAR(50) NOT NULL,
  email     VARCHAR(100) UNIQUE
);

INSERT INTO authors (firstName, lastName, email)
VALUES
('George', 'Orwell', 'george.orwell@email.com'),
('Jane', 'Austen', 'jane.austen@email.com'),
('Mark', 'Twain', 'mark.twain@email.com'),
('Agatha', 'Christie', 'agatha.christie@email.com');

explain select * from authors;

CREATE TABLE employees (
  emp_id INT PRIMARY KEY,          -- uniquely identifies each employee
  first_name VARCHAR(50),
  last_name VARCHAR(50),
  email VARCHAR(100)
);


CREATE TABLE students (
  student_id INT PRIMARY KEY,
  email VARCHAR(100) UNIQUE,
  phone VARCHAR(15) UNIQUE
);

drop database librarydb