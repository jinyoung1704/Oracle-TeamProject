--[ �⺻ �Է� ���ν��� & ���̵����� �Է� ]-------------------------------------------------------------------------------

-- 1 ) ���� �Է� ���ν���
-- �� ������ ����
CREATE SEQUENCE BCODE_NUM
MINVALUE 1
START WITH 1
INCREMENT BY 1;
--==>Sequence BCODE_NUM��(��) �����Ǿ����ϴ�.

CREATE OR REPLACE PROCEDURE PRC_BOOK_INSERT(
V_B_NAME      IN      BOOK.B_NAME%TYPE
)
IS
TEMP_B_NAME     BOOK.B_NAME%TYPE;
BOOK_JUNGBOK_ERROR    EXCEPTION;
BEGIN
  
    -- �����̸��� å�� �ִ��� Ȯ��
        SELECT B_NAME INTO TEMP_B_NAME
        FROM BOOK
        WHERE B_NAME=V_B_NAME;
        
    -- ����å�� �̸��� ������ BOOK_JUNGBOK_ERROR �߻�
        IF(TEMP_B_NAME = V_B_NAME)
            THEN RAISE   BOOK_JUNGBOK_ERROR ;
        
        END IF;
    -- ����å�� �̸��� ���ٸ� å�� INSERT ���ش�.  
        EXCEPTION
            WHEN BOOK_JUNGBOK_ERROR
            THEN RAISE_APPLICATION_ERROR(-20001,'�̹� �����ϴ� å�Դϴ�.');
            
            WHEN NO_DATA_FOUND
                THEN 
                
                INSERT INTO BOOK(B_CODE,B_NAME)
                VALUES('B'||TO_CHAR(BCODE_NUM.NEXTVAL),V_B_NAME);
END;



--�� ������ ����
DROP SEQUENCE BCODE_NUM;

SELECT *
FROM BOOK;

--å �̸��� ������ ���
EXEC PRC_BOOK_INSERT('�ڹ��� ����');

--å �̸��� �������� ���� ���
EXEC PRC_BOOK_INSERT('�ڹ� �μ���');




-- 1-2) ���� ���̵����� �Է�

EXEC PRC_BOOK_INSERT('�ڹ��� ����');
EXEC PRC_BOOK_INSERT('����Ŭ�� ����');
EXEC PRC_BOOK_INSERT('�ڹٽ�ũ��Ʈ�� ����');
EXEC PRC_BOOK_INSERT('HTML ������');
EXEC PRC_BOOK_INSERT('CSS ������');
EXEC PRC_BOOK_INSERT('�����ͺ��̽� ����');
EXEC PRC_BOOK_INSERT('���̽� �⺻');
EXEC PRC_BOOK_INSERT('SQL ����');
EXEC PRC_BOOK_INSERT('UI ������');




-------------------------------------------------------------------------------------------------------------------------------
-- 2) ���ǽ� �߰� ���ν���

-- ���ǽ� ������ ����
CREATE SEQUENCE RCODE_NUM
MINVALUE 1
START WITH 1
INCREMENT BY 1;
--==>Sequence RCODE_NUM��(��) �����Ǿ����ϴ�.


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
        THEN RAISE_APPLICATION_ERROR(-20010,'�̹� �����ϴ� ���ǽ��Դϴ�.');
        
        WHEN NO_DATA_FOUND
        THEN INSERT INTO ROOM(R_CODE,R_NAME)
        VALUES('R'||TO_CHAR(RCODE_NUM.NEXTVAL),V_R_NAME);

END;



--ROOM ������ ����
DROP SEQUENCE RCODE_NUM;
--==>Sequence RCODE_NUM��(��) �����Ǿ����ϴ�.

SELECT *
FROM ROOM;


-- �� �׽�Ʈ
-- �ߺ��� ���ǽ� ����ó�� üũ
EXEC PRC_ROOM_INSERT('A');
--==>ORA-20010: �̹� �����ϴ� ���ǽ��Դϴ�.
EXEC PRC_ROOM_INSERT('A���ǽ�');


------- 2 - 2 ) ���ǽ� ���� ������ �Է�

