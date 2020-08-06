-- 1. 관리자 로그인 함수   ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION FN_MIDPW(IN_ID VARCHAR2, IN_PW VARCHAR2)
RETURN NUMBER
IS
  N_RESULT NUMBER; 
  MNG_ID  MANAGER.M_ID%TYPE;
  MNG_PW  MANAGER.M_PW%TYPE;
  FLAG    NUMBER;
BEGIN
    --아이디가 존재하는지 체크하는 부분  
    
        BEGIN
            SELECT M_ID INTO MNG_ID
            FROM MANAGER
            WHERE M_ID = IN_ID;
            
            EXCEPTION
                WHEN NO_DATA_FOUND
                        THEN RAISE_APPLICATION_ERROR(-20001,'아이디가 존재하지 않습니다..'); 
        END;
       
          
    -- 아이디가 존재한다면 패스워드 맞는지 확인
      SELECT M_PW INTO MNG_PW
      FROM MANAGER
      WHERE M_ID = IN_ID;
   
   
       IF (IN_PW = MNG_PW)
            THEN N_RESULT :=  1;
       ELSE
            N_RESULT :=  -1;
           
        END IF;
 
    RETURN N_RESULT;
END;
--정책) 1이면 아이디 패스워드 일치 -1이면 아이디 패스워드 불일치

--더미 데이터 입력
INSERT INTO MANAGER
VALUES('TEAM4','java006$');

SELECT *
FROM MANAGER;
--==>TEAM4	java006$

-- [ 테스트 ]---------

--비밀번호 오류
SELECT FN_MIDPW('TEAM4','Hava006$')
FROM DUAL;
--==>>-1

--없는 아이디
SELECT FN_MIDPW('TEAM3','Java006$')
FROM DUAL;
--==>>ORA-20005: 아이디가 없습니다.

--맞는 아이디/패스워드
SELECT FN_MIDPW('TEAM4','java006$')
FROM DUAL;
--==>>1



------------------------------------------------------------------------------------------------------------------------

-- 2. 교수가 배점 설정하는 프로시져 (매개변수 : OC_CODE(X), OS_CODE,배점,배점,배점)  

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
        THEN RAISE_APPLICATION_ERROR(-20002,'입력한 과목코드가 없습니다.'); 
                ROLLBACK;
    
   END; 
   
   IF(V_P_CHUL<=0 OR V_P_SILGI<=0 OR V_P_PILGI<=0)
     THEN RAISE P_CPS_ERROR;
   END IF;



    -- 입력받은 OS_CODE와 동일한 과목을 찾아서 배점을 UPDATE 해준다.
    UPDATE OPEN_SUBJECT
    SET P_CHUL=V_P_CHUL ,P_SILGI= V_P_SILGI ,P_PILGI= V_P_PILGI
    WHERE OS_CODE=V_OS_CODE;  
    
    --커밋
    COMMIT;
    
    EXCEPTION
        WHEN P_CPS_ERROR
        THEN RAISE_APPLICATION_ERROR(-20003,'배점이 유효하지 않습니다.');
  
END;

--==>>Procedure PRC_PRO_P_CPS이(가) 컴파일되었습니다.



-- [ 테스트 ]---------

--체크 제약조건 확인
EXEC PRC_PRO_P_CPS('OS3',50,50,50);

--과목 코드가 없을 때
EXEC PRC_PRO_P_CPS('OS425',20,30,30);

--유효하지 않은 배점을 넣었을때
EXEC PRC_PRO_P_CPS('OS3',-5,50,50);

-- 확인
EXEC PRC_PRO_P_CPS('OS3',20,30,50);



-- 3. 교수 입력 프로시저 ---------------------------------------------------------------------------------
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
        
        --커밋
        COMMIT;
END;

SELECT *
FROM PROFESSOR;
/*
PRO201   김호진   861230-1012546   1012546
PRO202   좌민혜   581030-2028857   2028857
PRO203   문승중   960712-1023597   1023597
PRO204   전진   970129-2065621   2065621
PRO205   암효림   960730-2065411   2065411
*/

-- [ 테스트 ]----------
--교수 시퀀스 생성은 INSERT_DATA에서 완료.

-- 실행
EXEC PRC_PRO_INSERT('김이주','97031-1234567');

SELECT *
FROM PROFESSOR;
--==>>
/*
PRO201   김호진   861230-1012546   1012546
PRO202   좌민혜   581030-2028857   2028857
PRO203   문승중   960712-1023597   1023597
PRO204   전진   970129-2065621   2065621
PRO205   암효림   960730-2065411   2065411
PRO2021   김이주   97031-1234567   234567
*/

-- 4. 학생 입력 프로시저 -------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE PRC_STU_INSERT
(
    V_S_NAME    IN STUDENTS.S_NAME %TYPE
   ,V_S_SSN     IN STUDENTS.S_SSN %TYPE
)
IS
    V_COUNT     NUMBER(10);
    V_SIZE      NUMBER(20);
    USER_DEFINE_ERROR EXCEPTION;            -- 이미 존재하는 사용자 있을 때 예외처리 발생
    SSN_WRONG_ERROR EXCEPTION;              -- 주민번호가 유효하지 않을 때 예외처리 발생
BEGIN
        -- 주민번호 확인 1이면 이미 가입된 유저
        SELECT COUNT(*) INTO V_COUNT
        FROM STUDENTS
        WHERE S_SSN = V_S_SSN;
        
        -- 주민 번호 사이즈 검사
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
                THEN RAISE_APPLICATION_ERROR(-20004,'주민번호가 유효하지 않습니다.');
         WHEN USER_DEFINE_ERROR
                THEN RAISE_APPLICATION_ERROR(-20005,'이미 존재하는 사용자입니다..');         
            WHEN OTHERS 
                THEN ROLLBACK;

END;

--[ 테스트 ]----------

SELECT *
FROM STUDENTS;
--==>>
/*
STU201   김동휘   950728-2123456   DNEHD1828
STU202   전진영   970129-2123457   2123457
STU203   문승주   960712-1123456   1123456
STU204   임효림   950728-2123458   2123458
STU205   주기연   990505-1123457   1123457
STU206   오진녕   930728-2123456   2123456
STU207   이채빈   950729-2133457   2133457
STU208   송수진   950712-1153456   1153456
STU209   장기혜   950828-2123458   2123458
STU2010   신성철   990505-1143457   1143457
*/
EXEC PRC_STU_INSERT('홍길동','980124-1233456');
--==>>PL/SQL 프로시저가 성공적으로 완료되었습니다.

SELECT *
FROM STUDENTS;
--==>>
/*
STU201   김동휘   950728-2123456   DNEHD1828
STU202   전진영   970129-2123457   2123457
STU203   문승주   960712-1123456   1123456
STU204   임효림   950728-2123458   2123458
STU205   주기연   990505-1123457   1123457
STU206   오진녕   930728-2123456   2123456
STU207   이채빈   950729-2133457   2133457
STU208   송수진   950712-1153456   1153456
STU209   장기혜   950828-2123458   2123458
STU2010   신성철   990505-1143457   1143457
STU2011   홍길동   980124-1233456   1233456
*/


--5. 과정 개설 프로시저  -----------------------------------------------------------------------------------
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
  WHERE (P_ID=V_P_ID OR R_CODE=V_R_CODE) AND V_OC_START BETWEEN OC_START AND OC_END;
  
  IF(OC_CHECK!=0)
    THEN RAISE INPUT_ERROR;
  END IF;

   --OC_CODE
   SELECT  MAX(SUBSTR(OC_CODE,3))+1 INTO V_OC_CODE
   FROM OPEN_COURSE;

    --데이터 입력 
    INSERT INTO OPEN_COURSE(OC_CODE,OC_START,OC_END,R_CODE,P_ID,C_CODE)
    VALUES('OC'||V_OC_CODE,V_OC_START,V_OC_END,V_R_CODE,V_P_ID,V_C_CODE);
  
  --커밋
  COMMIT;
  
  --예외처리
   EXCEPTION
   WHEN ROOM_ERROR
        THEN RAISE_APPLICATION_ERROR(-20006,'강의실이 등록되어 있지 않습니다');
        ROLLBACK;
   WHEN PROFESSOR_ERROR
        THEN RAISE_APPLICATION_ERROR(-20007,'교수번호가 등록되어 있지 않습니다');
        ROLLBACK;
   WHEN COURSE_ERROR
        THEN RAISE_APPLICATION_ERROR(-20008,'과정이 등록되어 있지 않습니다');
        ROLLBACK;
   WHEN INPUT_ERROR
        THEN RAISE_APPLICATION_ERROR(-20009,'교수와 강의실이 이미 등록되어 있습니다.');
        ROLLBACK;
   WHEN OTHERS
        THEN ROLLBACK;
   
END; 
  
--[ 테스트 ]---------

SELECT *
FROM OPEN_COURSE;
--==>>
/*
OC1   20/01/13   20/07/30   R6   PRO201   C1
OC2   20/02/09   20/08/21   R5   PRO202   C1
OC3   20/02/12   20/09/01   R4   PRO203   C2
OC4   20/02/20   20/09/21   R3   PRO204   C2
*/
--없는 교수일 때
EXEC PRC_COURSE_INPUT(TO_DATE('2021-04-10','YYYY-MM-DD'),TO_DATE('2021-05-10','YYYY-MM-DD'),'R1','imjin','C1');
--==>>ORA-20003: 교수번호가 등록되어 있지 않습니다 

--없는 강의실일 때
EXEC PRC_COURSE_INPUT(TO_DATE('2022-04-10','YYYY-MM-DD'),TO_DATE('2022-05-10','YYYY-MM-DD'),'R300','PRO201','C1');
--==>>ORA-20002: 강의실이 등록되어 있지 않습니다

--없는 과정 일 때
EXEC PRC_COURSE_INPUT(TO_DATE('2022-04-10','YYYY-MM-DD'),TO_DATE('2022-05-10','YYYY-MM-DD'),'R1','PRO201','C300');
--==>>ORA-20004: 과정이 등록되어 있지 않습니다

