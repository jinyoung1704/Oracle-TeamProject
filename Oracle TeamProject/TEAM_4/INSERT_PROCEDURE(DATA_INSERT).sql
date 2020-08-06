--[ 기본 입력 프로시저 & 더미데이터 입력 ]-------------------------------------------------------------------------------

-- 1 ) 교재 입력 프로시저
-- 북 시퀀스 생성
CREATE SEQUENCE BCODE_NUM
MINVALUE 1
START WITH 1
INCREMENT BY 1;
--==>Sequence BCODE_NUM이(가) 생성되었습니다.

CREATE OR REPLACE PROCEDURE PRC_BOOK_INSERT(
V_B_NAME      IN      BOOK.B_NAME%TYPE
)
IS
TEMP_B_NAME     BOOK.B_NAME%TYPE;
BOOK_JUNGBOK_ERROR    EXCEPTION;
BEGIN
  
    -- 같은이름의 책이 있는지 확인
        SELECT B_NAME INTO TEMP_B_NAME
        FROM BOOK
        WHERE B_NAME=V_B_NAME;
        
    -- 같은책에 이름이 있으면 BOOK_JUNGBOK_ERROR 발생
        IF(TEMP_B_NAME = V_B_NAME)
            THEN RAISE   BOOK_JUNGBOK_ERROR ;
        
        END IF;
    -- 같은책에 이름이 없다면 책을 INSERT 해준다.  
        EXCEPTION
            WHEN BOOK_JUNGBOK_ERROR
            THEN RAISE_APPLICATION_ERROR(-20001,'이미 존재하는 책입니다.');
            
            WHEN NO_DATA_FOUND
                THEN 
                
                INSERT INTO BOOK(B_CODE,B_NAME)
                VALUES('B'||TO_CHAR(BCODE_NUM.NEXTVAL),V_B_NAME);
END;



--북 시퀀스 삭제
DROP SEQUENCE BCODE_NUM;

SELECT *
FROM BOOK;

--책 이름이 존재할 경우
EXEC PRC_BOOK_INSERT('자바의 정석');

--책 이름이 존재하지 않을 경우
EXEC PRC_BOOK_INSERT('자바 부수기');




-- 1-2) 교재 더미데이터 입력

EXEC PRC_BOOK_INSERT('자바의 정석');
EXEC PRC_BOOK_INSERT('오라클의 정석');
EXEC PRC_BOOK_INSERT('자바스크립트의 정석');
EXEC PRC_BOOK_INSERT('HTML 맛보기');
EXEC PRC_BOOK_INSERT('CSS 맛보기');
EXEC PRC_BOOK_INSERT('데이터베이스 개론');
EXEC PRC_BOOK_INSERT('파이썬 기본');
EXEC PRC_BOOK_INSERT('SQL 정석');
EXEC PRC_BOOK_INSERT('UI 맛보기');




-------------------------------------------------------------------------------------------------------------------------------
-- 2) 강의실 추가 프로시저

-- 강의실 시퀀스 생성
CREATE SEQUENCE RCODE_NUM
MINVALUE 1
START WITH 1
INCREMENT BY 1;
--==>Sequence RCODE_NUM이(가) 생성되었습니다.


CREATE OR REPLACE PROCEDURE PRC_ROOM_INSERT(
V_R_NAME    IN  ROOM.R_NAME%TYPE
)
IS
TEMP_R_NAME     ROOM.R_NAME%TYPE;
ROOM_JUNGBOK_ERROR  EXCEPTION;
BEGIN

    SELECT R_NAME INTO TEMP_R_NAME
    FROM ROOM
    WHERE R_NAME=V_R_NAME;
    
    IF(TEMP_R_NAME = V_R_NAME)
        THEN   RAISE ROOM_JUNGBOK_ERROR;
    END IF;
    
    EXCEPTION
        WHEN ROOM_JUNGBOK_ERROR
        THEN RAISE_APPLICATION_ERROR(-20010,'이미 존재하는 강의실입니다.');
        
        WHEN NO_DATA_FOUND
        THEN INSERT INTO ROOM(R_CODE,R_NAME)
        VALUES('R'||TO_CHAR(RCODE_NUM.NEXTVAL),V_R_NAME);

END;



--ROOM 시퀀스 삭제
DROP SEQUENCE RCODE_NUM;
--==>Sequence RCODE_NUM이(가) 삭제되었습니다.

SELECT *
FROM ROOM;


-- ○ 테스트
-- 중복된 강의실 예외처리 체크
EXEC PRC_ROOM_INSERT('A');
--==>ORA-20010: 이미 존재하는 강의실입니다.
EXEC PRC_ROOM_INSERT('A강의실');


------- 2 - 2 ) 강의실 더미 데이터 입력

EXEC PRC_ROOM_INSERT('A강의실');
EXEC PRC_ROOM_INSERT('B강의실');
EXEC PRC_ROOM_INSERT('C강의실');
EXEC PRC_ROOM_INSERT('D강의실');
EXEC PRC_ROOM_INSERT('E강의실');
EXEC PRC_ROOM_INSERT('F강의실');




--------------------------------------------------------------------------------------------------------------------------
-- 3) COURSE 데이터 입력 프로시저

-- 과정 시퀀스 생성
CREATE SEQUENCE CCODE_NUM
MINVALUE 1
START WITH 1
INCREMENT BY 1;
--==>Sequence CCODE_NUM이(가) 생성되었습니다.

-- COURSE 입력 프로시저
CREATE OR REPLACE PROCEDURE PRC_COURSE_INSERT(
V_C_NAME    IN  COURSE.C_NAME%TYPE
)
IS

    TEMP_C_NAME     COURSE.C_NAME%TYPE;
    COURSE_JUNGBOK_ERROR    EXCEPTION;
