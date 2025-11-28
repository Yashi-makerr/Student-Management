-- Create the database
CREATE DATABASE IF NOT EXISTS student_management;

-- Use the database
USE student_management;

-- Create the students table
CREATE TABLE IF NOT EXISTS students (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(20),
    date_of_birth DATE NOT NULL,
    address TEXT,
    department VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create the courses table
CREATE TABLE IF NOT EXISTS courses (
    id INT PRIMARY KEY AUTO_INCREMENT,
    course_code VARCHAR(20) NOT NULL UNIQUE,
    course_name VARCHAR(100) NOT NULL,
    description TEXT,
    credits INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create the marks table
CREATE TABLE IF NOT EXISTS marks (
    id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    marks_obtained DECIMAL(5,2) NOT NULL,
    max_marks DECIMAL(5,2) NOT NULL,
    exam_type VARCHAR(50) NOT NULL, -- e.g., 'Midterm', 'Final', 'Quiz', etc.
    exam_date DATE NOT NULL,
    remarks TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
);

-- Create the attendance table
CREATE TABLE IF NOT EXISTS attendance (
    id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    date DATE NOT NULL,
    status ENUM('PRESENT', 'ABSENT', 'LATE', 'EXCUSED') NOT NULL,
    remarks TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
    UNIQUE KEY unique_attendance (student_id, course_id, date)
);

-- Create a user and grant privileges
CREATE USER IF NOT EXISTS 'javauser'@'localhost' IDENTIFIED BY 'mypassword';
GRANT ALL PRIVILEGES ON student_management.* TO 'javauser'@'localhost';
FLUSH PRIVILEGES;

-- Insert sample data for students
INSERT INTO students (first_name, last_name, email, phone_number, date_of_birth, address, department) VALUES
('John', 'Doe', 'john.doe@example.com', '1234567890', '2000-01-15', '123 Main St, Anytown, USA', 'Computer Science'),
('Jane', 'Smith', 'jane.smith@example.com', '0987654321', '1999-05-22', '456 Oak Ave, Somewhere, USA', 'Electrical Engineering'),
('Robert', 'Johnson', 'robert.j@example.com', '5551234567', '2001-03-10', '789 Pine Rd, Nowhere, USA', 'Mechanical Engineering'),
('Emily', 'Williams', 'emily.w@example.com', '4445556666', '2000-11-30', '101 Elm St, Anywhere, USA', 'Computer Science'),
('Michael', 'Brown', 'michael.b@example.com', '7778889999', '1999-08-17', '202 Maple Dr, Somewhere, USA', 'Civil Engineering');

-- Insert sample data for courses
INSERT INTO courses (course_code, course_name, description, credits) VALUES
('CS101', 'Introduction to Computer Science', 'Basic concepts of computer science', 3),
('MATH201', 'Calculus I', 'Differential and integral calculus', 4),
('PHYS101', 'Physics I', 'Mechanics and thermodynamics', 4),
('ENG101', 'English Composition', 'Academic writing and composition', 3);

-- Create a view for attendance summary
CREATE VIEW attendance_summary AS
SELECT 
    s.id as student_id,
    s.first_name,
    s.last_name,
    c.id as course_id,
    c.course_code,
    c.course_name,
    COUNT(CASE WHEN a.status = 'PRESENT' THEN 1 END) as present_days,
    COUNT(a.id) as total_days,
    ROUND((COUNT(CASE WHEN a.status = 'PRESENT' THEN 1 END) / COUNT(a.id)) * 100, 2) as attendance_percentage
FROM 
    students s
CROSS JOIN 
    courses c
LEFT JOIN 
    attendance a ON s.id = a.student_id AND c.id = a.course_id
GROUP BY 
    s.id, c.id;

-- Create a view for marks summary
CREATE VIEW marks_summary AS
SELECT 
    s.id as student_id,
    s.first_name,
    s.last_name,
    c.id as course_id,
    c.course_code,
    c.course_name,
    m.exam_type,
    m.marks_obtained,
    m.max_marks,
    ROUND((m.marks_obtained / m.max_marks) * 100, 2) as percentage,
    m.exam_date
FROM 
    students s
JOIN 
    marks m ON s.id = m.student_id
JOIN 
    courses c ON m.course_id = c.id
ORDER BY 
    s.last_name, s.first_name, c.course_code, m.exam_date;
