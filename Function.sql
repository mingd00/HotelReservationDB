#데이터베이스 생성
DROP schema IF exists hotelRegistration;
create schema hotelRegistration;

#데이터베이스 삭제

#호텔 스키마 사용
USE hotelRegistration;
SET GLOBAL log_bin_trust_function_creators = 1;

delimiter $$
CREATE FUNCTION `total_Price`(res_id INT) RETURNS int
BEGIN
    DECLARE total INTEGER;
    DECLARE hotelNum INTEGER;
    DECLARE servicePrice INTEGER;
    DECLARE hotelPrice INTEGER;
    SET total = 0;

SELECT price INTO servicePrice
FROM service
WHERE service.service_id = (SELECT service_id 
                             FROM reservation_service 
                             WHERE reservation_service.reservation_id = res_id);

SELECT hotelId INTO hotelNum 
FROM service
WHERE service.service_id = (SELECT service_id 
                             FROM reservation_service 
                             WHERE reservation_service.reservation_id = res_id);

SELECT price INTO hotelPrice 
FROM room
WHERE room.hotelId = hotelNum 
      AND room.roomId = (SELECT roomId 
                            FROM reservations 
                            WHERE reservations.reservation_id = res_id);

SET total = servicePrice + hotelPrice;
RETURN total;
END$$
#테이블 생성
#고객 테이블
CREATE TABLE customer(
	customer_id int auto_increment,
    name varchar(15) not null,
    gender varchar(20) ,
    date_of_birth date , 
    phone_number varchar(15) not null,
    email varchar(40) ,
    password varchar(25) not null,
    primary key (customer_id)
);

CREATE TABLE hotel (
  hotelId INT AUTO_INCREMENT ,
  hotelName VARCHAR(20) NOT NULL,
  hotelAddress VARCHAR(40) NOT NULL,
  hotelContact VARCHAR(20) NOT NULL,
  PRIMARY KEY (hotelId)
);

-- 호텔의 약한개체
CREATE TABLE room (
  roomId INT AUTO_INCREMENT,
  hotelId  INT NOT NULL,
  roomNumber INT NOT NULL,
  roomType VARCHAR(20) NOT NULL,
  price DECIMAL(10, 2) NOT NULL,
  PRIMARY KEY (roomId, hotelId),
  FOREIGN KEY (hotelId) REFERENCES hotel(hotelId) ON DELETE CASCADE
);

#예약 테이블
CREATE TABLE reservations (
    reservation_id int auto_increment,
    customer_id int not null,
	roomId int not null,
    reservation_date date not null,
    check_in_date date not null,
    check_out_date date not null,
    reservation_status varchar(20),
    reservation_effectiveness boolean not null,
    refundable_date date ,
    num_people int not null,
    total_cost decimal(10, 2) not null,
    primary key (reservation_id),
    foreign key (customer_id) references customer(customer_id) on delete cascade,
    foreign key (roomId) references room(roomId) on delete cascade
);
#결제 테이블
CREATE TABLE payment (
	payment_id int auto_increment,
    reservation_id int not null,
    payment_date date not null,
    payment_amount decimal(20,2) not null,
    payment_method varchar(10) not null,
    primary key (payment_id),
    foreign key (reservation_id) references reservations(reservation_id) on delete cascade
);

#결제취소 테이블
CREATE TABLE reservation_cancel(
	customer_id int not null,
    reservation_id int not null,
    cancellation_date date not null,
	reason text,
	primary key (customer_id, reservation_id),
    foreign key (customer_id) references customer(customer_id) on delete cascade,
    foreign key (reservation_id) references reservations(reservation_id) on delete cascade
);
#서비스 테이블
CREATE TABLE service (
    service_id int not null auto_increment,
	hotelId INT not null,
    price decimal(10,2) not null,
    service_option text,
    primary key(service_id, hotelId),
	foreign key (hotelId) references hotel(hotelId) on delete cascade
);

#서비스 예약 테이블
CREATE TABLE reservation_service(
	  service_id int not null,
      reservation_id int not null,
      primary key(service_id, reservation_id ),
      foreign key(service_id) references service(service_id) on delete cascade,
      foreign key(reservation_id ) references reservations(reservation_id ) on delete cascade
      
);


#리뷰 테이블
CREATE TABLE review (
    review_id int not null auto_increment,
	reservation_id int not null,
    review_date date ,
    review_content text,
    primary key(review_id, reservation_id),
    foreign key (reservation_id) references reservations(reservation_id) on delete cascade
);

#예제 데이터 삽입
-- 호텔 테이블
INSERT INTO customer (name, gender, date_of_birth, phone_number, email, password) 
VALUES 
('Minji', 'Female', '2002-04-03', '010-1111-1111', 'minji@example.com', 'password123'),
('Season', 'Female', '1990-01-01', '010-2222-2222', 'season@example.com', 'password123'),
('Jisoo', 'Male', '1990-01-02', '010-3333-3333', 'jisoo@example.com', 'password123'),
('Donghyo', 'Male', '1990-01-03', '010-4444-4444', 'donghyo@example.com', 'password123');