BEGIN

    SELECT C_NAME INTO TEMP_C_NAME
    FROM COURSE
    WHERE C_NAME=V_C_NAME;
    
    IF(V_C_NAME = TEMP_C_NAME)
        THEN RAISE COURSE_JUNGBOK_ERROR;
    END IF;
    
    

    EXCEPTION
        WHEN COURSE_JUNGBOK_ERROR
            THEN  RAISE_APPLICATION_ERROR(-20011,'이미 존재하는 과정입니다.');
        WHEN NO_DATA_FOUND
            THEN  INSERT INTO COURSE(C_CODE,C_NAME)
            VALUES('C'||TO_CHAR(CCODE_NUM.NEXTVAL),V_C_NAME);


END;




SELECT *
FROM COURSE;

--이미 존재하는 과정 입력
EXEC PRC_COURSE_INSERT('SW개발자 양성과정');
--==>ORA-20011: 이미 존재하는 과정입니다.

EXEC PRC_COURSE_INSERT('SW개발자 양성과정2');

-- 3 - 1) 과정 더미데이터 입력

EXEC PRC_COURSE_INSERT('SW개발자 양성과정');
EXEC PRC_COURSE_INSERT('DB개발자 양성과정');


----------------------------------------------------------------------------------------------------------------------
-- 4 ) 과목입력 프로시저

-- 과목 시퀀스 생성
CREATE SEQUENCE SUBCODE_NUM
MINVALUE 1
START WITH 1
INCREMENT BY 1;


--과목 입력 프로시저
CREATE OR REPLACE PROCEDURE PRC_SUBJECT_INSERT(
V_SUB_NAME    IN  SUBJECT.SUB_NAME%TYPE
)
IS

    TEMP_SUB_NAME     SUBJECT.SUB_NAME%TYPE;
    SUBJECT_JUNGBOK_ERROR    EXCEPTION;
BEGIN

    SELECT SUB_NAME INTO TEMP_SUB_NAME
    FROM SUBJECT
    WHERE SUB_NAME=V_SUB_NAME;
    
    IF(V_SUB_NAME = TEMP_SUB_NAME)
        THEN RAISE SUBJECT_JUNGBOK_ERROR;
    END IF;
    
    

    EXCEPTION
        WHEN SUBJECT_JUNGBOK_ERROR
            THEN  RAISE_APPLICATION_ERROR(-20011,'이미 존재하는 과목입니다.');
        WHEN NO_DATA_FOUND
            THEN  INSERT INTO SUBJECT(SUB_CODE,SUB_NAME)
            VALUES('SUB'||TO_CHAR(SUBCODE_NUM.NEXTVAL),V_SUB_NAME);


END;




SELECT *
FROM SUBJECT;

-- 이미 존재하는 과목 INSERT
EXEC PRC_SUBJECT_INSERT('자바');
--==>ORA-20011: 이미 존재하는 과목입니다.

---4 -1 ) 과목 더미 데이터 입력
EXEC PRC_SUBJECT_INSERT('자바');
EXEC PRC_SUBJECT_INSERT('오라클');
EXEC PRC_SUBJECT_INSERT('자바스크립트');
EXEC PRC_SUBJECT_INSERT('HTML');
EXEC PRC_SUBJECT_INSERT('CSS');
EXEC PRC_SUBJECT_INSERT('데이터베이스');
EXEC PRC_SUBJECT_INSERT('파이썬');
EXEC PRC_SUBJECT_INSERT('SQL');
EXEC PRC_SUBJECT_INSERT('UI');




-----------------------------------------------------------------------------------------------------------------------

-- 5 )교수 입력 프로시저

--교수 시퀀스 생성
CREATE SEQUENCE PID_NUM
MINVALUE 1
START WITH 1
INCREMENT BY 1;


-- 교수 입력 프로시저
CREATE OR REPLACE PROCEDURE PRC_PRO_INSERT
(
    V_P_NAME    IN PROFESSOR.P_NAME %TYPE
   ,V_P_SSN     IN PROFESSOR.P_SSN %TYPE
)
IS
    V_COUNT     NUMBER(10);   
BEGIN
        -- 주민번호 확인 1이면 이미 가입된 유저
        SELECT COUNT(*) INTO V_COUNT
        FROM PROFESSOR
        WHERE P_SSN = V_P_SSN;
    
        -- 주민번호 없을시 교수 정보 입력
        IF(V_COUNT=0)
        THEN
            INSERT INTO PROFESSOR(P_ID, P_NAME, P_SSN, P_PW) 
            VALUES('PRO' || TO_CHAR(SYSDATE,'YY') || TO_CHAR(PID_NUM.NEXTVAL), V_P_NAME, V_P_SSN, SUBSTR( V_P_SSN, 8));
        END IF;
        
        COMMIT;
END;

--교수 시퀀스 삭제
DROP SEQUENCE PID_NUM;

-- 5 - 1) 교수 더미 데이터 입력
EXEC PRC_PRO_INSERT('김호진','861230-1012546');
EXEC PRC_PRO_INSERT('좌민혜','581030-2028857');
EXEC PRC_PRO_INSERT('문승중','960712-1023597');
EXEC PRC_PRO_INSERT('전진','970129-2065621');
EXEC PRC_PRO_INSERT('암효림','960730-2065411');


SELECT *
FROM PROFESSOR;

------------------------------------------------------------------------------------------------------------------
-- 6) 학생 정보 입력 프로시저