--개설된 강의들과 겹치지 않는 경우 
EXEC PRC_COURSE_INPUT(TO_DATE('2021-04-10','YYYY-MM-DD'),TO_DATE('2021-05-10','YYYY-MM-DD'),'R1','PRO201','C1');

SELECT *
FROM OPEN_COURSE;
--==>>입력 완료
/*
OC1   20/01/13   20/07/30   R6   PRO201   C1
OC2   20/02/09   20/08/21   R5   PRO202   C1
OC3   20/02/12   20/09/01   R4   PRO203   C2
OC4   20/02/20   20/09/21   R3   PRO204   C2
OC5   21/04/10   21/05/10   R1   PRO201   C1
*/

--이미 존재하는 경우
EXEC PRC_COURSE_INPUT(TO_DATE('2021-04-10','YYYY-MM-DD'),TO_DATE('2021-05-10','YYYY-MM-DD'),'R1','PRO201','C1');
--==>>ORA-20005: 교수와 강의실이 이미 등록되어 있습니다.

--같은 과정,기간에 다른 교수님이지만 강의실이 이미 사용 중
EXEC PRC_COURSE_INPUT(TO_DATE('2021-04-10','YYYY-MM-DD'),TO_DATE('2021-05-10','YYYY-MM-DD'),'R1','PRO202','C1');
--ORA-20005: 교수와 강의실이 이미 등록되어 있습니다.

--교수가 같은 기간,다른 강의실이지만 이미 수업 중인경우
EXEC PRC_COURSE_INPUT(TO_DATE('2020-01-20','YYYY-MM-DD'),TO_DATE('2020-07-10','YYYY-MM-DD'),'R2','PRO201','C1');
--ORA-20005: 교수와 강의실이 이미 등록되어 있습니다.


--------------------------------------------------------------------------------------------------------------------------

--6. 개설된 과정을 보여주는 뷰 생성

CREATE OR REPLACE VIEW VIEW_OPEN_COURSE
AS
SELECT  C.C_NAME"강의 이름",P.P_ID"교수번호",P.P_NAME"교수이름",OC.OC_START"시작일",OC.OC_END"과정종료일",R.R_NAME"강의실이름"
FROM PROFESSOR P,OPEN_COURSE OC,ROOM R,COURSE C
WHERE C.C_CODE=OC.C_CODE
    AND P.P_ID =OC.P_ID 
     AND OC.R_CODE=R.R_CODE;
     


-- VIEW_OPEN_COURSE 뷰 조회      
SELECT *
FROM VIEW_OPEN_COURSE;  
/*
DB개발자 양성과정   PRO204   전진   20/02/20   20/09/21    C강의실
DB개발자 양성과정   PRO203   문승중   20/02/12   20/09/01   D강의실
SW개발자 양성과정   PRO202   좌민혜   20/02/09   20/08/21   E강의실
SW개발자 양성과정   PRO201   김호진   20/01/13   20/07/30   F강의실
*/
---------------------------------------------------------------------------------------------------------------------------

--7. 개설된 과목을 보여주는 기능(뷰 생성)
-- 과목 확인
CREATE OR REPLACE VIEW VIEW_OPEN_SUBJECT
AS
SELECT OC.OC_CODE"과정코드",C_NAME"과정명", SUB_NAME"과목명"
,OS_START"과목시작일",OS_END"과목종료일", R_NAME "강의실", B_NAME"교재", P_NAME "교수자명"
FROM OPEN_COURSE OC JOIN OPEN_SUBJECT OS
ON OC.OC_CODE = OS.OC_CODE
JOIN COURSE C
ON C.C_CODE = OC.C_CODE
JOIN ROOM R
ON R.R_CODE = OC.R_CODE
JOIN PROFESSOR P
ON P.P_ID = OC.P_ID
JOIN SUBJECT S
ON S.SUB_CODE = OS.SUB_CODE
JOIN BOOK B
ON B.B_CODE = OS.B_CODE
ORDER BY 1 ;

-- 커밋
COMMIT;

-- VIEW_OPEN_SUBJECT 뷰 조회
SELECT *
FROM VIEW_OPEN_SUBJECT;
--==>>
/*
OC1   SW개발자 양성과정   HTML           20/04/13   20/05/12       F강의실   HTML 맛보기           김호진
OC1   SW개발자 양성과정   CSS            20/05/13   20/07/30       F강의실   CSS 맛보기            김호진
OC1   SW개발자 양성과정   오라클         20/02/13   20/02/12       F강의실   오라클의 정석         김호진
OC1   SW개발자 양성과정   자바           20/01/13   20/02/12       F강의실   자바의 정석           김호진
OC1   SW개발자 양성과정   자바스크립트   20/03/13   20/04/12       F강의실   자바스크립트의 정석   김호진
OC2   SW개발자 양성과정   자바스크립트   20/04/11   20/05/10       E강의실   자바스크립트의 정석   좌민혜
OC2   SW개발자 양성과정   오라클         20/03/11   20/04/10       E강의실   오라클의 정석         좌민혜
OC2   SW개발자 양성과정   자바           20/02/09   20/03/10       E강의실   자바의 정석           좌민혜
OC2   SW개발자 양성과정   CSS            20/06/11   20/08/21       E강의실   CSS 맛보기            좌민혜
OC2   SW개발자 양성과정   HTML           20/05/11   20/06/10       E강의실   HTML 맛보기           좌민혜
OC3   DB개발자 양성과정   HTML           20/03/16   20/04/15       D강의실   HTML 맛보기           문승중
OC3   DB개발자 양성과정   CSS            20/04/16   20/05/15       D강의실   CSS 맛보기            문승중
OC3   DB개발자 양성과정   자바스크립트   20/02/12   20/03/15       D강의실   자바스크립트의 정석   문승중
OC3   DB개발자 양성과정   데이터베이스   20/06/16   20/07/15       D강의실   데이터베이스 개론     문승중
OC3   DB개발자 양성과정   파이썬         20/07/16   20/09/01       D강의실   파이썬 기본           문승중
OC4   DB개발자 양성과정   CSS            20/04/20   20/05/19       C강의실   CSS 맛보기            전진
OC4   DB개발자 양성과정   자바스크립트   20/02/20   20/03/19       C강의실   자바스크립트의 정석   전진
OC4   DB개발자 양성과정   데이터베이스   20/05/20   20/06/19       C강의실   데이터베이스 개론     전진
OC4   DB개발자 양성과정   파이썬         20/06/20   20/09/21       C강의실   파이썬 기본           전진
OC4   DB개발자 양성과정   HTML           20/03/20   20/04/19       C강의실   HTML 맛보기           전진
*/

-- 8. 교수 정보 수정 프로시저-------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE PRC_PRO_UPDATE
(   V_P_ID     IN      PROFESSOR.P_ID%TYPE
,   V_P_NAME   IN      PROFESSOR.P_NAME%TYPE
,   V_P_PW     IN      PROFESSOR.P_PW%TYPE
)
IS
    COMPARE_P_ID      PROFESSOR.P_ID%TYPE;
BEGIN
    
    BEGIN
        SELECT P_ID  INTO COMPARE_P_ID
        FROM PROFESSOR
        WHERE P_ID = V_P_ID;
        
        EXCEPTION
            WHEN NO_DATA_FOUND
                THEN RAISE_APPLICATION_ERROR(-20001,'아이디가 존재 하지 않습니다.');
    END;
    
        SELECT P_ID  INTO COMPARE_P_ID
        FROM PROFESSOR
        WHERE P_ID = V_P_ID;
    
    
    UPDATE PROFESSOR
    SET P_NAME = V_P_NAME , P_PW =V_P_PW
    WHERE  P_ID = V_P_ID;    
    
    --커밋
    COMMIT;
    
END;

-- 교수 테이블 조회
SELECT *
FROM PROFESSOR;
--==>>
/*
PRO201   김호진   861230-1012546   1012546
PRO202   좌민혜   581030-2028857   2028857
PRO203   문승중   960712-1023597   1023597
PRO204   전진   970129-2065621   2065621
PRO205   암효림   960730-2065411   2065411
*/

--[ 테스트 ]---------

-- 아이디가 등록되어 있지 않을 때 예외처리
EXEC PRC_PRO_UPDATE('PRO224','좌민승','min234');
--==>> 에러발생 (ORA-20008: 아이디가 존재 하지 않습니다.)


-- 아이디가 등록된 아이디와 일치할 때 교수정보 업데이트
EXEC PRC_PRO_UPDATE('PRO202','좌민승','min234');
--==>> PL/SQL 프로시저가 성공적으로 완료되었습니다.

-- 프로시저 실행후 교수 테이블 조회
SELECT *
FROM PROFESSOR;
--==>>
/*
PRO201   김호진   861230-1012546   1012546
PRO202   좌민승   581030-2028857   min234
PRO203   문승중   960712-1023597   1023597
PRO204   전진   970129-2065621   2065621
PRO205   암효림   960730-2065411   2065411
*/

-- 9. 모든 교수자의 정보를 출력 (뷰생성)----------------------------------------------------------------------------
CREATE OR REPLACE VIEW VIEW_ALLPRO_INFO
AS
SELECT P_NAME "교수명",SUB_NAME"배정된과목",OS_START"과목시작일",OS_END"과목종료일",B_NAME"교재명", R_NAME"강의실명",
(
CASE WHEN  OS_START >= SYSDATE THEN '강의예정'
     WHEN  OS_END <= SYSDATE THEN '강의종료'
     ELSE '강의진행중'
     END
)"강의 진행 여부"

FROM PROFESSOR P JOIN OPEN_COURSE OC  
ON P.P_ID = OC.P_ID 
JOIN ROOM R
ON OC.R_CODE=R.R_CODE
JOIN OPEN_SUBJECT OS
ON OS.OC_CODE =OC.OC_CODE
JOIN SUBJECT S
ON S.SUB_CODE = OS.SUB_CODE
JOIN BOOK B
ON B.B_CODE = OS.B_CODE
ORDER BY P_NAME;
--==>> View VIEW_ALLPRO_INFO이(가) 생성되었습니다.

