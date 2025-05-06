use pharmacy_portal_db;
create table Medications (
medicationId INT NOT NULL UNIQUE AUTO_INCREMENT,
medicationName VARCHAR(45) NOT NULL,
dosage VARCHAR(45) NOT NULL,
manufacturer VARCHAR(100),
Primary Key (medicationId)
);
create table Prescriptions (
PrescriptionId INT NOT NULL UNIQUE AUTO_INCREMENT,
userId INT NOT NULL,
medicationId INT NOT NULL,
prescribedDate DATETIME NOT NULL,
dosageInstructions VARCHAR(200),
quantity INT NOT NULL,
refillCount INT DEFAULT 0,
Primary Key (prescriptionId),
Foreign Key (userId) REFERENCES Users(userId),
Foreign Key (medicationId) REFERENCES Medications(medicationId)
);
create table Inventory (
inventoryId INT NOT NULL UNIQUE AUTO_INCREMENT,
medicationId INT NOT NULL UNIQUE,
quantityAvailable INT NOT NULL,
lastUpdated DATETIME NOT NULL,
Primary Key (inventoryId),
Foreign Key (medicationId) REFERENCES Medications(medicationId)
);
create table Sales (
saleId INT NOT NULL UNIQUE AUTO_INCREMENT,
prescriptionId INT NOT NULL,
saleDate DATETIME NOT NULL,
quantitySold INT NOT NULL,
saleAmount DECIMAL(10,2) NOT NULL,
Primary Key (saleId),
Foreign Key (prescriptionId) REFERENCES Prescriptions(prescriptionId)
);
DELIMITER //
CREATE PROCEDURE AddOrUpdateUser(
    IN p_userId INT,
    IN p_userName VARCHAR(45),
    IN p_contactInfo VARCHAR(200),
    IN p_userType ENUM('pharmacist', 'patient')
)
BEGIN
    IF EXISTS (SELECT 1 FROM Users WHERE userId = p_userId) THEN
        UPDATE Users SET userName = p_userName, contactInfo = p_contactInfo, userType = p_userType WHERE userId = p_userId;
    ELSE
        INSERT INTO Users (userName, contactInfo, userType) VALUES (p_userName, p_contactInfo, p_userType);
    END IF;
END //
DELIMITER ;
DELIMITER //
CREATE PROCEDURE ProcessSale(
    IN p_prescriptionId INT,
    IN p_quantitySold INT
)
BEGIN
    DECLARE v_medicationId INT;
    
    SELECT medicationId INTO v_medicationId FROM Prescriptions WHERE prescriptionId = p_prescriptionId;
    
    UPDATE Inventory SET quantityAvailable = quantityAvailable - p_quantitySold WHERE medicationId = v_medicationId;
    
    INSERT INTO Sales (prescriptionId, saleDate, quantitySold, saleAmount)
    VALUES (p_prescriptionId, NOW(), p_quantitySold, (p_quantitySold * 15.00)); -- Using a unit price of $15
END //
DELIMITER ;
CREATE VIEW MedicationInventoryView AS
SELECT Medications.medicationName, Medications.dosage, Medications.manufacturer, Inventory.quantityAvailable
FROM Medications
JOIN Inventory ON Medications.medicationId = Inventory.medicationId;
DELIMITER //
CREATE TRIGGER AfterPrescriptionInsert
AFTER INSERT ON Prescriptions
FOR EACH ROW
BEGIN
    UPDATE Inventory SET quantityAvailable = quantityAvailable - NEW.quantity WHERE medicationId = NEW.medicationId;
END //
DELIMITER ;
INSERT INTO Users (userName, contactInfo, userType) VALUES
('Chad', 'chad@pharm.com', 'pharmacist'),
('Nia', 'nia@pharm.com', 'patient'),
('Ben', 'ben@pharm.com', 'patient');
INSERT INTO Medications (medicationName, dosage, manufacturer) VALUES
('Ibuprofen', '35mg', 'CVS'),
('Amoxicillin', '70mg', 'Pharma'),
('Cetirizine', '10mg', 'Klarma');
INSERT INTO Inventory (medicationId, quantityAvailable, lastUpdated) VALUES
(1, 30, NOW()),
(2, 25, NOW()),
(3, 45, NOW());
INSERT INTO Prescriptions (userId, medicationId, prescribedDate, dosageInstructions, quantity, refillCount) VALUES
(2, 1, NOW(), 'Have 2 each day', 20, 4),
(3, 2, NOW(), 'Have 3 each day', 15, 5),
(3, 3, NOW(), 'Have 1 each day', 30, 3);
INSERT INTO Sales (prescriptionId, saleDate, quantitySold, saleAmount) VALUES
(1, NOW(), 17, 200.00),
(2, NOW(), 26, 100.00),
(3, NOW(), 7, 300.00);