--학생 시퀀스 생성
CREATE SEQUENCE SID_NUM
MINVALUE 1
START WITH 1
INCREMENT BY 1;



CREATE OR REPLACE PROCEDURE PRC_STU_INSERT
(
    V_S_NAME    IN STUDENTS.S_NAME %TYPE
   ,V_S_SSN     IN STUDENTS.S_SSN %TYPE
)
IS
    V_COUNT     NUMBER(10);
    V_SIZE      NUMBER(20);
    USER_DEFINE_ERROR EXCEPTION;
    SSN_WRONG_ERROR EXCEPTION;    
BEGIN
        -- 주민번호 확인 1이면 이미 가입된 유저
        SELECT COUNT(*) INTO V_COUNT
        FROM STUDENTS
        WHERE S_SSN = V_S_SSN;
        
        -- 주민 번호 사이즈 건사
        SELECT LENGTH(V_S_SSN) INTO V_SIZE
        FROM DUAL;
    
        -- 주민번호 없을시 학생 정보 입력
        IF(V_SIZE=14)
            THEN
                IF(V_COUNT=0)
                    THEN
                        INSERT INTO STUDENTS(S_ID, S_NAME, S_SSN, S_PW) 
                        VALUES('STU' || TO_CHAR(SYSDATE,'YY') || TO_CHAR(SID_NUM.NEXTVAL), V_S_NAME, V_S_SSN, SUBSTR(V_S_SSN, 8));
                ELSE RAISE USER_DEFINE_ERROR ;            
                END IF;
        ELSE RAISE SSN_WRONG_ERROR;
                      
        END IF;
        
        -- 커밋
        COMMIT;
        
        EXCEPTION
        WHEN SSN_WRONG_ERROR 
                THEN RAISE_APPLICATION_ERROR(-20001,'주민번호가 유효하지 않습니다.');
         WHEN USER_DEFINE_ERROR
                THEN RAISE_APPLICATION_ERROR(-20002,'이미 존재하는 사용자입니다..');         
            WHEN OTHERS 
                THEN ROLLBACK;

END;

--학생 시퀀스 삭제
DROP SEQUENCE SID_NUM;

-- 6 - 2) 학생 더미 데이터 입력

EXEC PRC_STU_INSERT('김동휘','950728-2123456');
EXEC PRC_STU_INSERT('전진영','970129-2123457');
EXEC PRC_STU_INSERT('문승주','960712-1123456');
EXEC PRC_STU_INSERT('임효림','950728-2123458');
EXEC PRC_STU_INSERT('주기연','990505-1123457');
EXEC PRC_STU_INSERT('오진녕','930728-2123456');
EXEC PRC_STU_INSERT('이채빈','950729-2133457');
EXEC PRC_STU_INSERT('송수진','950712-1153456');
EXEC PRC_STU_INSERT('장기혜','950828-2123458');
EXEC PRC_STU_INSERT('신성철','990505-1143457');


----------------------------------------------------------------------------------------------------------------------
-- 7) 개설된 과정 입력 프로시저

CREATE SEQUENCE OC_NUM
MINVALUE 1
START WITH 1
INCREMENT BY 1;

CREATE OR REPLACE PROCEDURE PRC_COURSE_INPUT
( 
    V_OC_START IN  OPEN_COURSE.OC_START%TYPE    --과정시작일
,   V_OC_END   IN  OPEN_COURSE.OC_END%TYPE     --과정 종료일
,   V_R_CODE     IN   ROOM.R_CODE%TYPE         --강의실코드
,   V_P_ID     IN   PROFESSOR.P_ID%TYPE        --교수번호
,   V_C_CODE IN COURSE.C_CODE%TYPE             --과정코드
      

)
IS
   
   R_CHECK NUMBER;   --방 코드가 ROOM에 있는지 확인하기 위해
   P_CHECK NUMBER;   --교수번호가 PROFESSOR에 있는지 확인하기 위해
   C_CHECK NUMBER;   --강의가 COURSE에 있는지 체크
   OC_CHECK NUMBER;  --기존에 등록이 되어있으면 중복입력 불가를 위해
   
   V_OC_CODE OPEN_COURSE.OC_CODE%TYPE;
 
   --예외
   PROFESSOR_ERROR EXCEPTION;
   ROOM_ERROR EXCEPTION;
   COURSE_ERROR EXCEPTION;
   INPUT_ERROR EXCEPTION;