-- 뷰 조회
SELECT *
FROM VIEW_ALLPRO_INFO;
--==>>
/*
김호진   CSS               20/05/13   20/07/30       CSS 맛보기           F강의실   강의예정
김호진   오라클           20/02/13   20/02/12       오라클의 정석       F강의실   강의종료
김호진   HTML           20/04/13   20/05/12       HTML 맛보기           F강의실   강의예정
김호진   자바스크립트   20/05/30   20/06/12       자바스크립트의 정석   F강의실   강의예정
김호진   자바스크립트   20/03/13   20/04/12       자바스크립트의 정석   F강의실   강의종료
문승중   파이썬           20/07/16   20/09/01       파이썬 기본           D강의실   강의예정
문승중   데이터베이스   20/06/16   20/07/15       데이터베이스 개론   D강의실   강의예정
문승중   CSS               20/04/16   20/05/15       CSS 맛보기           D강의실   강의예정
문승중   HTML           20/03/16   20/04/15       HTML 맛보기           D강의실   강의진행중
문승중   자바스크립트   20/02/12   20/03/15       자바스크립트의 정석   D강의실   강의종료
전진   파이썬           20/06/20   20/09/21       파이썬 기본           C강의실   강의예정
전진   HTML           20/03/20   20/04/19       HTML 맛보기           C강의실   강의진행중
전진   데이터베이스   20/05/20   20/06/19       데이터베이스 개론   C강의실   강의예정
전진   CSS               20/04/20   20/05/19       CSS 맛보기           C강의실   강의예정
전진   자바스크립트   20/02/20   20/03/19       자바스크립트의 정석   C강의실   강의종료
좌민혜   HTML           20/05/11   20/06/10       HTML 맛보기           E강의실   강의예정
좌민혜   오라클           20/03/11   20/04/10       오라클의 정석       E강의실   강의종료
좌민혜   자바스크립트   20/04/11   20/05/10       자바스크립트의 정석   E강의실   강의진행중
좌민혜   CSS               20/06/11   20/08/21       CSS 맛보기           E강의실   강의예정
좌민혜   자바           20/02/09   20/03/10       자바의 정석           E강의실   강의종료
*/

-- 커밋
COMMIT;
----------------------------------------------------------------------------------------------------------------

--10. 삭제기능 교수 삭제 아이디를 입력했을 때 삭제해주는 프로시저
CREATE OR REPLACE PROCEDURE PRC_PRO_DELETE
(   V_P_ID     IN      PROFESSOR.P_ID%TYPE -- 입력받을 교수ID
)
IS
    COMPARE_P_ID      PROFESSOR.P_ID%TYPE;
    FLAG    NUMBER(1);
BEGIN
    
    -- 아이디가 존재하지 않을 때 예외처리
    BEGIN
        SELECT P_ID  INTO COMPARE_P_ID
        FROM PROFESSOR
        WHERE P_ID = V_P_ID;
        
        EXCEPTION
            WHEN NO_DATA_FOUND
                THEN RAISE_APPLICATION_ERROR(-20001,'아이디가 존재하지 않습니다.');
    END;
    
      
    
    DELETE
    FROM PROFESSOR
    WHERE P_ID =V_P_ID;
    
    --커밋
    --COMMIT;

END;
--==>> Procedure PRC_PRO_DELETE이(가) 컴파일되었습니다.


-- 교수 테이블 조회
SELECT *
FROM PROFESSOR;
--==>> 
/*
PRO201   김호진   861230-1012546   1012546
PRO202   좌민혜   581030-2028857   2028857
PRO203   문승중   960712-1023597   1023597
PRO204   전진   970129-2065621   2065621
PRO205   암효림   960730-2065411   2065411
*/

--[ 테스트 ]--------

--아이디가 존재 하지 않을 때 테스트
EXEC PRC_PRO_DELETE('123');
--==>> ORA-20008: 아이디가 존재하지 않습니다.

EXEC PRC_PRO_DELETE('PRO204');
--==>> PL/SQL 프로시저가 성공적으로 완료되었습니다.

SELECT *
FROM PROFESSOR;
--==>>
/*
PRO201   김호진   861230-1012546   1012546
PRO202   좌민혜   581030-2028857   2028857
PRO203   문승중   960712-1023597   1023597
PRO205   암효림   960730-2065411   2065411
*/
-------------------------------------------------------------------------------------------------------------------------------

--11.학생 로그인 기능(함수사용)

CREATE OR REPLACE FUNCTION FN_STUDENT_LOGIN(
V_S_ID            STUDENTS.S_ID%TYPE
,V_S_PW           STUDENTS.S_PW%TYPE
)
RETURN  NUMBER
IS
TEMP_S_ID      STUDENTS.S_ID%TYPE;
TEMP_S_PW    STUDENTS.S_PW%TYPE;
V_SCCODE      STUDENT_COURSE.SC_CODE%TYPE;
DS_CK              NUMBER;
FLAG                NUMBER;
BEGIN 

    -- 입력한 아이디와 동일한 아이디가 있는지 조회  
    SELECT S_ID   INTO TEMP_S_ID 
    FROM STUDENTS
    WHERE S_ID = V_S_ID;
    
    
    
    --입력한 아이디가 존재 할때 패스워드 조회
    SELECT S_PW  INTO TEMP_S_PW
    FROM STUDENTS
    WHERE S_ID =V_S_ID;
    
  
     -- 패스워드가 일치 하지 않을 때 -1 아이디와 패스워드가 모두 일치하면 1,  중도탈락 학생이면 3
    IF(TEMP_S_PW = V_S_PW)
        THEN FLAG := 1 ;
    ELSE
             FLAG := -1;
    END IF;  
    
    SELECT COUNT(DS.SC_CODE) INTO DS_CK
    FROM STUDENT_COURSE SC, DROP_STUDENTS DS
    WHERE V_S_ID = S_ID AND FLAG = 1 AND SC.SC_CODE = DS.SC_CODE;
    
    IF (FLAG = 1 AND DS_CK != 0)
        THEN FLAG :=3;
    ELSIF( FLAG = 1 AND DS_CK =0)
           THEN FLAG := 1 ;
    ELSE FLAG := -1;
    END IF;
    
    
    RETURN FLAG; -- 예외처리 위에 있어야한다

    
    -- 아이디 또는 비밀번호가 없을 때 예외처리
    EXCEPTION
        WHEN NO_DATA_FOUND
            THEN    RAISE_APPLICATION_ERROR(-20010,'아이디 또는 비밀번호가 일치하지 않습니다.');
    
END;

 

-- [ 테스트 ]--------------

--1.  아이디와 패스워드가 일치할 때 
SELECT FN_STUDENT_LOGIN('STU201','2123456')
FROM DUAL;
--==>> 1

--2. 아이디만 일치하지 않을 때
SELECT FN_STUDENT_LOGIN('STU','2123456')
FROM DUAL;
--==>> 에러 발생
--(ORA-20013: 아이디 또는 비밀번호가 일치하지 않습니다.)

--3. 패스워드만 일치하지 않을 때
SELECT FN_STUDENT_LOGIN('STU201','2123')
FROM DUAL;
--==>> -1

--4. 아이디와 패스워드가 모두 일치하지 않을 때
SELECT FN_STUDENT_LOGIN('ST1','215685855')
FROM DUAL;
--==>> 에러 발생
--(ORA-20013: 아이디 또는 비밀번호가 일치하지 않습니다.)

--5. 중도탈락학생이 로그인 했을 때
SELECT FN_STUDENT_LOGIN('STU203','1123456')
FROM DUAL;
--==>> 3


------------------------------------------------------------------------------------------------------------------------------------

--12.등록된 과정 수정(* 과정명수정(),과정기간,강의실번호,교수명 )프로시저

--과정코드,과정시작일,과정종료일,교수자명,강의실명 입력
CREATE OR REPLACE PROCEDURE PRO_OC_UPDATE
( V_OC_CODE IN OPEN_COURSE.OC_CODE%TYPE
, V_C_CODE IN  COURSE.C_CODE%TYPE
, V_OC_START IN OPEN_COURSE.OC_START%TYPE
, V_OC_END   IN OPEN_COURSE.OC_END%TYPE
, V_R_NAME   IN ROOM.R_NAME%TYPE
, V_P_NAME   IN PROFESSOR.P_NAME%TYPE 
)
IS
--(개설된 강좌,강의실,교수님)코드
 
  V_R_CODE     ROOM.R_CODE%TYPE;
  V_P_ID     PROFESSOR.P_ID%TYPE;

--존재하는지 확인
  C_CHECK      NUMBER; --입력한 과정명이 생성되어 있는지 체크하기 위해
  R_CHECK      NUMBER; --입력한 강의실이 강의실 테이블에 있는지 체크하기 위해
  P_CHECK      NUMBER;-- 입력한 교수이름이 교수자 테이블에 있는지 체크하기 위해
  DATE_CK  NUMBER; --업데이트 하려는 날짜가 개설된 과정들 날짜 사이에 있는지 체크
  TABLE_CK    NUMBER; --강의실이 사용중인지,교수가 수업중인지 체크
  
--에러 생성
 OC_CODE_ERROR EXCEPTION;
 OC_ROOM_ERROR EXCEPTION;
 OC_PROFESSOR_ERROR EXCEPTION;
 EXIST_ERROR EXCEPTION;
BEGIN

--입력한 과정코드가 과정테이블에 생성되어 있는지 조회
    SELECT COUNT(*) INTO C_CHECK  --있으면 1반환,없으면 0반환 후 에러
    FROM COURSE
    WHERE C_CODE = V_C_CODE;

    
    --존재 안 한다면 에러
    IF(C_CHECK =0)
       THEN RAISE OC_CODE_ERROR;
    END IF;

    
