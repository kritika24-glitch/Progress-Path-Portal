const express = require("express");
const session = require('express-session');
const mysql = require("mysql2");
const nodemailer = require('nodemailer');
const bodyParser = require("body-parser");
const cors = require("cors");
const multer = require("multer");
const xlsx = require("xlsx");
const fs = require('fs');
const path = require("path");
const bcrypt = require("bcrypt");
const {LocalStorage} = require("node-localstorage")

const app = express();
const PORT = 3000;  

// Middleware
app.use(cors());
app.use((req, res, next) => {
    res.set('Cache-Control', 'no-store');
    next();
});
app.use(express.json());  
app.use(bodyParser.json());
app.use(express.urlencoded({ extended: true }));
app.use("/uploads/", express.static("uploads")); // Serving uploaded files
app.use('/uploads/StudentAssignments', express.static(path.join(__dirname, 'uploads/StudentAssignments')));

app.set("view engine", "ejs");
app.use(express.static("public"));
app.use(session({
    secret: 'progress-path-secret', 
    resave: false,
    saveUninitialized: true,
    cookie: { secure: false } // true if using https
}));
const localStorage = new LocalStorage('./Creds');
// Database Connection
const pool = mysql.createPool({
    host: "localhost",
    user: "root",
    password: "kri@74ayu42_chi",
    database: "teacherstudentportal",
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

pool.getConnection((err, connection) => {
    if (err) {
        console.error("❌ Database connection failed:", err.stack);
        return;
    }
    console.log("✅ Connected to the database.");
    connection.release();
});

// POST route for login
app.post('/login', (req, res) => {
    const { email, password, userType } = req.body;

    if (!email || !password || !userType) {
        return res.status(400).json({ message: 'Please fill out all fields.' });
    }

    let query;
    if (userType === 'student') {
        query = `SELECT * FROM Students WHERE email = ?`;
    } else if (userType === 'teacher') {
        query = `SELECT * FROM Teachers WHERE email = ?`;
    } else if (userType === 'admin') {
        query = `SELECT * FROM admin WHERE email = ?`;
    } else {
        return res.status(400).json({ message: 'Invalid user type.' });
    }

    pool.query(query, [email], (err, results) => {
        if (err) {
            console.error('Database query failed:', err);
            return res.status(500).json({ message: 'Something went wrong. Please try again.' });
        }

        console.log("Query Results:", results); // Debugging

        if (results.length === 0) {
            return res.status(401).json({ message: 'Invalid email or password.' });
        }

        // Bypassing bcrypt for testing (Direct password check)
        if (password !== results[0].password) {
            return res.status(401).json({ message: 'Invalid email or password.' });
        }
        const user = results[0];
      localStorage.setItem('email', user.email);
      

        res.status(200).json({  message: 'Login successful.',
            user: {
                email: user.email,
                userType: userType,}
             });
    });
});

// Express + Nodemailer Example
app.post('/forget-password', (req, res) => { 
    const { userType, email } = req.body;

    if (!userType || !email) return res.send("All fields are required.");

    let table = "";
    const type = userType.toLowerCase();

    if (type === "student") table = "Students";
    else if (type === "teacher") table = "Teachers";
    else if (type === "admin") table = "Admin";
    else return res.send("Invalid user type.");

    const query = `SELECT password FROM ${table} WHERE email = ?`;
    pool.query(query, [email], (err, result) => {
        if (err) return res.send("Database Error: " + err.message);
        if (result.length === 0) return res.send("User not found.");

        const password = result[0].password;

        // Nodemailer Setup
        const transporter = nodemailer.createTransport({
            service: 'gmail',
            auth: {
                user: 'ayushipramodsingh@gmail.com', // <--- yaha apna email
                pass: 'ogzg ghuj auxq folz'     // <--- yaha apna app password
            }
        });

        const mailOptions = {
            from: 'Progress Path Portal <ayushipramodsingh@gmail.com>',
            to: email,
            subject: 'Progress Path Portal | Password Recovery',
            html: `
                <div style="font-family: Arial; padding: 20px; border:1px solid #ddd; border-radius:10px;">
                    <h2 style="color:#4CAF50;">Password Recovery</h2>
                    <p>Hello,</p>
                    <p>You requested your password for <b>${type}</b> account.</p>
                    <p><strong>Password:</strong> <span style="color:#f44336;">${password}</span></p>
                    <p>Please keep it safe and do not share it with anyone.</p>
                    <p>Regards,<br>Progress Path Portal</p>
                </div>
            `
        };

        transporter.sendMail(mailOptions, function(error, info){
            if (error) {
                console.log(error);
                res.send("Failed to send mail. Please try again.");
            } else {
                res.send("Password has been sent to your registered email.");
            }
        });
    });
});

// Fetch student details, credit points, performance, and activities
app.get('/student', (req, res) => {
   
   const email = req.params.email;
   
  const storedEmail = localStorage.getItem('email');
    // Fetch student details
    const studentQuery = `SELECT student_id, name, section, branch, email, roll_number, current_semester FROM Students WHERE email = ?`;
    
    pool.query(studentQuery, [storedEmail] , (err, studentResults) => {
        if (err) {
            console.error("Database error (Student Details):", err);
            return res.status(500).json({ error: "Database Server Error" });
        }
        
        if (studentResults.length === 0) {
            return res.status(404).json({ error: "Student not found" });
        }
        
        const student = studentResults[0];
        const { student_id, current_semester } = student;
        
        // Fetch credit points
        const creditQuery = `SELECT SUM(credit_point) AS total_credits FROM Subjects WHERE semester = ?`;
        
        pool.query(creditQuery, [current_semester], (err, creditResults) => {
            if (err) {
                console.error("Database error (Credit Points):", err);
                return res.status(500).json({ error: "credit point Server Error" });
            }
            
            const creditPoints = creditResults[0].total_credits || 0;
            
            // Fetch performance data
            const marksQuery = `SELECT AVG(assignment_1_marks) AS assignment_1, 
                                      AVG(periodical_1_marks) AS periodical_1, 
                                      AVG(assignment_2_marks) AS assignment_2, 
                                      AVG(periodical_2_marks) AS periodical_2 
                                FROM Marks 
                                WHERE student_id = ? AND semester = ?`;
            
            pool.query(marksQuery, [student_id, current_semester], (err, marksResults) => {
                if (err) {
                    console.error("Database error (Performance Data):", err);
                    return res.status(500).json({ error: "peerformance Server Error" });
                }
                
                const performanceData = marksResults[0] || {
                    assignment_1: 0,
                    periodical_1: 0,
                    assignment_2: 0,
                    periodical_2: 0
                };
                
                // Fetch current courses count
                const courseQuery = `SELECT COUNT(*) AS course_count FROM Subjects WHERE semester = ?`;
                
                pool.query(courseQuery, [current_semester], (err, courseResults) => {
                    if (err) {
                        console.error("Database error (Current Courses):", err);
                        return res.status(500).json({ error: "current course  Server Error" });
                    }
                    
                    const courseCount = courseResults[0].course_count || 0;
                    
                    // Fetch total assignments count
                    const assignmentQuery = `SELECT COUNT(*) AS total_assignments FROM Assignments 
                                            WHERE subject_id IN (SELECT subject_id FROM Marks WHERE student_id = ?)`;
                    
                    pool.query(assignmentQuery, [student_id], (err, assignmentResults) => {
                        if (err) {
                            console.error("Database error (Total Assignments):", err);
                            return res.status(500).json({ error: "total assignment Server Error" });
                        }
                        
                        const totalAssignments = assignmentResults[0].total_assignments || 0;
                        
                        // Fetch recent activities (Assignments + Study Material)
                        const activityQuery = `
                            (SELECT A.title, A.uploaded_date, 
        (SELECT name FROM Teachers WHERE teacher_id = A.uploaded_by_teacher) AS uploaded_by, 
        'Assignment' AS type, A.file_path 
 FROM Assignments A
 WHERE subject_id IN (
     SELECT subject_id FROM Teacher_Subject_Section 
     WHERE section_name = ? AND semester = ?
 ))
UNION
(SELECT S.title, S.uploaded_date, 
        (SELECT name FROM Teachers WHERE teacher_id = S.uploaded_by_teacher) AS uploaded_by, 
        'Study Material' AS type, S.file_path 
 FROM Study_Material S
 WHERE subject_id IN (
     SELECT subject_id FROM Teacher_Subject_Section 
     WHERE section_name = ? AND semester = ?
 ))
ORDER BY uploaded_date DESC LIMIT 6;
                        `;
                        
                        pool.query(activityQuery, [student.section, student.current_semester, student.section, student.current_semester], (err, activityResults) => {
                            if (err) {
                                console.error("Database error (Recent Activities):", err);
                                return res.status(500).json({ error: "recent activityes  Server Error" });
                            }
                            
                            const recentActivities = activityResults.map(a => ({
                                title: a.title,
                                uploaded_date: a.uploaded_date,
                                uploaded_by: a.uploaded_by,
                                type: a.type,
                                file_path: a.file_path
                            }));
                            
                            // Final Response
                            res.json({
                                ...student,
                                credit_points: creditPoints,
                                graph_data: performanceData,
                                courses: courseCount,
                                recent_activities: recentActivities,
                                total_assignments: totalAssignments // Include total assignments
                            });
                        });
                    });
                });
            });
        });
    });
});
//dkjfud
app.get('/student/notifications', (req, res) => {
    const email = req.params.email;
    const storedEmail = localStorage.getItem('email');
    // Fetch student details
    const studentQuery = `SELECT student_id FROM Students WHERE email = ?`;
    
    pool.query(studentQuery, [storedEmail] , (err, studentResults) => {
        if (err) {
            console.error("Database error (Student Details):", err);
            return res.status(500).json({ error: "Database Server Error" });
        }
        
        if (studentResults.length === 0) {
            return res.status(404).json({ error: "Student not found" });
        }
        
        const student = studentResults[0];
        const { student_id} = student;
  
    const sql = `
        SELECT message, timestamp FROM notifications WHERE user_id = ?
        ORDER BY timestamp DESC
    `;
    pool.query(sql, [student_id], (err, result) => {
        if (err) return res.json({ error: "Failed to fetch notifications" });
        res.json(result);
    });
});
});
//fetch teacher detail, graph and basic infromation 
app.get('/teacher', (req, res) => {
    const email = req.params.email;
    const storedEmail = localStorage.getItem('email');


    // Fetch teacher details
    const teacherQuery = `SELECT teacher_id, name, email FROM Teachers WHERE email = ?`;

    pool.query(teacherQuery, [storedEmail], (err, teacherResults) => {
        if (err) {
            console.error("Database error (Teacher Details):", err);
            return res.status(500).json({ error: "Database Server Error" });
        }

        if (teacherResults.length === 0) {
            return res.status(404).json({ error: "Teacher not found" });
        }

        const teacher = teacherResults[0];
        const { teacher_id } = teacher;

        // Fetch total students
        const totalStudentsQuery = `SELECT COUNT(DISTINCT s.student_id) AS total_students
                                    FROM Students s
                                    JOIN Teacher_Subject_Section ts 
                                    ON s.section = ts.section_name 
                                    AND s.current_semester = ts.semester
                                    WHERE ts.teacher_id = ?`;

        pool.query(totalStudentsQuery, [teacher_id], (err, totalStudentsResults) => {
            if (err) {
                console.error("Database error (Total Students):", err);
                return res.status(500).json({ error: "Total Students Server Error" });
            }

            const totalStudents = totalStudentsResults[0].total_students || 0;

            // Fetch active courses
            const activeCoursesQuery = `SELECT COUNT(DISTINCT ts.subject_id) AS active_courses 
                                        FROM Teacher_Subject_Section ts 
                                        WHERE ts.teacher_id = ?`;

            pool.query(activeCoursesQuery, [teacher_id], (err, activeCoursesResults) => {
                if (err) {
                    console.error("Database error (Active Courses):", err);
                    return res.status(500).json({ error: "Active Courses Server Error" });
                }

                const activeCourses = activeCoursesResults[0].active_courses || 0;

                // Fetch pending assignments
                const pendingAssignmentsQuery = `SELECT COUNT(*) AS pending_assignments 
                                                 FROM Assignments 
                                                 WHERE uploaded_by_teacher = ? 
                                                 AND due_date > NOW()`;

                pool.query(pendingAssignmentsQuery, [teacher_id], (err, pendingAssignmentsResults) => {
                    if (err) {
                        console.error("Database error (Pending Assignments):", err);
                        return res.status(500).json({ error: "Pending Assignments Server Error" });
                    }

                    const pendingAssignments = pendingAssignmentsResults[0].pending_assignments || 0;

                    // Fetch recent activities (study materials & assignments)
                    const activitiesQuery = `
                      (
        SELECT 'Study Material' AS type, title AS name, file_path, uploaded_date AS date FROM Study_material WHERE uploaded_by_teacher = ? ORDER BY uploaded_date DESC LIMIT 5 ) UNION ALL ( SELECT 'Assignment' AS type, title AS name, file_path, uploaded_date AS date FROM Assignments WHERE uploaded_by_teacher = ? ORDER BY uploaded_date DESC  LIMIT 5
    ) ORDER BY date DESC LIMIT 5 
                    `;

                    pool.query(activitiesQuery, [teacher_id, teacher_id], (err, activitiesResults) => {
                        if (err) {
                            console.error("Database error (Recent Activities):", err);
                            return res.status(500).json({ error: "Recent Activities Server Error" });
                        }

                        // Convert MySQL date output to 'YYYY-MM-DD'
                        const activities = activitiesResults.map(activity => ({
                            type: activity.type,
                            name: activity.name,
                            date: activity.date.toISOString().split('T')[0],
                            file_path: activity.file_path // ✅ Include file path
                        }));

                        // Fetch sections & semesters for dropdown
                        const sectionQuery = `
                            SELECT DISTINCT section_name, semester 
                            FROM Teacher_Subject_Section 
                            WHERE teacher_id = ?
                            ORDER BY semester, section_name
                        `;

                        pool.query(sectionQuery, [teacher_id], (err, sectionResults) => {
                            if (err) {
                                console.error("Database error (Fetching Sections & Semesters):", err);
                                return res.status(500).json({ error: "Dropdown Fetching Error" });
                            }

                            // Fetch class performance data for all sections at once
                            const classPerformanceQuery = `
                              SELECT  
    ts.section_name AS section,  
    ts.semester AS semester,  
    COALESCE(AVG(m.periodical_1_marks), 0) AS periodical1,  
    COALESCE(AVG(m.assignment_1_marks), 0) AS assignment1,  
    COALESCE(AVG(m.periodical_2_marks), 0) AS periodical2,  
    COALESCE(AVG(m.assignment_2_marks), 0) AS assignment2  
FROM Teacher_Subject_Section ts  
LEFT JOIN Students s  
    ON s.section = ts.section_name  
    AND s.current_semester = ts.semester  
LEFT JOIN Marks m  
    ON m.student_id = s.student_id  
WHERE ts.teacher_id = ?  
GROUP BY ts.section_name, ts.semester;

                            `;

                            pool.query(classPerformanceQuery, [teacher_id], (err, classPerformanceResults) => {
                                if (err) {
                                    console.error("Database error (Class Performance):", err);
                                    return res.status(500).json({ error: "Class Performance Server Error" });
                                }

                                // Format class performance data for easier access
                                const classPerformance = {};
                                classPerformanceResults.forEach(row => {
                                    const key = `${row.section}-${row.semester}`;
                                    classPerformance[key] = {
                                        periodical1: row.periodical1 || 0,
                                        assignment1: row.assignment1 || 0,
                                        periodical2: row.periodical2 || 0,
                                        assignment2: row.assignment2 || 0
                                    };
                                });

                                // Final Response
                                res.json({
                                    ...teacher,
                                    total_students: totalStudents,
                                    active_courses: activeCourses,
                                    pending_assignments: pendingAssignments,
                                    activities,
                                    sections: sectionResults,
                                    class_performance: classPerformance
                                });
                            });
                        });
                    });
                });
            });
        });
    });
});

app.post('/student/change-password', (req, res) => {
    const { email, currentPassword, newPassword } = req.body;

    const sql = "SELECT password FROM Students WHERE email = ?";
    pool.query(sql, [email], (err, result) => {
        if(err) return res.json({ error: "Database Error" });
        if(result.length === 0) return res.json({ error: "Email not found" });

        const storedPassword = result[0].password;

        if (storedPassword !== currentPassword) {
            return res.json({ error: "Current Password is incorrect" });
        }

        const updateSQL = "UPDATE Students SET password = ? WHERE email = ?";
        pool.query(updateSQL, [newPassword, email], (err) => {
            if(err) return res.json({ error: "Failed to update password" });
            return res.json({ success: true });
        });
    });
});

app.post('/teacher/change-password', (req, res) => {
    const { email, currentPassword, newPassword } = req.body;
    console.log("Received Email:", email); // Debugging ke liye

    const sql = "SELECT password FROM Teachers WHERE email = ?";
    pool.query(sql, [email], (err, result) => {
        if(err) return res.json({ error: "Database Error" });
        if(result.length === 0) return res.json({ error: "Email not found" });

        const storedPassword = result[0].password;

        if (storedPassword !== currentPassword) {
            return res.json({ error: "Current Password is incorrect" });
        }

        const updateSQL = "UPDATE Teachers SET password = ? WHERE email = ?";
        pool.query(updateSQL, [newPassword, email], (err) => {
            if(err) return res.json({ error: "Failed to update password" });
            return res.json({ success: true });
        });
    });
});

// Route for fetching the student's academic records
app.get('/acad', async (req, res) => {
    const email = req.params.email;
    const storedEmail = localStorage.getItem('email');
    // Fetch student details
    const studentQuery = `SELECT student_id, name, section, branch, email, roll_number, current_semester FROM Students WHERE email = ?`;
    
    pool.query(studentQuery, [storedEmail] , (err, studentResults) => {
        if (err) {
            console.error("Database error (Student Details):", err);
            return res.status(500).json({ error: "Database Server Error" });
        }
        
        if (studentResults.length === 0) {
            return res.status(404).json({ error: "Student not found" });
        }
        
        const student = studentResults[0];
        const { student_id, current_semester } = student;
        
         // Fetch credit points
         const creditQuery = `SELECT SUM(credit_point) AS total_credits FROM Subjects WHERE semester = ?`;
        
         pool.query(creditQuery, [current_semester], (err, creditResults) => {
             if (err) {
                 console.error("Database error (Credit Points):", err);
                 return res.status(500).json({ error: "credit point Server Error" });
             }
             const creditPoints = creditResults[0].total_credits || 0;

    // Fetch TOTAL NUMBER OC COURSES  (sum of credits for all subjects student is enrolled in)
    const courseQuery = `SELECT COUNT(*) AS course_count FROM Subjects WHERE semester = ?`;
                
                pool.query(courseQuery, [current_semester], (err, courseResults) => {
                    if (err) {
                        console.error("Database error (Current Courses):", err);
                        return res.status(500).json({ error: "current course  Server Error" });
                    }
                    
                    const courseCount = courseResults[0].course_count || 0;

      // Fetch courses the student is currently enrolled in
      pool.query(`
        SELECT 
    s.subject_id, s.name AS subject_name,  s.credit_point, t.name AS teacher_name FROM Subjects s JOIN Teacher_Subject_Section tss ON s.subject_id = tss.subject_id JOIN Students st ON st.section = tss.section_name AND st.current_semester = s.semester JOIN Teachers t ON t.teacher_id = tss.teacher_id WHERE st.student_id = ?`,
         [student.student_id], (err, coursesResult) => {
        if (err) return res.status(500).json({ error: "Server error fetching courses" });

        const courses = coursesResult;

        // Fetch marks for the enrolled subjects
        pool.query(`
         SELECT 
    s.subject_id, COALESCE(m.assignment_1_marks, 0) AS assignment_1, COALESCE(m.periodical_1_marks, 0) AS periodical_1, COALESCE(m.assignment_2_marks, 0) AS assignment_2, COALESCE(m.periodical_2_marks, 0) AS periodical_2 FROM Subjects s LEFT JOIN Marks m ON s.subject_id = m.subject_id AND m.student_id = ?  JOIN Students st ON st.current_semester = s.semester WHERE st.student_id = ? `, [student.student_id,student.student_id], (err, marksResult) => {
          if (err) return res.status(500).json({ error: "Server error fetching marks" });

          const marks = marksResult;

          // Render the data dynamically in the academic records page

          res.json({
            student,
             credit_points: creditPoints,
            courses,
            marks,
            courseCount
           });
        });
        });
      });
    });
  });
});

// Route to fetch student data and study materials/assignments
app.get('/studentstudy', (req, res) => {
    // Get the student’s email from local storage (or from req.params, req.session, etc.)
    const email = req.params.email;
    const storedEmail = localStorage.getItem('email');
   
    // 1. Fetch student details by email.
    const studentQuery = `
        SELECT student_id, name, section, branch, email, roll_number,course, current_semester
        FROM Students
        WHERE email = ?
    `;
   
    pool.query(studentQuery, [storedEmail], (err, studentResults) => {
        if (err) {
            console.error("Database error (Student Details):", err);
            return res.status(500).json({ error: "Database Server Error" });
        }
       
        if (studentResults.length === 0) {
            return res.status(404).json({ error: "Student not found" });
        }
       
        const student = studentResults[0];
        const { section, current_semester } = student;
       
        // 2. Fetch 3 most recent study materials for the student’s section and semester.
        // Here we join Study_Material with Subjects to use the semester filter.
        const studyMaterialsQuery = `
        SELECT SM.title, SM.file_path, SM.uploaded_date, 
               SM.uploaded_by_teacher, T.name AS teacher_name, 
               S.subject_id, S.name AS subject_name  
        FROM Study_Material SM 
        JOIN Subjects S ON SM.subject_id = S.subject_id 
        JOIN Teachers T ON SM.uploaded_by_teacher = T.teacher_id 
        JOIN Teacher_Subject_Section TSS ON SM.subject_id = TSS.subject_id 
        WHERE SM.section_name = ? 
          AND TSS.semester = ?
          AND TSS.section_name = ? 
        ORDER BY SM.uploaded_date DESC 
        LIMIT 2;
    `;

    pool.query(studyMaterialsQuery, [section, current_semester, section], (err, studyMaterialsResults) => {
        if (err) {
            console.error("Database error (Study Materials):", err);
            return res.status(500).json({ error: "Study Material Server Error" });
        }
         // 2. Fetch 3 most recent study materials for the student’s section and semester.
        // Here we join Study_Material with Subjects to use the semester filter.
        const allstudyMaterialsQuery = `
        SELECT SM.title, SM.file_path, SM.uploaded_date, 
               SM.uploaded_by_teacher, T.name AS teacher_name, 
               S.subject_id, S.name AS subject_name  
        FROM Study_Material SM 
        JOIN Subjects S ON SM.subject_id = S.subject_id 
        JOIN Teachers T ON SM.uploaded_by_teacher = T.teacher_id 
        JOIN Teacher_Subject_Section TSS ON SM.subject_id = TSS.subject_id 
        WHERE SM.section_name = ? 
          AND TSS.semester = ?
          AND TSS.section_name = ? 
        ORDER BY SM.uploaded_date DESC ;
    `;

    pool.query(allstudyMaterialsQuery, [section, current_semester, section], (err, allstudyMaterialsResults) => {
        if (err) {
            console.error("Database error (Study Materials):", err);
            return res.status(500).json({ error: "Study Material Server Error" });
        }


        // 3. Fetch Assignments (Only for Student's Subjects)
        const assignmentsQuery = `
            SELECT A.title, A.file_path, A.uploaded_date, A.due_date, A.assignment_id,
                   A.uploaded_by_teacher,T.teacher_id, T.name AS teacher_name, 
                   S.subject_id, S.name AS subject_name  
            FROM Assignments A 
            JOIN Subjects S ON A.subject_id = S.subject_id 
            JOIN Teachers T ON A.uploaded_by_teacher = T.teacher_id 
            JOIN Teacher_Subject_Section TSS ON A.subject_id = TSS.subject_id 
            WHERE A.section_name = ? 
              AND TSS.semester = ?
              AND TSS.section_name = ? 
            ORDER BY A.uploaded_date DESC 
            LIMIT 2;
        `;

        pool.query(assignmentsQuery, [section, current_semester, section], (err, assignmentsResults) => {
            if (err) {
                console.error("Database error (Assignments):", err);
                return res.status(500).json({ error: "Assignments Server Error" });
            }
         // 3. Fetch Assignments (Only for Student's Subjects)
         const  allassignmentsQuery = `
         SELECT A.title, A.file_path, A.uploaded_date, A.due_date, A.assignment_id,
                A.uploaded_by_teacher,T.teacher_id, T.name AS teacher_name, 
                S.subject_id, S.name AS subject_name  
         FROM Assignments A 
         JOIN Subjects S ON A.subject_id = S.subject_id 
         JOIN Teachers T ON A.uploaded_by_teacher = T.teacher_id 
         JOIN Teacher_Subject_Section TSS ON A.subject_id = TSS.subject_id 
         WHERE A.section_name = ? 
           AND TSS.semester = ?
           AND TSS.section_name = ? 
         ORDER BY A.uploaded_date DESC ;
     `;

     pool.query(allassignmentsQuery, [section, current_semester, section], (err, allassignmentsResults) => {
         if (err) {
             console.error("Database error (Assignments):", err);
             return res.status(500).json({ error: "Assignments Server Error" });
         }
                  
                       
                        // Finally, render the page with the fetched data.
                        res.json({
                            student: student,
                            recentStudyMaterials: studyMaterialsResults,
                            allrecentStudyMaterials: allstudyMaterialsResults,
                            recentAssignments: assignmentsResults,
                            allrecentAssignments: allassignmentsResults
                        });
                    });
                });
            }); 
        });
    });
 });

 //upload assignments

 const StudentAssignmentStorage = multer.diskStorage({
    destination: function(req, file, cb) {
        cb(null, "uploads/StudentAssignment");  // ✅ Folder set
    },
    filename: function (req, file, cb) {
        cb(null, Date.now() + "_" + file.originalname);
    }
});
const studentupload = multer({ storage: StudentAssignmentStorage });

// Student Assignment Upload API
app.post("/uploadStudentAssignment", studentupload.single("file"), (req, res) => {
    const {student_id, subject_id, teacher_id, assignment_id, Semester, section, course } = req.body;
    const file = req.file;

  
    if (!file) {
        return res.status(400).json({ message: "❌ File not received!" });
    }

  
  
    const filePath = `uploads/StudentAssignment/${file.filename}`;
  
    const insertQuery = `
      INSERT INTO student_assignments 
      (student_id, subject_id, teacher_id, assignment_id, semester, section,  course, file_path, submission_date) 
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW())
    `;
  
    pool.query(insertQuery, [student_id, subject_id, teacher_id, assignment_id, Semester, section, course, filePath], (err, result) => {
      if (err) {
        console.error("❌ Error uploading student assignment:", err);
        return res.status(500).json({ message: "Error saving assignment" });
      }
  
      console.log("✅ Student assignment uploaded");
      res.json({ message: "✅ Assignment uploaded successfully!" });
    });
  });
// API to fetch teacher's study materials & assignments
app.get('/teacherstudy', (req, res) => {
    const storedEmail = localStorage.getItem('email');

    // 1️⃣ Fetch teacher details
    const teacherQuery = `SELECT teacher_id, name, email FROM Teachers WHERE email = ?`;

    pool.query(teacherQuery, [storedEmail], (err, teacherResults) => {
        if (err) {
            console.error("Database error (Teacher Details):", err);
            return res.status(500).json({ error: "Database Server Error" });
        }

        if (teacherResults.length === 0) {
            return res.status(404).json({ error: "Teacher not found" });
        }

        const teacher = teacherResults[0];

        // 2️⃣ Fetch recent 3 study materials uploaded by the teacher
        const studyMaterialsQuery = `
        SELECT 
            SM.title, SM.file_path, SM.uploaded_date, SM.uploaded_by_teacher, 
            SM.section_name, TSS.semester, S.name AS subject_name, T.name AS teacher_name
        FROM Study_Material SM
        JOIN Subjects S ON SM.subject_id = S.subject_id
        JOIN Teachers T ON SM.uploaded_by_teacher = T.teacher_id
        JOIN Teacher_Subject_Section TSS ON SM.section_name = TSS.section_name AND SM.subject_id = TSS.subject_id
        WHERE SM.uploaded_by_teacher = ? 
        ORDER BY SM.uploaded_date DESC 
        LIMIT 2;
           
        `;

        pool.query(studyMaterialsQuery, [teacher.teacher_id], (err, studyMaterialsResults) => {
            if (err) {
                console.error("Database error (Study Materials):", err);
                return res.status(500).json({ error: "Study Material Server Error" });
            }
            // 2️⃣ Fetch recent 3 study materials uploaded by the teacher
        const allstudyMaterialsQuery = `
        SELECT 
            SM.title, SM.file_path, SM.uploaded_date, SM.uploaded_by_teacher, 
            SM.section_name, TSS.semester, S.name AS subject_name, T.name AS teacher_name
        FROM Study_Material SM
        JOIN Subjects S ON SM.subject_id = S.subject_id
        JOIN Teachers T ON SM.uploaded_by_teacher = T.teacher_id
        JOIN Teacher_Subject_Section TSS ON SM.section_name = TSS.section_name AND SM.subject_id = TSS.subject_id
        WHERE SM.uploaded_by_teacher = ? 
        ORDER BY SM.uploaded_date DESC ;
           
        `;

        pool.query(allstudyMaterialsQuery, [teacher.teacher_id], (err, allstudyMaterialsResults) => {
            if (err) {
                console.error("Database error (Study Materials):", err);
                return res.status(500).json({ error: "Study Material Server Error" });
            }


            // 3️⃣ Fetch recent 2 assignments uploaded by the teacher
            const assignmentsQuery = `
                SELECT 
            A.title, A.file_path,S.subject_id,T.teacher_id, A.uploaded_date, A.uploaded_by_teacher, A.assignment_id, 
            A.section_name, TSS.semester, S.name AS subject_name, T.name AS teacher_name
        FROM Assignments A
        JOIN Subjects S ON A.subject_id = S.subject_id
        JOIN Teachers T ON A.uploaded_by_teacher = T.teacher_id
        JOIN Teacher_Subject_Section TSS ON A.section_name = TSS.section_name AND A.subject_id = TSS.subject_id
        WHERE A.uploaded_by_teacher = ? 
        ORDER BY A.uploaded_date DESC 
        LIMIT 2;`;

            pool.query(assignmentsQuery, [teacher.teacher_id], (err, assignmentsResults) => {
                if (err) {
                    console.error("Database error (Assignments):", err);
                    return res.status(500).json({ error: "Assignment Server Error" });
                }

              // 3️⃣ Fetch recent 2 assignments uploaded by the teacher
              const allassignmentsQuery = `
              SELECT 
          A.title, A.file_path, A.uploaded_date,  A.uploaded_by_teacher, A.assignment_id, 
          A.section_name, TSS.semester, S.name AS subject_name, T.name AS teacher_name, A.subject_id, T.teacher_id
      FROM Assignments A
      JOIN Subjects S ON A.subject_id = S.subject_id
      JOIN Teachers T ON A.uploaded_by_teacher = T.teacher_id
      JOIN Teacher_Subject_Section TSS ON A.section_name = TSS.section_name AND A.subject_id = TSS.subject_id
      WHERE A.uploaded_by_teacher = ? 
      ORDER BY A.uploaded_date DESC ;`;

          pool.query(allassignmentsQuery, [teacher.teacher_id], (err, allassignmentsResults) => {
              if (err) {
                  console.error("Database error (Assignments):", err);
                  return res.status(500).json({ error: "Assignment Server Error" });
              }

                // ✅ Return teacher details + materials + assignments
                res.json({
                    teacher,
                    studyMaterials: studyMaterialsResults,
                    allstudyMaterials: allstudyMaterialsResults,
                    assignments: assignmentsResults,
                    allassignments: allassignmentsResults
                });
            });
           
               });
            });
        });
    });
});

app.get('/studentSubmissions', (req, res) => {
    const { subject_id, section, semester, teacher_id, assignment_id } = req.query;
  
    const query = `
      SELECT sa.*, s.name AS student_name, s.roll_number
      FROM student_assignments sa
      JOIN students s ON sa.student_id = s.student_id
      WHERE sa.subject_id = ? AND sa.section = ? AND sa.semester = ? AND sa.teacher_id = ? AND sa.assignment_id =?
    `;
  
    pool.query(query, [subject_id, section, semester, teacher_id, assignment_id], (err, results) => {
      if (err) {
        console.error("Error fetching student submissions:", err);
        res.status(500).json({ error: "Database error" });
      } else {
        res.json(results);
      }
    });
  });
  
//API to fetch teacher's classes information and total students 
app.get('/teacherclasses', (req, res) => {
    const storedEmail = localStorage.getItem('email');

    // Fetch teacher details
    const teacherQuery = `SELECT teacher_id, name, email FROM Teachers WHERE email = ?`;

    pool.query(teacherQuery, [storedEmail], (err, teacherResults) => {
        if (err) {
            console.error("Database error (Teacher Details):", err);
            return res.status(500).json({ error: "Database Server Error" });
        }

        if (teacherResults.length === 0) {
            return res.status(404).json({ error: "Teacher not found" });
        }

        const teacher = teacherResults[0];

        // Fetch Classes, Total Students, and Subjects Assigned to Teacher
        const classQuery = ` SELECT  tss.section_name,  tss.semester, tss.subject_id, s.name AS subject_name,  (SELECT COUNT(*) FROM Students WHERE section = tss.section_name AND current_semester = tss.semester) AS total_students FROM Teacher_Subject_Section tss  JOIN Subjects s ON tss.subject_id = s.subject_id WHERE tss.teacher_id = ?  GROUP BY tss.section_name, tss.semester, tss.subject_id, s.name;
        `;

        pool.query(classQuery, [teacher.teacher_id], (err, classQueryresult) => {
            if (err) {
                console.error("Database error (classQuery):", err);
                return res.status(500).json({ error: "Internal Server Error" });
            }
            return res.json({
                teacher,
                class: classQueryresult
            });
        });
    });
});
// API to fetch students for a specific section & semester with their marks
// Fetch students for a selected class
app.get('/students/:teacher_id/:subject_id/:section_name/:semester', (req, res) => {
    const { teacher_id, subject_id, section_name, semester } = req.params;
    
    const studentQuery = `SELECT s.student_id, s.name, s.roll_number, m.assignment_1_marks, m.periodical_1_marks, m.assignment_2_marks, m.periodical_2_marks FROM Students s LEFT JOIN Marks m ON s.student_id = m.student_id AND m.subject_id = ? WHERE s.section = ? AND s.current_semester = ?;
        
    `;
    
    pool.query(studentQuery, [subject_id, section_name, semester], (err, results) => {
        if (err) {
            console.error("Database error (Fetching Students):", err);
            return res.status(500).json({ error: "Database Server Error" });
        }
        res.json(results);
    });
});
app.post("/savemarks", (req, res) => {
    const email = req.params.email;
    const storedEmail = localStorage.getItem('email');


    // Fetch teacher details
    const teacherQuery = `SELECT teacher_id FROM Teachers WHERE email = ?`;

    pool.query(teacherQuery, [storedEmail], (err, teacherResults) => {
        if (err) {
            console.error("Database error (Teacher Details):", err);
            return res.status(500).json({ error: "Database Server Error" });
        }

        if (teacherResults.length === 0) {
            return res.status(404).json({ error: "Teacher not found" });
        }

        const teacher = teacherResults[0];
        const { teacher_id } = teacher;
    

    if (!storedEmail){
        return res.status(401).json({ message: "Unauthorized - Teacher not logged in" });
    }

    console.log("Received data:", req.body);
    const marks = req.body.marks;

    if (!marks || marks.length === 0) {
        return res.status(400).json({ message: "No marks data provided" });
    }

    // Prepare values for bulk insert
    let values = marks.map(entry => [
        entry.student_id,
        entry.subject_id,
        entry.section_name,
        entry.semester,
        entry.assignment_1_marks || 0,
        entry.periodical_1_marks || 0,
        entry.assignment_2_marks || 0,
        entry.periodical_2_marks || 0
    ]);

    // Insert/Update Marks
    let sql = `
        INSERT INTO Marks (student_id, subject_id, section_name, semester, assignment_1_marks, periodical_1_marks, assignment_2_marks, periodical_2_marks)
        VALUES ?
        ON DUPLICATE KEY UPDATE 
            assignment_1_marks = VALUES(assignment_1_marks),
            periodical_1_marks = VALUES(periodical_1_marks),
            assignment_2_marks = VALUES(assignment_2_marks),
            periodical_2_marks = VALUES(periodical_2_marks)
    `;

    pool.query(sql, [values], (err, results) => {
        if (err) {
            console.error("❌ Error inserting/updating marks:", err);
            return res.status(500).json({ message: "Database error", error: err });
        }
        console.log("✅ Marks inserted/updated successfully!", results);

        // --- Get teacher & subject info ---
        const subject_id = marks[0].subject_id;
        const section_name = marks[0].section_name;
        const semester = marks[0].semester;

        pool.query(`
            SELECT T.name as teacher_name, S.name as subject_name, TS.course
            FROM Teachers T
            JOIN Teacher_Subject_Section TS ON T.teacher_id = TS.teacher_id AND TS.subject_id = ?
            JOIN Subjects S ON S.subject_id = TS.subject_id
            WHERE T.teacher_id = ?
        `, [subject_id, teacher_id], (err, infoResults) => {
            if (err) {
                console.error("❌ Error fetching teacher/subject details:", err);
                return res.status(500).json({ message: "Error fetching teacher info", error: err });
            }

            if (infoResults.length === 0) {
                return res.status(404).json({ message: "Teacher or subject details not found" });
            }

            const teacher_name = infoResults[0].teacher_name;
            const subject_name = infoResults[0].subject_name;
            const course = infoResults[0].course;

            // --- Student Notification ---
            const studentNotificationQuery = `
                INSERT INTO Notifications (user_type, user_id, message)
                VALUES ?
            `;
            const studentNotifications = marks.map(entry => [
                'student',
                entry.student_id,
                'Marks updated by ' + teacher_name
            ]);

            pool.query(studentNotificationQuery, [studentNotifications], (err) => {
                if (err) {
                    console.error("❌ Error inserting student notifications:", err);
                } else {
                    console.log("✅ Student notifications sent");
                }
            });

            // --- Admin Notification ---
            const adminMessage = `${teacher_name} has updated marks for subject (${subject_name}) for section (${section_name}), semester (${semester}), course (${course})`;

            const adminNotificationQuery = `
                INSERT INTO Notifications (user_type, user_id, message)
                VALUES ('admin', 'admin', ?)
            `;

            pool.query(adminNotificationQuery, [adminMessage, new Date()], (err) => {
                if (err) {
                    console.error("❌ Error inserting admin notification:", err);
                } else {
                    console.log("✅ Admin notification sent");
                }
            });

            res.json({ message: "Marks saved successfully!" });
        });
    });
});
});


// File Storage Setup
const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, "uploads/study_material");
    },
    filename: function (req, file, cb) {
        cb(null, Date.now() + "_" + file.originalname);
    }
});
const upload = multer({ storage: storage });
// Upload Study Material
app.post("/upload-study-material", upload.single("study_material"), (req, res) => {
    console.log("Received Data:", req.body);
    console.log("Uploaded File:", req.file);

    if (!req.file) {
        return res.status(400).json({ message: "❌ File upload failed, file not received." });
    }

    const title = req.file.originalname;
    const { description, subject_id, section_name, uploaded_by_teacher } = req.body;
    const filePath = `uploads/study_material/${req.file.filename}`;
    const uploaded_date = new Date().toISOString().slice(0, 19).replace("T", " ");

    // Step 1️⃣ Insert Study Material
    const insertQuery = `
        INSERT INTO Study_Material (title, description, file_path, subject_id, section_name, uploaded_by_teacher, uploaded_date)
        VALUES (?, ?, ?, ?, ?, ?, ?)`;

    pool.query(insertQuery, [title, description, filePath, subject_id, section_name, uploaded_by_teacher, uploaded_date], (err, result) => {
        if (err) {
            console.error("❌ Database error:", err);
            return res.status(500).json({ message: "❌ Database error", error: err });
        }

        // Step 2️⃣ Directly fetch teacher name
        const teacherQuery = `SELECT name AS teacher_name FROM Teachers WHERE teacher_id = ?`;

        pool.query(teacherQuery, [uploaded_by_teacher], (err, teacherResults) => {
            if (err) {
                console.error("❌ Error fetching teacher name:", err);
                return res.status(500).json({ message: "Error fetching teacher name" });
            }

            if (teacherResults.length === 0) {
                return res.status(404).json({ message: "Teacher not found" });
            }

            const { teacher_name } = teacherResults[0];

            // Step 3️⃣ Fetch eligible students
            const studentQuery = `
                SELECT student_id 
                FROM Students 
                WHERE course = (SELECT course FROM Subjects WHERE subject_id = ?)
                AND section = ?`;

            pool.query(studentQuery, [subject_id, section_name], (err, studentResults) => {
                if (err) {
                    console.error("❌ Error fetching students:", err);
                    return res.status(500).json({ message: "Error fetching students" });
                }

                if (studentResults.length === 0) {
                    return res.status(404).json({ message: "No students found for this section" });
                }

                // Step 4️⃣ Insert Notifications
                const notificationQuery = `
                    INSERT INTO Notifications (user_type, user_id, message)
                    VALUES ?`;

                const notifications = studentResults.map(student => [
                    'student',
                    student.student_id,
                    `New study material uploaded by ${teacher_name}`
                ]);

                pool.query(notificationQuery, [notifications], (err) => {
                    if (err) {
                        console.error("❌ Error inserting student notifications:", err);
                        return res.status(500).json({ message: "Error inserting student notifications" });
                    }

                    console.log("✅ Study material and notifications sent");
                    res.json({ message: "✅ Study material uploaded" });
                });
            });
        });
    });
});
//upload assignment 
app.post("/upload-assignment", upload.single("assignment_file"), (req, res) => {
    const { description, subject_id, section_name, uploaded_by_teacher, due_date } = req.body;
    const filePath = req.file ? `uploads/study_material/${req.file.filename}` : null;   // 
    const title = req.file ? req.file.originalname : "Untitled Assignment";

    if (!filePath) {
        return res.status(400).json({ message: "❌ File upload failed" });
    }

    // Step 1️⃣ Insert Assignment
    const query = `
        INSERT INTO Assignments (title, description, file_path, subject_id, section_name, uploaded_by_teacher, due_date, uploaded_date)
        VALUES (?, ?, ?, ?, ?, ?, ?, NOW())`;

    pool.query(query, [title, description, filePath, subject_id, section_name, uploaded_by_teacher, due_date], (err, result) => {
        if (err) {
            console.error("❌ Error saving assignment:", err);
            return res.status(500).json({ message: "Error saving assignment" });
        }

        // Step 2️⃣ Get Teacher Name
        const teacherQuery = `SELECT name AS teacher_name FROM Teachers WHERE teacher_id = ?`;

        pool.query(teacherQuery, [uploaded_by_teacher], (err, teacherResults) => {
            if (err) {
                console.error("❌ Error fetching teacher name:", err);
                return res.status(500).json({ message: "Error fetching teacher name" });
            }

            if (teacherResults.length === 0) {
                return res.status(404).json({ message: "Teacher not found" });
            }

            const { teacher_name } = teacherResults[0];

            // Step 3️⃣ Find Students of that class
            const studentQuery = `
                SELECT student_id 
                FROM Students 
                WHERE course = (SELECT course FROM Subjects WHERE subject_id = ?)
                AND section = ?`;

            pool.query(studentQuery, [subject_id, section_name], (err, studentResults) => {
                if (err) {
                    console.error("❌ Error fetching students:", err);
                    return res.status(500).json({ message: "Error fetching students" });
                }

                if (studentResults.length === 0) {
                    return res.status(404).json({ message: "No students found for this section" });
                }

                // Step 4️⃣ Insert Notifications
                const notificationQuery = `
                    INSERT INTO Notifications (user_type, user_id, message)
                    VALUES ?`;

                const notifications = studentResults.map(student => [
                    'student',
                    student.student_id,
                    `New assignment uploaded by ${teacher_name}`
                ]);

                pool.query(notificationQuery, [notifications], (err) => {
                    if (err) {
                        console.error("❌ Error inserting student notifications:", err);
                        return res.status(500).json({ message: "Error inserting student notifications" });
                    }

                    console.log("✅ Assignment and notifications inserted");
                    res.json({ message: "✅ Assignment uploaded and students notified!" });
                });
            });
        });
    });
});

