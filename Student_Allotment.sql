DELIMITER $$

CREATE PROCEDURE AllotSubjects()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE sid VARCHAR(20);
    DECLARE cursor1 CURSOR FOR 
        SELECT StudentId FROM StudentDetails ORDER BY GPA DESC;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cursor1;

    student_loop: LOOP
        FETCH cursor1 INTO sid;
        IF done THEN
            LEAVE student_loop;
        END IF;

        DECLARE pref INT DEFAULT 1;
        DECLARE subject_id VARCHAR(20);
        DECLARE assigned BOOLEAN DEFAULT FALSE;

        preference_loop: WHILE pref <= 5 DO
            
            SELECT SubjectId INTO subject_id
            FROM StudentPreference
            WHERE StudentId = sid AND Preference = pref;

            
            IF EXISTS (
                SELECT 1 FROM SubjectDetails 
                WHERE SubjectId = subject_id AND RemainingSeats > 0
            ) THEN
                
                INSERT INTO Allotments(StudentId, SubjectId) 
                VALUES (sid, subject_id);

                
                UPDATE SubjectDetails 
                SET RemainingSeats = RemainingSeats - 1 
                WHERE SubjectId = subject_id;

                SET assigned = TRUE;
                LEAVE preference_loop;
            END IF;

            SET pref = pref + 1;
        END WHILE;

        IF NOT assigned THEN
            INSERT INTO UnallotedStudents(StudentId) VALUES (sid);
        END IF;

    END LOOP;

    CLOSE cursor1;
END$$

DELIMITER ;