--입력한 강의실 이름이 과정테이블에 생성되어 있는지 조회
    SELECT COUNT(*) INTO R_CHECK  --있으면 1반환,없으면 0반환 후 에러
    FROM ROOM
    WHERE R_NAME = V_R_NAME;
    
    --존재 안 한다면 에러
    IF(R_CHECK =0)
       THEN RAISE OC_ROOM_ERROR;
    END IF;
    
    --코드번호 반환
    SELECT R_CODE INTO V_R_CODE
    FROM ROOM
    WHERE R_NAME = V_R_NAME;
    
--입력한 교수이름이 과정테이블에 생성되어 있는지 조회
    SELECT COUNT(*) INTO P_CHECK  --있으면 1반환,없으면 0반환 후 에러
    FROM PROFESSOR
    WHERE P_NAME = V_P_NAME;
    
    --존재 안 한다면 에러
    IF(P_CHECK =0)
       THEN RAISE OC_PROFESSOR_ERROR;
    END IF;
    
    --교수번호 반환
    SELECT P_ID INTO V_P_ID
    FROM PROFESSOR
    WHERE P_NAME = V_P_NAME;

--업데이트 하려는 정보가 기존테이블에 있는 정보면 오류

SELECT COUNT(*) INTO DATE_CK
FROM OPEN_COURSE
WHERE (V_OC_START BETWEEN OC_START AND OC_END AND OC_CODE != V_OC_CODE); --바꾸려는 강의코드의 행은 제외
--업데이트 시작 날짜가 기존개설된 날짜들 사이에 있다면 교수님,강의실은 겹칠 수 없음


SELECT COUNT(*) INTO TABLE_CK --기존에 있는 교수아이디와 강의실 코드는 안됨
FROM OPEN_COURSE
WHERE (R_CODE =V_R_CODE OR  P_ID = V_P_ID )AND OC_CODE=V_OC_CODE;

IF(DATE_CK !=0 )
  THEN  IF(TABLE_CK !=0)
                THEN RAISE EXIST_ERROR;
            END IF;
END IF;

--과정명,과정시작일,과정종료일,교수자명,강의실명 입력  
    UPDATE OPEN_COURSE
    SET 
        OC_START =V_OC_START
        ,OC_END = V_OC_END
        ,P_ID=V_P_ID
        ,R_CODE =V_R_CODE
        ,C_CODE = V_C_CODE
    WHERE OC_CODE=V_OC_CODE ;
    
    --커밋 
    COMMIT;
    
  
    --예외처리
   EXCEPTION
   WHEN OC_ROOM_ERROR
        THEN RAISE_APPLICATION_ERROR(-20006,'강의실이 등록되어 있지 않습니다');
        ROLLBACK;
   WHEN OC_PROFESSOR_ERROR
        THEN RAISE_APPLICATION_ERROR(-20014,'교수번호가 등록되어 있지 않습니다');
        ROLLBACK;
   WHEN OC_CODE_ERROR 
        THEN RAISE_APPLICATION_ERROR(-20008,'과정이 등록되어 있지 않습니다');
        ROLLBACK;
    WHEN EXIST_ERROR
        THEN RAISE_APPLICATION_ERROR(-20009,'업데이트 하려는 교수님이나 강의실이 이미  등록되어 있습니다.');
        ROLLBACK;
   WHEN OTHERS
      THEN ROLLBACK;
   
    
  
END;


-- [ 테스트 ]---------

--개설된과정코드, 과정코드, 개설과정시작일, 개설과정종료일, 강의실명, 교수명 
--1. 수정할 과정명이 생성되어 있는지 체크 (개설된 과정에 과정명을 바꿀 때 입력한 과정이 과정 테이블에 없을 때 수정할 수 없음)
EXEC PRO_OC_UPDATE('OC1','C0',TO_DATE('2020-01-13','YYYY-MM-DD'),TO_DATE('2020-07-30','YYYY-MM-DD'),'F강의실','김호진');
--==>> 에러 발생
--(ORA-20008: 과정이 등록되어 있지 않습니다)

--2. 수정할 강의실이 강의실 테이블에 있는지 체크 (없는 강의실 수정할 수 없음)
EXEC PRO_OC_UPDATE('OC1','C1',TO_DATE('2020-01-13','YYYY-MM-DD'),TO_DATE('2020-07-30','YYYY-MM-DD'),'강의실','김호진');
--==>> 에러 발생
--(ORA-20006: 강의실이 등록되어 있지 않습니다)

--3. 입력한 교수이름이 교수자 테이블에 있는지 체크 (수정할 교수가 없을 때 수정 할 수 없음)
EXEC PRO_OC_UPDATE('OC1','C1',TO_DATE('2020-01-13','YYYY-MM-DD'),TO_DATE('2020-07-30','YYYY-MM-DD'),'F강의실','김하나');
--==>> 에러 발생
--(ORA-20007: 교수번호가 등록되어 있지 않습니다)

--4. 업데이트 하려는 날짜가 개설된 과정들 날짜 사이에 있는지 체크 (수정할 과정기간에 이미 수강중인 교수님은 수정할 수 없다.)
EXEC PRO_OC_UPDATE('OC1','C1',TO_DATE('2020-02-09','YYYY-MM-DD'),TO_DATE('2020-08-21','YYYY-MM-DD'),'F강의실','좌민혜');
--==>> 에러 발생
--(ORA-20009: 업데이트 하려는 교수님이나 강의실이 이미  등록되어 있습니다.)

--5. 강의실이 사용중인지,교수가 수업중인지 체크 (수정할 과정기간에 이미 수정할 강의실과, 교수명이 같을 때 수정 할 수 없다.)
EXEC PRO_OC_UPDATE('OC1','C1',TO_DATE('2020-02-09','YYYY-MM-DD'),TO_DATE('2020-08-21','YYYY-MM-DD'),'E강의실','좌민혜');
--==>> 에러 발생
--(ORA-20009: 업데이트 하려는 교수님이나 강의실이 이미  등록되어 있습니다.)

-- 6. 강의실과 과정기간이 같을 때
EXEC PRO_OC_UPDATE('OC1','C1',TO_DATE('2020-02-09','YYYY-MM-DD'),TO_DATE('2020-08-21','YYYY-MM-DD'),'E강의실','김호진');
--==>> 에러 발생
--(ORA-20009: 업데이트 하려는 교수님이나 강의실이 이미  등록되어 있습니다.)

-- 7. 과정기간이 같지만 강의실만 다를 때
-- 수정 전
--==>> OC1   20/01/13   20/07/30   R6   PRO201   C1

-- 수정 후
EXEC PRO_OC_UPDATE('OC1','C1',TO_DATE('2020-02-09','YYYY-MM-DD'),TO_DATE('2020-08-21','YYYY-MM-DD'),'F강의실','김호진');
--==>> 
/*
PL/SQL 프로시저가 성공적으로 완료되었습니다.

OC1   20/02/09   20/08/21   R6   PRO201   C1              1-13 ~ 7-30 에서 과정 기간이 달라짐  
*/
-- 교수테이블에 교수가 있고 개설된 과정의 과정명이 있고, 과정기간과 강의실이 겹치지 않을 때 
-- 수정 전
--==>> OC1   20/01/13   20/07/30   R6   PRO201   C1

-- 수정 후
EXEC PRO_OC_UPDATE('OC1','C1',TO_DATE('2020-05-09','YYYY-MM-DD'),TO_DATE('2020-06-21','YYYY-MM-DD'),'E강의실','문승중');
--==>> 
/*
PL/SQL 프로시저가 성공적으로 완료되었습니다.

OC1   20/05/09   20/06/21   R5   PRO203   C2                     기간과 교수, 강의실 모두 바뀐 것을 확인 할 수 있다.
*/


-- 8. 담당 교수만 변경
-- 수정 전
--==>> OC1   20/01/13   20/07/30   R6   PRO201     C1

-- 수정 후
EXEC PRO_OC_UPDATE('OC1','C1',TO_DATE('2020-01-13','YYYY-MM-DD'),TO_DATE('2020-07-30','YYYY-MM-DD'),'F강의실','좌민혜');
--==>> 
/*
PL/SQL 프로시저가 성공적으로 완료되었습니다.

OC1   20/01/13   20/07/30   R6   PRO202   C1          담당 교수가 PRO201 -> PRO202로 바뀐 걸 확인 할 수 있다.
*/

----------------------------------------------------------------------------------------------------------------------------------------

--13. 교수 로그인 기능 (함수사용)

CREATE OR REPLACE FUNCTION FN_PIDPW(IN_PID VARCHAR2, IN_PPW VARCHAR2)
RETURN NUMBER
IS
    V_PID        PROFESSOR.P_ID%TYPE;
    V_PPW      PROFESSOR.P_PW%TYPE;
    P_RESULT NUMBER;
BEGIN 
    BEGIN
        --ID 가 일치하는지 안하는지 확인
        SELECT P_ID INTO V_PID
        FROM PROFESSOR
        WHERE P_ID = IN_PID;
        
       -- ID가 일치하지 않으면 예외처리
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN RAISE_APPLICATION_ERROR(-20010, '아이디 또는 비밀번호가 일치하지 않습니다.');
    END;
    
    -- ID가 일치하면 PW 일치하는 지 확인
    SELECT P_PW INTO V_PPW
    FROM PROFESSOR
    WHERE P_ID = IN_PID;
    
    -- PW가 일치하지 않으면 -1
    IF(IN_PPW = V_PPW)
        THEN P_RESULT := 1;
    ELSE 
            P_RESULT := -1;
    END IF;
 RETURN P_RESULT;
END;

---------

-- [ 테스트 ]----------------
SELECT *
FROM PROFESSOR;
-- 1. 아이디만 일치하지 않을 때
SELECT FN_PIDPW('P201','1012546')
FROM DUAL;
--==>> 에러 발생
--(ORA-20011: 아이디 또는 비밀번호가 일치하지 않습니다.)

-- 2. 패스워드만 일치하지 않을 때
SELECT FN_PIDPW('PRO201','10002546')
FROM DUAL;
--==>> -1