//ADMIN DASHBOARD 
app.get('/admindashboard', (req, res) => {
    const email = req.params.email;
    const storedEmail = localStorage.getItem('email');

    if (!storedEmail) {
        return res.status(400).json({ error: "Admin email required" });
    }

    // Fetch admin details
    const adminDetailsQuery = `SELECT admin_id, email FROM Admin WHERE email = ?`;

    pool.query(adminDetailsQuery, [storedEmail], (err, adminResult) => {
        if (err) {
            console.error("Database Error (Admin Details):", err);
            return res.status(500).json({ error: "Database Server Error" });
        }

        if (adminResult.length === 0) {
            return res.status(404).json({ error: "Admin not found" });
        }

        const adminName = adminResult[0].admin_id;
        const adminEmail = adminResult[0].email;

        // Fetch total users (Students + Teachers)
        const totalUsersQuery = `
            SELECT 
                (SELECT COUNT(*) FROM Students) AS total_students,
                (SELECT COUNT(*) FROM Teachers) AS total_teachers
        `;

        pool.query(totalUsersQuery, (err, totalUsersResult) => {
            if (err) {
                console.error("Database Error (Total Users):", err);
                return res.status(500).json({ error: "Database totaluser Error" });
            }

            const totalStudents = totalUsersResult[0].total_students || 0;
            const totalTeachers = totalUsersResult[0].total_teachers || 0;

            // Fetch total courses (distinct courses from Students & Subjects)
            const totalCoursesQuery = `SELECT COUNT(DISTINCT course) AS total_courses FROM Sections;

`;

            pool.query(totalCoursesQuery, (err, totalCoursesResult) => {
                if (err) {
                    console.error("Database Error (Total Courses):", err);
                    return res.status(500).json({ error: "Database totalcourse Error" });
                }

                const totalCourses = totalCoursesResult[0].total_courses || 0;

                // Fetch active users (Students + Teachers)
                const activeUsersQuery = `
                    SELECT 
                        (SELECT COUNT(*) FROM Students WHERE is_active = 1) AS active_students,
                        (SELECT COUNT(*) FROM Teachers WHERE is_active = 1) AS active_teachers
                `;

                pool.query(activeUsersQuery, (err, activeUsersResult) => {
                    if (err) {
                        console.error("Database Error (Active Users):", err);
                        return res.status(500).json({ error: "Database recent activity Error" });
                    }

                    const activeStudents = activeUsersResult[0].active_students || 0;
                    const activeTeachers = activeUsersResult[0].active_teachers || 0;
                    const activeUsers = activeStudents + activeTeachers;

                    

                        // Fetch recent activity (last 3 days notifications from teachers)
                        const recentActivityQuery = `
                            SELECT message, DATE_FORMAT(timestamp, '%d-%m-%Y %H:%i') as timeAgo
    FROM Notifications
    WHERE user_type = 'Admin'
    AND timestamp >= NOW() - INTERVAL 7 DAY
    ORDER BY timestamp DESC;

                        `;

                        pool.query(recentActivityQuery, (err, recentActivityResults) => {
                            if (err) {
                                console.error("Database Error (Recent Activity):", err);
                                return res.status(500).json({ error: "Database recentactivityquery Error" });
                            }

                            const recentActivities = recentActivityResults.map(n => ({
                                message: n.message,
                                created_at: n.timeAgo
                            }));

                            // Fetch class performance graph data
                            const { course, semester, section } = req.query;

                            if (!course || !semester || !section) {
                                return res.json({
                                    admin_name: adminName,
                                    admin_email: adminEmail,
                                    total_students: totalStudents,
                                    total_teachers: totalTeachers,
                                    total_courses: totalCourses,
                                    active_users: activeUsers,
                                    recent_activities: recentActivities
                                });
                            }

                            
                                res.json({
                                    admin_name: adminName,
                                    admin_email: adminEmail,
                                    total_students: totalStudents,
                                    total_teachers: totalTeachers,
                                    total_courses: totalCourses,
                                    active_users: activeUsers,
                                    recent_activities: recentActivities,
                                });
                            });
                        });
                    });
                });
            });
        });
 // API to get dropdown data (Courses, Semesters, Sections)
 app.get('/getDropdownData', (req, res) => {
    const dropdownData = {};

    pool.query('SELECT DISTINCT course FROM Sections', (err, courseResults) => {
        if (err) {
            console.error('Error fetching courses:', err);
            return res.status(500).json({ error: 'Database error' });
        }
        dropdownData.courses = courseResults.map(row => row.course);

        // Fetch max course duration
        pool.query('SELECT MAX(duration) AS max_duration FROM Sections', (err, results) => {
            if (err) {
                console.error('Error fetching course duration:', err);
                return res.status(500).json({ error: 'Database error' });
            }

            const maxDuration = results.length > 0 && results[0].max_duration ? results[0].max_duration : 4; 
            dropdownData.years = Array.from({ length: maxDuration }, (_, i) => `year ${i + 1}`);

            // Fetch sections
            pool.query('SELECT DISTINCT section_name FROM Sections', (err, sectionResults) => {
                if (err) {
                    console.error('Error fetching sections:', err);
                    return res.status(500).json({ error: 'Database error' });
                }
                dropdownData.sections = sectionResults.map(row => row.section_name);

                res.json(dropdownData);
            });
        });
    });
});