EXEC PRC_ROOM_INSERT('A���ǽ�');
EXEC PRC_ROOM_INSERT('B���ǽ�');
EXEC PRC_ROOM_INSERT('C���ǽ�');
EXEC PRC_ROOM_INSERT('D���ǽ�');
EXEC PRC_ROOM_INSERT('E���ǽ�');
EXEC PRC_ROOM_INSERT('F���ǽ�');




--------------------------------------------------------------------------------------------------------------------------
-- 3) COURSE ������ �Է� ���ν���

-- ���� ������ ����
CREATE SEQUENCE CCODE_NUM
MINVALUE 1
START WITH 1
INCREMENT BY 1;
--==>Sequence CCODE_NUM��(��) �����Ǿ����ϴ�.

-- COURSE �Է� ���ν���
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
            THEN  RAISE_APPLICATION_ERROR(-20011,'�̹� �����ϴ� �����Դϴ�.');
        WHEN NO_DATA_FOUND
            THEN  INSERT INTO COURSE(C_CODE,C_NAME)
            VALUES('C'||TO_CHAR(CCODE_NUM.NEXTVAL),V_C_NAME);


END;




SELECT *
FROM COURSE;

--�̹� �����ϴ� ���� �Է�
EXEC PRC_COURSE_INSERT('SW������ �缺����');
--==>ORA-20011: �̹� �����ϴ� �����Դϴ�.

EXEC PRC_COURSE_INSERT('SW������ �缺����2');

-- 3 - 1) ���� ���̵����� �Է�

EXEC PRC_COURSE_INSERT('SW������ �缺����');
EXEC PRC_COURSE_INSERT('DB������ �缺����');


----------------------------------------------------------------------------------------------------------------------
-- 4 ) �����Է� ���ν���

-- ���� ������ ����
CREATE SEQUENCE SUBCODE_NUM
MINVALUE 1
START WITH 1
INCREMENT BY 1;


--���� �Է� ���ν���
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
            THEN  RAISE_APPLICATION_ERROR(-20011,'�̹� �����ϴ� �����Դϴ�.');
        WHEN NO_DATA_FOUND
            THEN  INSERT INTO SUBJECT(SUB_CODE,SUB_NAME)
            VALUES('SUB'||TO_CHAR(SUBCODE_NUM.NEXTVAL),V_SUB_NAME);


END;




SELECT *
FROM SUBJECT;

-- �̹� �����ϴ� ���� INSERT
EXEC PRC_SUBJECT_INSERT('�ڹ�');
--==>ORA-20011: �̹� �����ϴ� �����Դϴ�.

---4 -1 ) ���� ���� ������ �Է�
EXEC PRC_SUBJECT_INSERT('�ڹ�');
EXEC PRC_SUBJECT_INSERT('����Ŭ');
EXEC PRC_SUBJECT_INSERT('�ڹٽ�ũ��Ʈ');
EXEC PRC_SUBJECT_INSERT('HTML');
EXEC PRC_SUBJECT_INSERT('CSS');
EXEC PRC_SUBJECT_INSERT('�����ͺ��̽�');
EXEC PRC_SUBJECT_INSERT('���̽�');
EXEC PRC_SUBJECT_INSERT('SQL');
EXEC PRC_SUBJECT_INSERT('UI');




-----------------------------------------------------------------------------------------------------------------------

-- 5 )���� �Է� ���ν���

--���� ������ ����
CREATE SEQUENCE PID_NUM
MINVALUE 1
START WITH 1
INCREMENT BY 1;


-- ���� �Է� ���ν���
CREATE OR REPLACE PROCEDURE PRC_PRO_INSERT
(
    V_P_NAME    IN PROFESSOR.P_NAME %TYPE
   ,V_P_SSN     IN PROFESSOR.P_SSN %TYPE
)
IS
    V_COUNT     NUMBER(10);   
BEGIN
        -- �ֹι�ȣ Ȯ�� 1�̸� �̹� ���Ե� ����
        SELECT COUNT(*) INTO V_COUNT
        FROM PROFESSOR
        WHERE P_SSN = V_P_SSN;
    
        -- �ֹι�ȣ ������ ���� ���� �Է�
        IF(V_COUNT=0)
        THEN
            INSERT INTO PROFESSOR(P_ID, P_NAME, P_SSN, P_PW) 
            VALUES('PRO' || TO_CHAR(SYSDATE,'YY') || TO_CHAR(PID_NUM.NEXTVAL), V_P_NAME, V_P_SSN, SUBSTR( V_P_SSN, 8));
        END IF;
        
        COMMIT;