-- 3. 아이디 패스워드 모두 일치하지 않을 때
SELECT FN_PIDPW('PRO','10002546')
FROM DUAL;
--==>> 에러 발생
--(ORA-20011: 아이디 또는 비밀번호가 일치하지 않습니다.)

-- 4. 아이디 패스워드 모두 일치했을 때
SELECT FN_PIDPW('PRO201','1012546')
FROM DUAL;
--==>> 1


---------------------------------------------------------------------------------------------------------------------------------------

--14.개설된 과정 삭제
CREATE OR REPLACE PROCEDURE PRO_OC_DELETE
(
    V_OC_CODE IN OPEN_COURSE.OC_CODE%TYPE
)
IS
BEGIN
    
    DELETE
    FROM OPEN_COURSE
    WHERE OC_CODE =V_OC_CODE;
    
    --커밋
    COMMIT;
   
END;

-------

-- [ 테스트 ]---------
SELECT *
FROM OPEN_COURSE;
--==>>
/*
OC1   20/01/13   20/07/30   R6   PRO201   C1
OC2   20/02/09   20/08/21   R5   PRO202   C1
OC3   20/02/12   20/09/01   R4   PRO203   C2
*/
-- 개설된 과정 OC3 삭제하기
EXEC PRO_OC_DELETE('OC3');

-- 삭제 후 개설된 과정 확인하기
SELECT *
FROM OPEN_COURSE;
--==>>
/*
OC1   20/01/13   20/07/30   R6   PRO201   C1
OC2   20/02/09   20/08/21   R5   PRO202   C1
*/
---------------------------------------------------------------------------------------------------------------------------
--15. 수강한 모든 학생 정보 출력 --데이터 다시 넣어서 확인하기
CREATE OR REPLACE VIEW VIEW_STUDENTS
AS
      SELECT DISTINCT S.S_NAME"학생이름", C.C_NAME "과정명", SUB.SUB_NAME"과목명"
                ,NVL((G.S_CHUL+G.S_SILGI+G.S_PILGI), 0)"총점"
                FROM STUDENTS S ,STUDENT_COURSE SC,OPEN_COURSE OC,GRADE G,OPEN_SUBJECT OS,SUBJECT SUB,COURSE C,DROP_STUDENTS DS
                WHERE 
                    S.S_ID = SC.S_ID (+)
                   AND OC.OC_CODE = SC.OC_CODE
                   AND SC.SC_CODE = G.SC_CODE
                   AND OS.OS_CODE = G.OS_CODE
                   AND SUB.SUB_CODE = OS.SUB_CODE
                   AND C.C_CODE=OC.C_CODE
                   AND DS.SC_CODE(+) = SC.SC_CODE
            ORDER BY 1;
 
-- [ 테스트 ]---------           
SELECT *
FROM VIEW_STUDENTS;


--------------------------------------------------------------------------------------------------------------------------
--16. 학생정보 수정 프로시저 (학생아이디,학생이름,학생주민번호,학생비밀번호)
CREATE OR REPLACE PROCEDURE PRC_STU_UPDATE(
V_S_ID  IN  STUDENTS.S_ID%TYPE          --학생아이디
,V_S_NAME IN    STUDENTS.S_NAME%TYPE    --학생이름
,V_S_SSN    IN  STUDENTS.S_SSN%TYPE     --학생주민번호
,V_S_PW     IN  STUDENTS.S_PW%TYPE      --학생비밀번호
)
IS
TEMP_S_ID   STUDENTS.S_ID%TYPE;
BEGIN
    -- 입력된 아이디가 테이블에 있는지 조회
    SELECT S_ID INTO TEMP_S_ID
    FROM STUDENTS
    WHERE S_ID = V_S_ID;
    
    -- 입력된 데이터로 학생 데이터 수정
    UPDATE STUDENTS
    SET S_NAME=V_S_NAME , S_SSN = V_S_SSN , S_PW = V_S_PW
    WHERE S_ID = V_S_ID;
    
    --커밋
    COMMIT;
    
    
    --입력한 학생 아이디가 없을 때 예외처리
    EXCEPTION
        WHEN NO_DATA_FOUND
            THEN RAISE_APPLICATION_ERROR(-20011,'일치하는 학생이 없습니다.');
     
END;

--[ 테스트 ]-----------------
-- 학생 테이블 조회
SELECT *
FROM STUDENTS;
/*
STU201	김동휘	950728-2123456	2123456
STU202	전진영	970129-2123457	2123457
STU203	문승주	960712-1123456	1123456
STU204	임효림	950728-2123458	2123458
STU205	주기연	990505-1123457	1123457
STU206	오진녕	930728-2123456	2123456
STU207	이채빈	950729-2133457	2133457
STU208	송수진	950712-1153456	1153456
STU209	장기혜	950828-2123458	2123458
STU2010	신성철	990505-1143457	1143457
*/


--학생정보 수정 프로시저 테스트 (학생아이디,학생이름,학생주민번호,학생비밀번호)
-- ID가 일치 할때
EXEC PRC_STU_UPDATE('STU201','김동휘','950728-2123456','DNEHD1828');
--==>PL/SQL 프로시저가 성공적으로 완료되었습니다.
--==>수정 전 )STU201	김동휘	950728-2123456	2123456
--==>수정 후 )STU201	김동휘	950728-2123456	DNEHD1828

--ID가 일치 하지 않을 때
EXEC PRC_STU_UPDATE('KDH915','김동휘','950728-2123456','DNEHD1828');
--==>ORA-20010: 일치하는 학생이 없습니다.

----------------------------------------------------------------------------------------------------------------------------

--17. 개설된 과목 수정 프로시저
SELECT *
FROM OPEN_SUBJECT;
--과목코드,과목명,과목시작일,과목종료일,교재,출석,배점,실기 입력 받음

SELECT *
FROM SUBJECT;

CREATE OR REPLACE PROCEDURE  PRO_OC_UPDATE
(  V_OC_CODE IN OPEN_COURSE.OC_CODE%TYPE 
,  V_OS_CODE IN OPEN_SUBJECT.OS_CODE%TYPE
,  V_SUB_CODE  IN OPEN_SUBJECT.SUB_CODE%TYPE
,  V_OS_START IN  OPEN_SUBJECT.OS_START%TYPE
,  V_OS_END IN  OPEN_SUBJECT.OS_END%TYPE
,  V_B_CODE IN OPEN_SUBJECT.B_CODE%TYPE
,  V_P_CHUL IN OPEN_SUBJECT.P_CHUL%TYPE
,  V_P_SILGI  IN OPEN_SUBJECT.P_SILGI%TYPE
,  V_P_PILGI  IN OPEN_SUBJECT.P_PILGI%TYPE
)
IS
    S_CHECK  NUMBER; --입력한 과목이 과목테이블에 존재하는지 확인할 것
    B_CHECK  NUMBER;--입력한 교재가 교재테이블에 존재하는지
    
 
    --설정한 과목기간이 과정기간안에 있는지 확인하기 위해
    CK_OC_START OPEN_COURSE.OC_START%TYPE;
    CK_OC_END  OPEN_COURSE.OC_END%TYPE;
    
    NO_SUBJECT EXCEPTION;--과목테이블에 존재 안 할 때 에러
    NO_BOOK EXCEPTION;--교재가 교재테이블에 존재 안 할 때 에러
    DATE_ERROR EXCEPTION; --과목 기간이 잘못되었을 때 에러
BEGIN
 
     --존재하는 과목인지 확인
     SELECT COUNT(*) INTO S_CHECK
     FROM SUBJECT
     WHERE SUB_CODE = V_SUB_CODE;
     
     IF(S_CHECK=0) --존재 안 하면 에러
        THEN RAISE NO_SUBJECT;
     END IF;
     
     --존재하는 교재인지 확인
     SELECT COUNT(*)  INTO B_CHECK
     FROM BOOK
     WHERE B_CODE =V_B_CODE;
     
     IF(B_CHECK=0)
       THEN RAISE NO_BOOK;
    END IF;


    --입력받은 과정코드로 과정 기간 담음
    SELECT OC_START,OC_END INTO CK_OC_START,CK_OC_END
    FROM OPEN_COURSE
    WHERE OC_CODE = V_OC_CODE;
    
    IF(V_OS_START <CK_OC_START OR V_OS_END >CK_OC_END)
        THEN RAISE DATE_ERROR;
    END IF;



  --업데이트 문
  UPDATE OPEN_SUBJECT
  SET 
      SUB_CODE = V_SUB_CODE
      ,OS_START = V_OS_START
      ,OS_END = V_OS_END
      ,B_CODE = V_B_CODE
      ,P_CHUL = V_P_CHUL
      ,P_SILGI = V_P_SILGI
      ,P_PILGI = V_P_PILGI
  WHERE OS_CODE = V_OS_CODE;
  
    --커밋  
    COMMIT;
 
  EXCEPTION
  WHEN DATE_ERROR
     THEN RAISE_APPLICATION_ERROR(-20012,'과목의 날짜가 올바르지 않습니다.');
     ROLLBACK;
  WHEN NO_SUBJECT
     THEN RAISE_APPLICATION_ERROR(-20013,'해당 과목이 존재하지 않습니다.');
     ROLLBACK;
  WHEN NO_BOOK
    THEN RAISE_APPLICATION_ERROR(-20014,'해당 교재가 존재하지 않습니다.');
    ROLLBACK;
    --WHEN OTHERS
    --THEN ROLLBACK;
  
END;


--[ 테스트 ]---------

SELECT *
FROM OPEN_SUBJECT;
--변경 전
--==> OS1	SUB1	20/01/13	20/02/12	B1	OC1	20	30	50