// API to get graph data based on selected Course, Semester, and Section
app.get('/getGraphData', (req, res) => {
    const { course, section , current_year } = req.query;

    if (!course || !section || !current_year) {
        return res.status(400).json({ error: 'Missing parameters' });
    }

    const query = `
         SELECT 
            AVG(m.assignment_1_marks) AS Assignment1, 
            AVG(m.periodical_1_marks) AS Periodical1, 
            AVG(m.assignment_2_marks) AS Assignment2, 
            AVG(m.periodical_2_marks) AS Periodical2
        FROM Marks m
        JOIN Students s ON m.student_id = s.student_id
        WHERE s.course = ? AND s.current_year = ? AND m.section_name = ?;`;

    pool.query(query, [course, current_year, section], (err, results) => {
        if (err) {
            console.error('Error fetching graph data:', err);
            return res.status(500).json({ error: 'Database error' });
        }

        const data = {
            marks: [
                results[0].Assignment1 || 0,
                results[0].Periodical1 || 0,
                results[0].Assignment2 || 0,
                results[0].Periodical2 || 0
            ]
        };

        res.json(data);
    });
});

// API: Students ki list fetch karne ke liye
app.get("/getStudents", (req, res) => {
    const { course, section, current_year } = req.query;
    console.log("Received prams get students:", { course, section, current_year });  // DebuggiNG
    if (!course || !section || !current_year) {
        return res.status(400).json({ error: "Missing parameters" });
    }

    const query = `
        SELECT s.student_id AS ID, s.name, s.roll_number AS Roll_NO,
    COALESCE(AVG(m.assignment_1_marks), 0) AS Assignment1_Avg,
    COALESCE(AVG(m.periodical_1_marks), 0) AS Periodical1_Avg,
    COALESCE(AVG(m.assignment_2_marks), 0) AS Assignment2_Avg,
    COALESCE(AVG(m.periodical_2_marks), 0) AS Periodical2_Avg
FROM Students s LEFT JOIN Marks m ON 
    s.student_id = m.student_id 
    AND s.section = m.section_name
    AND s.current_semester = m.semester
LEFT JOIN Subjects sub ON 
    m.subject_id = sub.subject_id 
    AND s.course = sub.course
WHERE  s.course = ?  AND s.section = ?  AND s.current_year = ? GROUP BY 
    s.student_id, s.name, s.roll_number;

`;

    pool.query(query, [course, section, current_year], (err, results) => {
        if (err) {
            console.error("Database Error:", err);  // Debugging ke liye
            return res.status(500).json({ error: err.message });
        }
        console.log("Fetched Students:", JSON.stringify({ students: results }, null, 2));  
        res.json({ students: results });
    });
});

