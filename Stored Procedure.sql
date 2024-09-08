#stored procedure 
-- 호텔 예약 가능여부 확인 후 예약 테이블에 정보 추가
-- 처음 받아야 할 값 : 호텔 이름, 방 타입, 예약 날짜, 체크인 날짜, 체크아웃 날짜, 고객id, 인원수

DELIMITER //

CREATE PROCEDURE CheckAvailabilityAndAddUser(
    -- IN: 호텔 정보
    IN p_hotel_name VARCHAR(20), 
      -- IN: 방 정보
	IN p_room_type VARCHAR(20),
    -- IN: 예약날짜 정보
    IN p_reservation_date DATE,
    -- IN: 체크인, 체크아웃 정보
    IN p_check_in_date DATE,
    IN p_check_out_date DATE,
    -- IN: 고객 아이디
    IN p_customer_id INT,
    -- IN: 인원 수
    IN p_num_people INT
)
BEGIN
	-- 입력한 정보에 맞는 룸이 있으면 count
	DECLARE roomCount INT;
    -- 예약이 가능하면 count
    DECLARE reservationCount INT;
    -- 예약 테이블에 넣을 변수
    DECLARE p_room_number INT;
    DECLARE p_hotel_id INT;
    DECLARE p_reservation_status VARCHAR(20);
    DECLARE p_refundable_date DATE;
    DECLARE p_total_cost DECIMAL(10, 2);
    DECLARE p_reservation_validity BOOLEAN;

    -- 예약 가능한 room 확인 : 예약이 가능한 경우를 COUNT
    SELECT COUNT(*) INTO roomCount
	FROM room
	-- 최대 인원, 룸 타입, 호텔 이름 체크
	WHERE maximum_number >= p_num_people 
		AND roomType = p_room_type 
        AND hotelId = (SELECT hotelId
					   FROM hotel
					   WHERE hotelName = p_hotel_name);
                                                                       
	IF roomCount > 0 THEN
		-- 예약할 수 없을 때 COUNT
		SELECT COUNT(*) INTO reservationCount
		FROM reservations
		WHERE (roomNumber, hotelId) IN (SELECT roomNumber, hotelId
										 FROM room
										 -- 최대 인원, 룸 타입, 호텔 이름 체크
										 WHERE maximum_number >= p_num_people 
											AND roomType = p_room_type 
											AND hotelId = (SELECT hotelId
														   FROM hotel
														   WHERE hotelName = p_hotel_name))
			-- 입력된 체크인 날짜와 체크아웃 날짜가 이미 예약된 방의 예약 기간과 겹치는지 확인하는 조건
			AND check_in_date < p_check_out_date AND check_out_date > p_check_in_date
            AND reservation_validity = FALSE;
        
		-- 예약 가능 여부 확인
		IF reservationCount = 0 THEN
			SET p_reservation_validity = FALSE;
			
			-- 객실번호, 호텔 아이디, 가격 설정
			SELECT roomNumber, hotelId, price INTO p_room_number, p_hotel_id, p_total_cost
			FROM room
			WHERE roomType = p_room_type AND hotelId = (SELECT hotelId 
														FROM hotel
														WHERE hotelName = p_hotel_name)
			ORDER BY roomNumber, hotelId
			LIMIT 1;
			
			-- 예약 상태 설정
			SET p_reservation_status = 'unPaid';
			
			-- 환불 가능일 설정 (체크인하기 3일전까지 가능)
			SET p_refundable_date = DATE_SUB(p_check_in_date, INTERVAL 3 DAY);
			
			-- 예약 정보 추가
			INSERT INTO reservations(customer_id, roomNumber, hotelId, reservation_date, check_in_date, check_out_date,
                                     reservation_status, reservation_validity, refundable_date, num_people, total_cost)
			VALUES (p_customer_id, p_room_number, p_hotel_id, p_reservation_date, p_check_in_date, p_check_out_date, 
                    p_reservation_status, p_reservation_validity, p_refundable_date, p_num_people, p_total_cost);
		END IF;	
    END IF;
END //

DELIMITER ;

CALL CheckAvailabilityAndAddUser('Hotel A', 'Suite', '2023-05-20', '2023-06-01', '2023-06-02', 1, 2);
CALL CheckAvailabilityAndAddUser('Hotel A', 'Suite', '2023-05-10', '2023-06-01', '2023-06-02', 2, 4);
CALL CheckAvailabilityAndAddUser('Hotel B', 'Standard', '2022-09-20', '2023-06-01', '2023-06-02', 3, 3);
CALL CheckAvailabilityAndAddUser('Hotel C', 'Deluxe', '2023-03-30', '2023-06-01', '2023-06-02', 4, 2);
CALL CheckAvailabilityAndAddUser('Hotel A', 'Standard', '2023-04-10', '2023-07-01', '2023-07-02', 2, 2);

SELECT * FROM reservations;