BEGIN
   --입력한 V_R_CODE 값이 ROOM에 존재하는지 안하는지 체크
    SELECT COUNT(*) INTO R_CHECK
    FROM ROOM
    WHERE R_CODE=V_R_CODE;

  
   IF(R_CHECK = 0)
     THEN RAISE ROOM_ERROR ;
   END IF;
  
  
  --입력한 V_P_ID가 PROFESSOR에 있는지 없는지 체크
  SELECT COUNT(*) INTO P_CHECK
  FROM PROFESSOR
  WHERE P_ID=V_P_ID;
  
  IF(P_CHECK=0)
    THEN RAISE PROFESSOR_ERROR ;
  END IF;

  
  --입력한 과정이 COURSE에 있는지 체크
  
  SELECT COUNT(*) INTO C_CHECK
  FROM COURSE
  WHERE C_CODE=V_C_CODE;
  
  IF(C_CHECK=0)
    THEN RAISE COURSE_ERROR ;
  END IF;

  --개설된 과정에 이미 교수와 강의실이 등록되어 있는 경우
  SELECT COUNT(*) INTO OC_CHECK
  FROM OPEN_COURSE
  WHERE P_ID=V_P_ID AND R_CODE=V_R_CODE AND OC_END>V_OC_START;
  
  IF(OC_CHECK!=0)
    THEN RAISE INPUT_ERROR;
  END IF;

   --OC_CODE
   SELECT  MAX(SUBSTR(OC_CODE,3))+1 INTO V_OC_CODE
   FROM OPEN_COURSE;

    --데이터 입력 
    INSERT INTO OPEN_COURSE(OC_CODE,OC_START,OC_END,R_CODE,P_ID,C_CODE)
    VALUES('OC'||TO_CHAR(OC_NUM.NEXTVAL),V_OC_START,V_OC_END,V_R_CODE,V_P_ID,V_C_CODE);
  
  --커밋
  COMMIT;
  
  --예외처리
   EXCEPTION
   WHEN ROOM_ERROR
        THEN RAISE_APPLICATION_ERROR(-20002,'강의실이 등록되어 있지 않습니다');
        ROLLBACK;
   WHEN PROFESSOR_ERROR
        THEN RAISE_APPLICATION_ERROR(-20003,'교수번호가 등록되어 있지 않습니다');
        ROLLBACK;
   WHEN COURSE_ERROR
        THEN RAISE_APPLICATION_ERROR(-20004,'과정이 등록되어 있지 않습니다');
        ROLLBACK;
   WHEN INPUT_ERROR
        THEN RAISE_APPLICATION_ERROR(-20005,'교수와 강의실이 이미 등록되어 있습니다.');
        ROLLBACK;
   WHEN OTHERS
        THEN ROLLBACK;
   
END;

-- 7 - 1) 개설된 과정 더미 데이터 
EXEC PRC_COURSE_INPUT(TO_DATE('2020-01-13','YYYY-MM-DD'),TO_DATE('2020-07-30','YYYY-MM-DD'),'R6','PRO201','C1');
EXEC PRC_COURSE_INPUT(TO_DATE('2020-02-09','YYYY-MM-DD'),TO_DATE('2020-08-21','YYYY-MM-DD'),'R5','PRO202','C1');
EXEC PRC_COURSE_INPUT(TO_DATE('2020-02-12','YYYY-MM-DD'),TO_DATE('2020-09-01','YYYY-MM-DD'),'R4','PRO203','C2');
EXEC PRC_COURSE_INPUT(TO_DATE('2020-02-20','YYYY-MM-DD'),TO_DATE('2020-09-21','YYYY-MM-DD'),'R3','PRO204','C2');



-------------------------------------------------------------------------------------------------------------------------------
-- 8) 중도탈락 학생 입력 프로시저

-- 중도 탈락 학생 시퀀스 생성
CREATE SEQUENCE DSCODE_NUM
MINVALUE 1
START WITH 1
INCREMENT BY 1;


-- 중도 탈락 학생 프로시저
CREATE OR REPLACE PROCEDURE PRC_DROPSTU_INSERT(
V_S_ID  IN  STUDENTS.S_ID%TYPE
,V_D_DATE IN DROP_STUDENTS.D_DATE%TYPE
)
IS
TEMP_S_ID   STUDENTS.S_ID%TYPE;
TEMP_SC_CODE STUDENT_COURSE.SC_CODE%TYPE;
BEGIN
    
    --수강신청된 학생인지 조회
    SELECT S_ID,SC_CODE INTO TEMP_S_ID,TEMP_SC_CODE
    FROM STUDENT_COURSE
    WHERE S_ID=V_S_ID;
    
    INSERT INTO DROP_STUDENTS(DS_CODE,D_DATE,SC_CODE)
    VALUES('DS'||TO_CHAR(DSCODE_NUM.NEXTVAL),V_D_DATE,TEMP_SC_CODE);
    
    EXCEPTION
        WHEN NO_DATA_FOUND
            THEN RAISE_APPLICATION_ERROR(-20013,'수강신청하지 않은 학생입니다.');
    
END;

-- 테스트
EXEC PRC_DROPSTU_INSERT('STU1',SYSDATE);


-- ※ 수강신청 더미데이터 입력후 입력하기 ※
-- 중도 탈락학생 더미 데이터 입력
EXEC PRC_DROPSTU_INSERT('STU203',SYSDATE);


------------------------------------------------------------------------------------------------------------------
-- 9) 개설된 과목 입력 프로시저
-- 9) 개설된 과목 입력 프로시저
-- 과목 시퀀스 생성
CREATE SEQUENCE OS_NUM
MINVALUE 1
START WITH 1
INCREMENT BY 1;


-- 개설된 과목 입력 프로시저
CREATE OR REPLACE PROCEDURE PRC_SUBJECT_INSERT
(
  V_SUB_CODE     IN SUBJECT.SUB_CODE%TYPE           -- 과목코드
, V_OS_START     IN OPEN_SUBJECT.OS_START%TYPE      -- 과목 시작
, V_OS_END       IN OPEN_SUBJECT.OS_END%TYPE        -- 과목 끝
, V_B_CODE       IN BOOK.B_CODE%TYPE                -- 책
, V_OC_CODE      IN OPEN_COURSE.OC_CODE%TYPE        -- 개강과정     
)
IS
  CHECK_OC_CODE NUMBER(20);         
  CHECK_SUB_CODE NUMBER(20);
  CHECK_B_CODE NUMBER(20);
  TEMP_OC_START OPEN_COURSE.OC_START%TYPE;
  TEMP_OC_END   OPEN_COURSE.OC_END%TYPE;
  
  NOT_OCCODE_ERROR EXCEPTION;
  NOT_SUBCODE_ERROR EXCEPTION; 
  NOT_BCODE_ERROR EXCEPTION;
  WRONG_DATE_ERROR EXCEPTION;