// Fetch all subjects
app.get('/subjects', (req, res) => {
    let sql = "SELECT subject_id, name AS subject_name, credit_point, course, semester FROM Subjects"; 
    
    pool.query(sql, (err, result) => {
      if (err) {
        console.error("Database Error:", err);
        return res.status(500).json({ error: "Database error" });
      }
  
      console.log("Subjects Fetched:", result); // Debugging
      res.json(result);
    });
  })
  //fetch teacher details in course management page 
  app.get('/getSubjectTeachers', (req, res) => {
    let subjectID = req.query.subject_id;
    if (!subjectID) return res.status(400).json({ error: "Subject ID is required" });

    let sql = `
      SELECT T.teacher_id, T.name AS teacher_name, T.email, TS.section_name, TS.semester, TS.current_year, 
             (SELECT COUNT(*) FROM Students WHERE section = TS.section_name) AS total_students
      FROM Teacher_Subject_Section TS
      JOIN Teachers T ON TS.teacher_id = T.teacher_id
      WHERE TS.subject_id = ?`;

    pool.query(sql, [subjectID], (err, result) => {
      if (err) return res.status(500).json({ error: "Database error" });
      res.json(result);
    });
});
// Add a new subject
app.post('/addSubject', (req, res) => {
    let { subject_id, name, branch, semester, credit_point, subject_type, course } = req.body;
    console.log("Received Data:", req.body); // Debugging ke liye
  
    // 🛑 **Check if subject_id is missing**
      if (!subject_id) {
        return res.status(400).json({ success: false, error: "Subject ID cannot be empty!" });
    }

    let sql = "INSERT INTO Subjects (subject_id, name, branch, semester, credit_point, subject_type, course) VALUES (?, ?, ?, ?, ?, ?, ?)";

    pool.query(sql, [subject_id, name, branch, semester, credit_point, subject_type, course], (err, result) => {
        if (err) return res.status(500).json({ success: false, error: err.message });
        res.json({ success: true });
    });
});
//delete subject 
app.delete('/deleteSubject/:subject_id', (req, res) => {
    let subjectID = req.params.subject_id;

    let sql = "DELETE FROM Subjects WHERE subject_id = ?";
    pool.query(sql, [subjectID], (err, result) => {
        if (err) {
            console.error("Error deleting subject:", err);
            return res.json({ success: false, message: "Error deleting subject" });
        }
        res.json({ success: true, message: "Subject deleted successfully!" });
    });
});
//TEACHER MANAGEMENT
//to get teacher information in cards of Teacher Management 
app.get('/teachers', (req, res) => {
    let sql = "SELECT teacher_id, name AS teacher_name, email FROM Teachers";

    pool.query(sql, (err, result) => {
        if (err) {
            console.error("Database Error:", err);
            return res.status(500).json({ error: "Database error" });
        }
        res.json(result);
    });
});
//Add a new Teacher
app.post('/addTeacher', (req, res) => {
    const { teacher_id, name, email, department, password } = req.body;

    if (!teacher_id || !name || !email || !department || !password) {
        return res.status(400).json({ error: "All fields are required!" });
    }

    let sql = "INSERT INTO Teachers (teacher_id, name, email, department, password) VALUES (?, ?, ?, ?, ?)";
    pool.query(sql, [teacher_id, name, email, department, password], (err, result) => {
        if (err) {
            console.error("Database Error:", err);
            return res.status(500).json({ error: "Error adding teacher" });
        }
        res.json({ success: true, message: "Teacher added successfully!" });
    });
});
//upload teacher
const teacherStorage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, "uploads/teachers");  // ✅ Folder set
    },
    filename: function (req, file, cb) {
        cb(null, Date.now() + "_" + file.originalname);
    }
});
const uploadTeachers = multer({ storage: teacherStorage });