END;

--���� ������ ����
DROP SEQUENCE PID_NUM;

-- 5 - 1) ���� ���� ������ �Է�
EXEC PRC_PRO_INSERT('��ȣ��','861230-1012546');
EXEC PRC_PRO_INSERT('�¹���','581030-2028857');
EXEC PRC_PRO_INSERT('������','960712-1023597');
EXEC PRC_PRO_INSERT('����','970129-2065621');
EXEC PRC_PRO_INSERT('��ȿ��','960730-2065411');


SELECT *
FROM PROFESSOR;

------------------------------------------------------------------------------------------------------------------
-- 6) �л� ���� �Է� ���ν���

--�л� ������ ����
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
        -- �ֹι�ȣ Ȯ�� 1�̸� �̹� ���Ե� ����
        SELECT COUNT(*) INTO V_COUNT
        FROM STUDENTS
        WHERE S_SSN = V_S_SSN;
        
        -- �ֹ� ��ȣ ������ �ǻ�
        SELECT LENGTH(V_S_SSN) INTO V_SIZE
        FROM DUAL;
    
        -- �ֹι�ȣ ������ �л� ���� �Է�
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
        
        -- Ŀ��
        COMMIT;
        
        EXCEPTION
        WHEN SSN_WRONG_ERROR 
                THEN RAISE_APPLICATION_ERROR(-20001,'�ֹι�ȣ�� ��ȿ���� �ʽ��ϴ�.');
         WHEN USER_DEFINE_ERROR
                THEN RAISE_APPLICATION_ERROR(-20002,'�̹� �����ϴ� ������Դϴ�..');         
            WHEN OTHERS 
                THEN ROLLBACK;

END;

--�л� ������ ����
DROP SEQUENCE SID_NUM;

-- 6 - 2) �л� ���� ������ �Է�

EXEC PRC_STU_INSERT('�赿��','950728-2123456');
EXEC PRC_STU_INSERT('������','970129-2123457');
EXEC PRC_STU_INSERT('������','960712-1123456');
EXEC PRC_STU_INSERT('��ȿ��','950728-2123458');
EXEC PRC_STU_INSERT('�ֱ⿬','990505-1123457');
EXEC PRC_STU_INSERT('������','930728-2123456');
EXEC PRC_STU_INSERT('��ä��','950729-2133457');
EXEC PRC_STU_INSERT('�ۼ���','950712-1153456');
EXEC PRC_STU_INSERT('�����','950828-2123458');
EXEC PRC_STU_INSERT('�ż�ö','990505-1143457');


----------------------------------------------------------------------------------------------------------------------
-- 7) ������ ���� �Է� ���ν���

CREATE SEQUENCE OC_NUM
MINVALUE 1
START WITH 1
INCREMENT BY 1;

CREATE OR REPLACE PROCEDURE PRC_COURSE_INPUT
( 
    V_OC_START IN  OPEN_COURSE.OC_START%TYPE    --����������
,   V_OC_END   IN  OPEN_COURSE.OC_END%TYPE     --���� ������
,   V_R_CODE     IN   ROOM.R_CODE%TYPE         --���ǽ��ڵ�
,   V_P_ID     IN   PROFESSOR.P_ID%TYPE        --������ȣ
,   V_C_CODE IN COURSE.C_CODE%TYPE             --�����ڵ�
      

)
IS
   
   R_CHECK NUMBER;   --�� �ڵ尡 ROOM�� �ִ��� Ȯ���ϱ� ����
   P_CHECK NUMBER;   --������ȣ�� PROFESSOR�� �ִ��� Ȯ���ϱ� ����
   C_CHECK NUMBER;   --���ǰ� COURSE�� �ִ��� üũ
   OC_CHECK NUMBER;  --������ ����� �Ǿ������� �ߺ��Է� �Ұ��� ����
   
   V_OC_CODE OPEN_COURSE.OC_CODE%TYPE;
 
   --����
   PROFESSOR_ERROR EXCEPTION;
   ROOM_ERROR EXCEPTION;
   COURSE_ERROR EXCEPTION;
   INPUT_ERROR EXCEPTION;
