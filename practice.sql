Delimiter $$
CREATE TRIGGER reservation_trigger
Before INSERT ON reservations
FOR  each row
begin 
declare existing_reservation_count Int;
DECLARE check_in_date_valid INT;
DECLARE check_out_date_valid INT;
DECLARE room_price DECIMAL(10, 2);

 
#checking if the inforamtion already exicts
select count(*) into existing_reservation_count
from reservations
where customer_id=new.customer_id 
and hotelId=new.hoteId
and roomId=new.roomId
and reservation_validity=false
 and reservation_id<>new.reservation_id;
 
 IF existing_reservation_count > 0 THEN
    -- Handle the case when a duplicate reservation is detected
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A reservation with the same customer and hotel information already exists and is in use';
END IF;
-- Ensure that the check-in date is not earlier than the reservation date
IF NEW.check_in_date < NEW.reservation_date THEN
    SET check_in_date_valid = 0;
ELSE
    SET check_in_date_valid = 1;
END IF;

-- Ensure that the check-out date is not earlier than the check-in date
IF NEW.check_out_date < NEW.check_in_date THEN
    SET check_out_date_valid = 0;
ELSE
    SET check_out_date_valid = 1;
END IF;

 
-- Handle the cases when check-in or check-out dates are invalid
IF check_in_date_valid = 0 THEN
    -- Handle the case when the check-in date is earlier than the reservation date
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '체크인 날짜가 예약 날짜보다 빠를 수 없습니다.';
END IF;

   IF check_out_date_valid = 0 THEN
    -- Handle the case when the check-out date is earlier than the check-in date
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '체크아웃 날짜가 체크인 날짜보다 빠를 수 없습니다.';
   end if;

   
    -- Calculate the total cost of the reservation automatically based on the room price
    SELECT price INTO room_price
    FROM room
    WHERE roomId = NEW.roomId;
    IF NEW.total_cost <> room_price THEN
        SET NEW.total_cost = room_price;
    END IF;
    
   IF new.refundable_date <> new.check_in_date - INTERVAL 3 DAY or new.refundable_date IS  NULL THEN 
    SET new.refundable_date = new.check_in_date - INTERVAL 3 DAY;
END IF;

END;