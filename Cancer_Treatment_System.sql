USE CancerTreatmentSystem;

-- Table Payment
CREATE TABLE [Payment]
(
 [paymentID] Int  NOT NULL PRIMARY KEY,
 [paymentAmount] Int NOT NULL,
 [paymentType] Varchar(15) NOT NULL,
 [paymentDate] Date NOT NULL,
 [status] Bit NOT NULL,
 [invoiceId] Int NOT NULL REFERENCES Invoice(InvoiceID),
 [patientId] Int NOT NULL REFERENCES Patient(PatientID),
 [insuranceId] Int NOT NULL REFERENCES Insurance(InsuranceID)
)
go


-- Table Invoice

CREATE TABLE [Invoice]
(
 [invoiceID] Int NOT NULL PRIMARY KEY,
 [appointmentBill] Int NOT NULL,
 [balance] Int NOT NULL,
 [creditDate] Date NOT NULL,
 [dueDate] Date NOT NULL,
 [patientId] Int NOT NULL REFERENCES Patient(PatientID),
 [appointmentId] Int NOT NULL REFERENCES PatientAppointment(appointmentID) ,
 [status] Bit NOT NULL
)
go

--Table Insurance

CREATE TABLE [Insurance]
(
 [insuranceID] Int  NOT NULL PRIMARY KEY,
 [policyId] Varchar(15) NOT NULL,
 [policyStartDate] Date NOT NULL,
 [policyEndDate] Date NOT NULL,
 [status] Bit NOT NULL,
 [amountCovered] Int NOT NULL,
 [patientID] Int NOT NULL REFERENCES Patient(PatientID),
 [companyID] Int NOT NULL REFERENCES InsuranceCompany(companyID)
)
go


--Table Insurance Company

CREATE TABLE [InsuranceCompany]
(
 [companyID] Int  NOT NULL PRIMARY KEY,
 [companyName] Varchar(20) NOT NULL,
 [companyContact] CHAR(10) NOT NULL
)
go
select * from InsuranceCompany 

ALTER TABLE InsuranceCompany ALTER COLUMN companyContact CHAR(10)




--Table Inventory

CREATE TABLE [Inventory]
(
 [inventoryID] Int  NOT NULL PRIMARY KEY,
 [inventoryName] Varchar(20) NOT NULL,
 [installedDate] Date NOT NULL,
 [warrantyYears] INT NOT NULL,
 [orderID] INT NOT NULL,
 [vendorDetails] Varchar(30) NULL,
 [locationID] INT NOT NULL  REFERENCES Location(locationID)
)
go

--Table Location

CREATE TABLE [Location]
(
 [locationID] INT NOT NULL PRIMARY KEY,
 [facilityName] Varchar(30) NOT NULL,
 [street] Varchar(30) NOT NULL,
 [city] Varchar(15) NOT NULL,
 [state] Char(2) NOT NULL,
 [zipCode] Char(5) NOT NULL CHECK (zipCode like '[0-9][0-9][0-9][0-9][0-9]'),
 [contactNumber] Char(10) NOT NULL CHECK (contactNumber like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
)
go

--Table Room

CREATE TABLE [Room]
(
 [roomID] Int NOT NULL PRIMARY KEY,
 [roomNumber] Int NOT NULL,
 [floorNumber] Int NOT NULL,
  [roomType] varchar(30) NOT NULL,
 [available] Bit NOT NULL,
 [locationID] Int NOT NULL REFERENCES Location (locationID)
)
go

-- Table Patient Room Relation

CREATE TABLE [PatientRoomRelation]
(
 [patientRoomID] Int NOT NULL PRIMARY KEY,
 [patientID] INT NOT NULL REFERENCES Patient(patientID),
 [roomID] INT NOT NULL REFERENCES Room(roomID),
 [admitDate] Date NOT NULL,
 [dischargeDate] Date NOT NULL
)
go


--Table Drug Catalogue

CREATE TABLE [DrugCatalogue]
(
 [drugId] Int NOT NULL PRIMARY KEY,
 [drugName] Varchar(20) NOT NULL,
 [amountOrdered] Int NOT NULL,
 [orderId] Varchar(20) NOT NULL,
 [expiryDate] Date NOT NULL,
 [locationId] Int NOT NULL REFERENCES Location(locationID)
)
go

--Table Patient Drug Relation

CREATE TABLE [PatientDrugRelation]
(
 [patientdDrugID] Int NOT NULL PRIMARY KEY,
 [drugID] Int NOT NULL REFERENCES DrugCatalogue(drugID),
 [patientID] Int NOT NULL REFERENCES Patient(patientID),
 [purchaseDate] Date NOT NULL,
 [quantity] Int 
)
go

--Encryption on Payment

--CREATE MASTER KEY

CREATE MASTER KEY ENCRYPTION 
BY PASSWORD = 'Payment2020$';

 -- CREATE CERTIFICATE

CREATE CERTIFICATE paymentcert

WITH SUBJECT = 'User Payment';


-- CREATE SYMMETRIC KEY

CREATE SYMMETRIC KEY payment_Key_1

WITH ALGORITHM = AES_256  -- it can be AES_128,AES_192,DES etc

ENCRYPTION BY CERTIFICATE paymentcert;

--Encryption


ALTER TABLE Payment ADD paymentamount_encrypt varbinary(MAX),paymentType_encrypt varbinary(MAX),paymentDate_encrypt varbinary(MAX);

OPEN SYMMETRIC KEY payment_Key_1 DECRYPTION BY CERTIFICATE paymentcert;


UPDATE Payment
        SET paymentamount_encrypt = EncryptByKey (Key_GUID('payment_Key_1'),CONVERT(varchar(10), paymentAmount)),
		    paymentType_encrypt = EncryptByKey (Key_GUID('payment_Key_1'),CONVERT(varchar(10), paymentType)),
			paymentDate_encrypt = EncryptByKey (Key_GUID('payment_Key_1'),CONVERT(varchar(10), paymentDate))
        FROM Payment;
        GO



-- Close SYMMETRIC KEY

CLOSE SYMMETRIC KEY payment_Key_1;
            GO

--Verify the records in Payment Table
SELECT * FROM Payment

--Let's remove the old column paymentID

 ALTER TABLE Payment DROP COLUMN paymentAmount,paymentType,paymentDate


 --- Decryption

OPEN SYMMETRIC KEY payment_Key_1

DECRYPTION BY CERTIFICATE paymentcert;


select patientId, SSN as 'actual SSN',encryptedssn as 'encrypted ssn',CONVERT(varchar(30), DecryptByKey(encryptedssn)) as 'decrypted ssn' from SSN;


SELECT paymentamount_encrypt, paymentType_encrypt, paymentDate_encrypt,
            CONVERT(varchar, DecryptByKey(paymentamount_encrypt)) AS 'Decrypted Payment amount',
			CONVERT(varchar, DecryptByKey(paymentType_encrypt)) AS 'Decrypted Payment Type ',
			CONVERT(varchar, DecryptByKey(paymentDate_encrypt)) AS 'Decrypted Payment Date'
            FROM Payment;

-- Close SYMMETRIC KEY
CLOSE SYMMETRIC KEY payment_Key_1;
            GO

select * from Payment