BEGIN

    -- 개설과정 확인
    SELECT COUNT(*) INTO CHECK_OC_CODE
    FROM OPEN_COURSE
    WHERE OC_CODE = V_OC_CODE;
    
    -- 과목 확인
    SELECT COUNT(*) INTO CHECK_SUB_CODE
    FROM SUBJECT
    WHERE SUB_CODE = V_SUB_CODE;

    -- 책 확인
    SELECT COUNT(*) INTO CHECK_B_CODE
    FROM BOOK
    WHERE B_CODE = V_B_CODE;
    
    -- 과정기간 확인
    SELECT OC_START, OC_END INTO TEMP_OC_START, TEMP_OC_END
    FROM OPEN_COURSE
    WHERE OC_CODE = V_OC_CODE;
    
    -- OPEN_COURSE에 개설과정 없을시 예외처리
    IF(CHECK_OC_CODE=0)             
        THEN RAISE NOT_OCCODE_ERROR;
    -- SUBJECT에 과목 없을시 예외처리
    ELSIF(CHECK_SUB_CODE=0)
        THEN RAISE NOT_SUBCODE_ERROR;
    -- BOOK에 책 없을시 예외처리    
    ELSIF(CHECK_B_CODE=0)
        THEN RAISE NOT_BCODE_ERROR;
    -- 과목기간이 과정기간에 벗어나면 예외처리   
    ELSIF(TEMP_OC_START <= V_OS_START AND V_OS_END <= TEMP_OC_END AND V_OS_START < V_OS_END)
        THEN INSERT INTO OPEN_SUBJECT(OS_CODE, SUB_CODE, OS_START, OS_END, B_CODE, OC_CODE)
        VALUES( 'OS'||TO_CHAR(OS_NUM.NEXTVAL), V_SUB_CODE, V_OS_START, V_OS_END, V_B_CODE, V_OC_CODE );
    ELSE
        RAISE WRONG_DATE_ERROR;
    END IF;
    
    
    -- COMMIT;

    EXCEPTION
        WHEN NOT_SUBCODE_ERROR
            THEN RAISE_APPLICATION_ERROR(-20021,'해당과목은 없습니다.');
        WHEN NOT_BCODE_ERROR
            THEN RAISE_APPLICATION_ERROR(-20022,'해당하는 교재는 없습니다.');
        WHEN WRONG_DATE_ERROR
            THEN RAISE_APPLICATION_ERROR(-20023,'해당날짜는 유효하지 않습니다.');
         WHEN NOT_OCCODE_ERROR
            THEN RAISE_APPLICATION_ERROR(-20024,'no data found');
       WHEN OTHERS
            THEN ROLLBACK; 
END;



-- 9-1)개설된 과목 더미 데이터 입력 

--OC1의 개설된 과목 데이터
EXEC PRC_SUBJECT_INSERT('SUB1',TO_DATE('2020-01-13','YYYY-MM-DD'),TO_DATE('2020-02-12','YYYY-MM-DD'),'B1','OC1');
EXEC PRC_SUBJECT_INSERT('SUB2',TO_DATE('2020-02-13','YYYY-MM-DD'),TO_DATE('2020-02-12','YYYY-MM-DD'),'B2','OC1');
EXEC PRC_SUBJECT_INSERT('SUB3',TO_DATE('2020-03-13','YYYY-MM-DD'), TO_DATE('2020-04-12','YYYY-MM-DD'),'B3','OC1');
EXEC PRC_SUBJECT_INSERT('SUB4',TO_DATE('2020-04-13','YYYY-MM-DD'), TO_DATE('2020-05-12','YYYY-MM-DD'),'B4','OC1');
EXEC PRC_SUBJECT_INSERT('SUB5',TO_DATE('2020-05-13','YYYY-MM-DD'), TO_DATE('2020-07-30','YYYY-MM-DD'),'B5','OC1');


COMMIT;



-----
--OC2의 개설된 과목 데이터
EXEC PRC_SUBJECT_INSERT('SUB1',TO_DATE('2020-02-09','YYYY-MM-DD'), TO_DATE('2020-03-10','YYYY-MM-DD'),'B1','OC2');
EXEC PRC_SUBJECT_INSERT('SUB2',TO_DATE('2020-03-11','YYYY-MM-DD'), TO_DATE('2020-04-10','YYYY-MM-DD'),'B2','OC2');
EXEC PRC_SUBJECT_INSERT('SUB3',TO_DATE('2020-04-11','YYYY-MM-DD'), TO_DATE('2020-05-10','YYYY-MM-DD'),'B3','OC2');
EXEC PRC_SUBJECT_INSERT('SUB4',TO_DATE('2020-05-11','YYYY-MM-DD'), TO_DATE('2020-06-10','YYYY-MM-DD'),'B4','OC2');
EXEC PRC_SUBJECT_INSERT('SUB5',TO_DATE('2020-06-11','YYYY-MM-DD'), TO_DATE('2020-08-21','YYYY-MM-DD'),'B5','OC2');




----
--OC3의 개설된 과목 데이터
EXEC PRC_SUBJECT_INSERT('SUB3',TO_DATE('2020-02-12','YYYY-MM-DD'), TO_DATE('2020-03-15','YYYY-MM-DD'),'B3','OC3');
EXEC PRC_SUBJECT_INSERT('SUB4',TO_DATE('2020-03-16','YYYY-MM-DD'), TO_DATE('2020-04-15','YYYY-MM-DD'),'B4','OC3');
EXEC PRC_SUBJECT_INSERT('SUB5',TO_DATE('2020-04-16','YYYY-MM-DD'), TO_DATE('2020-05-15','YYYY-MM-DD'),'B5','OC3');
EXEC PRC_SUBJECT_INSERT('SUB6',TO_DATE('2020-06-16','YYYY-MM-DD'), TO_DATE('2020-07-15','YYYY-MM-DD'),'B6','OC3');
EXEC PRC_SUBJECT_INSERT('SUB7',TO_DATE('2020-07-16','YYYY-MM-DD'), TO_DATE('2020-09-01','YYYY-MM-DD'),'B7','OC3');



