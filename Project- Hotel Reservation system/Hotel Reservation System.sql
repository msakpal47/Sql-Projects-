
---Create Room Table 

CREATE SEQUENCE room_seq
START WITH 1
INCREMENT BY 1;


CREATE TABLE Room (
    id NUMBER PRIMARY KEY,
    room_number VARCHAR2(10) NOT NULL,
    room_type VARCHAR2(50) NOT NULL,
    price NUMBER(10, 2) NOT NULL,
    availability_status VARCHAR2(10) DEFAULT 'Available' NOT NULL
);

----- Create a Trigger (to auto-increment the id column):---

----Explanation:
----Sequence: Generates the next value for the id column each time a new row is inserted.
----Trigger: Automatically inserts the next value from the sequence into the id column before the insert operation.----

CREATE OR REPLACE TRIGGER room_trigger
BEFORE INSERT ON Room
FOR EACH ROW
BEGIN
    IF :new.id IS NULL THEN
        SELECT room_seq.NEXTVAL INTO :new.id FROM dual;
    END IF;
END;

---Create Guest Table---

CREATE SEQUENCE guest_seq
START WITH 1
INCREMENT BY 1;


CREATE TABLE Guest (
    id NUMBER PRIMARY KEY,
    name VARCHAR2(100) NOT NULL,
    email VARCHAR2(100),
    phone_number VARCHAR2(15)
);

---Create a Trigger (to auto-increment the id column):

CREATE OR REPLACE TRIGGER guest_trigger
BEFORE INSERT ON Guest
FOR EACH ROW
BEGIN
    IF :new.id IS NULL THEN
        SELECT guest_seq.NEXTVAL INTO :new.id FROM dual;
    END IF;
END;


-- Create Reservation Table

CREATE SEQUENCE Reservation_seq
START WITH 1
INCREMENT BY 1;



CREATE TABLE Reservation (
    id NUMBER PRIMARY KEY,
    guest_id NUMBER,
    room_id NUMBER,
    check_in DATE NOT NULL,
    check_out DATE NOT NULL,
    total_price NUMBER(10, 2) NOT NULL,
    reservation_status VARCHAR2(20) DEFAULT 'Booked' NOT NULL,
    FOREIGN KEY (guest_id) REFERENCES Guest(id),
    FOREIGN KEY (room_id) REFERENCES Room(id)
);


----Create a Trigger (to auto-increment the id column):

CREATE OR REPLACE TRIGGER reservation_trigger
BEFORE INSERT ON Reservation
FOR EACH ROW
BEGIN
    IF :new.id IS NULL THEN
        SELECT reservation_seq.NEXTVAL INTO :new.id FROM dual;
    END IF;
END;



-- Insert into Room
INSERT INTO Room (room_number, room_type, price, availability_status)
VALUES ('101', 'Deluxe', 120.00, 'Available');

INSERT INTO Room (room_number, room_type, price, availability_status)
VALUES ('102', 'Suite', 250.00, 'Available');

INSERT INTO Room (room_number, room_type, price, availability_status)
VALUES ('103', 'Standard', 80.00, 'Occupied');


-- Insert into Guest
INSERT INTO Guest (name, email, phone_number)
VALUES ('John Doe', 'john.doe@example.com', '1234567890');

INSERT INTO Guest (name, email,phone_number)
VALUES('Jane Smith', 'jane.smith@example.com', '0987654321');

-- Insert into Reservation
INSERT INTO Reservation (guest_id, room_id, check_in, check_out, total_price)
VALUES (1, 1, TO_DATE('2023-10-15', 'YYYY-MM-DD'), TO_DATE('2023-10-20', 'YYYY-MM-DD'), 600.00);

INSERT INTO Reservation (guest_id, room_id, check_in, check_out, total_price)
VALUES (2, 2, TO_DATE('2023-10-18', 'YYYY-MM-DD'), TO_DATE('2023-10-25', 'YYYY-MM-DD'), 1750.00);


-----Reservation Management Queries:

-- Get all reservations
SELECT G.name AS GuestName, R.room_number, RV.check_in, RV.check_out, RV.total_price, RV.reservation_status
FROM Reservation RV
JOIN Guest G ON RV.guest_id = G.id
JOIN Room R ON RV.room_id = R.id;

-- Get available rooms
SELECT * FROM Room WHERE availability_status = 'Available';

-- Update room availability after booking
UPDATE Room SET availability_status = 'Occupied' WHERE id = 1;

select * from Guest;