--과목코드 바꾸기
EXEC PRO_OC_UPDATE('OC1','OS1','SUB3',TO_DATE('2020-05-30','YYYY-MM-DD'),TO_DATE('2020-06-12','YYYY-MM-DD'),'B3',20,40,40);
--변경 후 
--==>OS1	SUB3	20/05/30	20/06/12	B3	OC1	20	40	40

    
--과목 날짜가 과정 안에 포함 안 될 때
EXEC PRO_OC_UPDATE('OC1','OS1','SUB3',TO_DATE('202-05-30','YYYY-MM-DD'),TO_DATE('2002-06-12','YYYY-MM-DD'),'B3',20,40,40);
--==>ORA-20001: 과목의 날짜가 올바르지 않습니다.

--과목 없을 때
EXEC PRO_OC_UPDATE('OC1','OS1','SUB3',TO_DATE('2020-05-30','YYYY-MM-DD'),TO_DATE('2020-06-12','YYYY-MM-DD'),'B50',20,40,40);
--==>ORA-20003: 해당 교재가 존재하지 않습니다.


----------------------------------------------------------------------------------------------------------------------------

--18. 교수가 자신이 강의하는 과목을 출력
CREATE OR REPLACE PROCEDURE PRC_P_SUB_SELECT
( V_PID  IN PROFESSOR.P_ID%TYPE
, V_OUT OUT SYS_REFCURSOR
)
IS
BEGIN
    
     OPEN V_OUT FOR
     
      SELECT C.C_NAME "과정명", SUB.SUB_NAME"과목명", OS.OS_START"과목시작일", OS.OS_END"과목종료일"
        FROM PROFESSOR P, COURSE C, OPEN_COURSE OC, OPEN_SUBJECT OS, SUBJECT SUB
        WHERE P.P_ID = V_PID
                      AND P.P_ID = OC.P_ID
                     AND C.C_CODE = OC.C_CODE
                     AND SUB.SUB_CODE = OS.SUB_CODE
                     AND OC.OC_CODE = OS.OC_CODE ;
END;



-----
SET SERVEROUTPUT ON;

-- PRO201 교수가 강의하는 과목 출력 확인
DECLARE
V_CURSOR    SYS_REFCURSOR;

V_CNAME        COURSE.C_NAME%TYPE;
V_SUBNAME    SUBJECT.SUB_NAME%TYPE;
V_OSSTART     OPEN_SUBJECT.OS_START%TYPE;
V_OSEND         OPEN_SUBJECT.OS_END%TYPE;

BEGIN
    
    PRC_P_SUB_SELECT('PRO201',V_CURSOR);
  
    LOOP
   
        FETCH V_CURSOR INTO V_CNAME,V_SUBNAME,V_OSSTART,V_OSEND;

        EXIT WHEN V_CURSOR%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE(V_CNAME ||'  '|| V_SUBNAME ||'  '||V_OSSTART||'   '||V_OSEND);
        
    END LOOP;
END;
/*
SW개발자 양성과정  자바스크립트  20/05/30   20/06/12
SW개발자 양성과정  오라클  20/02/13   20/02/12
SW개발자 양성과정  자바스크립트  20/03/13   20/04/12
SW개발자 양성과정  HTML  20/04/13   20/05/12
SW개발자 양성과정  CSS  20/05/13   20/07/30
*/

-------------------------------------------------------------------------------------------------------------------------
--19.교수자 성적 입력 & 수정 프로시저 

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
JUMSU_UMSU           EXCEPTION; -- 점수가 음수값이 입력되었을 때 일어나는 예외
BEGIN

    SELECT GRADE_CODE,OS_CODE INTO TEMP_GRADE_CODE,TEMP_OS_CODE
    FROM GRADE
    WHERE GRADE_CODE = V_GRADE_CODE;
    
    
    SELECT P_CHUL,P_SILGI,P_PILGI INTO TEMP_P_CHUL,TEMP_P_SILGI,TEMP_P_PILGI 
    FROM OPEN_SUBJECT 
    WHERE OS_CODE = TEMP_OS_CODE;
    
    -- 입력한 점수가 교수가 입력한 배점보다 클 때 예외처리
    IF(V_S_PILGI >TEMP_P_PILGI OR V_S_SILGI >TEMP_P_SILGI OR V_S_CHUL > TEMP_P_CHUL)
        THEN RAISE JUMSU_ERROR;
    END IF;
    
    -- 입력한 점수가 음수 일 때 예외처리
    IF(V_S_PILGI< 0 OR V_S_SILGI <0 OR V_S_CHUL <0)
        THEN RAISE JUMSU_UMSU;
    END IF;
    
    UPDATE GRADE
    SET S_PILGI=V_S_PILGI , S_SILGI=V_S_SILGI , S_CHUL=V_S_CHUL
    WHERE GRADE_CODE=V_GRADE_CODE;
    
    EXCEPTION
        WHEN JUMSU_ERROR
            THEN RAISE_APPLICATION_ERROR(-20015,'점수가 초과하였습니다.');
        WHEN JUMSU_UMSU
            THEN RAISE_APPLICATION_ERROR(-20016,'잘못된 점수 입니다.');
        WHEN NO_DATA_FOUND
            THEN RAISE_APPLICATION_ERROR(-20017,'입력하신 성적코드가 존재하지 않습니다.');  
    
END;

--성적 테이블 조회
SELECT *
FROM GRADE;
/*
GRD1	SC1	    OS1	
--==> 성적이 들어가 있지 않을 상태
*/
SELECT *
FROM OPEN_SUBJECT;                    -- 과목OS1의 출결,실기,필기 배점
--==>OS1	SUB3	20/05/30	20/06/12	B3	OC1	20	40	40

-- 테스트-----------------------------------------------------------------------

-- 음수가 입력 되었을 때
EXEC PRC_GRADE_UPDATE('GRD1',-1,3,30);
--==>ORA-20012: 잘못된 점수 입니다.

--교수가 입력한 배점보다 초과 입력 되었을 때
EXEC PRC_GRADE_UPDATE('GRD1',30,3,30);
--==>ORA-20030: 점수가 초과하였습니다

-- 올바른 점수 입력 했을 때
EXEC PRC_GRADE_UPDATE('GRD1',20,33,30);
--==>GRD1	SC1	OS1	20	30	33

---------------------------------------------------------------------------------------------------------------------------
-- 20.중도탈락 학생 입력 프로시저
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
            THEN RAISE_APPLICATION_ERROR(-20018,'수강신청하지 않은 학생입니다.');
    
END;

-- 학생 정보 테이블 조회
SELECT *
FROM STUDENTS;
/*
STU201	김동휘	950728-2123456	DNEHD1828
STU202	전진영	970129-2123457	2123457
STU203	문승주	960712-1123456	1123456
STU204	임효림	950728-2123458	2123458
STU205	주기연	990505-1123457	1123457
STU206	오진녕	930728-2123456	2123456
STU207	이채빈	950729-2133457	2133457
STU208	송수진	950712-1153456	1153456
STU209	장기혜	950828-2123458	2123458
STU2010	신성철	990505-1143457	1143457
STU2011	홍길동	980124-1233456	1233456
*/

SELECT *
FROM DROP_STUDENTS;
--==>DS1	20/04/12	SC3



-----[ 테스트 ]-------------------------------------------------------------

-- 수강신청 하지 않은 학생이 중도 탈락 테이블에 입력 되는 경우
EXEC PRC_DROPSTU_INSERT('STU20S3',TO_DATE('2020-03-31','YYYY-MM-DD'));
--==>ORA-20013: 수강신청하지 않은 학생입니다.