----
--OC4의 개설된 과목 데이터
EXEC PRC_SUBJECT_INSERT('SUB3',TO_DATE('2020-02-20','YYYY-MM-DD'), TO_DATE('2020-03-19','YYYY-MM-DD'),'B3','OC4');
EXEC PRC_SUBJECT_INSERT('SUB4',TO_DATE('2020-03-20','YYYY-MM-DD'), TO_DATE('2020-04-19','YYYY-MM-DD'),'B4','OC4');
EXEC PRC_SUBJECT_INSERT('SUB5',TO_DATE('2020-04-20','YYYY-MM-DD'), TO_DATE('2020-05-19','YYYY-MM-DD'),'B5','OC4');
EXEC PRC_SUBJECT_INSERT('SUB6',TO_DATE('2020-05-20','YYYY-MM-DD'), TO_DATE('2020-06-19','YYYY-MM-DD'),'B6','OC4');
EXEC PRC_SUBJECT_INSERT('SUB7',TO_DATE('2020-06-20','YYYY-MM-DD'), TO_DATE('2020-09-21','YYYY-MM-DD'),'B7','OC4');


----------------------------------------------------------------------------------------------------------------

--10 ) 수강신청 한 학생 입력 프로시저 (수강신청 테이블)


--STUDENT_COURSE 시퀀스생성
CREATE SEQUENCE SCCODE_NUM
MINVALUE 1
START WITH 1
INCREMENT BY 1;
--==>Sequence SCCODE_NUM이(가) 생성되었습니다.

--GRADE_COURSE 시퀀스생성
CREATE SEQUENCE GRADE_NUM
MINVALUE 1
START WITH 1
INCREMENT BY 1;



--수강신청한 학생 프로시저
CREATE OR REPLACE PROCEDURE PRC_SC_INSERT(
 V_S_ID      IN  STUDENTS.S_ID%TYPE
,V_OC_CODE  IN  OPEN_COURSE.OC_CODE%TYPE
,V_SC_DATE  IN  STUDENT_COURSE.SC_CODE%TYPE
)
IS
CHECK_S_ID      NUMBER(20);
CHECK_OC_CODE   NUMBER(20);
CHECK_SC   NUMBER(20);
TEMP_SC_CODE    STUDENT_COURSE.SC_CODE%TYPE;
NOT_SID_ERROR EXCEPTION;
NOT_OCCODE_ERROR EXCEPTION; 
CHECK_SC_ERROR EXCEPTION; 

BEGIN

    --STUDENTS 테이블에 학생아이디 체크 (0이면 존재하지않으므로 예외처리)
    SELECT COUNT(*) INTO CHECK_S_ID
    FROM STUDENTS
    WHERE S_ID = V_S_ID;
    
    --OPEN_COURSE 테이블에 OC_CODE 체크 (0이면 존재하지않으므로 예외처리)
    SELECT COUNT(*) INTO CHECK_OC_CODE
    FROM OPEN_COURSE
    WHERE OC_CODE = V_OC_CODE;
    
    --STUDENT_COURSE 테이블에 동일과정  (0이 아니면 존재하므로 예외처리)
    SELECT COUNT(*) INTO CHECK_SC
    FROM STUDENT_COURSE
    WHERE V_S_ID = S_ID AND OC_CODE = V_OC_CODE;
    
    -- 학생아이디 없으면 예외처리
    IF(CHECK_S_ID=0)
        THEN RAISE NOT_SID_ERROR;
    -- 과정코드 없으면 예외처리
    ELSIF(CHECK_OC_CODE=0)
        THEN RAISE NOT_OCCODE_ERROR;
    -- 동일한 과정을 듣는 학생이없으면 입력
    ELSIF(CHECK_SC=0)
    THEN
    INSERT INTO STUDENT_COURSE(SC_CODE, S_ID, OC_CODE, SC_DATE)
    VALUES('SC'||TO_CHAR(SCCODE_NUM.NEXTVAL) ,V_S_ID , V_OC_CODE ,V_SC_DATE );
     -- 동일한 과정을 듣는 학생이 있으면 예외처리
    ELSE
        RAISE CHECK_SC_ERROR;    
    END IF;
    
    
    SELECT SC_CODE INTO TEMP_SC_CODE
    FROM  STUDENT_COURSE
    WHERE S_ID = V_S_ID;
    
    
    PRC_GRADE_INSERT(TEMP_SC_CODE);
     
    -- 예외처리
    EXCEPTION
        --학생 아이디가 없다면 예외처리
        WHEN NOT_SID_ERROR   
            THEN RAISE_APPLICATION_ERROR(-20010,'아이디가 존재하지 않습니다.');
        WHEN NOT_OCCODE_ERROR 
            THEN RAISE_APPLICATION_ERROR(-20011,'과정이 존재하지 않습니다.');
        WHEN CHECK_SC_ERROR
            THEN RAISE_APPLICATION_ERROR(-20012,'동일한 과정을 듣는 학생이 존재합니다.');
      
        --COMMIT;               
END;