BEGIN
   --�Է��� V_R_CODE ���� ROOM�� �����ϴ��� ���ϴ��� üũ
    SELECT COUNT(*) INTO R_CHECK
    FROM ROOM
    WHERE R_CODE=V_R_CODE;

  
   IF(R_CHECK = 0)
     THEN RAISE ROOM_ERROR ;
   END IF;
  
  
  --�Է��� V_P_ID�� PROFESSOR�� �ִ��� ������ üũ
  SELECT COUNT(*) INTO P_CHECK
  FROM PROFESSOR
  WHERE P_ID=V_P_ID;
  
  IF(P_CHECK=0)
    THEN RAISE PROFESSOR_ERROR ;
  END IF;

  
  --�Է��� ������ COURSE�� �ִ��� üũ
  
  SELECT COUNT(*) INTO C_CHECK
  FROM COURSE
  WHERE C_CODE=V_C_CODE;
  
  IF(C_CHECK=0)
    THEN RAISE COURSE_ERROR ;
  END IF;

  --������ ������ �̹� ������ ���ǽ��� ��ϵǾ� �ִ� ���
  SELECT COUNT(*) INTO OC_CHECK
  FROM OPEN_COURSE
  WHERE P_ID=V_P_ID AND R_CODE=V_R_CODE AND OC_END>V_OC_START;
  
  IF(OC_CHECK!=0)
    THEN RAISE INPUT_ERROR;
  END IF;

   --OC_CODE
   SELECT  MAX(SUBSTR(OC_CODE,3))+1 INTO V_OC_CODE
   FROM OPEN_COURSE;

    --������ �Է� 
    INSERT INTO OPEN_COURSE(OC_CODE,OC_START,OC_END,R_CODE,P_ID,C_CODE)
    VALUES('OC'||TO_CHAR(OC_NUM.NEXTVAL),V_OC_START,V_OC_END,V_R_CODE,V_P_ID,V_C_CODE);
  
  --Ŀ��
  COMMIT;
  
  --����ó��
   EXCEPTION
   WHEN ROOM_ERROR
        THEN RAISE_APPLICATION_ERROR(-20002,'���ǽ��� ��ϵǾ� ���� �ʽ��ϴ�');
        ROLLBACK;
   WHEN PROFESSOR_ERROR
        THEN RAISE_APPLICATION_ERROR(-20003,'������ȣ�� ��ϵǾ� ���� �ʽ��ϴ�');
        ROLLBACK;
   WHEN COURSE_ERROR
        THEN RAISE_APPLICATION_ERROR(-20004,'������ ��ϵǾ� ���� �ʽ��ϴ�');
        ROLLBACK;
   WHEN INPUT_ERROR
        THEN RAISE_APPLICATION_ERROR(-20005,'������ ���ǽ��� �̹� ��ϵǾ� �ֽ��ϴ�.');
        ROLLBACK;
   WHEN OTHERS
        THEN ROLLBACK;
   
END;

-- 7 - 1) ������ ���� ���� ������ 
EXEC PRC_COURSE_INPUT(TO_DATE('2020-01-13','YYYY-MM-DD'),TO_DATE('2020-07-30','YYYY-MM-DD'),'R6','PRO201','C1');
EXEC PRC_COURSE_INPUT(TO_DATE('2020-02-09','YYYY-MM-DD'),TO_DATE('2020-08-21','YYYY-MM-DD'),'R5','PRO202','C1');
EXEC PRC_COURSE_INPUT(TO_DATE('2020-02-12','YYYY-MM-DD'),TO_DATE('2020-09-01','YYYY-MM-DD'),'R4','PRO203','C2');
EXEC PRC_COURSE_INPUT(TO_DATE('2020-02-20','YYYY-MM-DD'),TO_DATE('2020-09-21','YYYY-MM-DD'),'R3','PRO204','C2');



-------------------------------------------------------------------------------------------------------------------------------
-- 8) �ߵ�Ż�� �л� �Է� ���ν���

-- �ߵ� Ż�� �л� ������ ����
CREATE SEQUENCE DSCODE_NUM
MINVALUE 1
START WITH 1
INCREMENT BY 1;


-- �ߵ� Ż�� �л� ���ν���
CREATE OR REPLACE PROCEDURE PRC_DROPSTU_INSERT(
V_S_ID  IN  STUDENTS.S_ID%TYPE
,V_D_DATE IN DROP_STUDENTS.D_DATE%TYPE
)
IS
TEMP_S_ID   STUDENTS.S_ID%TYPE;
TEMP_SC_CODE STUDENT_COURSE.SC_CODE%TYPE;
BEGIN
    
    --������û�� �л����� ��ȸ
    SELECT S_ID,SC_CODE INTO TEMP_S_ID,TEMP_SC_CODE
    FROM STUDENT_COURSE
    WHERE S_ID=V_S_ID;
    
    INSERT INTO DROP_STUDENTS(DS_CODE,D_DATE,SC_CODE)
    VALUES('DS'||TO_CHAR(DSCODE_NUM.NEXTVAL),V_D_DATE,TEMP_SC_CODE);
    
    EXCEPTION
        WHEN NO_DATA_FOUND
            THEN RAISE_APPLICATION_ERROR(-20013,'������û���� ���� �л��Դϴ�.');
    
END;

-- �׽�Ʈ
EXEC PRC_DROPSTU_INSERT('STU1',SYSDATE);


-- �� ������û ���̵����� �Է��� �Է��ϱ� ��
-- �ߵ� Ż���л� ���� ������ �Է�
EXEC PRC_DROPSTU_INSERT('STU203',SYSDATE);


------------------------------------------------------------------------------------------------------------------
-- 9) ������ ���� �Է� ���ν���
-- 9) ������ ���� �Է� ���ν���
-- ���� ������ ����
CREATE SEQUENCE OS_NUM
MINVALUE 1
START WITH 1
INCREMENT BY 1;


-- ������ ���� �Է� ���ν���
CREATE OR REPLACE PROCEDURE PRC_SUBJECT_INSERT
(
  V_SUB_CODE     IN SUBJECT.SUB_CODE%TYPE           -- �����ڵ�
, V_OS_START     IN OPEN_SUBJECT.OS_START%TYPE      -- ���� ����
, V_OS_END       IN OPEN_SUBJECT.OS_END%TYPE        -- ���� ��
, V_B_CODE       IN BOOK.B_CODE%TYPE                -- å
, V_OC_CODE      IN OPEN_COURSE.OC_CODE%TYPE        -- ��������     
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

    -- �������� Ȯ��
    SELECT COUNT(*) INTO CHECK_OC_CODE
    FROM OPEN_COURSE
    WHERE OC_CODE = V_OC_CODE;
    
    -- ���� Ȯ��
    SELECT COUNT(*) INTO CHECK_SUB_CODE
    FROM SUBJECT
    WHERE SUB_CODE = V_SUB_CODE;

    -- å Ȯ��
    SELECT COUNT(*) INTO CHECK_B_CODE
    FROM BOOK
    WHERE B_CODE = V_B_CODE;
    
    -- �����Ⱓ Ȯ��
    SELECT OC_START, OC_END INTO TEMP_OC_START, TEMP_OC_END
    FROM OPEN_COURSE
    WHERE OC_CODE = V_OC_CODE;
    
    -- OPEN_COURSE�� �������� ������ ����ó��
    IF(CHECK_OC_CODE=0)             
        THEN RAISE NOT_OCCODE_ERROR;
    -- SUBJECT�� ���� ������ ����ó��
    ELSIF(CHECK_SUB_CODE=0)
        THEN RAISE NOT_SUBCODE_ERROR;
    -- BOOK�� å ������ ����ó��    
    ELSIF(CHECK_B_CODE=0)
        THEN RAISE NOT_BCODE_ERROR;
    -- ����Ⱓ�� �����Ⱓ�� ����� ����ó��   
    ELSIF(TEMP_OC_START <= V_OS_START AND V_OS_END <= TEMP_OC_END AND V_OS_START < V_OS_END)
        THEN INSERT INTO OPEN_SUBJECT(OS_CODE, SUB_CODE, OS_START, OS_END, B_CODE, OC_CODE)
        VALUES( 'OS'||TO_CHAR(OS_NUM.NEXTVAL), V_SUB_CODE, V_OS_START, V_OS_END, V_B_CODE, V_OC_CODE );
    ELSE
        RAISE WRONG_DATE_ERROR;
    END IF;
    
    
    -- COMMIT;

    EXCEPTION
        WHEN NOT_SUBCODE_ERROR
            THEN RAISE_APPLICATION_ERROR(-20021,'�ش������ �����ϴ�.');
        WHEN NOT_BCODE_ERROR
            THEN RAISE_APPLICATION_ERROR(-20022,'�ش��ϴ� ����� �����ϴ�.');
        WHEN WRONG_DATE_ERROR
            THEN RAISE_APPLICATION_ERROR(-20023,'�ش糯¥�� ��ȿ���� �ʽ��ϴ�.');
         WHEN NOT_OCCODE_ERROR
            THEN RAISE_APPLICATION_ERROR(-20024,'no data found');
       WHEN OTHERS
            THEN ROLLBACK; 
END;



-- 9-1)������ ���� ���� ������ �Է� 

