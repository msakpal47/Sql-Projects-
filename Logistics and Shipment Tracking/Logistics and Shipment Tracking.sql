----Create a Sequence for auto-incrementing id:
CREATE SEQUENCE shipment_seq
START WITH 1
INCREMENT BY 1;



-- Create Shipment Table

CREATE TABLE Shipment (
    id NUMBER PRIMARY KEY,
    tracking_number VARCHAR2(50) NOT NULL UNIQUE,
    origin VARCHAR2(100) NOT NULL,
    destination VARCHAR2(100) NOT NULL,
    status VARCHAR2(50) DEFAULT 'In Transit' NOT NULL,
    estimated_delivery DATE NOT NULL
);


----Create a Trigger for auto-incrementing id:

CREATE OR REPLACE TRIGGER shipment_trigger
BEFORE INSERT ON Shipment
FOR EACH ROW
BEGIN
    IF :new.id IS NULL THEN
        SELECT shipment_seq.NEXTVAL INTO :new.id FROM dual;
    END IF;
END;



----Create a Sequence for auto-incrementing id:
CREATE SEQUENCE Customer_seq
START WITH 1
INCREMENT BY 1;


-- Create Customer Table
CREATE TABLE Customer (
    id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    phone_number VARCHAR(15)
);

----Create a Trigger for auto-incrementing id:

CREATE OR REPLACE TRIGGER  Customer_trigger
BEFORE INSERT ON  Customer
FOR EACH ROW
BEGIN
    IF :new.id IS NULL THEN
        SELECT  Customer_seq.NEXTVAL INTO :new.id FROM dual;
    END IF;
END;


----Create a Sequence for auto-incrementing id:
CREATE SEQUENCE ShipmentTracking_seq
START WITH 1
INCREMENT BY 1;


-- Create Shipment Tracking Table


CREATE TABLE ShipmentTracking (
    id NUMBER PRIMARY KEY,
    shipment_id NUMBER,
    status_update VARCHAR2(100) NOT NULL,
    update_time TIMESTAMP NOT NULL,
    location VARCHAR2(100),
    FOREIGN KEY (shipment_id) REFERENCES Shipment(id)
);

----Create a Trigger for auto-incrementing id:

CREATE OR REPLACE TRIGGER  ShipmentTracking_trigger
BEFORE INSERT ON  ShipmentTracking
FOR EACH ROW
BEGIN
    IF :new.id IS NULL THEN
        SELECT  ShipmentTracking_seq.NEXTVAL INTO :new.id FROM dual;
    END IF;
END;


----Sample Data Insertion:

-- Insert into Shipment
INSERT INTO Shipment (tracking_number, origin, destination, status, estimated_delivery)
VALUES ('TRK12345', 'New York', 'Los Angeles', 'In Transit', TO_DATE('2023-10-25', 'YYYY-MM-DD'));

INSERT INTO Shipment (tracking_number, origin, destination, status, estimated_delivery)
VALUES ('TRK67890', 'Chicago', 'Houston', 'Dispatched', TO_DATE('2023-10-28', 'YYYY-MM-DD'));

-- Insert into ShipmentTracking
INSERT INTO ShipmentTracking (shipment_id, status_update, update_time, location)
VALUES (1, 'Dispatched', TO_TIMESTAMP('2023-10-10 09:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'New York');

INSERT INTO ShipmentTracking (shipment_id, status_update, update_time, location)
VALUES (1, 'In Transit', TO_TIMESTAMP('2023-10-12 12:30:00', 'YYYY-MM-DD HH24:MI:SS'), 'Philadelphia');

---Shipment Tracking Queries:---

-- Get all shipments
SELECT * FROM Shipment;

-- Get shipment status updates
SELECT S.tracking_number, ST.status_update, ST.update_time, ST.location
FROM ShipmentTracking ST
JOIN Shipment S ON ST.shipment_id = S.id
WHERE S.tracking_number = 'TRK12345';

-- Get shipments that are still in transit
SELECT * FROM Shipment WHERE status = 'In Transit';

-- Update shipment status
UPDATE Shipment SET status = 'Delivered' WHERE tracking_number = 'TRK12345';

