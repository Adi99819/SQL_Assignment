DELIMITER $$

CREATE PROCEDURE UpdateSubjectAllotment()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE sid VARCHAR(20);
    DECLARE new_subid VARCHAR(20);
    DECLARE current_subid VARCHAR(20);

    
    DECLARE request_cursor CURSOR FOR 
        SELECT StudentId, SubjectId FROM SubjectRequest;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN request_cursor;

    request_loop: LOOP
        FETCH request_cursor INTO sid, new_subid;
        IF done THEN 
            LEAVE request_loop;
        END IF;

        
        SELECT SubjectId INTO current_subid
        FROM SubjectAllotments
        WHERE StudentId = sid AND Is_valid = 1
        LIMIT 1;

        
        IF current_subid IS NULL THEN
            INSERT INTO SubjectAllotments(StudentId, SubjectId, Is_valid)
            VALUES (sid, new_subid, 1);
        ELSE
            
            IF current_subid != new_subid THEN
                
                UPDATE SubjectAllotments
                SET Is_valid = 0
                WHERE StudentId = sid AND Is_valid = 1;

                
                INSERT INTO SubjectAllotments(StudentId, SubjectId, Is_valid)
                VALUES (sid, new_subid, 1);
            END IF;
           
        END IF;
    END LOOP;

    CLOSE request_cursor;
END$$

DELIMITER ;
