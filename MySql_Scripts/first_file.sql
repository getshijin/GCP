create database schooldb;

use schooldb;


create table students(

studentId int,
firstname varchar(25),
lastName varchar(25),
Email varchar(25),
enrollmentData date
);

###create cource
create table courses(
CourseId int,
CourseName varchar(25),
Department varchar(25),
credits int);

#insert into
INSERT INTO students (studentId, firstname, lastName, Email, enrollmentData)
VALUES
(1, 'Alice', 'Johnson', 'alice.johnson@email.com', '2023-09-01'),
(2, 'Bob', 'Smith', 'bob.smith@email.com', '2022-08-15'),
(3, 'Clara', 'Brown', 'clara.brown@email.com', '2024-01-10'),
(4, 'David', 'Miller', 'david.miller@email.com', '2023-02-05'),
(5, 'Eva', 'Garcia', 'eva.garcia@email.com', '2023-07-20'),
(6, 'Frank', 'Wilson', 'frank.wilson@email.com', '2022-09-12'),
(7, 'Grace', 'Lee', 'grace.lee@email.com', '2024-03-18'),
(8, 'Henry', 'Davis', 'henry.davis@email.com', '2023-11-25'),
(9, 'Isabella', 'Martinez', 'isabella.mar@email.com', '2024-06-30'),
(10, 'Jack', 'Anderson', 'jack.anderson@email.com', '2023-04-02');


###insert into courses

INSERT INTO courses (CourseId, CourseName, Department, credits)
VALUES
(101, 'Database Systems', 'Computer Science', 4),
(102, 'Data Structures', 'Computer Science', 3),
(103, 'Calculus I', 'Mathematics', 4),
(104, 'Linear Algebra', 'Mathematics', 3),
(105, 'Organic Chemistry', 'Chemistry', 4),
(106, 'Microeconomics', 'Economics', 3),
(107, 'Business Analytics', 'Business', 3),
(108, 'Artificial Intelligence', 'Computer Science', 4),
(109, 'Physics I', 'Physics', 4),
(110, 'Statistics', 'Mathematics', 3);


select * from students;

select * from courses;

drop database schooldb