--OC1�� ������ ���� ������
EXEC PRC_SUBJECT_INSERT('SUB1',TO_DATE('2020-01-13','YYYY-MM-DD'),TO_DATE('2020-02-12','YYYY-MM-DD'),'B1','OC1');
EXEC PRC_SUBJECT_INSERT('SUB2',TO_DATE('2020-02-13','YYYY-MM-DD'),TO_DATE('2020-02-12','YYYY-MM-DD'),'B2','OC1');
EXEC PRC_SUBJECT_INSERT('SUB3',TO_DATE('2020-03-13','YYYY-MM-DD'), TO_DATE('2020-04-12','YYYY-MM-DD'),'B3','OC1');
EXEC PRC_SUBJECT_INSERT('SUB4',TO_DATE('2020-04-13','YYYY-MM-DD'), TO_DATE('2020-05-12','YYYY-MM-DD'),'B4','OC1');
EXEC PRC_SUBJECT_INSERT('SUB5',TO_DATE('2020-05-13','YYYY-MM-DD'), TO_DATE('2020-07-30','YYYY-MM-DD'),'B5','OC1');


COMMIT;



-----
--OC2�� ������ ���� ������
EXEC PRC_SUBJECT_INSERT('SUB1',TO_DATE('2020-02-09','YYYY-MM-DD'), TO_DATE('2020-03-10','YYYY-MM-DD'),'B1','OC2');
EXEC PRC_SUBJECT_INSERT('SUB2',TO_DATE('2020-03-11','YYYY-MM-DD'), TO_DATE('2020-04-10','YYYY-MM-DD'),'B2','OC2');
EXEC PRC_SUBJECT_INSERT('SUB3',TO_DATE('2020-04-11','YYYY-MM-DD'), TO_DATE('2020-05-10','YYYY-MM-DD'),'B3','OC2');
EXEC PRC_SUBJECT_INSERT('SUB4',TO_DATE('2020-05-11','YYYY-MM-DD'), TO_DATE('2020-06-10','YYYY-MM-DD'),'B4','OC2');
EXEC PRC_SUBJECT_INSERT('SUB5',TO_DATE('2020-06-11','YYYY-MM-DD'), TO_DATE('2020-08-21','YYYY-MM-DD'),'B5','OC2');




----
--OC3�� ������ ���� ������
EXEC PRC_SUBJECT_INSERT('SUB3',TO_DATE('2020-02-12','YYYY-MM-DD'), TO_DATE('2020-03-15','YYYY-MM-DD'),'B3','OC3');
EXEC PRC_SUBJECT_INSERT('SUB4',TO_DATE('2020-03-16','YYYY-MM-DD'), TO_DATE('2020-04-15','YYYY-MM-DD'),'B4','OC3');
EXEC PRC_SUBJECT_INSERT('SUB5',TO_DATE('2020-04-16','YYYY-MM-DD'), TO_DATE('2020-05-15','YYYY-MM-DD'),'B5','OC3');
EXEC PRC_SUBJECT_INSERT('SUB6',TO_DATE('2020-06-16','YYYY-MM-DD'), TO_DATE('2020-07-15','YYYY-MM-DD'),'B6','OC3');
EXEC PRC_SUBJECT_INSERT('SUB7',TO_DATE('2020-07-16','YYYY-MM-DD'), TO_DATE('2020-09-01','YYYY-MM-DD'),'B7','OC3');



