USE hotelregistration;

DROP PROCEDURE CheckAvailabilityAndAddUser;

DROP DATABASE hotelregistration;

        
SELECT COUNT(*) as roomCount
FROM room
-- 최대 인원 체크하기
WHERE maximum_number <= 3 AND roomType = "Standard" AND hotelId = (SELECT hotelId
	                                                               FROM hotel
																   WHERE hotelName = "Hotel A");
                                                                   

        
    SELECT COUNT(*) 
    FROM reservations
    WHERE roomId IN (SELECT roomId
					 FROM room
					 -- 최대 인원 체크하기
					 WHERE maximum_number <= 3 AND roomType = "Suite" AND hotelId = (SELECT hotelId
																						FROM hotel
																						WHERE hotelName = "Hotel A"))
		-- 입력된 체크인 날짜와 체크아웃 날짜가 이미 예약된 방의 예약 기간과 겹치는지 확인하는 조건
		AND (check_in_date <= '2023-06-02' OR check_out_date <= '2023-06-01')
        AND reservation_validity = FALSE;
        
        

SELECT COUNT(*) 
FROM reservations AS r
JOIN room AS rm ON r.roomId = rm.roomId
JOIN hotel AS h ON rm.hotelId = h.hotelId
WHERE rm.roomType = "Standard"
    AND h.hotelName = "Hotel A"
    AND r.check_in_date < '2023-05-20'
    AND r.check_out_date > '2023-06-01';

        


CALL CheckAvailabilityAndAddUser('Hotel A', 'Suite', '2023-05-20', '2023-06-01', '2023-06-02', 1, 2);
CALL CheckAvailabilityAndAddUser('Hotel A', 'Suite', '2023-05-10', '2023-06-01', '2023-06-02', 2, 4);
CALL CheckAvailabilityAndAddUser('Hotel B', 'Standard', '2022-09-20', '2023-06-01', '2023-06-02', 3, 3);
CALL CheckAvailabilityAndAddUser('Hotel C', 'Deluxe', '2023-03-30', '2023-06-01', '2023-06-02', 4, 2);
CALL CheckAvailabilityAndAddUser('Hotel A', 'Standard', '2023-04-10', '2023-07-01', '2023-07-02', 2, 6);

SELECT * FROM reservations;