INSERT INTO hotel (hotelName, hotelAddress, hotelContact)
VALUES
  ('Hotel A', '123 Main St, Seoul', '+82 2-1234-5678'),
  ('Hotel B', '456 Elm St, Busan', '+82 51-9876-5432'),
  ('Hotel C', '789 Oak Ave, Incheon', '+82 32-5678-9012'),
  ('Hotel D', '321 Cherry Rd, Daegu', '+82 53-2345-6789'),
  ('Hotel E', '555 Pine Ave, Gwangju', '+82 62-9012-3456');

-- 호텔 정보 테이블
INSERT INTO room (hotelId, roomNumber, roomType, price)
VALUES
  (1, 101, 'Standard', 100000.00),
  (1, 102, 'Deluxe', 150000.00),
  (1, 103, 'Suite', 200000.00),
  (1, 104, 'Superior', 120000.00),
  (1, 105, 'Standard', 100000.00),
  (2, 101, 'Deluxe', 180000.00),
  (2, 102, 'Superior', 150000.00),
  (2, 103, 'Standard', 120000.00),
  (2, 104, 'Deluxe', 180000.00),
  (2, 105, 'Superior', 150000.00),
  (3, 101, 'Superior', 140000.00),
  (3, 102, 'Standard', 110000.00),
  (3, 103, 'Deluxe', 160000.00),
  (3, 104, 'Superior', 140000.00),
  (3, 105, 'Standard', 110000.00),
  (4, 101, 'Deluxe', 160000.00),
  (4, 102, 'Superior', 140000.00),
  (4, 103, 'Standard', 110000.00),
  (4, 104, 'Deluxe', 160000.00),
  (4, 105, 'Superior', 140000.00),
  (5, 101, 'Standard', 80000.00),
  (5, 102, 'Deluxe', 120000.00),
  (5, 103, 'Superior', 100000.00),
  (5, 104, 'Standard', 80000.00),
  (5, 105, 'Deluxe', 120000.00);

-- 서비스 테이블
INSERT INTO service (hotelId, price, service_option)
VALUES
  (1, 100.00, 'BBQ'),
  (1, 150.00, 'Minibar'),
  (1, 200.00, 'Laundry and dry cleaning'),
  (1, 250.00, 'Parking'),
  (1, 300.00, 'Fitness center'),
  (2, 120.00, 'Spa'),
  (2, 180.00, 'BBQ'),
  (2, 220.00, 'Minibar'),
  (2, 270.00, 'Laundry and dry cleaning'),
  (2, 320.00, 'Parking'),
  (2, 80.00, 'Fitness center'),
  (3, 140.00, 'Spa'),
  (3, 190.00, 'BBQ'),
  (3, 230.00, 'Minibar'),
  (3, 280.00, 'Laundry and dry cleaning'),
  (3, 330.00, 'Parking'),
  (4, 110.00, 'Fitness center'),
  (4, 170.00, 'Spa'),
  (4, 210.00, 'BBQ'),
  (4, 260.00, 'Minibar'),
  (4, 310.00, 'Laundry and dry cleaning'),
  (4, 360.00, 'Parking'),
  (5, 130.00, 'Fitness center'),
  (5, 190.00, 'Spa'),
  (5, 230.00, 'BBQ'),
  (5, 280.00, 'Minibar'),
  (5, 330.00, 'Laundry and dry cleaning'),
  (5, 380.00, 'Parking');
INSERT INTO reservations (customer_id,roomId,reservation_date,check_in_date,check_out_date,reservation_status,reservation_effectiveness,refundable_date,num_people,total_cost)
VALUES
(1,5,'2023-04-01','2023-04-03','2023-04-05','숙박 전',true,'2023-03-31',5,0),
(2,3,'2023-04-01','2023-04-03','2023-04-05','숙박 전',true,'2023-03-31',5,0),
(3,4,'2023-04-01','2023-04-03','2023-04-05','숙박 전',true,'2023-03-31',5,0),
(2,6,'2023-04-01','2023-04-03','2023-04-05','숙박 전',true,'2023-03-31',5,0);
INSERT INTO reservation_service (service_id,reservation_id)
VALUES
(8,4),
(2,3),
(3,1),
(4,2);
set sql_safe_updates=0;
UPDATE reservations SET total_cost = (select hotelregistration.total_Price(reservation_id)) WHERE total_cost = 0;

INSERT INTO payment (reservation_id, payment_amount, payment_date, payment_method)
VALUES
(1,(SELECT hotelregistration.total_Price(1)),'2023-03-20','card'),
(2,(SELECT hotelregistration.total_Price(2)),'2023-03-10','card'),
(3,(SELECT hotelregistration.total_Price(3)),'2023-04-01','point'),
(4,(SELECT hotelregistration.total_Price(4)),'2023-03-10','card');

#테이블 출력
select *
from customer;

select *
from hotel;

select *
from room;

select *
from service;

select *
from reservations;

select *
from payment;

select *
from reservation_cancel;

select *
from reservation_service;

select *
from review;