app.post("/uploadTeachers", uploadTeachers.single("file"), (req, res) => {
    if (!req.file) {
        return res.status(400).json({ error: "No file uploaded" });
    }

    const filePath = req.file.path;
    const workbook = xlsx.readFile(filePath);
    const sheetName = workbook.SheetNames[0];
    const data = xlsx.utils.sheet_to_json(workbook.Sheets[sheetName]);

    let teachers = data.map(teacher => [
        teacher.teacher_id,
        teacher.name,
        teacher.email,
        teacher.contact_number,
        teacher.password,
        teacher.department

    ]);

    const sql = `INSERT INTO Teachers (teacher_id, name, email, password, contact_number, department) VALUES ?`;

    pool.query(sql, [teachers], (err, result) => {
        if (err) {
            console.error("Error inserting teachers:", err);
            return res.status(500).json({ error: "Database error" });
        }
        res.json({ message: "Teachers added successfully!" });
    });
});


//delete teacher in teachermanagement page
app.delete('/deleteTeacher/:id', (req, res) => {
    let teacherID = req.params.id;

    // Pehle linked records delete karo
    let deleteMappings = `DELETE FROM teacher_subject_section WHERE teacher_id = ?`;
    let deleteTeacher = `DELETE FROM Teachers WHERE teacher_id = ?`;

    pool.query(deleteMappings, [teacherID], (err, result) => {
        if (err) {
            console.error("Error deleting teacher from teacher_subject_section:", err);
            return res.json({ success: false, message: "Failed to delete teacher from teacher_subject_section" });
        }

        // Jab linked records delete ho jaye tab teacher delete karo
        pool.query(deleteTeacher, [teacherID], (err, result) => {
            if (err) {
                console.error("Error deleting teacher:", err);
                return res.json({ success: false, message: "Failed to delete teacher" });
            }
            res.json({ success: true, message: "Teacher deleted successfully" });
        });
    });
});
//teacher lecture details 
app.get('/teacher-lecture/:teacher_id', (req, res) => {
    let teacherID = req.params.teacher_id;
    let sql = `
        
  SELECT 
    t.teacher_id, 
    t.name, 
    t.email,
    t.contact_number, 
    t.department,  
    ts.semester, 
    ts.section_name AS section,  
    ts.subject_id, 
    s.name AS subject_name, 
    ts.course, 
    IFNULL(ts.current_year, 'N/A') AS current_year,  
    COUNT(st.student_id) AS total_students  
FROM Teachers t  
JOIN Teacher_Subject_Section ts ON t.teacher_id = ts.teacher_id  
JOIN Subjects s ON ts.subject_id = s.subject_id  
LEFT JOIN Students st ON ts.section_name = st.section  
    AND ts.semester = st.current_semester  
WHERE t.teacher_id = ?  
GROUP BY 
    t.teacher_id, 
    t.name, 
    t.email,
    t.contact_number, 
    t.department,  
    ts.semester, 
    ts.section_name,  
    ts.subject_id, 
    s.name, 
    ts.course, 
    ts.current_year;


`;

    pool.query(sql, [teacherID], (err, result) => {
        if (err) {
            console.error("Database Error:", err);
            return res.status(500).json({ error: "Database error" });
        }

        if (result.length === 0) {
            return res.status(404).json({ error: "Teacher not found" });
        }

        let teacherInfo = {
            teacher_id: result[0].teacher_id,
            name: result[0].name,
            email: result[0].email,
            contact_number: result[0].contact_number,
            department: result[0].department,
            classes: result.map(cls => ({
                semester: cls.semester,
                section: cls.section,
                subject_id: cls.subject_id,
                subject_name: cls.subject_name,
                course: cls.course,
                current_year: cls.current_year,
                total_students: cls.total_students
            }))
        };

        res.json(teacherInfo);
    });
});
//add class in teacher management and detail page 
app.post('/addClass', (req, res) => {
    const { teacher_id, semester, section, course, subject_id,} = req.body;
    
    const query = `INSERT INTO Teacher_Subject_Section 
                   (teacher_id, semester, section_name, course, subject_id) 
                   VALUES (?, ?, ?, ?, ?)`;

    pool.query(query, [teacher_id, semester, section, course, subject_id], (err, result) => {
        if (err) {
            console.error(err);
            return res.status(500).json({ message: "Database Error" });
        }
        res.json({ message: "Class added successfully!" });
    });
});
//upload classes 
const teachersubjectStorage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, "uploads/teacherSubject");  // ✅ Folder set
    },
    filename: function (req, file, cb) {
        cb(null, Date.now() + "_" + file.originalname);
    }
});
const uploadTeacherSubject = multer({ storage: teachersubjectStorage });