----
--OC4�� ������ ���� ������
EXEC PRC_SUBJECT_INSERT('SUB3',TO_DATE('2020-02-20','YYYY-MM-DD'), TO_DATE('2020-03-19','YYYY-MM-DD'),'B3','OC4');
EXEC PRC_SUBJECT_INSERT('SUB4',TO_DATE('2020-03-20','YYYY-MM-DD'), TO_DATE('2020-04-19','YYYY-MM-DD'),'B4','OC4');
EXEC PRC_SUBJECT_INSERT('SUB5',TO_DATE('2020-04-20','YYYY-MM-DD'), TO_DATE('2020-05-19','YYYY-MM-DD'),'B5','OC4');
EXEC PRC_SUBJECT_INSERT('SUB6',TO_DATE('2020-05-20','YYYY-MM-DD'), TO_DATE('2020-06-19','YYYY-MM-DD'),'B6','OC4');
EXEC PRC_SUBJECT_INSERT('SUB7',TO_DATE('2020-06-20','YYYY-MM-DD'), TO_DATE('2020-09-21','YYYY-MM-DD'),'B7','OC4');


----------------------------------------------------------------------------------------------------------------

--10 ) ������û �� �л� �Է� ���ν��� (������û ���̺�)


--STUDENT_COURSE ����������
CREATE SEQUENCE SCCODE_NUM
MINVALUE 1
START WITH 1
INCREMENT BY 1;
--==>Sequence SCCODE_NUM��(��) �����Ǿ����ϴ�.

--GRADE_COURSE ����������
CREATE SEQUENCE GRADE_NUM
MINVALUE 1
START WITH 1
INCREMENT BY 1;



--������û�� �л� ���ν���
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

    --STUDENTS ���̺� �л����̵� üũ (0�̸� �������������Ƿ� ����ó��)
    SELECT COUNT(*) INTO CHECK_S_ID
    FROM STUDENTS
    WHERE S_ID = V_S_ID;
    
    --OPEN_COURSE ���̺� OC_CODE üũ (0�̸� �������������Ƿ� ����ó��)
    SELECT COUNT(*) INTO CHECK_OC_CODE
    FROM OPEN_COURSE
    WHERE OC_CODE = V_OC_CODE;
    
    --STUDENT_COURSE ���̺� ���ϰ���  (0�� �ƴϸ� �����ϹǷ� ����ó��)
    SELECT COUNT(*) INTO CHECK_SC
    FROM STUDENT_COURSE
    WHERE V_S_ID = S_ID AND OC_CODE = V_OC_CODE;
    
    -- �л����̵� ������ ����ó��
    IF(CHECK_S_ID=0)
        THEN RAISE NOT_SID_ERROR;
    -- �����ڵ� ������ ����ó��
    ELSIF(CHECK_OC_CODE=0)
        THEN RAISE NOT_OCCODE_ERROR;
    -- ������ ������ ��� �л��̾����� �Է�
    ELSIF(CHECK_SC=0)
    THEN
    INSERT INTO STUDENT_COURSE(SC_CODE, S_ID, OC_CODE, SC_DATE)
    VALUES('SC'||TO_CHAR(SCCODE_NUM.NEXTVAL) ,V_S_ID , V_OC_CODE ,V_SC_DATE );
     -- ������ ������ ��� �л��� ������ ����ó��
    ELSE
        RAISE CHECK_SC_ERROR;    
    END IF;
    
    
    SELECT SC_CODE INTO TEMP_SC_CODE
    FROM  STUDENT_COURSE
    WHERE S_ID = V_S_ID;
    
    
    PRC_GRADE_INSERT(TEMP_SC_CODE);
     
    -- ����ó��
    EXCEPTION
        --�л� ���̵� ���ٸ� ����ó��
        WHEN NOT_SID_ERROR   
            THEN RAISE_APPLICATION_ERROR(-20010,'���̵� �������� �ʽ��ϴ�.');
        WHEN NOT_OCCODE_ERROR 
            THEN RAISE_APPLICATION_ERROR(-20011,'������ �������� �ʽ��ϴ�.');
        WHEN CHECK_SC_ERROR
            THEN RAISE_APPLICATION_ERROR(-20012,'������ ������ ��� �л��� �����մϴ�.');
      
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
  
