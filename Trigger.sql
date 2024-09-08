
Delimiter $$
CREATE TRIGGER reservation_trigger
BEFORE INSERT ON reservations
FOR  EACH ROW
BEGIN 
DECLARE existing_reservation_count Int;
DECLARE check_in_date_valid INT;
DECLARE check_out_date_valid INT;
DECLARE room_price DECIMAL(10, 2);
 
-- 정보가 이미 들어있는지 체크
select count(*) into existing_reservation_count
from reservations
where customer_id=new.customer_id 
    and hotelId=new.hotelId
    and roomNumber=new.roomNumber 
    and reservation_validity=false
    and reservation_id<>new.reservation_id;
 
IF existing_reservation_count > 0 THEN
    -- 중복 예약 처리
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '이 방은 이미 다른 사용자가 사용중입니다.';
END IF;

-- 체크인 날짜가 예약 날짜보다 빠른지 체크
IF NEW.check_in_date < NEW.reservation_date THEN
    SET check_in_date_valid = 0;
ELSE
    SET check_in_date_valid = 1;
END IF;

-- 체크인 날짜가 체크아웃 날짜보다 빠른지 체크
IF NEW.check_out_date < NEW.check_in_date THEN
    SET check_out_date_valid = 0;
ELSE
    SET check_out_date_valid = 1;
END IF;

-- 체크인, 체크아웃 날짜에 대한 에러 체크
IF check_in_date_valid = 0 THEN
    -- 체크인 날짜가 예약 날짜보다 빠를 때
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '체크인 날짜가 예약 날짜보다 빠를 수 없습니다.';
END IF;

IF check_out_date_valid = 0 THEN
    -- 체크아웃 날짜가 체크인 날짜보다 빠를 때
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '체크아웃 날짜가 체크인 날짜보다 빠를 수 없습니다.';
END IF;

    -- 룸 테이블의 가격에 의해 호텔 테이블 total_cost 자동으로 업데이트
    SELECT price INTO room_price
    FROM room
    WHERE hotelId=new.hotelId
    and roomNumber=new.roomNumber ;
    IF NEW.total_cost <> room_price THEN
        SET NEW.total_cost = room_price;
    END IF;
    
   IF new.refundable_date <> new.check_in_date - INTERVAL 3 DAY 
       OR new.refundable_date IS  NULL THEN 
    SET new.refundable_date = new.check_in_date - INTERVAL 3 DAY;
   END IF;

END;