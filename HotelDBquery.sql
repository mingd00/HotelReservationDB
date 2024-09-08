#데이터베이스 생성
CREATE DATABASE hotelRegistration;

#호텔 스키마 사용
USE hotelRegistration;

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

# 호텔 테이블
CREATE TABLE hotel (
  hotelId INT AUTO_INCREMENT ,
  hotelName VARCHAR(20) NOT NULL,
  hotelAddress VARCHAR(40) NOT NULL,
  hotelContact VARCHAR(20) NOT NULL,
  PRIMARY KEY (hotelId)
);

# 객실 테이블
CREATE TABLE room (
  roomNumber INT NOT NULL,
  hotelId  INT NOT NULL,  
  roomType VARCHAR(20) NOT NULL,
  price DECIMAL(10, 2) NOT NULL,
  maximum_number INT,
  PRIMARY KEY (roomNumber, hotelId),
  FOREIGN KEY (hotelId) REFERENCES 
				hotel(hotelId) ON DELETE CASCADE
);

#예약 테이블
CREATE TABLE reservations (
    reservation_id int auto_increment,
    customer_id int not null,
	roomNumber INT NOT NULL,
	hotelId  INT NOT NULL,
    reservation_date date not null,
    check_in_date date not null,
    check_out_date date not null,
    reservation_status varchar(20),
    reservation_validity boolean not null,
    refundable_date date ,
    num_people int not null,
    total_cost decimal(10, 2) not null,
    primary key (reservation_id),
    foreign key (customer_id) references customer(customer_id) on delete cascade,
    foreign key (roomNumber) references room(roomNumber) on delete cascade,
    foreign key (hotelId) references room(hotelId) on delete cascade
);
#결제 테이블
CREATE TABLE payment (
	payment_id int auto_increment,
    reservation_id int not null,
    payment_date date not null,
    payment_amount decimal(20,2) not null,
    payment_method varchar(10) not null,
    primary key (payment_id),
    foreign key (reservation_id) references
			reservations(reservation_id) on delete cascade
);

#취소 테이블
CREATE TABLE reservation_cancel(
	reservation_cancel_id int auto_increment,
    reservation_id int not null,
    cancellation_date date not null,
	reason text,
	primary key (reservation_cancel_id),
    foreign key (reservation_id) references 
			reservations(reservation_id) on delete cascade
);
#서비스 테이블
CREATE TABLE service (
    service_id int auto_increment,
	hotelId INT,
    price decimal(10,2) not null,
    service_option text,
    primary key(service_id, hotelId),
	foreign key (hotelId) references 
			hotel(hotelId) on delete cascade
);

#서비스 예약 테이블
CREATE TABLE reservation_service(
	  service_id int not null,
      reservation_id int not null,
      primary key(service_id, reservation_id ),
      foreign key(service_id) references 
				 service(service_id) on delete cascade,
      foreign key(reservation_id ) references 
				  reservations(reservation_id ) on delete cascade
      
);

#리뷰 테이블
CREATE TABLE review (
    review_id int auto_increment,
	reservation_id int not null,
    review_date date ,
    review_content text,
    primary key(review_id),
    foreign key (reservation_id) references 
			reservations(reservation_id) on delete cascade
);

#예제 데이터 삽입
-- 호텔 테이블
INSERT INTO hotel (hotelName, hotelAddress, hotelContact)
VALUES
  ('Hotel A', '123 Main St, Seoul', '+82 2-1234-5678'),
  ('Hotel B', '456 Elm St, Busan', '+82 51-9876-5432'),
  ('Hotel C', '789 Oak Ave, Incheon', '+82 32-5678-9012'),
  ('Hotel D', '321 Cherry Rd, Daegu', '+82 53-2345-6789'),
  ('Hotel E', '555 Pine Ave, Gwangju', '+82 62-9012-3456');

-- 객실 테이블
INSERT INTO room (hotelId, roomNumber, roomType, price, maximum_number)
VALUES
  (1, 101, 'Standard', 100000.00, 2),
  (1, 102, 'Deluxe', 150000.00, 2),
  (1, 103, 'Suite', 200000.00, 3),
  (1, 104, 'Superior', 120000.00, 3),
  (1, 105, 'Standard', 100000.00, 2),
  (2, 101, 'Deluxe', 180000.00, 3),
  (2, 102, 'Superior', 150000.00, 2),
  (2, 103, 'Standard', 120000.00, 2),
  (2, 104, 'Deluxe', 180000.00, 4),
  (2, 105, 'Superior', 150000.00, 2),
  (3, 101, 'Superior', 140000.00, 2),
  (3, 102, 'Standard', 110000.00, 2),
  (3, 103, 'Deluxe', 160000.00, 4),
  (3, 104, 'Superior', 140000.00, 3),
  (3, 105, 'Standard', 110000.00, 2),
  (4, 101, 'Deluxe', 160000.00, 4),
  (4, 102, 'Superior', 140000.00, 3),
  (4, 103, 'Standard', 110000.00, 2),
  (4, 104, 'Deluxe', 160000.00, 3),
  (4, 105, 'Superior', 140000.00, 2),
  (5, 101, 'Standard', 80000.00, 2),
  (5, 102, 'Deluxe', 120000.00, 3),
  (5, 103, 'Superior', 100000.00, 3),
  (5, 104, 'Standard', 80000.00, 2),
  (5, 105, 'Deluxe', 120000.00, 2);

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

-- 고객 테이블
INSERT INTO customer (name, gender, date_of_birth, phone_number, email, password)
VALUES
  ('Minji', 'Female', '2002-04-03', '010-1111-1111', 'm@example.com', 1234),
  ('Season', 'Female', '2002-01-01', '010-2222-2222', 's@example.com', 1234),
  ('Jisu', 'Male', '2000-08-25', '010-3333-3333', 'j@example.com', 1234),
  ('Donghyo', 'Male', '2000-12-12', '010-4444-4444', 'd@example.com', 1234);
  
-- 예약 테이블
INSERT INTO reservations (customer_id, hotelId, roomNumber, reservation_date, check_in_date, check_out_date, 
						  reservation_status, reservation_validity, refundable_date, num_people, total_cost) 
VALUES 
(1, 1, 101, '2023-03-20', '2023-04-01', '2023-04-02', 'unPaid', FALSE, '2023-03-31', 2, 100000),
(1, 2, 101, '2023-03-10', '2023-05-01', '2023-05-05', 'unPaid', FALSE, '2023-04-20', 2, 300000),
(2, 3, 102, '2023-04-01', '2023-04-17', '2023-04-18', 'unPaid', FALSE, '2023-04-12', 2, 180000);

-- 결제 테이블
INSERT INTO payment (reservation_id, payment_date, payment_amount, payment_method) 
VALUES 
(1, '2023-03-20', 100000, 'card'),
(2, '2023-03-10', 300000, 'point'),
(3, '2023-04-01', 180000, 'card');

-- 예약취소 테이블
INSERT INTO reservation_cancel (reservation_id, cancellation_date, reason) 
VALUES 
(1, '2023-03-29', 'for personal reasons'),
(2, '2023-03-20', 'for personal reasons');

-- 리뷰 테이블
INSERT INTO review (reservation_id, review_date, review_content) 
VALUES 
(1, '2023-04-01', 'good'),
(2, '2023-05-01', 'good'),
(3, '2023-04-10', 'bad');

-- 서비스 예약 테이블
INSERT INTO reservation_service (service_id, reservation_id) 
VALUES 
(1, 1),
(1, 3),
(2, 3);


-- 테이블 출력
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
from review;

select *
from reservation_service;