-- ������ ��
       
    -- Ŀ�� �̿��� ���� Ŀ������ ����(�� Ŀ�� ����)

         -- Ŀ�� ����
        OPEN CUR_GRADE_SELECT;    
        -- Ŀ�� ���� �� ����������� �����͵� ó��(��Ƴ���)
        LOOP
        -- �� �� �� �� �޾ƴٰ� ó���ϴ� ���� �� ��FETCH��
        FETCH CUR_GRADE_SELECT INTO  V_OS_CODE;
        
        -- Ŀ������ �� �̻� �����Ͱ� ����� ������ �ʴ� ����... NOTFOUND
        EXIT WHEN CUR_GRADE_SELECT%NOTFOUND;       
        -- ���
        INSERT INTO GRADE(GRADE_CODE,SC_CODE,OS_CODE) 
        VALUES ('GRD'||TO_CHAR(GRADE_NUM.NEXTVAL), V_SC_CODE, V_OS_CODE);       
        END LOOP;
        CLOSE CUR_GRADE_SELECT;        
  
END;



--- 10-2) ������û�� �л� ���� ������ �Է�

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

-- 11) ������ ���� �Է� ���̺�
-- �� ������ ���� �����ϴ� ���ν��� (�Ű����� : OC_CODE(X), OS_CODE,����,����,����)  
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
    --OS_CODE�� ���� �� ����ó��
    BEGIN
        SELECT OS_CODE INTO TEMP_OS_CODE
        FROM OPEN_SUBJECT
        WHERE OS_CODE =V_OS_CODE;
    
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN RAISE_APPLICATION_ERROR(-20001,'�Է��� �����ڵ尡 �����ϴ�.'); 
                ROLLBACK;
    
   END; 
   
   IF(V_P_CHUL<=0 OR V_P_SILGI<=0 OR V_P_PILGI<=0)
     THEN RAISE P_CPS_ERROR;
   END IF;



    -- �Է¹��� OS_CODE�� ������ ������ ã�Ƽ� ������ UPDATE ���ش�.
    UPDATE OPEN_SUBJECT
    SET P_CHUL=V_P_CHUL ,P_SILGI= V_P_SILGI ,P_PILGI= V_P_PILGI
    WHERE OS_CODE=V_OS_CODE;  
    
    
    EXCEPTION
        WHEN P_CPS_ERROR
        THEN RAISE_APPLICATION_ERROR(-20007,'������ ��ȿ���� �ʽ��ϴ�.');
  
END;

--üũ �������� Ȯ��
EXEC PRC_PRO_P_CPS('OS3',50,50,50);

--���� �ڵ尡 ���� ��
EXEC PRC_PRO_P_CPS('OS425',20,30,30);

--��ȿ���� ���� ������ �־�����
EXEC PRC_PRO_P_CPS('OS3',-5,50,50);

-- Ȯ��
EXEC PRC_PRO_P_CPS('OS3',20,30,50);


--11 - 1) ���� ���� ���� ������ �Է� 
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
--12)������ ���) ���� �Է� ���ν��� 

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
JUMSU_ERROR          EXCEPTION; -- ������ �Է��� ������ �ʰ����� �� �Ͼ�� ����
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
            THEN RAISE_APPLICATION_ERROR(-20030,'������ �ʰ��Ͽ����ϴ�.');
        WHEN NO_DATA_FOUND
            THEN RAISE_APPLICATION_ERROR(-20011,'�Է��Ͻ� �����ڵ尡 �������� �ʽ��ϴ�.');  
    
END;

-- ���� ���̵����� �Է�
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

--Ŀ��
COMMIT;