CREATE OR REPLACE PROCEDURE PRC_GRADE_INSERT(
V_SC_CODE  IN  STUDENT_COURSE.SC_CODE%TYPE
)
IS

    V_OS_CODE      OPEN_SUBJECT.OS_CODE%TYPE;

    CURSOR CUR_GRADE_SELECT
        IS        
        SELECT OS_CODE
        FROM STUDENT_COURSE SC,OPEN_COURSE OC,OPEN_SUBJECT OS
        WHERE OC.OC_CODE = SC.OC_CODE
          AND OS.OC_CODE = OC.OC_CODE
          AND SC_CODE=V_SC_CODE;
               
BEGIN
  
-- 삽입할 때
       
    -- 커서 이용을 위한 커서변수 선언(→ 커서 정의)

         -- 커서 오픈
        OPEN CUR_GRADE_SELECT;    
        -- 커서 오픈 시 쏟아져나오는 데이터들 처리(잡아내기)
        LOOP
        -- 한 행 한 행 받아다가 처리하는 행위 → 『FETCH』
        FETCH CUR_GRADE_SELECT INTO  V_OS_CODE;
        
        -- 커서에서 더 이상 데이터가 쏟아져 나오지 않는 상태... NOTFOUND
        EXIT WHEN CUR_GRADE_SELECT%NOTFOUND;       
        -- 출력
        INSERT INTO GRADE(GRADE_CODE,SC_CODE,OS_CODE) 
        VALUES ('GRD'||TO_CHAR(GRADE_NUM.NEXTVAL), V_SC_CODE, V_OS_CODE);       
        END LOOP;
        CLOSE CUR_GRADE_SELECT;        
  
END;



--- 10-2) 수강신청한 학생 더미 데이터 입력

EXEC PRC_SC_INSERT('STU201','OC1',TO_DATE('2019-12-30','YYYY-MM-DD'));
EXEC PRC_SC_INSERT('STU202','OC1',TO_DATE('2019-12-31','YYYY-MM-DD'));
EXEC PRC_SC_INSERT('STU203','OC2',TO_DATE('2019-01-31','YYYY-MM-DD'));
EXEC PRC_SC_INSERT('STU204','OC3',TO_DATE('2019-02-05','YYYY-MM-DD'));
EXEC PRC_SC_INSERT('STU205','OC4',TO_DATE('2019-02-19','YYYY-MM-DD'));
EXEC PRC_SC_INSERT('STU206','OC1',TO_DATE('2019-12-30','YYYY-MM-DD'));
EXEC PRC_SC_INSERT('STU207','OC1',TO_DATE('2019-12-31','YYYY-MM-DD'));
EXEC PRC_SC_INSERT('STU208','OC2',TO_DATE('2019-01-31','YYYY-MM-DD'));
EXEC PRC_SC_INSERT('STU209','OC3',TO_DATE('2019-02-05','YYYY-MM-DD'));
EXEC PRC_SC_INSERT('STU2010','OC4',TO_DATE('2019-02-19','YYYY-MM-DD'));





------------------------------------------------------------------------------------------------------------

-- 11) 교수의 배점 입력 테이블
-- ② 교수가 배점 설정하는 프로시져 (매개변수 : OC_CODE(X), OS_CODE,배점,배점,배점)  
CREATE OR REPLACE PROCEDURE PRC_PRO_P_CPS(
V_OS_CODE      IN    OPEN_SUBJECT.OS_CODE%TYPE
,V_P_CHUL       IN    OPEN_SUBJECT.P_CHUL%TYPE
,V_P_SILGI      IN    OPEN_SUBJECT.P_SILGI%TYPE
,V_P_PILGI      IN    OPEN_SUBJECT.P_PILGI%TYPE
)
IS
TEMP_OS_CODE    OPEN_SUBJECT.OS_CODE%TYPE;
P_CPS_ERROR EXCEPTION;

BEGIN
    --OS_CODE가 없을 시 예외처리
    BEGIN
        SELECT OS_CODE INTO TEMP_OS_CODE
        FROM OPEN_SUBJECT
        WHERE OS_CODE =V_OS_CODE;
    
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN RAISE_APPLICATION_ERROR(-20001,'입력한 과목코드가 없습니다.'); 
                ROLLBACK;
    
   END; 
   
   IF(V_P_CHUL<=0 OR V_P_SILGI<=0 OR V_P_PILGI<=0)
     THEN RAISE P_CPS_ERROR;
   END IF;



    -- 입력받은 OS_CODE와 동일한 과목을 찾아서 배점을 UPDATE 해준다.
    UPDATE OPEN_SUBJECT
    SET P_CHUL=V_P_CHUL ,P_SILGI= V_P_SILGI ,P_PILGI= V_P_PILGI
    WHERE OS_CODE=V_OS_CODE;  
    
    
    EXCEPTION
        WHEN P_CPS_ERROR
        THEN RAISE_APPLICATION_ERROR(-20007,'배점이 유효하지 않습니다.');
  
END;

--체크 제약조건 확인
EXEC PRC_PRO_P_CPS('OS3',50,50,50);

--과목 코드가 없을 때
EXEC PRC_PRO_P_CPS('OS425',20,30,30);

--유효하지 않은 배점을 넣었을때
EXEC PRC_PRO_P_CPS('OS3',-5,50,50);

-- 확인
EXEC PRC_PRO_P_CPS('OS3',20,30,50);


