-- MySQL dump 10.13  Distrib 9.2.0, for Win64 (x86_64)
--
-- Host: localhost    Database: teacherstudentportal
-- ------------------------------------------------------
-- Server version	9.2.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `admin`
--

DROP TABLE IF EXISTS `admin`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin` (
  `admin_id` varchar(50) NOT NULL,
  `password` varchar(255) DEFAULT NULL,
  `email` varchar(100) NOT NULL,
  PRIMARY KEY (`admin_id`),
  UNIQUE KEY `admin_email` (`email`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admin`
--

LOCK TABLES `admin` WRITE;
/*!40000 ALTER TABLE `admin` DISABLE KEYS */;
INSERT INTO `admin` VALUES ('admin','admin123','admin@example.com');
/*!40000 ALTER TABLE `admin` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `assignments`
--

DROP TABLE IF EXISTS `assignments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `assignments` (
  `assignment_id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(100) NOT NULL,
  `description` text,
  `subject_id` varchar(50) NOT NULL,
  `uploaded_by_teacher` varchar(20) NOT NULL,
  `uploaded_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `due_date` date NOT NULL,
  `section_name` varchar(50) NOT NULL,
  `file_path` varchar(255) NOT NULL,
  PRIMARY KEY (`assignment_id`),
  KEY `subject_id` (`subject_id`),
  KEY `uploaded_by_teacher` (`uploaded_by_teacher`),
  CONSTRAINT `assignments_ibfk_1` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`subject_id`),
  CONSTRAINT `assignments_ibfk_2` FOREIGN KEY (`uploaded_by_teacher`) REFERENCES `teachers` (`teacher_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `assignments`
--

LOCK TABLES `assignments` WRITE;
/*!40000 ALTER TABLE `assignments` DISABLE KEYS */;
INSERT INTO `assignments` VALUES (3,'Toc assignment 1.pdf','Uploaded assignment.','CS 315','APJT01','2025-02-19 19:44:44','2025-03-01','CS A','uploads/study_material/1739994284707_Toc assignment 1.pdf'),(4,'Unit 1 Toc assignment.pptx','Uploaded assignment.','CS 315','APJT01','2025-02-19 19:47:20','2025-02-27','CS A','uploads/study_material/1739994440634_Unit 1 Toc assignment.pptx'),(5,'DCN ASSIGNMENT 1.pdf','Uploaded assignment.','CS 302','APJT01','2025-02-19 19:48:31','2025-03-04','CS A','uploads/study_material/1739994510948_DCN ASSIGNMENT 1.pdf'),(6,'C Structures.docx','Uploaded assignment.','CS 315','APJT01','2025-02-23 11:50:35','2025-03-01','CS A','uploads/study_material/1740311435359_C Structures.docx'),(7,'TOC Assignment.pdf','Uploaded assignment.','CS 315','APJT01','2025-03-28 16:50:34','2025-04-01','CS A','uploads/study_material/1743180634697_TOC Assignment.pdf'),(8,'ML_Practical_Questions-2.docx','Uploaded assignment.','CS 315','APJT01','2025-04-05 08:28:44','2024-04-10','CS A','uploads/study_material/1743841724109_ML_Practical_Questions-2.docx'),(9,'ML_Practical_Questions-3.docx','Uploaded assignment.','CS 315','APJT01','2025-04-05 08:31:18','2025-04-09','CS A','uploads/study_material/1743841878260_ML_Practical_Questions-3.docx'),(10,'Screenshot 2024-06-22 122407.png','Uploaded assignment.','CS 315','APJT01','2025-04-12 09:42:02','2025-05-12','CS A','uploads/study_material/1744450921824_Screenshot 2024-06-22 122407.png');
/*!40000 ALTER TABLE `assignments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `marks`
--

DROP TABLE IF EXISTS `marks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `marks` (
  `mark_id` int NOT NULL AUTO_INCREMENT,
  `student_id` varchar(20) NOT NULL,
  `subject_id` varchar(50) NOT NULL,
  `semester` int NOT NULL,
  `assignment_1_marks` int DEFAULT '0',
  `periodical_1_marks` int DEFAULT '0',
  `assignment_2_marks` int DEFAULT '0',
  `periodical_2_marks` int DEFAULT '0',
  `average_marks` float GENERATED ALWAYS AS (((((`assignment_1_marks` + `periodical_1_marks`) + `assignment_2_marks`) + `periodical_2_marks`) / 4)) STORED,
  `section_name` enum('CS A','CS B','CS C','IT A') NOT NULL,
  `teacher_id` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`mark_id`),
  UNIQUE KEY `student_id` (`student_id`,`subject_id`),
  KEY `subject_id` (`subject_id`),
  KEY `fk_teacher_marks` (`teacher_id`),
  CONSTRAINT `fk_teacher_marks` FOREIGN KEY (`teacher_id`) REFERENCES `teachers` (`teacher_id`),
  CONSTRAINT `marks_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`) ON DELETE CASCADE,
  CONSTRAINT `marks_ibfk_2` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`subject_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=187 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `marks`
--

LOCK TABLES `marks` WRITE;
/*!40000 ALTER TABLE `marks` DISABLE KEYS */;
INSERT INTO `marks` (`mark_id`, `student_id`, `subject_id`, `semester`, `assignment_1_marks`, `periodical_1_marks`, `assignment_2_marks`, `periodical_2_marks`, `section_name`, `teacher_id`) VALUES (1,'BTBTC22254','STAT 204',6,8,7,9,8,'CS A',NULL),(2,'BTBTC22254','ECO 307',6,7,6,8,7,'CS A',NULL),(3,'BTBTC22254','CS 315',6,4,6,9,6,'CS A',NULL),(5,'BTBTC22256','STAT 204',6,7,7,4,8,'CS A',NULL),(6,'BTBTC22256','ECO 307',6,9,6,9,7,'CS A',NULL),(7,'BTBTC22256','CS 315',6,3,9,5,2,'CS A',NULL),(27,'BTBTC22163','MATH 311',5,7,6,8,9,'CS A',NULL),(28,'BTBTC22163','ENGG 205',5,8,9,7,6,'CS A',NULL),(29,'BTBTC22163','CS 302',5,9,8,6,8,'CS A',NULL),(30,'BTBTC22163','MGMT 310',5,6,9,8,7,'CS A',NULL),(31,'BTBTC22163','CS 304',5,8,7,9,8,'CS A',NULL),(32,'BTBTC22163','CS 308',5,7,8,6,7,'CS A',NULL),(51,'BTBTC22164','MATH 311',5,7,5,5,9,'CS A',NULL),(52,'BTBTC22164','ENGG 205',5,4,6,9,6,'CS A',NULL),(53,'BTBTC22164','CS 302',5,9,9,4,8,'CS A',NULL),(54,'BTBTC22164','MGMT 310',5,4,9,9,6,'CS A',NULL),(55,'BTBTC22164','CS 304',5,3,5,9,1,'CS A',NULL),(56,'BTBTC22164','CS 308',5,6,8,8,4,'CS A',NULL),(59,'BTBTC23236','MATH 209',4,6,9,5,7,'CS A',NULL),(60,'BTBTC23236','ENGG 205',4,7,6,5,6,'CS A',NULL),(61,'BTBTC23236','CS 313',4,6,8,5,6,'CS A',NULL),(62,'BTBTC23236','CS 213',4,5,6,7,8,'CS A',NULL),(63,'BTBTC23236','CS 216',4,7,8,9,5,'CS A',NULL),(80,'BTBTC23365','MATH 209',4,6,7,8,9,'CS A',NULL),(81,'BTBTC23365','ENGG 205',4,5,7,3,6,'CS A',NULL),(82,'BTBTC23365','CS 313',4,5,6,7,3,'CS A',NULL),(83,'BTBTC23365','CS 213',4,5,6,7,7,'CS A',NULL),(84,'BTBTC23365','CS 214',4,5,6,3,6,'CS A',NULL),(102,'BTBTC23145','MATH 210',3,4,7,6,5,'CS A',NULL),(103,'BTBTC23145','CS 207',3,6,4,8,9,'CS A',NULL),(104,'BTBTC23145','CS 209',3,5,7,4,6,'CS A',NULL),(105,'BTBTC23145','ENGG 201',3,4,6,8,4,'CS A',NULL),(106,'BTBTC23145','MATH 211',3,4,6,3,5,'CS A',NULL),(107,'BTBTC23145','CS 212',3,5,6,7,8,'CS A',NULL),(110,'BTBTC23245','MATH 210',3,4,5,6,2,'CS A',NULL),(111,'BTBTC23245','CS 207',3,4,6,3,2,'CS A',NULL),(112,'BTBTC23245','CS 209',3,5,6,7,4,'CS A',NULL),(113,'BTBTC23245','ENGG 201',3,4,6,3,3,'CS A',NULL),(114,'BTBTC23245','MATH 211',3,4,3,7,8,'CS A',NULL),(115,'BTBTC23245','CS 212',3,5,7,4,6,'CS A',NULL),(125,'BTBTI22080','STAT 204',6,8,7,9,8,'IT A',NULL),(126,'BTBTI22080','ECO 307',6,7,6,8,7,'IT A',NULL),(127,'BTBTI22080','CS 315',6,9,9,8,8,'IT A',NULL),(129,'BTBTI22081','STAT 204',6,7,7,4,8,'IT A',NULL),(130,'BTBTI22081','ECO 307',6,9,6,9,7,'IT A',NULL),(131,'BTBTI22081','CS 315',6,8,9,5,2,'IT A',NULL),(135,'BTBTC22112','CS 315',6,6,0,0,0,'CS B',NULL),(136,'BTBTC22122','CS 315',6,9,0,0,0,'CS B',NULL),(140,'BTBTC22113','CS 315',6,5,0,0,0,'CS B',NULL),(141,'BTBTC22123','CS 315',6,3,0,0,0,'CS B',NULL),(142,'BTBTC23112','CS 315',6,7,0,0,0,'CS B',NULL),(143,'BTBTC23122','CS 315',6,5,0,0,0,'CS B',NULL),(182,'bt22','CS 315',6,0,0,0,0,'CS A',NULL),(183,'BTBTC22163','CS 315',6,0,0,0,0,'CS A',NULL),(184,'BTBTC22164','CS 315',6,0,0,0,0,'CS A',NULL),(185,'btbti22','CS 315',6,0,0,0,0,'CS A',NULL),(186,'btbti22000','CS 315',6,0,0,0,0,'CS A',NULL);
/*!40000 ALTER TABLE `marks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
  `notification_id` int NOT NULL AUTO_INCREMENT,
  `user_id` varchar(20) NOT NULL,
  `user_type` enum('Student','Teacher','Admin') NOT NULL,
  `message` text NOT NULL,
  `timestamp` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`notification_id`)
) ENGINE=InnoDB AUTO_INCREMENT=158 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
INSERT INTO `notifications` VALUES (1,'APJT01','Teacher','New assignment uploaded!','2025-03-05 22:26:16'),(2,'admin','Admin','Alice Smith has updated marks for subject (Theory of Computation) for section (CS B), semester (6), course (B.Tech)','2025-03-28 14:28:19'),(3,'BTBTC22112','Student','Marks updated by Alice Smith','2025-03-28 14:40:21'),(4,'BTBTC22113','Student','Marks updated by Alice Smith','2025-03-28 14:40:21'),(5,'BTBTC22122','Student','Marks updated by Alice Smith','2025-03-28 14:40:21'),(6,'BTBTC22123','Student','Marks updated by Alice Smith','2025-03-28 14:40:21'),(7,'BTBTC23112','Student','Marks updated by Alice Smith','2025-03-28 14:40:21'),(8,'BTBTC23122','Student','Marks updated by Alice Smith','2025-03-28 14:40:21'),(9,'admin','Admin','Alice Smith has updated marks for subject (Theory of Computation) for section (CS B), semester (6), course (B.Tech)','2025-03-28 14:40:21'),(10,'b12','Student','New study material uploaded by Alice Smith','2025-03-28 16:34:15'),(11,'b2','Student','New study material uploaded by Alice Smith','2025-03-28 16:34:15'),(12,'bt22','Student','New study material uploaded by Alice Smith','2025-03-28 16:34:15'),(13,'btbt67','Student','New study material uploaded by Alice Smith','2025-03-28 16:34:15'),(14,'btbtc22100','Student','New study material uploaded by Alice Smith','2025-03-28 16:34:15'),(15,'BTBTC22163','Student','New study material uploaded by Alice Smith','2025-03-28 16:34:15'),(16,'BTBTC22164','Student','New study material uploaded by Alice Smith','2025-03-28 16:34:15'),(17,'BTBTC22254','Student','New study material uploaded by Alice Smith','2025-03-28 16:34:15'),(18,'BTBTC22256','Student','New study material uploaded by Alice Smith','2025-03-28 16:34:15'),(19,'BTBTC23145','Student','New study material uploaded by Alice Smith','2025-03-28 16:34:15'),(20,'BTBTC23236','Student','New study material uploaded by Alice Smith','2025-03-28 16:34:15'),(21,'BTBTC23245','Student','New study material uploaded by Alice Smith','2025-03-28 16:34:15'),(22,'BTBTC23365','Student','New study material uploaded by Alice Smith','2025-03-28 16:34:15'),(23,'btbti22','Student','New study material uploaded by Alice Smith','2025-03-28 16:34:15'),(24,'btbti22000','Student','New study material uploaded by Alice Smith','2025-03-28 16:34:15'),(25,'btbti22222','Student','New study material uploaded by Alice Smith','2025-03-28 16:34:15'),(26,'b12','Student','New assignment uploaded by Alice Smith','2025-03-28 16:50:34'),(27,'b2','Student','New assignment uploaded by Alice Smith','2025-03-28 16:50:34'),(28,'bt22','Student','New assignment uploaded by Alice Smith','2025-03-28 16:50:34'),(29,'btbt67','Student','New assignment uploaded by Alice Smith','2025-03-28 16:50:34'),(30,'btbtc22100','Student','New assignment uploaded by Alice Smith','2025-03-28 16:50:34'),(31,'BTBTC22163','Student','New assignment uploaded by Alice Smith','2025-03-28 16:50:34'),(32,'BTBTC22164','Student','New assignment uploaded by Alice Smith','2025-03-28 16:50:34'),(33,'BTBTC22254','Student','New assignment uploaded by Alice Smith','2025-03-28 16:50:34'),(34,'BTBTC22256','Student','New assignment uploaded by Alice Smith','2025-03-28 16:50:34'),(35,'BTBTC23145','Student','New assignment uploaded by Alice Smith','2025-03-28 16:50:34'),(36,'BTBTC23236','Student','New assignment uploaded by Alice Smith','2025-03-28 16:50:34'),(37,'BTBTC23245','Student','New assignment uploaded by Alice Smith','2025-03-28 16:50:34'),(38,'BTBTC23365','Student','New assignment uploaded by Alice Smith','2025-03-28 16:50:34'),(39,'btbti22','Student','New assignment uploaded by Alice Smith','2025-03-28 16:50:34'),(40,'btbti22000','Student','New assignment uploaded by Alice Smith','2025-03-28 16:50:34'),(41,'btbti22222','Student','New assignment uploaded by Alice Smith','2025-03-28 16:50:34'),(42,'BTBTC22112','Student','Marks updated by Alice Smith','2025-03-29 12:46:35'),(43,'BTBTC22113','Student','Marks updated by Alice Smith','2025-03-29 12:46:35'),(44,'BTBTC22122','Student','Marks updated by Alice Smith','2025-03-29 12:46:35'),(45,'BTBTC22123','Student','Marks updated by Alice Smith','2025-03-29 12:46:35'),(46,'BTBTC23112','Student','Marks updated by Alice Smith','2025-03-29 12:46:35'),(47,'BTBTC23122','Student','Marks updated by Alice Smith','2025-03-29 12:46:35'),(48,'admin','Admin','Alice Smith has updated marks for subject (Theory of Computation) for section (CS B), semester (6), course (B.Tech)','2025-03-29 12:46:35'),(49,'BTBTC22112','Student','Marks updated by Alice Smith','2025-04-03 01:53:35'),(50,'BTBTC22113','Student','Marks updated by Alice Smith','2025-04-03 01:53:35'),(51,'BTBTC22122','Student','Marks updated by Alice Smith','2025-04-03 01:53:35'),(52,'BTBTC22123','Student','Marks updated by Alice Smith','2025-04-03 01:53:35'),(53,'BTBTC23112','Student','Marks updated by Alice Smith','2025-04-03 01:53:35'),(54,'BTBTC23122','Student','Marks updated by Alice Smith','2025-04-03 01:53:35'),(55,'admin','Admin','Alice Smith has updated marks for subject (Theory of Computation) for section (CS B), semester (6), course (B.Tech)','2025-04-03 01:53:35'),(56,'b12','Student','New assignment uploaded by Alice Smith','2025-04-05 08:28:44'),(57,'b2','Student','New assignment uploaded by Alice Smith','2025-04-05 08:28:44'),(58,'bt22','Student','New assignment uploaded by Alice Smith','2025-04-05 08:28:44'),(59,'btbt67','Student','New assignment uploaded by Alice Smith','2025-04-05 08:28:44'),(60,'btbtc22100','Student','New assignment uploaded by Alice Smith','2025-04-05 08:28:44'),(61,'BTBTC22163','Student','New assignment uploaded by Alice Smith','2025-04-05 08:28:44'),(62,'BTBTC22164','Student','New assignment uploaded by Alice Smith','2025-04-05 08:28:44'),(63,'BTBTC22254','Student','New assignment uploaded by Alice Smith','2025-04-05 08:28:44'),(64,'BTBTC22256','Student','New assignment uploaded by Alice Smith','2025-04-05 08:28:44'),(65,'btbtc23005','Student','New assignment uploaded by Alice Smith','2025-04-05 08:28:44'),(66,'btbtc23008','Student','New assignment uploaded by Alice Smith','2025-04-05 08:28:44'),(67,'btbtc23021','Student','New assignment uploaded by Alice Smith','2025-04-05 08:28:44'),(68,'btbtc23028','Student','New assignment uploaded by Alice Smith','2025-04-05 08:28:44'),(69,'btbtc23030','Student','New assignment uploaded by Alice Smith','2025-04-05 08:28:44'),(70,'btbtc23036','Student','New assignment uploaded by Alice Smith','2025-04-05 08:28:44'),(71,'btbtc23042','Student','New assignment uploaded by Alice Smith','2025-04-05 08:28:44'),(72,'btbtc23047','Student','New assignment uploaded by Alice Smith','2025-04-05 08:28:44'),(73,'btbtc23060','Student','New assignment uploaded by Alice Smith','2025-04-05 08:28:44'),(74,'btbtc23061','Student','New assignment uploaded by Alice Smith','2025-04-05 08:28:44'),(75,'btbtc23062','Student','New assignment uploaded by Alice Smith','2025-04-05 08:28:44'),(76,'btbtc23064','Student','New assignment uploaded by Alice Smith','2025-04-05 08:28:44'),(77,'btbtc23085','Student','New assignment uploaded by Alice Smith','2025-04-05 08:28:44'),(78,'BTBTC23145','Student','New assignment uploaded by Alice Smith','2025-04-05 08:28:44'),(79,'BTBTC23236','Student','New assignment uploaded by Alice Smith','2025-04-05 08:28:44'),(80,'BTBTC23245','Student','New assignment uploaded by Alice Smith','2025-04-05 08:28:44'),(81,'BTBTC23365','Student','New assignment uploaded by Alice Smith','2025-04-05 08:28:44'),(82,'btbti22','Student','New assignment uploaded by Alice Smith','2025-04-05 08:28:44'),(83,'btbti22000','Student','New assignment uploaded by Alice Smith','2025-04-05 08:28:44'),(84,'btbti22222','Student','New assignment uploaded by Alice Smith','2025-04-05 08:28:44'),(85,'b12','Student','New assignment uploaded by Alice Smith','2025-04-05 08:31:18'),(86,'b2','Student','New assignment uploaded by Alice Smith','2025-04-05 08:31:18'),(87,'bt22','Student','New assignment uploaded by Alice Smith','2025-04-05 08:31:18'),(88,'btbt67','Student','New assignment uploaded by Alice Smith','2025-04-05 08:31:18'),(89,'btbtc22100','Student','New assignment uploaded by Alice Smith','2025-04-05 08:31:18'),(90,'BTBTC22163','Student','New assignment uploaded by Alice Smith','2025-04-05 08:31:18'),(91,'BTBTC22164','Student','New assignment uploaded by Alice Smith','2025-04-05 08:31:18'),(92,'BTBTC22254','Student','New assignment uploaded by Alice Smith','2025-04-05 08:31:18'),(93,'BTBTC22256','Student','New assignment uploaded by Alice Smith','2025-04-05 08:31:18'),(94,'btbtc23005','Student','New assignment uploaded by Alice Smith','2025-04-05 08:31:18'),(95,'btbtc23008','Student','New assignment uploaded by Alice Smith','2025-04-05 08:31:18'),(96,'btbtc23021','Student','New assignment uploaded by Alice Smith','2025-04-05 08:31:18'),(97,'btbtc23028','Student','New assignment uploaded by Alice Smith','2025-04-05 08:31:18'),(98,'btbtc23030','Student','New assignment uploaded by Alice Smith','2025-04-05 08:31:18'),(99,'btbtc23036','Student','New assignment uploaded by Alice Smith','2025-04-05 08:31:18'),(100,'btbtc23042','Student','New assignment uploaded by Alice Smith','2025-04-05 08:31:18'),(101,'btbtc23047','Student','New assignment uploaded by Alice Smith','2025-04-05 08:31:18'),(102,'btbtc23060','Student','New assignment uploaded by Alice Smith','2025-04-05 08:31:18'),(103,'btbtc23061','Student','New assignment uploaded by Alice Smith','2025-04-05 08:31:18'),(104,'btbtc23062','Student','New assignment uploaded by Alice Smith','2025-04-05 08:31:18'),(105,'btbtc23064','Student','New assignment uploaded by Alice Smith','2025-04-05 08:31:18'),(106,'btbtc23085','Student','New assignment uploaded by Alice Smith','2025-04-05 08:31:18'),(107,'BTBTC23145','Student','New assignment uploaded by Alice Smith','2025-04-05 08:31:18'),(108,'BTBTC23236','Student','New assignment uploaded by Alice Smith','2025-04-05 08:31:18'),(109,'BTBTC23245','Student','New assignment uploaded by Alice Smith','2025-04-05 08:31:18'),(110,'BTBTC23365','Student','New assignment uploaded by Alice Smith','2025-04-05 08:31:18'),(111,'btbti22','Student','New assignment uploaded by Alice Smith','2025-04-05 08:31:18'),(112,'btbti22000','Student','New assignment uploaded by Alice Smith','2025-04-05 08:31:18'),(113,'btbti22222','Student','New assignment uploaded by Alice Smith','2025-04-05 08:31:18'),(114,'BTBTC22112','Student','Marks updated by Alice Smith','2025-04-07 18:16:28'),(115,'BTBTC22113','Student','Marks updated by Alice Smith','2025-04-07 18:16:28'),(116,'BTBTC22122','Student','Marks updated by Alice Smith','2025-04-07 18:16:28'),(117,'BTBTC22123','Student','Marks updated by Alice Smith','2025-04-07 18:16:28'),(118,'BTBTC23112','Student','Marks updated by Alice Smith','2025-04-07 18:16:28'),(119,'BTBTC23122','Student','Marks updated by Alice Smith','2025-04-07 18:16:28'),(120,'admin','Admin','Alice Smith has updated marks for subject (Theory of Computation) for section (CS B), semester (6), course (B.Tech)','2025-04-07 18:16:28'),(121,'bt22','Student','Marks updated by Alice Smith','2025-04-07 18:16:56'),(122,'BTBTC22163','Student','Marks updated by Alice Smith','2025-04-07 18:16:56'),(123,'BTBTC22164','Student','Marks updated by Alice Smith','2025-04-07 18:16:56'),(124,'BTBTC22254','Student','Marks updated by Alice Smith','2025-04-07 18:16:56'),(125,'BTBTC22256','Student','Marks updated by Alice Smith','2025-04-07 18:16:56'),(126,'btbti22','Student','Marks updated by Alice Smith','2025-04-07 18:16:56'),(127,'btbti22000','Student','Marks updated by Alice Smith','2025-04-07 18:16:56'),(128,'admin','Admin','Alice Smith has updated marks for subject (Theory of Computation) for section (CS A), semester (6), course (B.Tech)','2025-04-07 18:16:56'),(129,'b12','Student','New assignment uploaded by Alice Smith','2025-04-12 09:42:02'),(130,'b2','Student','New assignment uploaded by Alice Smith','2025-04-12 09:42:02'),(131,'bt22','Student','New assignment uploaded by Alice Smith','2025-04-12 09:42:02'),(132,'btbt67','Student','New assignment uploaded by Alice Smith','2025-04-12 09:42:02'),(133,'btbtc22100','Student','New assignment uploaded by Alice Smith','2025-04-12 09:42:02'),(134,'BTBTC22163','Student','New assignment uploaded by Alice Smith','2025-04-12 09:42:02'),(135,'BTBTC22164','Student','New assignment uploaded by Alice Smith','2025-04-12 09:42:02'),(136,'BTBTC22254','Student','New assignment uploaded by Alice Smith','2025-04-12 09:42:02'),(137,'BTBTC22256','Student','New assignment uploaded by Alice Smith','2025-04-12 09:42:02'),(138,'btbtc23005','Student','New assignment uploaded by Alice Smith','2025-04-12 09:42:02'),(139,'btbtc23008','Student','New assignment uploaded by Alice Smith','2025-04-12 09:42:02'),(140,'btbtc23021','Student','New assignment uploaded by Alice Smith','2025-04-12 09:42:02'),(141,'btbtc23028','Student','New assignment uploaded by Alice Smith','2025-04-12 09:42:02'),(142,'btbtc23030','Student','New assignment uploaded by Alice Smith','2025-04-12 09:42:02'),(143,'btbtc23036','Student','New assignment uploaded by Alice Smith','2025-04-12 09:42:02'),(144,'btbtc23042','Student','New assignment uploaded by Alice Smith','2025-04-12 09:42:02'),(145,'btbtc23047','Student','New assignment uploaded by Alice Smith','2025-04-12 09:42:02'),(146,'btbtc23060','Student','New assignment uploaded by Alice Smith','2025-04-12 09:42:02'),(147,'btbtc23061','Student','New assignment uploaded by Alice Smith','2025-04-12 09:42:02'),(148,'btbtc23062','Student','New assignment uploaded by Alice Smith','2025-04-12 09:42:02'),(149,'btbtc23064','Student','New assignment uploaded by Alice Smith','2025-04-12 09:42:02'),(150,'btbtc23085','Student','New assignment uploaded by Alice Smith','2025-04-12 09:42:02'),(151,'BTBTC23145','Student','New assignment uploaded by Alice Smith','2025-04-12 09:42:02'),(152,'BTBTC23236','Student','New assignment uploaded by Alice Smith','2025-04-12 09:42:02'),(153,'BTBTC23245','Student','New assignment uploaded by Alice Smith','2025-04-12 09:42:02'),(154,'BTBTC23365','Student','New assignment uploaded by Alice Smith','2025-04-12 09:42:02'),(155,'btbti22','Student','New assignment uploaded by Alice Smith','2025-04-12 09:42:02'),(156,'btbti22000','Student','New assignment uploaded by Alice Smith','2025-04-12 09:42:02'),(157,'btbti22222','Student','New assignment uploaded by Alice Smith','2025-04-12 09:42:02');
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sections`
--

DROP TABLE IF EXISTS `sections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sections` (
  `section_name` varchar(50) NOT NULL,
  `branch` varchar(50) DEFAULT NULL,
  `course` varchar(50) DEFAULT NULL,
  `duration` int DEFAULT NULL,
  PRIMARY KEY (`section_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sections`
--

LOCK TABLES `sections` WRITE;
/*!40000 ALTER TABLE `sections` DISABLE KEYS */;
INSERT INTO `sections` VALUES ('CS A','CS','B.Tech',4),('CS B','CS','B.Tech',4),('CS C','CS','B.Tech',4),('IT A','IT','B.Tech',4);
/*!40000 ALTER TABLE `sections` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `student_assignments`
--

DROP TABLE IF EXISTS `student_assignments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `student_assignments` (
  `submission_id` int NOT NULL AUTO_INCREMENT,
  `student_id` varchar(10) DEFAULT NULL,
  `subject_id` varchar(10) DEFAULT NULL,
  `teacher_id` varchar(10) DEFAULT NULL,
  `semester` int DEFAULT NULL,
  `section` varchar(10) DEFAULT NULL,
  `course` varchar(100) DEFAULT NULL,
  `file_path` varchar(255) DEFAULT NULL,
  `submission_date` date DEFAULT NULL,
  `assignment_id` int DEFAULT NULL,
  PRIMARY KEY (`submission_id`),
  KEY `student_id` (`student_id`),
  KEY `subject_id` (`subject_id`),
  KEY `teacher_id` (`teacher_id`),
  KEY `fk_assignment_id` (`assignment_id`),
  CONSTRAINT `fk_assignment_id` FOREIGN KEY (`assignment_id`) REFERENCES `assignments` (`assignment_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `student_assignments_ibfk_2` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`),
  CONSTRAINT `student_assignments_ibfk_3` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`subject_id`),
  CONSTRAINT `student_assignments_ibfk_4` FOREIGN KEY (`teacher_id`) REFERENCES `teachers` (`teacher_id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `student_assignments`
--

LOCK TABLES `student_assignments` WRITE;
/*!40000 ALTER TABLE `student_assignments` DISABLE KEYS */;
INSERT INTO `student_assignments` VALUES (8,'BTBTC22254','CS 315','APJT01',6,'CS A','B.Tech','uploads/StudentAssignment/1744454520348_Screenshot 2024-06-22 124003.png','2025-04-12',10);
/*!40000 ALTER TABLE `student_assignments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `students`
--

DROP TABLE IF EXISTS `students`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `students` (
  `student_id` varchar(20) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(100) NOT NULL,
  `roll_number` varchar(50) NOT NULL,
  `branch` enum('CS','IT') NOT NULL,
  `section` enum('CS A','CS B','CS C','IT A') NOT NULL,
  `current_year` int DEFAULT NULL,
  `current_semester` int DEFAULT NULL,
  `batch` varchar(10) NOT NULL,
  `course` varchar(100) NOT NULL,
  `is_active` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`student_id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `roll_number` (`roll_number`),
  CONSTRAINT `students_chk_1` CHECK ((`current_year` between 1 and 4)),
  CONSTRAINT `students_chk_2` CHECK ((`current_semester` between 1 and 8))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `students`
--

LOCK TABLES `students` WRITE;
/*!40000 ALTER TABLE `students` DISABLE KEYS */;
INSERT INTO `students` VALUES ('b12','dii','btbt21','fijoirh','345','CS','CS A',2,4,'2023','B.Tech',0),('b2','Dia','b2_dia@banasthali.in','dia234','27','CS','CS A',1,1,'2022','B.Tech',0),('bt22','Disha','bt2_diksha@banasthali.in','diksha1234','227','CS','CS A',4,6,'2022','B.Tech',0),('btbt67','d','btbt67@jyg','uigff','789','CS','CS A',1,2,'2024','B.Tech',0),('btbtc22100','muskan','btbtc22100_muskan@banasthali.in','muskan1223','5643627','CS','CS A',2,4,'2023','B.Tech',0),('BTBTC22112','Rashi Mangal','btbtc22112_rashi@banasthali.in','rashi1234','2316865','CS','CS B',3,6,'2022','B.Tech',0),('BTBTC22113','Sejal Tagore','btbtc22113_sejal@banasthali.in','sejal1234','2366867','CS','CS B',3,6,'2022','B.Tech',0),('BTBTC22122','Ruchi Shakhtwat','btbtc22122_ruchi@banasthali.in','ruchi1234','2216864','CS','CS B',3,6,'2022','B.Tech',0),('BTBTC22123','Amrita Rao','btbtc22123_amrita@banasthali.in','amrita1234','2266866','CS','CS B',3,6,'2022','B.Tech',0),('BTBTC22163','Charu Arora','btbtc22163_charu@banasthali.in','charuarora1234','2216263','CS','CS A',3,6,'2022','B.Tech',0),('BTBTC22164','Akshita Singh','btbtc22164_akshita@banasthali.in','akshita1234','2216264','CS','CS A',3,6,'2022','B.Tech',0),('BTBTC22244','Shristi Mishra','btbtc22244_shrishti@banasthali.in','shrishti1234','2216458','CS','CS C',3,6,'2022','B.Tech',0),('BTBTC22245','Tanya Sharma','btbtc22245_tanya@banasthali.in','tanya1234','2216425','CS','CS C',3,6,'2022','B.Tech',0),('BTBTC22254','Ayushi Yadav','btbtc22254_ayushi@banasthali.in','ayushi1234','2216245','CS','CS A',3,6,'2022','B.Tech',0),('BTBTC22256','Ayushka Sahu','btbtc22256_ayushka@banasthali.in','ayushka1234','2216246','CS','CS A',3,6,'2022','B.Tech',0),('BTBTC22282','Riya Pathak','btbtc22282_riya@banasthali.in','riya1234','2216453','CS','CS C',3,6,'2022','B.Tech',0),('BTBTC22283','Sakshi Chouhan','btbtc22283_sakshi@banasthali.in','sakshi1234','2216457','CS','CS C',3,6,'2022','B.Tech',0),('btbtc23000','Molly','btbtc23000_molly@banasthali.in','Pass@123','2389207','CS','IT A',2,4,'2023','B.Tech',0),('btbtc23005','Nicole','btbtc23005_nicole@banasthali.in','Pass@123','2366374','CS','CS A',2,4,'2023','B.Tech',0),('btbtc23006','Katie','btbtc23006_katie@banasthali.in','Pass@123','2326687','CS','CS C',2,4,'2023','B.Tech',0),('btbtc23008','Brenda','btbtc23008_brenda@banasthali.in','Pass@123','2332111','CS','CS A',2,4,'2023','B.Tech',0),('btbtc23011','Heather','btbtc23011_heather@banasthali.in','Pass@123','2335822','CS','IT A',2,4,'2023','B.Tech',0),('btbtc23012','Rebecca','btbtc23012_rebecca@banasthali.in','Pass@123','2367584','CS','IT A',2,4,'2023','B.Tech',0),('btbtc23015','Jennifer','btbtc23015_jennifer@banasthali.in','Pass@123','2336108','CS','CS C',2,4,'2023','B.Tech',0),('btbtc23016','Patricia','btbtc23016_patricia@banasthali.in','Pass@123','2324343','CS','CS B',2,4,'2023','B.Tech',0),('btbtc23019','Rebecca','btbtc23019_rebecca@banasthali.in','Pass@123','2374974','CS','CS C',2,4,'2023','B.Tech',0),('btbtc23020','Cynthia','btbtc23020_cynthia@banasthali.in','Pass@123','2351794','CS','CS C',2,4,'2023','B.Tech',0),('btbtc23021','Allison','btbtc23021_allison@banasthali.in','Pass@123','2381536','CS','CS A',2,4,'2023','B.Tech',0),('btbtc23022','Patricia','btbtc23022_patricia@banasthali.in','Pass@123','2327873','CS','CS B',2,4,'2023','B.Tech',0),('btbtc23024','Lisa','btbtc23024_lisa@banasthali.in','Pass@123','2353088','CS','CS B',2,4,'2023','B.Tech',0),('btbtc23028','Ashley','btbtc23028_ashley@banasthali.in','Pass@123','2355001','CS','CS A',2,4,'2023','B.Tech',0),('btbtc23030','Miranda','btbtc23030_miranda@banasthali.in','Pass@123','2310613','CS','CS A',2,4,'2023','B.Tech',0),('btbtc23033','Regina','btbtc23033_regina@banasthali.in','Pass@123','2337831','CS','CS B',2,4,'2023','B.Tech',0),('btbtc23034','Sherry','btbtc23034_sherry@banasthali.in','Pass@123','2321135','CS','CS C',2,4,'2023','B.Tech',0),('btbtc23035','Valerie','btbtc23035_valerie@banasthali.in','Pass@123','2331678','CS','CS B',2,4,'2023','B.Tech',0),('btbtc23036','Michelle','btbtc23036_michelle@banasthali.in','Pass@123','2328448','CS','CS A',2,4,'2023','B.Tech',0),('btbtc23039','Deanna','btbtc23039_deanna@banasthali.in','Pass@123','2331939','CS','IT A',2,4,'2023','B.Tech',0),('btbtc23040','Brandi','btbtc23040_brandi@banasthali.in','Pass@123','2384896','CS','CS B',2,4,'2023','B.Tech',0),('btbtc23041','Jessica','btbtc23041_jessica@banasthali.in','Pass@123','2361010','CS','CS C',2,4,'2023','B.Tech',0),('btbtc23042','Anna','btbtc23042_anna@banasthali.in','Pass@123','2348563','CS','CS A',2,4,'2023','B.Tech',0),('btbtc23043','Sandra','btbtc23043_sandra@banasthali.in','Pass@123','2331618','CS','IT A',2,4,'2023','B.Tech',0),('btbtc23047','Jean','btbtc23047_jean@banasthali.in','Pass@123','2328358','CS','CS A',2,4,'2023','B.Tech',0),('btbtc23052','Lori','btbtc23052_lori@banasthali.in','Pass@123','2339559','CS','IT A',2,4,'2023','B.Tech',0),('btbtc23056','April','btbtc23056_april@banasthali.in','Pass@123','2337718','CS','CS C',2,4,'2023','B.Tech',0),('btbtc23058','Mary','btbtc23058_mary@banasthali.in','Pass@123','2314884','CS','IT A',2,4,'2023','B.Tech',0),('btbtc23059','Julie','btbtc23059_julie@banasthali.in','Pass@123','2360447','CS','CS C',2,4,'2023','B.Tech',0),('btbtc23060','Melissa','btbtc23060_melissa@banasthali.in','Pass@123','2315519','CS','CS A',2,4,'2023','B.Tech',0),('btbtc23061','Nancy','btbtc23061_nancy@banasthali.in','Pass@123','2316084','CS','CS A',2,4,'2023','B.Tech',0),('btbtc23062','Jamie','btbtc23062_jamie@banasthali.in','Pass@123','2372610','CS','CS A',2,4,'2023','B.Tech',0),('btbtc23063','Kelly','btbtc23063_kelly@banasthali.in','Pass@123','2386262','CS','CS B',2,4,'2023','B.Tech',0),('btbtc23064','Melissa','btbtc23064_melissa@banasthali.in','Pass@123','2327928','CS','CS A',2,4,'2023','B.Tech',0),('btbtc23065','Valerie','btbtc23065_valerie@banasthali.in','Pass@123','2388723','CS','IT A',2,4,'2023','B.Tech',0),('btbtc23067','Tricia','btbtc23067_tricia@banasthali.in','Pass@123','2336421','CS','CS C',2,4,'2023','B.Tech',0),('btbtc23069','Ann','btbtc23069_ann@banasthali.in','Pass@123','2360653','CS','CS B',2,4,'2023','B.Tech',0),('btbtc23073','Lisa','btbtc23073_lisa@banasthali.in','Pass@123','2328341','CS','CS C',2,4,'2023','B.Tech',0),('btbtc23074','Julie','btbtc23074_julie@banasthali.in','Pass@123','2374767','CS','CS B',2,4,'2023','B.Tech',0),('btbtc23077','Danielle','btbtc23077_danielle@banasthali.in','Pass@123','2377752','CS','CS B',2,4,'2023','B.Tech',0),('btbtc23080','Laura','btbtc23080_laura@banasthali.in','Pass@123','2387034','CS','CS B',2,4,'2023','B.Tech',0),('btbtc23081','Carrie','btbtc23081_carrie@banasthali.in','Pass@123','2361136','CS','CS C',2,4,'2023','B.Tech',0),('btbtc23085','Melissa','btbtc23085_melissa@banasthali.in','Pass@123','2396866','CS','CS A',2,4,'2023','B.Tech',0),('btbtc23086','Jennifer','btbtc23086_jennifer@banasthali.in','Pass@123','2319967','CS','CS B',2,4,'2023','B.Tech',0),('btbtc23088','Bethany','btbtc23088_bethany@banasthali.in','Pass@123','2343717','CS','CS C',2,4,'2023','B.Tech',0),('BTBTC23112','Shreyanshi Mittal','btbtc23112_shreyanshi@banasthali.in','shreyanshi1234','2336869','CS','CS B',3,6,'2022','B.Tech',0),('BTBTC23113','Yashu Mishra','btbtc23113_yashu@banasthali.in','yashu1234','2326671','CS','CS B',2,4,'2023','B.Tech',0),('BTBTC23122','Vridhi Bansal','btbtc23122_vridhi@banasthali.in','vridhi1234','2336868','CS','CS B',3,6,'2022','B.Tech',0),('BTBTC23123','Meenu Bharadwaj','btbtc23123_meenu@banasthali.in','meenu1234','2216670','CS','CS B',2,4,'2023','B.Tech',0),('BTBTC23145','Aditi Chouhan','btbtc23145_aditi@banasthali.in','aditi1234','2213646','CS','CS A',2,4,'2023','B.Tech',0),('BTBTC23182','Muskan Rathore','btbtc23182_muskan@banasthali.in','muskan1234','2116461','CS','CS C',2,4,'2023','B.Tech',0),('BTBTC23183','Priya Sikarwar','btbtc23183_priya@banasthali.in','priya1234','2316462','CS','CS C',2,4,'2023','B.Tech',0),('BTBTC23236','Bhoomika Singh','btbtc23236_bhoomika@banasthali.in','bhoomika1234','2216236','CS','CS A',2,4,'2023','B.Tech',0),('BTBTC23245','Varna Singh','btbtc23245_varna@banasthali.in','varna1234','2213546','CS','CS A',2,4,'2023','B.Tech',0),('BTBTC23282','Vanshika Rawat','btbtc23282_vanshika@banasthali.in','vanshika1234','2116459','CS','CS C',2,4,'2023','B.Tech',0),('BTBTC23283','Komal Singh','btbtc23283_komal@banasthali.in','komal1234','2116460','CS','CS C',2,4,'2023','B.Tech',0),('BTBTC23365','Priyanshi Mishra','btbtc23365_priyanshi@banasthali.in','priyanshi1234','2216456','CS','CS A',2,4,'2023','B.Tech',0),('BTBTC24101','Neha Sharma','btbtc24101_neha@banasthali.in','neha1234','2416101','CS','CS A',1,3,'2024','B.sc',0),('btbti22','Diksha','btbti22_diksha@banasthali.in','diks1234','22167','CS','CS A',3,6,'2022','B.Tech',0),('btbti22000','Dhanti ','btbti22000_dhanti@banasthali.in','dhanti1234','2214667','CS','CS A',3,6,'2022','B.Tech',0),('BTBTI22080','Kritika Bhati','btbti22080_kritika@banasthali.in','kritika1234','2216849','IT','IT A',3,6,'2022','B.Tech',0),('BTBTI22081','Rachna Yadav','btbti22081_rachna@banasthali.in','rachna1234','2216842','IT','IT A',3,6,'2022','B.Tech',0),('btbti22222','Diksha Pathak ','btbti22222_diksha@banasthali.in','diksha1234','2214567','CS','CS A',2,4,'2023','B.Tech',0),('BTBTI22480','Rupal Singh','btbti22480_rupal@banasthali.in','rupal1234','2214649','IT','IT A',3,6,'2022','B.Tech',0),('BTBTI22482','Ishhita Yadav','btbti22482_ishhita@banasthali.in','ishhita1234','2214642','IT','IT A',3,6,'2022','B.Tech',0),('BTBTI22580','Supriya Maheshwari','btbti22580_supriya@banasthali.in','supriya1234','2218249','IT','IT A',2,4,'2023','B.Tech',0),('BTBTI22581','Madhuri Rajput','btbti22581_madhuri@banasthali.in','madhuri1234','2218242','IT','IT A',2,4,'2023','B.Tech',0),('btbti23001','Erica','btbti23001_erica@banasthali.in','Pass@123','2324327','IT','IT A',2,4,'2023','B.Tech',0),('btbti23002','Sandy','btbti23002_sandy@banasthali.in','Pass@123','2340128','IT','IT A',2,4,'2023','B.Tech',0),('btbti23003','Patricia','btbti23003_patricia@banasthali.in','Pass@123','2335963','IT','IT A',2,4,'2023','B.Tech',0),('btbti23004','Kimberly','btbti23004_kimberly@banasthali.in','Pass@123','2348721','IT','IT A',2,4,'2023','B.Tech',0),('btbti23007','Laura','btbti23007_laura@banasthali.in','Pass@123','2340525','IT','IT A',2,4,'2023','B.Tech',0),('btbti23009','Tammy','btbti23009_tammy@banasthali.in','Pass@123','2389736','IT','IT A',2,4,'2023','B.Tech',0),('btbti23010','Michelle','btbti23010_michelle@banasthali.in','Pass@123','2343668','IT','IT A',2,4,'2023','B.Tech',0),('btbti23013','Julie','btbti23013_julie@banasthali.in','Pass@123','2388234','IT','IT A',2,4,'2023','B.Tech',0),('btbti23014','Stephanie','btbti23014_stephanie@banasthali.in','Pass@123','2371332','IT','IT A',2,4,'2023','B.Tech',0),('btbti23017','Cindy','btbti23017_cindy@banasthali.in','Pass@123','2397709','IT','IT A',2,4,'2023','B.Tech',0),('btbti23018','Gabrielle','btbti23018_gabrielle@banasthali.in','Pass@123','2333876','IT','IT A',2,4,'2023','B.Tech',0),('btbti23023','Jennifer','btbti23023_jennifer@banasthali.in','Pass@123','2371430','IT','IT A',2,4,'2023','B.Tech',0),('btbti23025','Misty','btbti23025_misty@banasthali.in','Pass@123','2330748','IT','IT A',2,4,'2023','B.Tech',0),('btbti23026','Hannah','btbti23026_hannah@banasthali.in','Pass@123','2321617','IT','IT A',2,4,'2023','B.Tech',0),('btbti23027','Heather','btbti23027_heather@banasthali.in','Pass@123','2331199','IT','IT A',2,4,'2023','B.Tech',0),('btbti23029','Anne','btbti23029_anne@banasthali.in','Pass@123','2334467','IT','IT A',2,4,'2023','B.Tech',0),('btbti23031','Veronica','btbti23031_veronica@banasthali.in','Pass@123','2356508','IT','IT A',2,4,'2023','B.Tech',0),('btbti23032','Sue','btbti23032_sue@banasthali.in','Pass@123','2319616','IT','IT A',2,4,'2023','B.Tech',0),('btbti23037','Dana','btbti23037_dana@banasthali.in','Pass@123','2356426','IT','IT A',2,4,'2023','B.Tech',0),('btbti23038','Whitney','btbti23038_whitney@banasthali.in','Pass@123','2386634','IT','IT A',2,4,'2023','B.Tech',0),('btbti23044','Laura','btbti23044_laura@banasthali.in','Pass@123','2333521','IT','IT A',2,4,'2023','B.Tech',0),('btbti23045','Abigail','btbti23045_abigail@banasthali.in','Pass@123','2388182','IT','IT A',2,4,'2023','B.Tech',0),('btbti23046','Judy','btbti23046_judy@banasthali.in','Pass@123','2392008','IT','IT A',2,4,'2023','B.Tech',0),('btbti23048','Makayla','btbti23048_makayla@banasthali.in','Pass@123','2359132','IT','IT A',2,4,'2023','B.Tech',0),('btbti23049','Melissa','btbti23049_melissa@banasthali.in','Pass@123','2350149','IT','IT A',2,4,'2023','B.Tech',0),('btbti23050','Emily','btbti23050_emily@banasthali.in','Pass@123','2372130','IT','IT A',2,4,'2023','B.Tech',0),('btbti23051','Kimberly','btbti23051_kimberly@banasthali.in','Pass@123','2336358','IT','IT A',2,4,'2023','B.Tech',0),('btbti23053','Karen','btbti23053_karen@banasthali.in','Pass@123','2349984','IT','IT A',2,4,'2023','B.Tech',0),('btbti23054','Rachael','btbti23054_rachael@banasthali.in','Pass@123','2314189','IT','IT A',2,4,'2023','B.Tech',0),('btbti23055','Michelle','btbti23055_michelle@banasthali.in','Pass@123','2322298','IT','IT A',2,4,'2023','B.Tech',0),('btbti23057','Lisa','btbti23057_lisa@banasthali.in','Pass@123','2369266','IT','IT A',2,4,'2023','B.Tech',0),('btbti23066','Robin','btbti23066_robin@banasthali.in','Pass@123','2383399','IT','IT A',2,4,'2023','B.Tech',0),('btbti23068','Jessica','btbti23068_jessica@banasthali.in','Pass@123','2324763','IT','IT A',2,4,'2023','B.Tech',0),('btbti23070','Christine','btbti23070_christine@banasthali.in','Pass@123','2368524','IT','IT A',2,4,'2023','B.Tech',0),('btbti23071','Karen','btbti23071_karen@banasthali.in','Pass@123','2336887','IT','IT A',2,4,'2023','B.Tech',0),('btbti23072','Jasmine','btbti23072_jasmine@banasthali.in','Pass@123','2316446','IT','IT A',2,4,'2023','B.Tech',0),('btbti23075','Tammy','btbti23075_tammy@banasthali.in','Pass@123','2310545','IT','IT A',2,4,'2023','B.Tech',0),('btbti23076','Lisa','btbti23076_lisa@banasthali.in','Pass@123','2350296','IT','IT A',2,4,'2023','B.Tech',0),('btbti23078','Denise','btbti23078_denise@banasthali.in','Pass@123','2338809','IT','IT A',2,4,'2023','B.Tech',0),('btbti23079','Claire','btbti23079_claire@banasthali.in','Pass@123','2372941','IT','IT A',2,4,'2023','B.Tech',0),('btbti23082','Heather','btbti23082_heather@banasthali.in','Pass@123','2334536','IT','IT A',2,4,'2023','B.Tech',0),('btbti23083','Tonya','btbti23083_tonya@banasthali.in','Pass@123','2394277','IT','IT A',2,4,'2023','B.Tech',0),('btbti23084','Sarah','btbti23084_sarah@banasthali.in','Pass@123','2340119','IT','IT A',2,4,'2023','B.Tech',0),('btbti23087','Tabitha','btbti23087_tabitha@banasthali.in','Pass@123','2396178','IT','IT A',2,4,'2023','B.Tech',0),('btbti23089','Cassidy','btbti23089_cassidy@banasthali.in','Pass@123','2341196','IT','IT A',2,4,'2023','B.Tech',0),('BTBTI23680','Vineeta Jadon','btbti23680_vineeta@banasthali.in','vineeta1234','2208749','IT','IT A',2,4,'2023','B.Tech',0),('BTBTI23682','Anshika Bhati','btbti23682_anshika@banasthali.in','anshika1234','2208742','IT','IT A',2,4,'2023','B.Tech',0);
/*!40000 ALTER TABLE `students` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `before_insert_students` BEFORE INSERT ON `students` FOR EACH ROW BEGIN
    DECLARE current_year_int INT;
    DECLARE current_semester_int INT;
    DECLARE batch_year INT;

    SET batch_year = CAST(NEW.batch AS UNSIGNED);
    

    IF MONTH(CURDATE()) BETWEEN 1 AND 6 THEN
        SET current_year_int = YEAR(CURDATE()) - batch_year;
    ELSE
        SET current_year_int = (YEAR(CURDATE()) - batch_year) + 1;
    END IF;

  
    IF MONTH(CURDATE()) BETWEEN 1 AND 6 THEN
        SET current_semester_int = (current_year_int * 2);
    ELSE
        SET current_semester_int = (current_year_int * 2) - 1;
    END IF;

   
    SET NEW.current_year = current_year_int;
    SET NEW.current_semester = current_semester_int;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `study_material`
--

DROP TABLE IF EXISTS `study_material`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `study_material` (
  `material_id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(100) NOT NULL,
  `description` text,
  `file_path` varchar(255) NOT NULL,
  `subject_id` varchar(20) NOT NULL,
  `section_name` varchar(50) DEFAULT NULL,
  `uploaded_by_teacher` varchar(20) NOT NULL,
  `uploaded_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`material_id`),
  KEY `subject_id` (`subject_id`),
  KEY `uploaded_by_teacher` (`uploaded_by_teacher`),
  KEY `study_material_ibfk_2` (`section_name`),
  CONSTRAINT `study_material_ibfk_1` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`subject_id`),
  CONSTRAINT `study_material_ibfk_2` FOREIGN KEY (`section_name`) REFERENCES `sections` (`section_name`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `study_material_ibfk_3` FOREIGN KEY (`uploaded_by_teacher`) REFERENCES `teachers` (`teacher_id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `study_material`
--

LOCK TABLES `study_material` WRITE;
/*!40000 ALTER TABLE `study_material` DISABLE KEYS */;
INSERT INTO `study_material` VALUES (10,'COA handout.pdf','Uploaded file for study material.','uploads/study_material/1739994233654_COA handout.pdf','CS 315','CS A','APJT01','2025-02-19 14:13:53'),(11,'COA handout.pdf','Uploaded file for study material.','uploads/study_material/1739994306623_COA handout.pdf','CS 315','CS A','APJT01','2025-02-19 14:15:06'),(12,'DCN_01.pdf','Uploaded file for study material.','uploads/study_material/1739994472020_DCN_01.pdf','CS 302','CS A','APJT01','2025-02-19 14:17:52'),(13,'cfp notes.pdf','Uploaded file for study material.','uploads/study_material/1740252508791_cfp notes.pdf','CS 315','CS A','APJT01','2025-02-22 13:58:28'),(14,'cfp.pdf','Uploaded file for study material.','uploads/study_material/1740311397997_cfp.pdf','CS 315','CS A','APJT01','2025-02-23 06:19:58'),(15,'TOC theory.pdf','Uploaded file for study material.','uploads/study_material/1743179655143_TOC theory.pdf','CS 315','CS A','APJT01','2025-03-28 11:04:15');
/*!40000 ALTER TABLE `study_material` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `subjects`
--

DROP TABLE IF EXISTS `subjects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `subjects` (
  `subject_id` varchar(20) NOT NULL,
  `name` varchar(100) NOT NULL,
  `branch` enum('CS','IT','Both') NOT NULL,
  `semester` int NOT NULL,
  `credit_point` int NOT NULL,
  `subject_type` enum('Main','Foundation') NOT NULL,
  `course` varchar(50) NOT NULL,
  PRIMARY KEY (`subject_id`),
  CONSTRAINT `subjects_chk_1` CHECK ((`semester` between 1 and 8))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subjects`
--

LOCK TABLES `subjects` WRITE;
/*!40000 ALTER TABLE `subjects` DISABLE KEYS */;
INSERT INTO `subjects` VALUES ('CS 001 ','Computer','Both',4,4,'Main','B.Tech'),('CS 207','Computer Organization and Architecture','Both',3,4,'Main','B.Tech'),('CS 209','Data Structures','Both',3,4,'Main','B.Tech'),('CS 212','Database Management Systems','Both',3,4,'Main','B.Tech'),('CS 213','Design and Analysis of Algorithms','Both',4,4,'Main','B.Tech'),('CS 214','Object Oriented Programming','Both',4,4,'Main','B.Tech'),('CS 216','Systems Programming','Both',4,4,'Main','B.Tech'),('CS 302','Data Communication and Networks','Both',5,4,'Main','B.Tech'),('CS 304','Java Programming','Both',5,4,'Main','B.Tech'),('CS 308','Operating Systems','Both',5,4,'Main','B.Tech'),('CS 313','Software Engineering','Both',4,4,'Main','B.Tech'),('CS 315','Theory of Computation','Both',6,4,'Main','B.Tech'),('ECO 307','Fundamentals of Economics','Both',6,3,'Main','B.Tech'),('ENGG 201','Structure and Properties of Materials','Both',3,4,'Main','B.Tech'),('ENGG 205','Basic Electronics','Both',4,4,'Main','B.Tech'),('MATH 209','Complex Variables','Both',4,4,'Main','B.Tech'),('MATH 210','Differential Equations','Both',3,4,'Main','B.Tech'),('MATH 211','Introduction to Discrete Mathematics','Both',3,4,'Main','B.Tech'),('MATH 311','Numerical Methods','Both',5,4,'Main','B.Tech'),('math12','Math','Both',4,4,'Main','B.Tech'),('MGMT 310','Principles of Management','Both',5,3,'Main','B.Tech'),('STAT 204','Probability and Statistical Methods','Both',6,4,'Main','B.Tech');
/*!40000 ALTER TABLE `subjects` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `teacher_subject_section`
--

DROP TABLE IF EXISTS `teacher_subject_section`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `teacher_subject_section` (
  `id` int NOT NULL AUTO_INCREMENT,
  `teacher_id` varchar(20) NOT NULL,
  `subject_id` varchar(20) NOT NULL,
  `section_name` varchar(50) DEFAULT NULL,
  `semester` int DEFAULT NULL,
  `current_year` int DEFAULT NULL,
  `course` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `teacher_id` (`teacher_id`),
  KEY `subject_id` (`subject_id`),
  KEY `teacher_subject_section_ibfk_3` (`section_name`),
  CONSTRAINT `teacher_subject_section_ibfk_1` FOREIGN KEY (`teacher_id`) REFERENCES `teachers` (`teacher_id`),
  CONSTRAINT `teacher_subject_section_ibfk_2` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`subject_id`),
  CONSTRAINT `teacher_subject_section_ibfk_3` FOREIGN KEY (`section_name`) REFERENCES `sections` (`section_name`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `teacher_subject_section`
--

LOCK TABLES `teacher_subject_section` WRITE;
/*!40000 ALTER TABLE `teacher_subject_section` DISABLE KEYS */;
INSERT INTO `teacher_subject_section` VALUES (10,'APJT01','CS 315','CS B',6,3,'B.Tech'),(11,'APJT01','CS 315','CS A',6,3,'B.Tech'),(17,'APJT03','ECO 307','CS A',6,3,'B.Tech'),(19,'NAVT04','STAT 204','CS A',6,3,'B.Tech');
/*!40000 ALTER TABLE `teacher_subject_section` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `before_insert_teacher_subject_section` BEFORE INSERT ON `teacher_subject_section` FOR EACH ROW BEGIN
    IF NEW.semester IN (1, 2) THEN 
        SET NEW.current_year = 1;
    ELSEIF NEW.semester IN (3, 4) THEN 
        SET NEW.current_year = 2;
    ELSEIF NEW.semester IN (5, 6) THEN 
        SET NEW.current_year = 3;
    ELSEIF NEW.semester IN (7, 8) THEN 
        SET NEW.current_year = 4;
    ELSE 
        SET NEW.current_year = NULL;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `before_update_teacher_subject_section` BEFORE UPDATE ON `teacher_subject_section` FOR EACH ROW BEGIN
    IF NEW.semester IN (1, 2) THEN 
        SET NEW.current_year = 1;
    ELSEIF NEW.semester IN (3, 4) THEN 
        SET NEW.current_year = 2;
    ELSEIF NEW.semester IN (5, 6) THEN 
        SET NEW.current_year = 3;
    ELSEIF NEW.semester IN (7, 8) THEN 
        SET NEW.current_year = 4;
    ELSE 
        SET NEW.current_year = NULL;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `teachers`
--

DROP TABLE IF EXISTS `teachers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `teachers` (
  `teacher_id` varchar(20) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(100) NOT NULL,
  `contact_number` varchar(15) DEFAULT NULL,
  `department` varchar(50) NOT NULL,
  `is_active` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`teacher_id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `teachers`
--

LOCK TABLES `teachers` WRITE;
/*!40000 ALTER TABLE `teachers` DISABLE KEYS */;
INSERT INTO `teachers` VALUES ('APJT01','Alice Smith','alice.smith@example.com','alice','9876543210','Apaji',0),('APJT03','Sunidhi chouhan','sunidhi.chouhan@example.com','sunidhi12344','98763524562','Apaji',0),('APJT08','Sunita Jain','sunita.jain@example.com','sunita12345','89374527365','Apaji',0),('APJT10','Neha Sharma','neha.sharma@example.com','9876123456','neha456','Apaji',0),('APJT15','Vikas Mehta','vikas.mehta@example.com','9876456789','vikas999','Apaji',0),('NAVT04','Manoj shah','manoj.shah@example.com','manoj4321','9837637457','Nav mandir',0),('NAVT07','Ravi Verma','ravi.verma@example.com','9876234567','ravi123','Nav mandir',0),('NAVT11','Pooja Patel','pooja.patel@example.com','9876567890','pooja777','Nav mandir',0),('SHKTO2','Bob Johnson','bob.johnson@example.com','securepass456','9876541234','Shiksha mandir',0),('SHKTO5','Kiran Gupta','kiran.gupta@example.com','9876345678','kiranpass','Shiksha mandir',0);
/*!40000 ALTER TABLE `teachers` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-04-15  3:46:39
