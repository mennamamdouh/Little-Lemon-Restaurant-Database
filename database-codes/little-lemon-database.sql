-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema little_lemon_db
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema little_lemon_db
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `little_lemon_db` DEFAULT CHARACTER SET utf8 ;
USE `little_lemon_db` ;

-- -----------------------------------------------------
-- Table `little_lemon_db`.`Customers`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `little_lemon_db`.`Customers` (
  `Customer_ID` INT NOT NULL,
  `Full_Name` VARCHAR(255) NOT NULL,
  `Phone_Number` VARCHAR(13) NOT NULL,
  PRIMARY KEY (`Customer_ID`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `little_lemon_db`.`Staff`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `little_lemon_db`.`Staff` (
  `Staff_ID` INT NOT NULL,
  `Name` VARCHAR(100) NOT NULL,
  `Role` VARCHAR(100) NOT NULL,
  `Salary` INT NOT NULL,
  `Address` VARCHAR(255) NOT NULL,
  `Contact_Number` VARCHAR(13) NOT NULL,
  `Email` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`Staff_ID`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `little_lemon_db`.`Bookings`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `little_lemon_db`.`Bookings` (
  `Booking_ID` INT NOT NULL,
  `Booking_Date` DATETIME NOT NULL,
  `Customer_ID` INT NOT NULL,
  `Table_number` INT NOT NULL,
  `Number_of_Persons` INT NOT NULL,
  `Staff_ID` INT NOT NULL,
  PRIMARY KEY (`Booking_ID`),
  INDEX `FK_customers_in_bookings_idx` (`Customer_ID` ASC) VISIBLE,
  INDEX `FK_staff_in_bookings_idx` (`Staff_ID` ASC) VISIBLE,
  CONSTRAINT `FK_customers_in_bookings`
    FOREIGN KEY (`Customer_ID`)
    REFERENCES `little_lemon_db`.`Customers` (`Customer_ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `FK_staff_in_bookings`
    FOREIGN KEY (`Staff_ID`)
    REFERENCES `little_lemon_db`.`Staff` (`Staff_ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `little_lemon_db`.`Orders`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `little_lemon_db`.`Orders` (
  `Order_ID` INT NOT NULL,
  `Table_number` INT NOT NULL,
  `Order_Date` DATETIME NOT NULL,
  `Total_Cost` DECIMAL NOT NULL,
  `Booking_ID` INT NOT NULL,
  PRIMARY KEY (`Order_ID`, `Table_number`),
  INDEX `FK_booking_in_orders_idx` (`Booking_ID` ASC) VISIBLE,
  CONSTRAINT `FK_booking_in_orders`
    FOREIGN KEY (`Booking_ID`)
    REFERENCES `little_lemon_db`.`Bookings` (`Booking_ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `little_lemon_db`.`Orders_Delivery_Status`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `little_lemon_db`.`Orders_Delivery_Status` (
  `Order_ID` INT NOT NULL,
  `Delivery_Date` DATETIME NOT NULL,
  `Delivery_Status` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`Order_ID`),
  CONSTRAINT `FK_order_status_in_orders`
    FOREIGN KEY (`Order_ID`)
    REFERENCES `little_lemon_db`.`Orders` (`Order_ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `little_lemon_db`.`Menu`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `little_lemon_db`.`Menu` (
  `Item_ID` INT NOT NULL,
  `Name` VARCHAR(45) NOT NULL,
  `Category` VARCHAR(45) NOT NULL,
  `Cuisine` VARCHAR(45) NOT NULL,
  `Price` INT NOT NULL,
  PRIMARY KEY (`Item_ID`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `little_lemon_db`.`Orders_Details`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `little_lemon_db`.`Orders_Details` (
  `OrderID` INT NOT NULL,
  `Item_ID` INT NOT NULL,
  `Quantity` INT NOT NULL,
  PRIMARY KEY (`OrderID`, `Item_ID`),
  INDEX `FK_items_in_menu_idx` (`Item_ID` ASC) VISIBLE,
  CONSTRAINT `FK_items_in_menu`
    FOREIGN KEY (`Item_ID`)
    REFERENCES `little_lemon_db`.`Menu` (`Item_ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `FK_order_detail_in_orders`
    FOREIGN KEY (`OrderID`)
    REFERENCES `little_lemon_db`.`Orders` (`Order_ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