//
app.post("/uploadTeacherSubject", uploadTeacherSubject.single("file"), (req, res) => {
    if (!req.file) {
        return res.status(400).json({ error: "No file uploaded" });
    }

    const filePath = req.file.path;
    const workbook = xlsx.readFile(filePath);
    const sheetName = workbook.SheetNames[0];
    const data = xlsx.utils.sheet_to_json(workbook.Sheets[sheetName]);

    let teachers = data.map(Teacher_subject_section  => [
       Teacher_subject_section .teacher_id,
       Teacher_subject_section .subject_id,
       Teacher_subject_section .section_name,
       Teacher_subject_section .current_year,
       Teacher_subject_section .course

    ]);

    const sql = `INSERT INTO Teacher_subject_section (teacher_id, subject_id, section_name, current_year, course) VALUES ?`;

    pool.query(sql, [teachers], (err, result) => {
        if (err) {
            console.error("Error inserting teachers:", err);
            return res.status(500).json({ error: "Database error" });
        }
        res.json({ message: "classes  added successfully!" });
    });
});
//delete the assigned class in teacher_lecture page 
app.delete('/deletelectureclass', (req, res) => {
    const { teacher_id, subject_id, section } = req.body;

    const sql = `DELETE FROM Teacher_Subject_Section WHERE teacher_id = ? AND subject_id = ? AND section_name = ?`;

    pool.query(sql, [teacher_id, subject_id, section], (err, result) => {
        if (err) {
            console.error("Error deleting class:", err);
            return res.json({ success: false, message: "Failed to delete class!" });
        }
        res.json({ success: true, message: "Class deleted successfully!" });
    });
});
//STUDENT MANAGEMENT 
 
