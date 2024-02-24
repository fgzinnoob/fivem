-- MySQL dump 10.13  Distrib 5.5.62, for Win64 (AMD64)
--
-- Host: localhost    Database: complexo
-- ------------------------------------------------------
-- Server version	5.5.5-10.4.22-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `garage`
--

DROP TABLE IF EXISTS `garage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `garage` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `x` varchar(20) NOT NULL,
  `y` varchar(20) NOT NULL,
  `z` varchar(20) NOT NULL,
  `tipo` varchar(20) NOT NULL,
  `perm` varchar(100) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `garage`
--

LOCK TABLES `garage` WRITE;
/*!40000 ALTER TABLE `garage` DISABLE KEYS */;
/*!40000 ALTER TABLE `garage` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `garage_spawn`
--

DROP TABLE IF EXISTS `garage_spawn`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `garage_spawn` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `idGaragem` bigint(20) NOT NULL,
  `x` varchar(20) NOT NULL,
  `y` varchar(20) NOT NULL,
  `z` varchar(20) NOT NULL,
  `h` varchar(20) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `garage_spawn`
--

LOCK TABLES `garage_spawn` WRITE;
/*!40000 ALTER TABLE `garage_spawn` DISABLE KEYS */;
/*!40000 ALTER TABLE `garage_spawn` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `garage_tipo_veh`
--

DROP TABLE IF EXISTS `garage_tipo_veh`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `garage_tipo_veh` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tipo` varchar(20) NOT NULL,
  `vehicle` varchar(100) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `garage_tipo_veh`
--

LOCK TABLES `garage_tipo_veh` WRITE;
/*!40000 ALTER TABLE `garage_tipo_veh` DISABLE KEYS */;
INSERT INTO `garage_tipo_veh` VALUES (1,'Police','riot'),(2,'Police','crownvictoria'),(3,'Police','dodgecharger2015'),(4,'Police','fordexplorer'),(5,'Police','fordtaurus'),(6,'Police','fordmustanggt'),(7,'Police','pol718'),(8,'Police','eliteclassx'),(9,'Police','rmodpolice'),(10,'Police','pbus'),(11,'Police','wrsxr'),(12,'Paramedic','ambulance'),(13,'Heliparamedic','helihp'),(14,'Helipolice','polmav'),(15,'Barco','tug'),(16,'Bike','bmx'),(17,'Driver','bus'),(18,'Boats','marquis'),(19,'Boats','seashark'),(20,'Boats','predator'),(21,'Boats','dinghy'),(22,'Transporter','stockade'),(23,'Lumberman','ratloader'),(24,'Caminhao','mule'),(25,'caminhoneiro','Packer'),(26,'Garbageman','trash'),(27,'Mecanico','flatbed3'),(28,'Mecanico','towtruck'),(29,'Taxi','taxi'),(30,'Trator','tractor2'),(31,'Ifood','nemesis');
/*!40000 ALTER TABLE `garage_tipo_veh` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2022-08-17  0:23:03