--11 - 1) 교수 배점 더미 데이터 입력 
EXEC PRC_PRO_P_CPS('OS1',20,30,50);
EXEC PRC_PRO_P_CPS('OS2',30,20,50);
EXEC PRC_PRO_P_CPS('OS3',30,30,40);
EXEC PRC_PRO_P_CPS('OS4',25,25,50);
EXEC PRC_PRO_P_CPS('OS5',20,30,50);
EXEC PRC_PRO_P_CPS('OS6',30,20,50);
EXEC PRC_PRO_P_CPS('OS7',30,30,40);
EXEC PRC_PRO_P_CPS('OS8',25,25,50);
EXEC PRC_PRO_P_CPS('OS9',20,30,50);
EXEC PRC_PRO_P_CPS('OS10',30,20,50);
EXEC PRC_PRO_P_CPS('OS11',30,30,40);
EXEC PRC_PRO_P_CPS('OS12',25,25,50);
EXEC PRC_PRO_P_CPS('OS13',20,30,50);
EXEC PRC_PRO_P_CPS('OS14',30,20,50);
EXEC PRC_PRO_P_CPS('OS15',30,30,40);
EXEC PRC_PRO_P_CPS('OS16',25,25,50);
EXEC PRC_PRO_P_CPS('OS17',25,25,50);
EXEC PRC_PRO_P_CPS('OS18',25,25,50);
EXEC PRC_PRO_P_CPS('OS19',25,25,50);
EXEC PRC_PRO_P_CPS('OS20',25,25,50);


--------------------------------------------------------------------------------------------------------------------------
--12)교수자 기능) 성적 입력 프로시저 

DESC GRADE;

CREATE OR REPLACE PROCEDURE PRC_GRADE_UPDATE
(V_GRADE_CODE     IN  GRADE.GRADE_CODE%TYPE
,V_S_CHUL         IN  GRADE.S_CHUL%TYPE
,V_S_PILGI        IN  GRADE.S_PILGI%TYPE
,V_S_SILGI        IN  GRADE.S_SILGI%TYPE
)
IS
TEMP_GRADE_CODE      GRADE.GRADE_CODE%TYPE;
TEMP_OS_CODE         GRADE.OS_CODE%TYPE;
TEMP_P_CHUL              OPEN_SUBJECT.P_CHUL%TYPE;
TEMP_P_SILGI             OPEN_SUBJECT.P_SILGI%TYPE;
TEMP_P_PILGI             OPEN_SUBJECT.P_PILGI %TYPE;
JUMSU_ERROR          EXCEPTION; -- 교수가 입력한 배점을 초과했을 때 일어나는 예외
BEGIN

    SELECT GRADE_CODE,OS_CODE INTO TEMP_GRADE_CODE,TEMP_OS_CODE
    FROM GRADE
    WHERE GRADE_CODE = V_GRADE_CODE;
    
    
    SELECT P_CHUL,P_SILGI,P_PILGI INTO TEMP_P_CHUL,TEMP_P_SILGI,TEMP_P_PILGI 
    FROM OPEN_SUBJECT 
    WHERE OS_CODE = TEMP_OS_CODE;
    
    
    IF(V_S_PILGI >TEMP_P_PILGI OR V_S_SILGI >TEMP_P_SILGI OR V_S_CHUL > TEMP_P_CHUL)
        THEN RAISE JUMSU_ERROR;
    END IF;
    
    UPDATE GRADE
    SET S_PILGI=V_S_PILGI , S_SILGI=V_S_SILGI , S_CHUL=V_S_CHUL
    WHERE GRADE_CODE=V_GRADE_CODE;
    
    EXCEPTION
        WHEN JUMSU_ERROR
            THEN RAISE_APPLICATION_ERROR(-20030,'점수가 초과하였습니다.');
        WHEN NO_DATA_FOUND
            THEN RAISE_APPLICATION_ERROR(-20011,'입력하신 성적코드가 존재하지 않습니다.');  
    
END;

-- 점수 더미데이터 입력
EXEC PRC_GRADE_UPDATE('GRD2',20,20,30);
EXEC PRC_GRADE_UPDATE('GRD3',10,20,20);
EXEC PRC_GRADE_UPDATE('GRD3',20,20,20);
EXEC PRC_GRADE_UPDATE('GRD4',20,23,20);
EXEC PRC_GRADE_UPDATE('GRD5',20,20,30);
EXEC PRC_GRADE_UPDATE('GRD6',10,20,20);
EXEC PRC_GRADE_UPDATE('GRD7',20,10,20);
EXEC PRC_GRADE_UPDATE('GRD8',20,23,20);
EXEC PRC_GRADE_UPDATE('GRD9',16,9,20);
EXEC PRC_GRADE_UPDATE('GRD10',10,11,23);
EXEC PRC_GRADE_UPDATE('GRD11',20,22,20);
EXEC PRC_GRADE_UPDATE('GRD12',20,23,20);
EXEC PRC_GRADE_UPDATE('GRD13',20,20,20);
EXEC PRC_GRADE_UPDATE('GRD14',10,10,20);
EXEC PRC_GRADE_UPDATE('GRD15',20,11,20);
EXEC PRC_GRADE_UPDATE('GRD16',20,23,20);
EXEC PRC_GRADE_UPDATE('GRD17',13,20,24);
EXEC PRC_GRADE_UPDATE('GRD18',10,20,20);
EXEC PRC_GRADE_UPDATE('GRD19',20,13,20);
EXEC PRC_GRADE_UPDATE('GRD20',20,23,20);
EXEC PRC_GRADE_UPDATE('GRD21',13,9,20);
EXEC PRC_GRADE_UPDATE('GRD22',10,21,23);
EXEC PRC_GRADE_UPDATE('GRD23',20,22,20);
EXEC PRC_GRADE_UPDATE('GRD24',20,23,20);

SELECT *
FROM GRADE;

--커밋
COMMIT;