//DISTINCT COURSES 
app.get('/courses', (req, res) => { 
    pool.query(
        `SELECT DISTINCT s.course, sec.duration 
         FROM Subjects s 
         JOIN Sections sec ON s.course = sec.course
         UNION 
         SELECT DISTINCT st.course, sec.duration
         FROM Students st
         JOIN Sections sec ON st.course = sec.course`,
        (err, result) => {
            if (err) {
                console.error("Error fetching courses:", err);
                res.status(500).json({ error: "Database error" });
            } else {
                res.json(result);
            }
        }
    );
});
//add courses
app.post('/addCourse', (req, res) => {
    const { course_name, section, duration, branch } = req.body;

    if ( !course_name || !section || !duration || !branch) {
        return res.status(400).json({ error: "All fields are required!" });
    }

    const query = `INSERT INTO Sections ( course, section_name,   duration, branch) VALUES (?, ?, ?, ?)`;

    pool.query(query, [course_name, section, duration, branch], (err, result) => {
        if (err) {
            console.error("Error adding course:", err);
            return res.status(500).json({ error: "Database error!" });
        }
        res.json({ message: "Course added successfully!" });
    });
});
//delete course 
app.delete('/deleteCourse/:course_name', (req, res) => {
    const course_name= decodeURIComponent(req.params.course_name);

    const query = `DELETE FROM Sections WHERE course = ?`;

    pool.query(query, [course_name], (err, result) => {
        if (err) {
            console.error("Error deleting course:", err);
            return res.status(500).json({ error: "Database error!" });
        }
        if (result.affectedRows === 0) {
            return res.status(404).json({ error: "Course not found!" });
        }
        res.json({ message: "Course deleted successfully!" });
    });
});
//FETCH STUDENTS FOR THAT DISTINCT COURSE 
app.get('/students', (req, res) => {
    console.log("Received Query Params:", req.query); // Debugging

    const course = req.query.course?.replace(/'/g, ""); // Single quotes hatao
    const year = req.query.year;

    if (!course || !year) {
        console.log("Missing params, received:", req.query); // Debugging
    return res.status(400).json({ error: `Missing course or year. Received: ${JSON.stringify(req.query)}` });
    }
    console.log("Received Query Params:", req.query); // Debugging ke liye
    pool.query(
        `SELECT student_id, name, roll_number, email, section, current_semester, current_year,branch, password, batch 
         FROM Students 
         WHERE course = ? AND current_year = ?`,
        [course, year],
        (err, result) => {
            if (err) {
                console.error("Error fetching students:", err);
                res.status(500).json({ error: "Database error" });
            } else {
                console.log("Fetched Students:", result); // Debuggin
                res.json(result);
            }
        }
    );
});

// ADD NEW STUDENT 
app.post('/addStudent', (req, res) => {
    const { student_id, name, roll_number, email, password, section, batch, course } = req.body;

    pool.query("INSERT INTO Students (student_id, name, roll_number, email, password, section, batch, course) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
        [student_id, name, roll_number, email, password, section, batch, course],
        (err, result) => {
            if (err) {
                console.error("Error adding student:", err);
                res.status(500).json({ error: "Database error" });
            } else {
                res.json({ success: true });
            }
        }
    );
});
const studentStorage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, "uploads/students");  // ✅ Students ke liye folder
    },
    filename: function (req, file, cb) {
        cb(null, Date.now() + "_" + file.originalname);
    }
});
const uploadStudents = multer({ storage: studentStorage });