-- 수강신청 한 학생이 중도 탈락 했을 경우
EXEC PRC_DROPSTU_INSERT('STU203',TO_DATE('2020-03-31','YYYY-MM-DD'));
/*
DS1	20/04/12	SC3
DS3	20/03/31	SC3
*/
---------------------------------------------------------------------------------------------------------------------------
-- 21. 수강신청 입력 프로시저
CREATE OR REPLACE PROCEDURE PRC_SC_INSERT(
 V_S_ID      IN  STUDENTS.S_ID%TYPE         -- 학생 아이디
,V_OC_CODE  IN  OPEN_COURSE.OC_CODE%TYPE    -- 개설된 과정 코드
,V_SC_DATE  IN  STUDENT_COURSE.SC_CODE%TYPE -- 수강 신청 날짜
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
    
    
    PRC_GRADE_INSERT(TEMP_SC_CODE); -- 수강신청 동시에 등록한 과정에 대한 과목들을 그 학생 수강과목 테이블에 넣어준다. 
     
    -- 예외처리
    EXCEPTION
        --학생 아이디가 없다면 예외처리
        WHEN NOT_SID_ERROR   
            THEN RAISE_APPLICATION_ERROR(-20001,'아이디가 존재하지 않습니다.');
        WHEN NOT_OCCODE_ERROR 
            THEN RAISE_APPLICATION_ERROR(-20008,'과정이 존재하지 않습니다.');
        WHEN CHECK_SC_ERROR
            THEN RAISE_APPLICATION_ERROR(-20019,'동일한 과정을 듣는 학생이 존재합니다.');
      
        --COMMIT;               
END;
  
 
 
 

--수강신청 동시에 등록한 과정에 대한 과목들을 그 학생 수강과목 테이블에 넣어주는 프로시져
CREATE OR REPLACE PROCEDURE PRC_GRADE_INSERT(
V_SC_CODE  IN  STUDENT_COURSE.SC_CODE%TYPE
)
IS

    V_OS_CODE      OPEN_SUBJECT.OS_CODE%TYPE;
    
    --입력받은 OS_CODE 와 일치하는 과목들을 커서에 넣어준다.
    CURSOR CUR_GRADE_SELECT
        IS        
        SELECT OS_CODE
        FROM STUDENT_COURSE SC,OPEN_COURSE OC,OPEN_SUBJECT OS
        WHERE OC.OC_CODE = SC.OC_CODE
          AND OS.OC_CODE = OC.OC_CODE
          AND SC_CODE=V_SC_CODE;
               
BEGIN

         -- 커서 오픈
        OPEN CUR_GRADE_SELECT;    
       
        LOOP
        -- OC_CODE와 일치하는 과목들을 하나씩 변수에 담는다
        FETCH CUR_GRADE_SELECT INTO  V_OS_CODE;
        
       
        EXIT WHEN CUR_GRADE_SELECT%NOTFOUND;       
        
        -- 변수에 담긴 데이터들 하나씩 학생 수강과목 테이블에 넣어준다.
        INSERT INTO GRADE(GRADE_CODE,SC_CODE,OS_CODE) 
        VALUES ('GRD'||TO_CHAR(GRADE_NUM.NEXTVAL), V_SC_CODE, V_OS_CODE);       
        END LOOP;
        CLOSE CUR_GRADE_SELECT;        
  
END;
----------------------------------------------------------------------------------------------------------------------------
-- (22)교수가 자신이 강의하는 과목의 학생들 출력
CREATE OR REPLACE PROCEDURE PRC_P_GRADE_VIEW
( V_P_ID  IN PROFESSOR.P_ID%TYPE
, V_OUT OUT SYS_REFCURSOR
)
IS
BEGIN
    
     OPEN V_OUT FOR
    
     
           SELECT  DISTINCT SUB.SUB_NAME"과목명", OS.OS_START"과목시작일", OS.OS_END"과목종료일",B.B_NAME"교재명", S.S_NAME"학생이름",G.S_CHUL"출석점수",G.S_SILGI"실기점수",G.S_PILGI"필기점수"
                ,(G.S_CHUL+G.S_SILGI+G.S_PILGI)"총점" ,RANK() OVER (PARTITION BY SUB.SUB_CODE ORDER BY  G.S_CHUL+G.S_SILGI+G.S_PILGI DESC )"등수"
                 ,(
                        CASE  WHEN DS.D_DATE BETWEEN OS.OS_START AND OS.OS_END THEN'중도탈락'
                               ELSE '수료'
                               END
                       
                
                )"중도탈락여부"
                FROM PROFESSOR P,STUDENTS S ,STUDENT_COURSE SC,OPEN_COURSE OC,GRADE G,OPEN_SUBJECT OS,SUBJECT SUB,COURSE C,DROP_STUDENTS DS,BOOK B
                WHERE  P.P_ID = V_P_ID
                   AND  P.P_ID=OC.P_ID
                   AND S.S_ID = SC.S_ID
                   AND OC.OC_CODE = SC.OC_CODE
                   AND SC.SC_CODE = G.SC_CODE
                   AND OS.OS_CODE = G.OS_CODE
                   AND SUB.SUB_CODE = OS.SUB_CODE
                   AND C.C_CODE=OC.C_CODE
                   AND OS.OS_END <=SYSDATE  
                   AND DS.SC_CODE(+) = SC.SC_CODE
                   AND B.B_CODE= OS.B_CODE;
        
        
        
END;




-----
SET SERVEROUTPUT ON;

-- 교수가 강의하는 과목 출력 확인
DECLARE
V_CURSOR    SYS_REFCURSOR; 
V_SUBNAME    SUBJECT.SUB_NAME%TYPE;
V_OSSTART     OPEN_SUBJECT.OS_START%TYPE;
V_OSEND         OPEN_SUBJECT.OS_END%TYPE;
V_BNAME        BOOK.B_NAME%TYPE;
V_SNAME        STUDENTS.S_NAME%TYPE;
V_GCHUL        GRADE.S_CHUL%TYPE;
V_GSILGI        GRADE.S_SILGI%TYPE;
V_GPILGI       GRADE.S_PILGI%TYPE;
V_TOTAL        NUMBER(3);
V_RANK          NUMBER(3);
V_DROP          VARCHAR2(30);

BEGIN
  
  



     PRC_P_GRADE_VIEW('PRO202',V_CURSOR);
  
    LOOP
   
        FETCH V_CURSOR INTO V_SUBNAME,V_OSSTART,V_OSEND,V_BNAME,V_SNAME,V_GCHUL,V_GSILGI,V_GPILGI,V_TOTAL,V_RANK,V_DROP  ;

        EXIT WHEN V_CURSOR%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE(V_SUBNAME ||'  '||V_OSSTART||'  '||V_OSEND||'  '||V_BNAME ||'  '||V_SNAME||'  '||V_GCHUL||'  '||V_GSILGI||'  '||V_GPILGI||'  '||V_TOTAL ||'  '||V_RANK||'  '||V_DROP);
        
    END LOOP;
END;
/*
오라클  20/03/11  20/04/10  오라클의 정석  송수진          1  수료
자바  20/02/09  20/03/10  자바의 정석  송수진          1  수료
오라클  20/03/11  20/04/10  오라클의 정석  문승주  20  20  23  63  2  중도탈락
자바  20/02/09  20/03/10  자바의 정석  문승주  20  20  22  62  2  수료


*/

----------------------------------------------------------------------------------------------------------------------------
SELECT *
FROM STUDENTS;

-- 23.학생이 자신이 수강한 학생명, 과정명, 과목명, 과목기간, 교재명, 출결, 실기, 필기, 총점, 등수 출력
CREATE OR REPLACE PROCEDURE PRC_S_SUB_SELECT
( V_SID  IN STUDENTS.S_ID%TYPE
, V_OUT OUT SYS_REFCURSOR
)
IS
BEGIN
    
     OPEN V_OUT FOR
     
      SELECT S.S_NAME"학생이름", SUB.SUB_NAME"과목명", OS.OS_START"과목시작일", OS.OS_END"과목종료일",B.B_NAME"교재명",G.S_CHUL"출석점수",G.S_SILGI"실기점수",G.S_PILGI"필기점수"
                ,(G.S_CHUL+G.S_SILGI+G.S_PILGI)"총점" ,RANK() OVER (PARTITION BY SUB.SUB_CODE ORDER BY  G.S_CHUL+G.S_SILGI+G.S_PILGI DESC )"등수"
                ,(
                        CASE  WHEN DS.D_DATE BETWEEN OS.OS_START AND OS.OS_END THEN'중도탈락'
                               ELSE '수료'
                               END
                       
                
                )"중도탈락여부"
                FROM STUDENTS S ,STUDENT_COURSE SC,OPEN_COURSE OC,GRADE G,OPEN_SUBJECT OS,SUBJECT SUB,COURSE C,DROP_STUDENTS DS,BOOK B
                WHERE  S.S_ID = V_SID
                   AND S.S_ID = SC.S_ID
                   AND OC.OC_CODE = SC.OC_CODE
                   AND SC.SC_CODE = G.SC_CODE
                   AND OS.OS_CODE = G.OS_CODE
                   AND SUB.SUB_CODE = OS.SUB_CODE
                   AND C.C_CODE=OC.C_CODE
                   AND OS.OS_END <=SYSDATE
                   AND DS.SC_CODE(+) = SC.SC_CODE
                   AND B.B_CODE= OS.B_CODE;

END;



-----
SET SERVEROUTPUT ON;

-- 학생이 자신이 수강한 과목의 성적출력 확인
DECLARE
V_CURSOR    SYS_REFCURSOR; 
V_SUBNAME    SUBJECT.SUB_NAME%TYPE;
V_OSSTART     OPEN_SUBJECT.OS_START%TYPE;
V_OSEND         OPEN_SUBJECT.OS_END%TYPE;
V_BNAME        BOOK.B_NAME%TYPE;
V_SNAME        STUDENTS.S_NAME%TYPE;
V_GCHUL        GRADE.S_CHUL%TYPE;
V_GSILGI        GRADE.S_SILGI%TYPE;
V_GPILGI       GRADE.S_PILGI%TYPE;
V_TOTAL        NUMBER(3);
V_RANK          NUMBER(3);
V_DROP          VARCHAR2(30);

BEGIN


    PRC_S_SUB_SELECT('STU201',V_CURSOR);
  
    LOOP
  
        FETCH V_CURSOR INTO V_SNAME,V_SUBNAME,V_OSSTART,V_OSEND,V_BNAME,V_GCHUL,V_GSILGI,V_GPILGI,V_TOTAL,V_RANK,V_DROP  ;

        EXIT WHEN V_CURSOR%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE( V_SUBNAME ||'  '||V_OSSTART||'  '||V_OSEND||'  '||V_BNAME ||'  '||V_SNAME||'  '||V_GCHUL||'  '||V_GSILGI||'  '||V_GPILGI||'  '||V_TOTAL ||'  '||V_RANK||'  '||V_DROP);
        
    END LOOP;
END;
/*
오라클        20/02/13  20/02/12  오라클의 정석  김동휘  20  20  20  60  1  수료 
자바스크립트  20/03/13  20/04/12  자바스크립트의 정석  김동휘  20  20  20  60  1  수료 
*/

-- 24.중도포기한 학생이 자신이 수강한 학생명, 과정명, 과목명, 과목기간, 교재명, 출결, 실기, 필기, 총점, 등수 출력
CREATE OR REPLACE PROCEDURE PRC_S_SUB_SELECT
( V_SID  IN STUDENTS.S_ID%TYPE
, V_OUT OUT SYS_REFCURSOR
)
IS
BEGIN
    
     OPEN V_OUT FOR
     
      SELECT DISTINCT S.S_NAME"학생이름", SUB.SUB_NAME"과목명", OS.OS_START"과목시작일", OS.OS_END"과목종료일",B.B_NAME"교재명",G.S_CHUL"출석점수",G.S_SILGI"실기점수",G.S_PILGI"필기점수"
                ,(G.S_CHUL+G.S_SILGI+G.S_PILGI)"총점" ,RANK() OVER (PARTITION BY SUB.SUB_CODE ORDER BY  G.S_CHUL+G.S_SILGI+G.S_PILGI DESC )"등수"
                ,(
                        CASE  WHEN DS.D_DATE BETWEEN OS.OS_START AND OS.OS_END THEN'중도탈락'
                               ELSE '수료'
                               END
                       
                
                )"중도탈락여부"
                FROM STUDENTS S ,STUDENT_COURSE SC,OPEN_COURSE OC,GRADE G,OPEN_SUBJECT OS,SUBJECT SUB,COURSE C,DROP_STUDENTS DS,BOOK B
                WHERE  S.S_ID = V_SID
                   AND S.S_ID = SC.S_ID
                   AND OC.OC_CODE = SC.OC_CODE
                   AND SC.SC_CODE = G.SC_CODE
                   AND OS.OS_CODE = G.OS_CODE
                   AND SUB.SUB_CODE = OS.SUB_CODE
                   AND C.C_CODE=OC.C_CODE
                   AND OS.OS_END <= D_DATE      -- 중도탈락한 날짜와 비교해서 그전까지 들은 수업까지 보여준다.
                   AND DS.SC_CODE = SC.SC_CODE
                   AND B.B_CODE= OS.B_CODE
                   ORDER BY 1;

END;


SELECT *
FROM DROP_STUDENTS;

-----
SET SERVEROUTPUT ON;

--24.중도탈락학생이 자신이 수강한 과목의 성적출력 확인
DECLARE
V_CURSOR    SYS_REFCURSOR; 
V_SUBNAME    SUBJECT.SUB_NAME%TYPE;
V_OSSTART     OPEN_SUBJECT.OS_START%TYPE;
V_OSEND         OPEN_SUBJECT.OS_END%TYPE;
V_BNAME        BOOK.B_NAME%TYPE;
V_SNAME        STUDENTS.S_NAME%TYPE;
V_GCHUL        GRADE.S_CHUL%TYPE;
V_GSILGI        GRADE.S_SILGI%TYPE;
V_GPILGI       GRADE.S_PILGI%TYPE;
V_TOTAL        NUMBER(3);
V_RANK          NUMBER(3);
V_DROP          VARCHAR2(30);

BEGIN


    PRC_S_SUB_SELECT('STU203',V_CURSOR);
  
    LOOP
  
        FETCH V_CURSOR INTO V_SNAME,V_SUBNAME,V_OSSTART,V_OSEND,V_BNAME,V_GCHUL,V_GSILGI,V_GPILGI,V_TOTAL,V_RANK,V_DROP  ;

        EXIT WHEN V_CURSOR%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE( V_SUBNAME ||'  '||V_OSSTART||'  '||V_OSEND||'  '||V_BNAME ||'  '||V_SNAME||'  '||V_GCHUL||'  '||V_GSILGI||'  '||V_GPILGI||'  '||V_TOTAL ||'  '||V_RANK||'  '||V_DROP);
        
    END LOOP;
END;
/*
오라클  20/03/11  20/04/10  오라클의 정석  문승주  20  20  23  63  1  수료
자바  20/02/09  20/03/10  자바의 정석  문승주  20  20  22  62  1  수료
*/
   
SELECT *
FROM SUBJECT;

--------------------------------------------------------------------------------------------------------------------
-- 25. 개설된 과목 입력 프로시저
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
    
    --커밋
    COMMIT;

    EXCEPTION
        WHEN NOT_SUBCODE_ERROR
            THEN RAISE_APPLICATION_ERROR(-20020,'해당과목은 없습니다.');
        WHEN NOT_BCODE_ERROR
            THEN RAISE_APPLICATION_ERROR(-20014,'해당하는 교재는 없습니다.');
        WHEN WRONG_DATE_ERROR
            THEN RAISE_APPLICATION_ERROR(-20012,'해당날짜는 유효하지 않습니다.');
         WHEN NOT_OCCODE_ERROR
            THEN RAISE_APPLICATION_ERROR(-20021,'no data found');
       WHEN OTHERS
            THEN ROLLBACK; 
END;


-------------------------------------------------------------------------------------------------------------------
-- ○ 삭제 프로시저 모음

--1.개설된 과정 삭제
CREATE OR REPLACE PROCEDURE PRO_OC_DELETE
(
    V_OC_CODE IN OPEN_COURSE.OC_CODE%TYPE
)
IS
BEGIN
    
    DELETE
    FROM OPEN_COURSE
    WHERE OC_CODE =V_OC_CODE;
    
    --나중에 지우기
   --COMMIT;
   
END;

--2.강의실 삭제 프로시저
CREATE OR REPLACE PROCEDURE PRO_ROOM_DELETE
(
    V_R_CODE IN ROOM.R_CODE%TYPE
)
IS
BEGIN
    
    DELETE
    FROM ROOM
    WHERE R_CODE=V_R_CODE;
    
    --나중에 지우기
   --COMMIT;
   
END;

--확인
COMMIT;

EXEC PRO_ROOM_DELETE('R1');

SELECT *
FROM OPEN_COURSE;

SELECT *
FROM ROOM;

-----------------------------------------------------------------------
--3.과정 삭제 프로시저
CREATE OR REPLACE PROCEDURE PRO_COURSE_DELETE
(
    V_C_CODE IN COURSE.C_CODE%TYPE
)
IS
BEGIN
    
    DELETE
    FROM COURSE
    WHERE C_CODE=V_C_CODE;
    
    --나중에 지우기
   --COMMIT;
   
END;

--확인
COMMIT;
ROLLBACK;

EXEC PRO_COURSE_DELETE('C1');

SELECT *
FROM COURSE;

SELECT *
FROM OPEN_COURSE;
-------------------------------------------------------------------
--4.과목 삭제 프로시저
CREATE OR REPLACE PROCEDURE PRO_SUBJECT_DELETE
(
    V_SUB_CODE IN SUBJECT.SUB_CODE%TYPE
)
IS
BEGIN
    
    DELETE
    FROM SUBJECT
    WHERE SUB_CODE=V_SUB_CODE;
    
    --나중에 지우기
   --COMMIT;
   
END;

--확인
COMMIT;
ROLLBACK;

EXEC PRO_SUBJECT_DELETE('SUB1');

SELECT *
FROM SUBJECT;

SELECT *
FROM OPEN_SUBJECT;
--------------------------------------------------------------------
--5.교재 삭제 프로시저
CREATE OR REPLACE PROCEDURE PRO_BOOK_DELETE
(
    V_B_CODE IN BOOK.B_CODE%TYPE
)
IS
BEGIN
    
    DELETE
    FROM BOOK
    WHERE B_CODE=V_B_CODE;
    
    --나중에 지우기
   --COMMIT;
   
END;

--확인
COMMIT;
ROLLBACK;

EXEC PRO_BOOK_DELETE('B1');

SELECT *
FROM BOOK;

SELECT *
FROM OPEN_SUBJECT;
-----------------------------------------------------------------------------------
--6.개설된 과목 삭제 프로시저
CREATE OR REPLACE PROCEDURE PRO_OS_DELETE
(
    V_OS_CODE IN OPEN_SUBJECT.OS_CODE%TYPE
)
IS
BEGIN
    
    DELETE
    FROM OPEN_SUBJECT
    WHERE OS_CODE=V_OS_CODE;
    
    --나중에 지우기
   --COMMIT;
   
END;

--확인
COMMIT;
ROLLBACK;

EXEC PRO_OS_DELETE('OS1');

SELECT *
FROM SUBJECT;

SELECT *
FROM OPEN_SUBJECT;
----------------------------------------------------------------------------------------------
--7.성적 삭제 프로시저
CREATE OR REPLACE PROCEDURE PRO_GRADE_DELETE
(
    V_GRADE_CODE IN GRADE.GRADE_CODE%TYPE
)
IS
BEGIN
    
    DELETE
    FROM GRADE
    WHERE GRADE_CODE=V_GRADE_CODE;
    
   --커밋
   COMMIT;
   
END;

--확인
COMMIT;
ROLLBACK;

EXEC PRO_GRADE_DELETE('G1');

SELECT *
FROM GRADE;

SELECT *
FROM OPEN_SUBJECT;

SELECT *
FROM OPEN_SUBJECT  OC,GRADE G
WHERE OC.OS_CODE=G.OS_CODE;
--------------------------------------------------------------
--8.학생별 수강과정 삭제 프로시저
CREATE OR REPLACE PROCEDURE PRO_SC_DELETE
(
    V_SC_CODE IN STUDENT_COURSE.SC_CODE%TYPE
)
IS
BEGIN
    
    DELETE
    FROM STUDENT_COURSE
    WHERE SC_CODE=V_SC_CODE;
    
    --커밋
   COMMIT;
   
END;

--확인
COMMIT;
ROLLBACK;

EXEC PRO_SC_DELETE('SC1');

SELECT *
FROM STUDENT_COURSE ;
-----------------------------------------------------------------------------
--9.학생 삭제 프로시저
CREATE OR REPLACE PROCEDURE PRO_STUDENTS_DELETE
(
    V_S_ID IN STUDENTS.S_ID%TYPE
)
IS
BEGIN
    
    DELETE
    FROM STUDENTS
    WHERE S_ID=V_S_ID;
    
    --커밋
   COMMIT;
   
END;

--확인
COMMIT;
ROLLBACK;

EXEC PRO_STUDENTS_DELETE('JGY99');

SELECT *
FROM STUDENTS ;

-----------------------------------------------------------------
--10.중도탈락학생 삭제 프로시저
CREATE OR REPLACE PROCEDURE PRO_DROP_DELETE
(
    V_DS_CODE IN DROP_STUDENTS.DS_CODE%TYPE
)
IS
BEGIN
    
    DELETE
    FROM DROP_STUDENTS
    WHERE DS_CODE=V_DS_CODE;
    
   --커밋
   COMMIT;
   
END;

--확인
COMMIT;
ROLLBACK;

EXEC PRO_DROP_DELETE('DS1');

SELECT *
FROM DROP_STUDENTS ;
------------------------------------------------------------------------
--11.관리자 삭제 프로시저
CREATE OR REPLACE PROCEDURE PRO_MANAGER_DELETE
(
    V_M_ID IN MANAGER.M_ID%TYPE
)
IS
BEGIN
    
    DELETE
    FROM MANAGER
    WHERE M_ID=V_M_ID;
    
   --커밋
   COMMIT;
   
END;

--확인
COMMIT;
ROLLBACK;

EXEC PRO_MANAGER_DELETE('TEAM4');