app.post("/uploadStudents", uploadStudents.single("file"), (req, res) => {
    if (!req.file) {
        return res.status(400).json({ error: "No file uploaded" });
    }

    const filePath = req.file.path;
    const workbook = xlsx.readFile(filePath);
    const sheetName = workbook.SheetNames[0];
    const data = xlsx.utils.sheet_to_json(workbook.Sheets[sheetName]);

    let students = data.map(student => [
        student.student_id,
        student.name,
        student.roll_number,
        student.email,
        student.password,
        student.section,
        student.batch,
        student.course,
        student.branch
    ]);

    const sql = `INSERT INTO Students (student_id, name, roll_number, email, password, section, batch, course, branch) VALUES ?`;

    pool.query(sql, [students], (err, result) => {
        if (err) {
            console.error("Error inserting students:", err);
            return res.status(500).json({ error: "Database error" });
        }
        res.json({ message: "Students added successfully!" });
    });
});


//delete student 
app.delete('/deleteStudent/:student_id', (req, res) => {
    const studentID = req.params.student_id;
    const deleteQuery = 'DELETE FROM Students WHERE student_id = ?';

    pool.query(deleteQuery, [studentID], (err, result) => {
        if (err) {
            console.error('Error deleting student:', err);
            return res.status(500).json({ message: 'Failed to delete student' });
        }
        res.json({ message: 'Student deleted successfully' });
    });
});

// Start Server
app.listen(PORT, () => {
    console.log(`🚀 Server running on http://localhost:${PORT}`);
});
 