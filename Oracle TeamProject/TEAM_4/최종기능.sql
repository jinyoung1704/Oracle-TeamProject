-- 1. ������ �α��� �Լ�   ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION FN_MIDPW(IN_ID VARCHAR2, IN_PW VARCHAR2)
RETURN NUMBER
IS
  N_RESULT NUMBER; 
  MNG_ID  MANAGER.M_ID%TYPE;
  MNG_PW  MANAGER.M_PW%TYPE;
  FLAG    NUMBER;
BEGIN
    --���̵� �����ϴ��� üũ�ϴ� �κ�  
    
        BEGIN
            SELECT M_ID INTO MNG_ID
            FROM MANAGER
            WHERE M_ID = IN_ID;
            
            EXCEPTION
                WHEN NO_DATA_FOUND
                        THEN RAISE_APPLICATION_ERROR(-20001,'���̵� �������� �ʽ��ϴ�..'); 
        END;
       
          
    -- ���̵� �����Ѵٸ� �н����� �´��� Ȯ��
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
--��å) 1�̸� ���̵� �н����� ��ġ -1�̸� ���̵� �н����� ����ġ

--���� ������ �Է�
INSERT INTO MANAGER
VALUES('TEAM4','java006$');

SELECT *
FROM MANAGER;
--==>TEAM4	java006$

-- [ �׽�Ʈ ]---------

--��й�ȣ ����
SELECT FN_MIDPW('TEAM4','Hava006$')
FROM DUAL;
--==>>-1

--���� ���̵�
SELECT FN_MIDPW('TEAM3','Java006$')
FROM DUAL;
--==>>ORA-20005: ���̵� �����ϴ�.

--�´� ���̵�/�н�����
SELECT FN_MIDPW('TEAM4','java006$')
FROM DUAL;
--==>>1



------------------------------------------------------------------------------------------------------------------------

-- 2. ������ ���� �����ϴ� ���ν��� (�Ű����� : OC_CODE(X), OS_CODE,����,����,����)  

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
        THEN RAISE_APPLICATION_ERROR(-20002,'�Է��� �����ڵ尡 �����ϴ�.'); 
                ROLLBACK;
    
   END; 
   
   IF(V_P_CHUL<=0 OR V_P_SILGI<=0 OR V_P_PILGI<=0)
     THEN RAISE P_CPS_ERROR;
   END IF;



    -- �Է¹��� OS_CODE�� ������ ������ ã�Ƽ� ������ UPDATE ���ش�.
    UPDATE OPEN_SUBJECT
    SET P_CHUL=V_P_CHUL ,P_SILGI= V_P_SILGI ,P_PILGI= V_P_PILGI
    WHERE OS_CODE=V_OS_CODE;  
    
    --Ŀ��
    COMMIT;
    
    EXCEPTION
        WHEN P_CPS_ERROR
        THEN RAISE_APPLICATION_ERROR(-20003,'������ ��ȿ���� �ʽ��ϴ�.');
  
END;

--==>>Procedure PRC_PRO_P_CPS��(��) �����ϵǾ����ϴ�.



-- [ �׽�Ʈ ]---------

--üũ �������� Ȯ��
EXEC PRC_PRO_P_CPS('OS3',50,50,50);

--���� �ڵ尡 ���� ��
EXEC PRC_PRO_P_CPS('OS425',20,30,30);

--��ȿ���� ���� ������ �־�����
EXEC PRC_PRO_P_CPS('OS3',-5,50,50);

-- Ȯ��
EXEC PRC_PRO_P_CPS('OS3',20,30,50);



-- 3. ���� �Է� ���ν��� ---------------------------------------------------------------------------------
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
        
        --Ŀ��
        COMMIT;
END;

SELECT *
FROM PROFESSOR;
/*
PRO201   ��ȣ��   861230-1012546   1012546
PRO202   �¹���   581030-2028857   2028857
PRO203   ������   960712-1023597   1023597
PRO204   ����   970129-2065621   2065621
PRO205   ��ȿ��   960730-2065411   2065411
*/

-- [ �׽�Ʈ ]----------
--���� ������ ������ INSERT_DATA���� �Ϸ�.

-- ����
EXEC PRC_PRO_INSERT('������','97031-1234567');

SELECT *
FROM PROFESSOR;
--==>>
/*
PRO201   ��ȣ��   861230-1012546   1012546
PRO202   �¹���   581030-2028857   2028857
PRO203   ������   960712-1023597   1023597
PRO204   ����   970129-2065621   2065621
PRO205   ��ȿ��   960730-2065411   2065411
PRO2021   ������   97031-1234567   234567
*/

-- 4. �л� �Է� ���ν��� -------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE PRC_STU_INSERT
(
    V_S_NAME    IN STUDENTS.S_NAME %TYPE
   ,V_S_SSN     IN STUDENTS.S_SSN %TYPE
)
IS
    V_COUNT     NUMBER(10);
    V_SIZE      NUMBER(20);
    USER_DEFINE_ERROR EXCEPTION;            -- �̹� �����ϴ� ����� ���� �� ����ó�� �߻�
    SSN_WRONG_ERROR EXCEPTION;              -- �ֹι�ȣ�� ��ȿ���� ���� �� ����ó�� �߻�
BEGIN
        -- �ֹι�ȣ Ȯ�� 1�̸� �̹� ���Ե� ����
        SELECT COUNT(*) INTO V_COUNT
        FROM STUDENTS
        WHERE S_SSN = V_S_SSN;
        
        -- �ֹ� ��ȣ ������ �˻�
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
                THEN RAISE_APPLICATION_ERROR(-20004,'�ֹι�ȣ�� ��ȿ���� �ʽ��ϴ�.');
         WHEN USER_DEFINE_ERROR
                THEN RAISE_APPLICATION_ERROR(-20005,'�̹� �����ϴ� ������Դϴ�..');         
            WHEN OTHERS 
                THEN ROLLBACK;

END;

--[ �׽�Ʈ ]----------

SELECT *
FROM STUDENTS;
--==>>
/*
STU201   �赿��   950728-2123456   DNEHD1828
STU202   ������   970129-2123457   2123457
STU203   ������   960712-1123456   1123456
STU204   ��ȿ��   950728-2123458   2123458
STU205   �ֱ⿬   990505-1123457   1123457
STU206   ������   930728-2123456   2123456
STU207   ��ä��   950729-2133457   2133457
STU208   �ۼ���   950712-1153456   1153456
STU209   �����   950828-2123458   2123458
STU2010   �ż�ö   990505-1143457   1143457
*/
EXEC PRC_STU_INSERT('ȫ�浿','980124-1233456');
--==>>PL/SQL ���ν����� ���������� �Ϸ�Ǿ����ϴ�.

SELECT *
FROM STUDENTS;
--==>>
/*
STU201   �赿��   950728-2123456   DNEHD1828
STU202   ������   970129-2123457   2123457
STU203   ������   960712-1123456   1123456
STU204   ��ȿ��   950728-2123458   2123458
STU205   �ֱ⿬   990505-1123457   1123457
STU206   ������   930728-2123456   2123456
STU207   ��ä��   950729-2133457   2133457
STU208   �ۼ���   950712-1153456   1153456
STU209   �����   950828-2123458   2123458
STU2010   �ż�ö   990505-1143457   1143457
STU2011   ȫ�浿   980124-1233456   1233456
*/


--5. ���� ���� ���ν���  -----------------------------------------------------------------------------------
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
  WHERE (P_ID=V_P_ID OR R_CODE=V_R_CODE) AND V_OC_START BETWEEN OC_START AND OC_END;
  
  IF(OC_CHECK!=0)
    THEN RAISE INPUT_ERROR;
  END IF;

   --OC_CODE
   SELECT  MAX(SUBSTR(OC_CODE,3))+1 INTO V_OC_CODE
   FROM OPEN_COURSE;

    --������ �Է� 
    INSERT INTO OPEN_COURSE(OC_CODE,OC_START,OC_END,R_CODE,P_ID,C_CODE)
    VALUES('OC'||V_OC_CODE,V_OC_START,V_OC_END,V_R_CODE,V_P_ID,V_C_CODE);
  
  --Ŀ��
  COMMIT;
  
  --����ó��
   EXCEPTION
   WHEN ROOM_ERROR
        THEN RAISE_APPLICATION_ERROR(-20006,'���ǽ��� ��ϵǾ� ���� �ʽ��ϴ�');
        ROLLBACK;
   WHEN PROFESSOR_ERROR
        THEN RAISE_APPLICATION_ERROR(-20007,'������ȣ�� ��ϵǾ� ���� �ʽ��ϴ�');
        ROLLBACK;
   WHEN COURSE_ERROR
        THEN RAISE_APPLICATION_ERROR(-20008,'������ ��ϵǾ� ���� �ʽ��ϴ�');
        ROLLBACK;
   WHEN INPUT_ERROR
        THEN RAISE_APPLICATION_ERROR(-20009,'������ ���ǽ��� �̹� ��ϵǾ� �ֽ��ϴ�.');
        ROLLBACK;
   WHEN OTHERS
        THEN ROLLBACK;
   
END; 
  
--[ �׽�Ʈ ]---------

SELECT *
FROM OPEN_COURSE;
--==>>
/*
OC1   20/01/13   20/07/30   R6   PRO201   C1
OC2   20/02/09   20/08/21   R5   PRO202   C1
OC3   20/02/12   20/09/01   R4   PRO203   C2
OC4   20/02/20   20/09/21   R3   PRO204   C2
*/
--���� ������ ��
EXEC PRC_COURSE_INPUT(TO_DATE('2021-04-10','YYYY-MM-DD'),TO_DATE('2021-05-10','YYYY-MM-DD'),'R1','imjin','C1');
--==>>ORA-20003: ������ȣ�� ��ϵǾ� ���� �ʽ��ϴ� 

--���� ���ǽ��� ��
EXEC PRC_COURSE_INPUT(TO_DATE('2022-04-10','YYYY-MM-DD'),TO_DATE('2022-05-10','YYYY-MM-DD'),'R300','PRO201','C1');
--==>>ORA-20002: ���ǽ��� ��ϵǾ� ���� �ʽ��ϴ�

--���� ���� �� ��
EXEC PRC_COURSE_INPUT(TO_DATE('2022-04-10','YYYY-MM-DD'),TO_DATE('2022-05-10','YYYY-MM-DD'),'R1','PRO201','C300');
--==>>ORA-20004: ������ ��ϵǾ� ���� �ʽ��ϴ�

--������ ���ǵ�� ��ġ�� �ʴ� ��� 
EXEC PRC_COURSE_INPUT(TO_DATE('2021-04-10','YYYY-MM-DD'),TO_DATE('2021-05-10','YYYY-MM-DD'),'R1','PRO201','C1');

SELECT *
FROM OPEN_COURSE;
--==>>�Է� �Ϸ�
/*
OC1   20/01/13   20/07/30   R6   PRO201   C1
OC2   20/02/09   20/08/21   R5   PRO202   C1
OC3   20/02/12   20/09/01   R4   PRO203   C2
OC4   20/02/20   20/09/21   R3   PRO204   C2
OC5   21/04/10   21/05/10   R1   PRO201   C1
*/

--�̹� �����ϴ� ���
EXEC PRC_COURSE_INPUT(TO_DATE('2021-04-10','YYYY-MM-DD'),TO_DATE('2021-05-10','YYYY-MM-DD'),'R1','PRO201','C1');
--==>>ORA-20005: ������ ���ǽ��� �̹� ��ϵǾ� �ֽ��ϴ�.

--���� ����,�Ⱓ�� �ٸ� ������������ ���ǽ��� �̹� ��� ��
EXEC PRC_COURSE_INPUT(TO_DATE('2021-04-10','YYYY-MM-DD'),TO_DATE('2021-05-10','YYYY-MM-DD'),'R1','PRO202','C1');
--ORA-20005: ������ ���ǽ��� �̹� ��ϵǾ� �ֽ��ϴ�.

--������ ���� �Ⱓ,�ٸ� ���ǽ������� �̹� ���� ���ΰ��
EXEC PRC_COURSE_INPUT(TO_DATE('2020-01-20','YYYY-MM-DD'),TO_DATE('2020-07-10','YYYY-MM-DD'),'R2','PRO201','C1');
--ORA-20005: ������ ���ǽ��� �̹� ��ϵǾ� �ֽ��ϴ�.


--------------------------------------------------------------------------------------------------------------------------

--6. ������ ������ �����ִ� �� ����

CREATE OR REPLACE VIEW VIEW_OPEN_COURSE
AS
SELECT  C.C_NAME"���� �̸�",P.P_ID"������ȣ",P.P_NAME"�����̸�",OC.OC_START"������",OC.OC_END"����������",R.R_NAME"���ǽ��̸�"
FROM PROFESSOR P,OPEN_COURSE OC,ROOM R,COURSE C
WHERE C.C_CODE=OC.C_CODE
    AND P.P_ID =OC.P_ID 
     AND OC.R_CODE=R.R_CODE;
     


-- VIEW_OPEN_COURSE �� ��ȸ      
SELECT *
FROM VIEW_OPEN_COURSE;  
/*
DB������ �缺����   PRO204   ����   20/02/20   20/09/21    C���ǽ�
DB������ �缺����   PRO203   ������   20/02/12   20/09/01   D���ǽ�
SW������ �缺����   PRO202   �¹���   20/02/09   20/08/21   E���ǽ�
SW������ �缺����   PRO201   ��ȣ��   20/01/13   20/07/30   F���ǽ�
*/
---------------------------------------------------------------------------------------------------------------------------

--7. ������ ������ �����ִ� ���(�� ����)
-- ���� Ȯ��
CREATE OR REPLACE VIEW VIEW_OPEN_SUBJECT
AS
SELECT OC.OC_CODE"�����ڵ�",C_NAME"������", SUB_NAME"�����"
,OS_START"���������",OS_END"����������", R_NAME "���ǽ�", B_NAME"����", P_NAME "�����ڸ�"
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

-- Ŀ��
COMMIT;

-- VIEW_OPEN_SUBJECT �� ��ȸ
SELECT *
FROM VIEW_OPEN_SUBJECT;
--==>>
/*
OC1   SW������ �缺����   HTML           20/04/13   20/05/12       F���ǽ�   HTML ������           ��ȣ��
OC1   SW������ �缺����   CSS            20/05/13   20/07/30       F���ǽ�   CSS ������            ��ȣ��
OC1   SW������ �缺����   ����Ŭ         20/02/13   20/02/12       F���ǽ�   ����Ŭ�� ����         ��ȣ��
OC1   SW������ �缺����   �ڹ�           20/01/13   20/02/12       F���ǽ�   �ڹ��� ����           ��ȣ��
OC1   SW������ �缺����   �ڹٽ�ũ��Ʈ   20/03/13   20/04/12       F���ǽ�   �ڹٽ�ũ��Ʈ�� ����   ��ȣ��
OC2   SW������ �缺����   �ڹٽ�ũ��Ʈ   20/04/11   20/05/10       E���ǽ�   �ڹٽ�ũ��Ʈ�� ����   �¹���
OC2   SW������ �缺����   ����Ŭ         20/03/11   20/04/10       E���ǽ�   ����Ŭ�� ����         �¹���
OC2   SW������ �缺����   �ڹ�           20/02/09   20/03/10       E���ǽ�   �ڹ��� ����           �¹���
OC2   SW������ �缺����   CSS            20/06/11   20/08/21       E���ǽ�   CSS ������            �¹���
OC2   SW������ �缺����   HTML           20/05/11   20/06/10       E���ǽ�   HTML ������           �¹���
OC3   DB������ �缺����   HTML           20/03/16   20/04/15       D���ǽ�   HTML ������           ������
OC3   DB������ �缺����   CSS            20/04/16   20/05/15       D���ǽ�   CSS ������            ������
OC3   DB������ �缺����   �ڹٽ�ũ��Ʈ   20/02/12   20/03/15       D���ǽ�   �ڹٽ�ũ��Ʈ�� ����   ������
OC3   DB������ �缺����   �����ͺ��̽�   20/06/16   20/07/15       D���ǽ�   �����ͺ��̽� ����     ������
OC3   DB������ �缺����   ���̽�         20/07/16   20/09/01       D���ǽ�   ���̽� �⺻           ������
OC4   DB������ �缺����   CSS            20/04/20   20/05/19       C���ǽ�   CSS ������            ����
OC4   DB������ �缺����   �ڹٽ�ũ��Ʈ   20/02/20   20/03/19       C���ǽ�   �ڹٽ�ũ��Ʈ�� ����   ����
OC4   DB������ �缺����   �����ͺ��̽�   20/05/20   20/06/19       C���ǽ�   �����ͺ��̽� ����     ����
OC4   DB������ �缺����   ���̽�         20/06/20   20/09/21       C���ǽ�   ���̽� �⺻           ����
OC4   DB������ �缺����   HTML           20/03/20   20/04/19       C���ǽ�   HTML ������           ����
*/

-- 8. ���� ���� ���� ���ν���-------------------------------------------------------------------------------------
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
                THEN RAISE_APPLICATION_ERROR(-20001,'���̵� ���� ���� �ʽ��ϴ�.');
    END;
    
        SELECT P_ID  INTO COMPARE_P_ID
        FROM PROFESSOR
        WHERE P_ID = V_P_ID;
    
    
    UPDATE PROFESSOR
    SET P_NAME = V_P_NAME , P_PW =V_P_PW
    WHERE  P_ID = V_P_ID;    
    
    --Ŀ��
    COMMIT;
    
END;

-- ���� ���̺� ��ȸ
SELECT *
FROM PROFESSOR;
--==>>
/*
PRO201   ��ȣ��   861230-1012546   1012546
PRO202   �¹���   581030-2028857   2028857
PRO203   ������   960712-1023597   1023597
PRO204   ����   970129-2065621   2065621
PRO205   ��ȿ��   960730-2065411   2065411
*/

--[ �׽�Ʈ ]---------

-- ���̵� ��ϵǾ� ���� ���� �� ����ó��
EXEC PRC_PRO_UPDATE('PRO224','�¹ν�','min234');
--==>> �����߻� (ORA-20008: ���̵� ���� ���� �ʽ��ϴ�.)


-- ���̵� ��ϵ� ���̵�� ��ġ�� �� �������� ������Ʈ
EXEC PRC_PRO_UPDATE('PRO202','�¹ν�','min234');
--==>> PL/SQL ���ν����� ���������� �Ϸ�Ǿ����ϴ�.

-- ���ν��� ������ ���� ���̺� ��ȸ
SELECT *
FROM PROFESSOR;
--==>>
/*
PRO201   ��ȣ��   861230-1012546   1012546
PRO202   �¹ν�   581030-2028857   min234
PRO203   ������   960712-1023597   1023597
PRO204   ����   970129-2065621   2065621
PRO205   ��ȿ��   960730-2065411   2065411
*/

-- 9. ��� �������� ������ ��� (�����)----------------------------------------------------------------------------
CREATE OR REPLACE VIEW VIEW_ALLPRO_INFO
AS
SELECT P_NAME "������",SUB_NAME"�����Ȱ���",OS_START"���������",OS_END"����������",B_NAME"�����", R_NAME"���ǽǸ�",
(
CASE WHEN  OS_START >= SYSDATE THEN '���ǿ���'
     WHEN  OS_END <= SYSDATE THEN '��������'
     ELSE '����������'
     END
)"���� ���� ����"

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
--==>> View VIEW_ALLPRO_INFO��(��) �����Ǿ����ϴ�.

-- �� ��ȸ
SELECT *
FROM VIEW_ALLPRO_INFO;
--==>>
/*
��ȣ��   CSS               20/05/13   20/07/30       CSS ������           F���ǽ�   ���ǿ���
��ȣ��   ����Ŭ           20/02/13   20/02/12       ����Ŭ�� ����       F���ǽ�   ��������
��ȣ��   HTML           20/04/13   20/05/12       HTML ������           F���ǽ�   ���ǿ���
��ȣ��   �ڹٽ�ũ��Ʈ   20/05/30   20/06/12       �ڹٽ�ũ��Ʈ�� ����   F���ǽ�   ���ǿ���
��ȣ��   �ڹٽ�ũ��Ʈ   20/03/13   20/04/12       �ڹٽ�ũ��Ʈ�� ����   F���ǽ�   ��������
������   ���̽�           20/07/16   20/09/01       ���̽� �⺻           D���ǽ�   ���ǿ���
������   �����ͺ��̽�   20/06/16   20/07/15       �����ͺ��̽� ����   D���ǽ�   ���ǿ���
������   CSS               20/04/16   20/05/15       CSS ������           D���ǽ�   ���ǿ���
������   HTML           20/03/16   20/04/15       HTML ������           D���ǽ�   ����������
������   �ڹٽ�ũ��Ʈ   20/02/12   20/03/15       �ڹٽ�ũ��Ʈ�� ����   D���ǽ�   ��������
����   ���̽�           20/06/20   20/09/21       ���̽� �⺻           C���ǽ�   ���ǿ���
����   HTML           20/03/20   20/04/19       HTML ������           C���ǽ�   ����������
����   �����ͺ��̽�   20/05/20   20/06/19       �����ͺ��̽� ����   C���ǽ�   ���ǿ���
����   CSS               20/04/20   20/05/19       CSS ������           C���ǽ�   ���ǿ���
����   �ڹٽ�ũ��Ʈ   20/02/20   20/03/19       �ڹٽ�ũ��Ʈ�� ����   C���ǽ�   ��������
�¹���   HTML           20/05/11   20/06/10       HTML ������           E���ǽ�   ���ǿ���
�¹���   ����Ŭ           20/03/11   20/04/10       ����Ŭ�� ����       E���ǽ�   ��������
�¹���   �ڹٽ�ũ��Ʈ   20/04/11   20/05/10       �ڹٽ�ũ��Ʈ�� ����   E���ǽ�   ����������
�¹���   CSS               20/06/11   20/08/21       CSS ������           E���ǽ�   ���ǿ���
�¹���   �ڹ�           20/02/09   20/03/10       �ڹ��� ����           E���ǽ�   ��������
*/

-- Ŀ��
COMMIT;
----------------------------------------------------------------------------------------------------------------

--10. ������� ���� ���� ���̵� �Է����� �� �������ִ� ���ν���
CREATE OR REPLACE PROCEDURE PRC_PRO_DELETE
(   V_P_ID     IN      PROFESSOR.P_ID%TYPE -- �Է¹��� ����ID
)
IS
    COMPARE_P_ID      PROFESSOR.P_ID%TYPE;
    FLAG    NUMBER(1);
BEGIN
    
    -- ���̵� �������� ���� �� ����ó��
    BEGIN
        SELECT P_ID  INTO COMPARE_P_ID
        FROM PROFESSOR
        WHERE P_ID = V_P_ID;
        
        EXCEPTION
            WHEN NO_DATA_FOUND
                THEN RAISE_APPLICATION_ERROR(-20001,'���̵� �������� �ʽ��ϴ�.');
    END;
    
      
    
    DELETE
    FROM PROFESSOR
    WHERE P_ID =V_P_ID;
    
    --Ŀ��
    --COMMIT;

END;
--==>> Procedure PRC_PRO_DELETE��(��) �����ϵǾ����ϴ�.


-- ���� ���̺� ��ȸ
SELECT *
FROM PROFESSOR;
--==>> 
/*
PRO201   ��ȣ��   861230-1012546   1012546
PRO202   �¹���   581030-2028857   2028857
PRO203   ������   960712-1023597   1023597
PRO204   ����   970129-2065621   2065621
PRO205   ��ȿ��   960730-2065411   2065411
*/

--[ �׽�Ʈ ]--------

--���̵� ���� ���� ���� �� �׽�Ʈ
EXEC PRC_PRO_DELETE('123');
--==>> ORA-20008: ���̵� �������� �ʽ��ϴ�.

EXEC PRC_PRO_DELETE('PRO204');
--==>> PL/SQL ���ν����� ���������� �Ϸ�Ǿ����ϴ�.

SELECT *
FROM PROFESSOR;
--==>>
/*
PRO201   ��ȣ��   861230-1012546   1012546
PRO202   �¹���   581030-2028857   2028857
PRO203   ������   960712-1023597   1023597
PRO205   ��ȿ��   960730-2065411   2065411
*/
-------------------------------------------------------------------------------------------------------------------------------

--11.�л� �α��� ���(�Լ����)

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

    -- �Է��� ���̵�� ������ ���̵� �ִ��� ��ȸ  
    SELECT S_ID   INTO TEMP_S_ID 
    FROM STUDENTS
    WHERE S_ID = V_S_ID;
    
    
    
    --�Է��� ���̵� ���� �Ҷ� �н����� ��ȸ
    SELECT S_PW  INTO TEMP_S_PW
    FROM STUDENTS
    WHERE S_ID =V_S_ID;
    
  
     -- �н����尡 ��ġ ���� ���� �� -1 ���̵�� �н����尡 ��� ��ġ�ϸ� 1,  �ߵ�Ż�� �л��̸� 3
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
    
    
    RETURN FLAG; -- ����ó�� ���� �־���Ѵ�

    
    -- ���̵� �Ǵ� ��й�ȣ�� ���� �� ����ó��
    EXCEPTION
        WHEN NO_DATA_FOUND
            THEN    RAISE_APPLICATION_ERROR(-20010,'���̵� �Ǵ� ��й�ȣ�� ��ġ���� �ʽ��ϴ�.');
    
END;

 

-- [ �׽�Ʈ ]--------------

--1.  ���̵�� �н����尡 ��ġ�� �� 
SELECT FN_STUDENT_LOGIN('STU201','2123456')
FROM DUAL;
--==>> 1

--2. ���̵� ��ġ���� ���� ��
SELECT FN_STUDENT_LOGIN('STU','2123456')
FROM DUAL;
--==>> ���� �߻�
--(ORA-20013: ���̵� �Ǵ� ��й�ȣ�� ��ġ���� �ʽ��ϴ�.)

--3. �н����常 ��ġ���� ���� ��
SELECT FN_STUDENT_LOGIN('STU201','2123')
FROM DUAL;
--==>> -1

--4. ���̵�� �н����尡 ��� ��ġ���� ���� ��
SELECT FN_STUDENT_LOGIN('ST1','215685855')
FROM DUAL;
--==>> ���� �߻�
--(ORA-20013: ���̵� �Ǵ� ��й�ȣ�� ��ġ���� �ʽ��ϴ�.)

--5. �ߵ�Ż���л��� �α��� ���� ��
SELECT FN_STUDENT_LOGIN('STU203','1123456')
FROM DUAL;
--==>> 3


------------------------------------------------------------------------------------------------------------------------------------

--12.��ϵ� ���� ����(* ���������(),�����Ⱓ,���ǽǹ�ȣ,������ )���ν���

--�����ڵ�,����������,����������,�����ڸ�,���ǽǸ� �Է�
CREATE OR REPLACE PROCEDURE PRO_OC_UPDATE
( V_OC_CODE IN OPEN_COURSE.OC_CODE%TYPE
, V_C_CODE IN  COURSE.C_CODE%TYPE
, V_OC_START IN OPEN_COURSE.OC_START%TYPE
, V_OC_END   IN OPEN_COURSE.OC_END%TYPE
, V_R_NAME   IN ROOM.R_NAME%TYPE
, V_P_NAME   IN PROFESSOR.P_NAME%TYPE 
)
IS
--(������ ����,���ǽ�,������)�ڵ�
 
  V_R_CODE     ROOM.R_CODE%TYPE;
  V_P_ID     PROFESSOR.P_ID%TYPE;

--�����ϴ��� Ȯ��
  C_CHECK      NUMBER; --�Է��� �������� �����Ǿ� �ִ��� üũ�ϱ� ����
  R_CHECK      NUMBER; --�Է��� ���ǽ��� ���ǽ� ���̺� �ִ��� üũ�ϱ� ����
  P_CHECK      NUMBER;-- �Է��� �����̸��� ������ ���̺� �ִ��� üũ�ϱ� ����
  DATE_CK  NUMBER; --������Ʈ �Ϸ��� ��¥�� ������ ������ ��¥ ���̿� �ִ��� üũ
  TABLE_CK    NUMBER; --���ǽ��� ���������,������ ���������� üũ
  
--���� ����
 OC_CODE_ERROR EXCEPTION;
 OC_ROOM_ERROR EXCEPTION;
 OC_PROFESSOR_ERROR EXCEPTION;
 EXIST_ERROR EXCEPTION;
BEGIN

--�Է��� �����ڵ尡 �������̺� �����Ǿ� �ִ��� ��ȸ
    SELECT COUNT(*) INTO C_CHECK  --������ 1��ȯ,������ 0��ȯ �� ����
    FROM COURSE
    WHERE C_CODE = V_C_CODE;

    
    --���� �� �Ѵٸ� ����
    IF(C_CHECK =0)
       THEN RAISE OC_CODE_ERROR;
    END IF;

    
--�Է��� ���ǽ� �̸��� �������̺� �����Ǿ� �ִ��� ��ȸ
    SELECT COUNT(*) INTO R_CHECK  --������ 1��ȯ,������ 0��ȯ �� ����
    FROM ROOM
    WHERE R_NAME = V_R_NAME;
    
    --���� �� �Ѵٸ� ����
    IF(R_CHECK =0)
       THEN RAISE OC_ROOM_ERROR;
    END IF;
    
    --�ڵ��ȣ ��ȯ
    SELECT R_CODE INTO V_R_CODE
    FROM ROOM
    WHERE R_NAME = V_R_NAME;
    
--�Է��� �����̸��� �������̺� �����Ǿ� �ִ��� ��ȸ
    SELECT COUNT(*) INTO P_CHECK  --������ 1��ȯ,������ 0��ȯ �� ����
    FROM PROFESSOR
    WHERE P_NAME = V_P_NAME;
    
    --���� �� �Ѵٸ� ����
    IF(P_CHECK =0)
       THEN RAISE OC_PROFESSOR_ERROR;
    END IF;
    
    --������ȣ ��ȯ
    SELECT P_ID INTO V_P_ID
    FROM PROFESSOR
    WHERE P_NAME = V_P_NAME;

--������Ʈ �Ϸ��� ������ �������̺� �ִ� ������ ����

SELECT COUNT(*) INTO DATE_CK
FROM OPEN_COURSE
WHERE (V_OC_START BETWEEN OC_START AND OC_END AND OC_CODE != V_OC_CODE); --�ٲٷ��� �����ڵ��� ���� ����
--������Ʈ ���� ��¥�� ���������� ��¥�� ���̿� �ִٸ� ������,���ǽ��� ��ĥ �� ����


SELECT COUNT(*) INTO TABLE_CK --������ �ִ� �������̵�� ���ǽ� �ڵ�� �ȵ�
FROM OPEN_COURSE
WHERE (R_CODE =V_R_CODE OR  P_ID = V_P_ID )AND OC_CODE=V_OC_CODE;

IF(DATE_CK !=0 )
  THEN  IF(TABLE_CK !=0)
                THEN RAISE EXIST_ERROR;
            END IF;
END IF;

--������,����������,����������,�����ڸ�,���ǽǸ� �Է�  
    UPDATE OPEN_COURSE
    SET 
        OC_START =V_OC_START
        ,OC_END = V_OC_END
        ,P_ID=V_P_ID
        ,R_CODE =V_R_CODE
        ,C_CODE = V_C_CODE
    WHERE OC_CODE=V_OC_CODE ;
    
    --Ŀ�� 
    COMMIT;
    
  
    --����ó��
   EXCEPTION
   WHEN OC_ROOM_ERROR
        THEN RAISE_APPLICATION_ERROR(-20006,'���ǽ��� ��ϵǾ� ���� �ʽ��ϴ�');
        ROLLBACK;
   WHEN OC_PROFESSOR_ERROR
        THEN RAISE_APPLICATION_ERROR(-20014,'������ȣ�� ��ϵǾ� ���� �ʽ��ϴ�');
        ROLLBACK;
   WHEN OC_CODE_ERROR 
        THEN RAISE_APPLICATION_ERROR(-20008,'������ ��ϵǾ� ���� �ʽ��ϴ�');
        ROLLBACK;
    WHEN EXIST_ERROR
        THEN RAISE_APPLICATION_ERROR(-20009,'������Ʈ �Ϸ��� �������̳� ���ǽ��� �̹�  ��ϵǾ� �ֽ��ϴ�.');
        ROLLBACK;
   WHEN OTHERS
      THEN ROLLBACK;
   
    
  
END;


-- [ �׽�Ʈ ]---------

--�����Ȱ����ڵ�, �����ڵ�, ��������������, ��������������, ���ǽǸ�, ������ 
--1. ������ �������� �����Ǿ� �ִ��� üũ (������ ������ �������� �ٲ� �� �Է��� ������ ���� ���̺� ���� �� ������ �� ����)
EXEC PRO_OC_UPDATE('OC1','C0',TO_DATE('2020-01-13','YYYY-MM-DD'),TO_DATE('2020-07-30','YYYY-MM-DD'),'F���ǽ�','��ȣ��');
--==>> ���� �߻�
--(ORA-20008: ������ ��ϵǾ� ���� �ʽ��ϴ�)

--2. ������ ���ǽ��� ���ǽ� ���̺� �ִ��� üũ (���� ���ǽ� ������ �� ����)
EXEC PRO_OC_UPDATE('OC1','C1',TO_DATE('2020-01-13','YYYY-MM-DD'),TO_DATE('2020-07-30','YYYY-MM-DD'),'���ǽ�','��ȣ��');
--==>> ���� �߻�
--(ORA-20006: ���ǽ��� ��ϵǾ� ���� �ʽ��ϴ�)

--3. �Է��� �����̸��� ������ ���̺� �ִ��� üũ (������ ������ ���� �� ���� �� �� ����)
EXEC PRO_OC_UPDATE('OC1','C1',TO_DATE('2020-01-13','YYYY-MM-DD'),TO_DATE('2020-07-30','YYYY-MM-DD'),'F���ǽ�','���ϳ�');
--==>> ���� �߻�
--(ORA-20007: ������ȣ�� ��ϵǾ� ���� �ʽ��ϴ�)

--4. ������Ʈ �Ϸ��� ��¥�� ������ ������ ��¥ ���̿� �ִ��� üũ (������ �����Ⱓ�� �̹� �������� �������� ������ �� ����.)
EXEC PRO_OC_UPDATE('OC1','C1',TO_DATE('2020-02-09','YYYY-MM-DD'),TO_DATE('2020-08-21','YYYY-MM-DD'),'F���ǽ�','�¹���');
--==>> ���� �߻�
--(ORA-20009: ������Ʈ �Ϸ��� �������̳� ���ǽ��� �̹�  ��ϵǾ� �ֽ��ϴ�.)

--5. ���ǽ��� ���������,������ ���������� üũ (������ �����Ⱓ�� �̹� ������ ���ǽǰ�, �������� ���� �� ���� �� �� ����.)
EXEC PRO_OC_UPDATE('OC1','C1',TO_DATE('2020-02-09','YYYY-MM-DD'),TO_DATE('2020-08-21','YYYY-MM-DD'),'E���ǽ�','�¹���');
--==>> ���� �߻�
--(ORA-20009: ������Ʈ �Ϸ��� �������̳� ���ǽ��� �̹�  ��ϵǾ� �ֽ��ϴ�.)

-- 6. ���ǽǰ� �����Ⱓ�� ���� ��
EXEC PRO_OC_UPDATE('OC1','C1',TO_DATE('2020-02-09','YYYY-MM-DD'),TO_DATE('2020-08-21','YYYY-MM-DD'),'E���ǽ�','��ȣ��');
--==>> ���� �߻�
--(ORA-20009: ������Ʈ �Ϸ��� �������̳� ���ǽ��� �̹�  ��ϵǾ� �ֽ��ϴ�.)

-- 7. �����Ⱓ�� ������ ���ǽǸ� �ٸ� ��
-- ���� ��
--==>> OC1   20/01/13   20/07/30   R6   PRO201   C1

-- ���� ��
EXEC PRO_OC_UPDATE('OC1','C1',TO_DATE('2020-02-09','YYYY-MM-DD'),TO_DATE('2020-08-21','YYYY-MM-DD'),'F���ǽ�','��ȣ��');
--==>> 
/*
PL/SQL ���ν����� ���������� �Ϸ�Ǿ����ϴ�.

OC1   20/02/09   20/08/21   R6   PRO201   C1              1-13 ~ 7-30 ���� ���� �Ⱓ�� �޶���  
*/
-- �������̺� ������ �ְ� ������ ������ �������� �ְ�, �����Ⱓ�� ���ǽ��� ��ġ�� ���� �� 
-- ���� ��
--==>> OC1   20/01/13   20/07/30   R6   PRO201   C1

-- ���� ��
EXEC PRO_OC_UPDATE('OC1','C1',TO_DATE('2020-05-09','YYYY-MM-DD'),TO_DATE('2020-06-21','YYYY-MM-DD'),'E���ǽ�','������');
--==>> 
/*
PL/SQL ���ν����� ���������� �Ϸ�Ǿ����ϴ�.

OC1   20/05/09   20/06/21   R5   PRO203   C2                     �Ⱓ�� ����, ���ǽ� ��� �ٲ� ���� Ȯ�� �� �� �ִ�.
*/


-- 8. ��� ������ ����
-- ���� ��
--==>> OC1   20/01/13   20/07/30   R6   PRO201     C1

-- ���� ��
EXEC PRO_OC_UPDATE('OC1','C1',TO_DATE('2020-01-13','YYYY-MM-DD'),TO_DATE('2020-07-30','YYYY-MM-DD'),'F���ǽ�','�¹���');
--==>> 
/*
PL/SQL ���ν����� ���������� �Ϸ�Ǿ����ϴ�.

OC1   20/01/13   20/07/30   R6   PRO202   C1          ��� ������ PRO201 -> PRO202�� �ٲ� �� Ȯ�� �� �� �ִ�.
*/

----------------------------------------------------------------------------------------------------------------------------------------

--13. ���� �α��� ��� (�Լ����)

CREATE OR REPLACE FUNCTION FN_PIDPW(IN_PID VARCHAR2, IN_PPW VARCHAR2)
RETURN NUMBER
IS
    V_PID        PROFESSOR.P_ID%TYPE;
    V_PPW      PROFESSOR.P_PW%TYPE;
    P_RESULT NUMBER;
BEGIN 
    BEGIN
        --ID �� ��ġ�ϴ��� ���ϴ��� Ȯ��
        SELECT P_ID INTO V_PID
        FROM PROFESSOR
        WHERE P_ID = IN_PID;
        
       -- ID�� ��ġ���� ������ ����ó��
        EXCEPTION
            WHEN NO_DATA_FOUND
            THEN RAISE_APPLICATION_ERROR(-20010, '���̵� �Ǵ� ��й�ȣ�� ��ġ���� �ʽ��ϴ�.');
    END;
    
    -- ID�� ��ġ�ϸ� PW ��ġ�ϴ� �� Ȯ��
    SELECT P_PW INTO V_PPW
    FROM PROFESSOR
    WHERE P_ID = IN_PID;
    
    -- PW�� ��ġ���� ������ -1
    IF(IN_PPW = V_PPW)
        THEN P_RESULT := 1;
    ELSE 
            P_RESULT := -1;
    END IF;
 RETURN P_RESULT;
END;

---------

-- [ �׽�Ʈ ]----------------
SELECT *
FROM PROFESSOR;
-- 1. ���̵� ��ġ���� ���� ��
SELECT FN_PIDPW('P201','1012546')
FROM DUAL;
--==>> ���� �߻�
--(ORA-20011: ���̵� �Ǵ� ��й�ȣ�� ��ġ���� �ʽ��ϴ�.)

-- 2. �н����常 ��ġ���� ���� ��
SELECT FN_PIDPW('PRO201','10002546')
FROM DUAL;
--==>> -1

-- 3. ���̵� �н����� ��� ��ġ���� ���� ��
SELECT FN_PIDPW('PRO','10002546')
FROM DUAL;
--==>> ���� �߻�
--(ORA-20011: ���̵� �Ǵ� ��й�ȣ�� ��ġ���� �ʽ��ϴ�.)

-- 4. ���̵� �н����� ��� ��ġ���� ��
SELECT FN_PIDPW('PRO201','1012546')
FROM DUAL;
--==>> 1


---------------------------------------------------------------------------------------------------------------------------------------

--14.������ ���� ����
CREATE OR REPLACE PROCEDURE PRO_OC_DELETE
(
    V_OC_CODE IN OPEN_COURSE.OC_CODE%TYPE
)
IS
BEGIN
    
    DELETE
    FROM OPEN_COURSE
    WHERE OC_CODE =V_OC_CODE;
    
    --Ŀ��
    COMMIT;
   
END;

-------

-- [ �׽�Ʈ ]---------
SELECT *
FROM OPEN_COURSE;
--==>>
/*
OC1   20/01/13   20/07/30   R6   PRO201   C1
OC2   20/02/09   20/08/21   R5   PRO202   C1
OC3   20/02/12   20/09/01   R4   PRO203   C2
*/
-- ������ ���� OC3 �����ϱ�
EXEC PRO_OC_DELETE('OC3');

-- ���� �� ������ ���� Ȯ���ϱ�
SELECT *
FROM OPEN_COURSE;
--==>>
/*
OC1   20/01/13   20/07/30   R6   PRO201   C1
OC2   20/02/09   20/08/21   R5   PRO202   C1
*/
---------------------------------------------------------------------------------------------------------------------------
--15. ������ ��� �л� ���� ��� --������ �ٽ� �־ Ȯ���ϱ�
CREATE OR REPLACE VIEW VIEW_STUDENTS
AS
      SELECT DISTINCT S.S_NAME"�л��̸�", C.C_NAME "������", SUB.SUB_NAME"�����"
                ,NVL((G.S_CHUL+G.S_SILGI+G.S_PILGI), 0)"����"
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
 
-- [ �׽�Ʈ ]---------           
SELECT *
FROM VIEW_STUDENTS;


--------------------------------------------------------------------------------------------------------------------------
--16. �л����� ���� ���ν��� (�л����̵�,�л��̸�,�л��ֹι�ȣ,�л���й�ȣ)
CREATE OR REPLACE PROCEDURE PRC_STU_UPDATE(
V_S_ID  IN  STUDENTS.S_ID%TYPE          --�л����̵�
,V_S_NAME IN    STUDENTS.S_NAME%TYPE    --�л��̸�
,V_S_SSN    IN  STUDENTS.S_SSN%TYPE     --�л��ֹι�ȣ
,V_S_PW     IN  STUDENTS.S_PW%TYPE      --�л���й�ȣ
)
IS
TEMP_S_ID   STUDENTS.S_ID%TYPE;
BEGIN
    -- �Էµ� ���̵� ���̺� �ִ��� ��ȸ
    SELECT S_ID INTO TEMP_S_ID
    FROM STUDENTS
    WHERE S_ID = V_S_ID;
    
    -- �Էµ� �����ͷ� �л� ������ ����
    UPDATE STUDENTS
    SET S_NAME=V_S_NAME , S_SSN = V_S_SSN , S_PW = V_S_PW
    WHERE S_ID = V_S_ID;
    
    --Ŀ��
    COMMIT;
    
    
    --�Է��� �л� ���̵� ���� �� ����ó��
    EXCEPTION
        WHEN NO_DATA_FOUND
            THEN RAISE_APPLICATION_ERROR(-20011,'��ġ�ϴ� �л��� �����ϴ�.');
     
END;

--[ �׽�Ʈ ]-----------------
-- �л� ���̺� ��ȸ
SELECT *
FROM STUDENTS;
/*
STU201	�赿��	950728-2123456	2123456
STU202	������	970129-2123457	2123457
STU203	������	960712-1123456	1123456
STU204	��ȿ��	950728-2123458	2123458
STU205	�ֱ⿬	990505-1123457	1123457
STU206	������	930728-2123456	2123456
STU207	��ä��	950729-2133457	2133457
STU208	�ۼ���	950712-1153456	1153456
STU209	�����	950828-2123458	2123458
STU2010	�ż�ö	990505-1143457	1143457
*/


--�л����� ���� ���ν��� �׽�Ʈ (�л����̵�,�л��̸�,�л��ֹι�ȣ,�л���й�ȣ)
-- ID�� ��ġ �Ҷ�
EXEC PRC_STU_UPDATE('STU201','�赿��','950728-2123456','DNEHD1828');
--==>PL/SQL ���ν����� ���������� �Ϸ�Ǿ����ϴ�.
--==>���� �� )STU201	�赿��	950728-2123456	2123456
--==>���� �� )STU201	�赿��	950728-2123456	DNEHD1828

--ID�� ��ġ ���� ���� ��
EXEC PRC_STU_UPDATE('KDH915','�赿��','950728-2123456','DNEHD1828');
--==>ORA-20010: ��ġ�ϴ� �л��� �����ϴ�.

----------------------------------------------------------------------------------------------------------------------------

--17. ������ ���� ���� ���ν���
SELECT *
FROM OPEN_SUBJECT;
--�����ڵ�,�����,���������,����������,����,�⼮,����,�Ǳ� �Է� ����

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
    S_CHECK  NUMBER; --�Է��� ������ �������̺� �����ϴ��� Ȯ���� ��
    B_CHECK  NUMBER;--�Է��� ���簡 �������̺� �����ϴ���
    
 
    --������ ����Ⱓ�� �����Ⱓ�ȿ� �ִ��� Ȯ���ϱ� ����
    CK_OC_START OPEN_COURSE.OC_START%TYPE;
    CK_OC_END  OPEN_COURSE.OC_END%TYPE;
    
    NO_SUBJECT EXCEPTION;--�������̺� ���� �� �� �� ����
    NO_BOOK EXCEPTION;--���簡 �������̺� ���� �� �� �� ����
    DATE_ERROR EXCEPTION; --���� �Ⱓ�� �߸��Ǿ��� �� ����
BEGIN
 
     --�����ϴ� �������� Ȯ��
     SELECT COUNT(*) INTO S_CHECK
     FROM SUBJECT
     WHERE SUB_CODE = V_SUB_CODE;
     
     IF(S_CHECK=0) --���� �� �ϸ� ����
        THEN RAISE NO_SUBJECT;
     END IF;
     
     --�����ϴ� �������� Ȯ��
     SELECT COUNT(*)  INTO B_CHECK
     FROM BOOK
     WHERE B_CODE =V_B_CODE;
     
     IF(B_CHECK=0)
       THEN RAISE NO_BOOK;
    END IF;


    --�Է¹��� �����ڵ�� ���� �Ⱓ ����
    SELECT OC_START,OC_END INTO CK_OC_START,CK_OC_END
    FROM OPEN_COURSE
    WHERE OC_CODE = V_OC_CODE;
    
    IF(V_OS_START <CK_OC_START OR V_OS_END >CK_OC_END)
        THEN RAISE DATE_ERROR;
    END IF;



  --������Ʈ ��
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
  
    --Ŀ��  
    COMMIT;
 
  EXCEPTION
  WHEN DATE_ERROR
     THEN RAISE_APPLICATION_ERROR(-20012,'������ ��¥�� �ùٸ��� �ʽ��ϴ�.');
     ROLLBACK;
  WHEN NO_SUBJECT
     THEN RAISE_APPLICATION_ERROR(-20013,'�ش� ������ �������� �ʽ��ϴ�.');
     ROLLBACK;
  WHEN NO_BOOK
    THEN RAISE_APPLICATION_ERROR(-20014,'�ش� ���簡 �������� �ʽ��ϴ�.');
    ROLLBACK;
    --WHEN OTHERS
    --THEN ROLLBACK;
  
END;


--[ �׽�Ʈ ]---------

SELECT *
FROM OPEN_SUBJECT;
--���� ��
--==> OS1	SUB1	20/01/13	20/02/12	B1	OC1	20	30	50

--�����ڵ� �ٲٱ�
EXEC PRO_OC_UPDATE('OC1','OS1','SUB3',TO_DATE('2020-05-30','YYYY-MM-DD'),TO_DATE('2020-06-12','YYYY-MM-DD'),'B3',20,40,40);
--���� �� 
--==>OS1	SUB3	20/05/30	20/06/12	B3	OC1	20	40	40

    
--���� ��¥�� ���� �ȿ� ���� �� �� ��
EXEC PRO_OC_UPDATE('OC1','OS1','SUB3',TO_DATE('202-05-30','YYYY-MM-DD'),TO_DATE('2002-06-12','YYYY-MM-DD'),'B3',20,40,40);
--==>ORA-20001: ������ ��¥�� �ùٸ��� �ʽ��ϴ�.

--���� ���� ��
EXEC PRO_OC_UPDATE('OC1','OS1','SUB3',TO_DATE('2020-05-30','YYYY-MM-DD'),TO_DATE('2020-06-12','YYYY-MM-DD'),'B50',20,40,40);
--==>ORA-20003: �ش� ���簡 �������� �ʽ��ϴ�.


----------------------------------------------------------------------------------------------------------------------------

--18. ������ �ڽ��� �����ϴ� ������ ���
CREATE OR REPLACE PROCEDURE PRC_P_SUB_SELECT
( V_PID  IN PROFESSOR.P_ID%TYPE
, V_OUT OUT SYS_REFCURSOR
)
IS
BEGIN
    
     OPEN V_OUT FOR
     
      SELECT C.C_NAME "������", SUB.SUB_NAME"�����", OS.OS_START"���������", OS.OS_END"����������"
        FROM PROFESSOR P, COURSE C, OPEN_COURSE OC, OPEN_SUBJECT OS, SUBJECT SUB
        WHERE P.P_ID = V_PID
                      AND P.P_ID = OC.P_ID
                     AND C.C_CODE = OC.C_CODE
                     AND SUB.SUB_CODE = OS.SUB_CODE
                     AND OC.OC_CODE = OS.OC_CODE ;
END;



-----
SET SERVEROUTPUT ON;

-- PRO201 ������ �����ϴ� ���� ��� Ȯ��
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
SW������ �缺����  �ڹٽ�ũ��Ʈ  20/05/30   20/06/12
SW������ �缺����  ����Ŭ  20/02/13   20/02/12
SW������ �缺����  �ڹٽ�ũ��Ʈ  20/03/13   20/04/12
SW������ �缺����  HTML  20/04/13   20/05/12
SW������ �缺����  CSS  20/05/13   20/07/30
*/

-------------------------------------------------------------------------------------------------------------------------
--19.������ ���� �Է� & ���� ���ν��� 

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
JUMSU_UMSU           EXCEPTION; -- ������ �������� �ԷµǾ��� �� �Ͼ�� ����
BEGIN

    SELECT GRADE_CODE,OS_CODE INTO TEMP_GRADE_CODE,TEMP_OS_CODE
    FROM GRADE
    WHERE GRADE_CODE = V_GRADE_CODE;
    
    
    SELECT P_CHUL,P_SILGI,P_PILGI INTO TEMP_P_CHUL,TEMP_P_SILGI,TEMP_P_PILGI 
    FROM OPEN_SUBJECT 
    WHERE OS_CODE = TEMP_OS_CODE;
    
    -- �Է��� ������ ������ �Է��� �������� Ŭ �� ����ó��
    IF(V_S_PILGI >TEMP_P_PILGI OR V_S_SILGI >TEMP_P_SILGI OR V_S_CHUL > TEMP_P_CHUL)
        THEN RAISE JUMSU_ERROR;
    END IF;
    
    -- �Է��� ������ ���� �� �� ����ó��
    IF(V_S_PILGI< 0 OR V_S_SILGI <0 OR V_S_CHUL <0)
        THEN RAISE JUMSU_UMSU;
    END IF;
    
    UPDATE GRADE
    SET S_PILGI=V_S_PILGI , S_SILGI=V_S_SILGI , S_CHUL=V_S_CHUL
    WHERE GRADE_CODE=V_GRADE_CODE;
    
    EXCEPTION
        WHEN JUMSU_ERROR
            THEN RAISE_APPLICATION_ERROR(-20015,'������ �ʰ��Ͽ����ϴ�.');
        WHEN JUMSU_UMSU
            THEN RAISE_APPLICATION_ERROR(-20016,'�߸��� ���� �Դϴ�.');
        WHEN NO_DATA_FOUND
            THEN RAISE_APPLICATION_ERROR(-20017,'�Է��Ͻ� �����ڵ尡 �������� �ʽ��ϴ�.');  
    
END;

--���� ���̺� ��ȸ
SELECT *
FROM GRADE;
/*
GRD1	SC1	    OS1	
--==> ������ �� ���� ���� ����
*/
SELECT *
FROM OPEN_SUBJECT;                    -- ����OS1�� ���,�Ǳ�,�ʱ� ����
--==>OS1	SUB3	20/05/30	20/06/12	B3	OC1	20	40	40

-- �׽�Ʈ-----------------------------------------------------------------------

-- ������ �Է� �Ǿ��� ��
EXEC PRC_GRADE_UPDATE('GRD1',-1,3,30);
--==>ORA-20012: �߸��� ���� �Դϴ�.

--������ �Է��� �������� �ʰ� �Է� �Ǿ��� ��
EXEC PRC_GRADE_UPDATE('GRD1',30,3,30);
--==>ORA-20030: ������ �ʰ��Ͽ����ϴ�

-- �ùٸ� ���� �Է� ���� ��
EXEC PRC_GRADE_UPDATE('GRD1',20,33,30);
--==>GRD1	SC1	OS1	20	30	33

---------------------------------------------------------------------------------------------------------------------------
-- 20.�ߵ�Ż�� �л� �Է� ���ν���
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
            THEN RAISE_APPLICATION_ERROR(-20018,'������û���� ���� �л��Դϴ�.');
    
END;

-- �л� ���� ���̺� ��ȸ
SELECT *
FROM STUDENTS;
/*
STU201	�赿��	950728-2123456	DNEHD1828
STU202	������	970129-2123457	2123457
STU203	������	960712-1123456	1123456
STU204	��ȿ��	950728-2123458	2123458
STU205	�ֱ⿬	990505-1123457	1123457
STU206	������	930728-2123456	2123456
STU207	��ä��	950729-2133457	2133457
STU208	�ۼ���	950712-1153456	1153456
STU209	�����	950828-2123458	2123458
STU2010	�ż�ö	990505-1143457	1143457
STU2011	ȫ�浿	980124-1233456	1233456
*/

SELECT *
FROM DROP_STUDENTS;
--==>DS1	20/04/12	SC3



-----[ �׽�Ʈ ]-------------------------------------------------------------

-- ������û ���� ���� �л��� �ߵ� Ż�� ���̺� �Է� �Ǵ� ���
EXEC PRC_DROPSTU_INSERT('STU20S3',TO_DATE('2020-03-31','YYYY-MM-DD'));
--==>ORA-20013: ������û���� ���� �л��Դϴ�.

-- ������û �� �л��� �ߵ� Ż�� ���� ���
EXEC PRC_DROPSTU_INSERT('STU203',TO_DATE('2020-03-31','YYYY-MM-DD'));
/*
DS1	20/04/12	SC3
DS3	20/03/31	SC3
*/
---------------------------------------------------------------------------------------------------------------------------
-- 21. ������û �Է� ���ν���
CREATE OR REPLACE PROCEDURE PRC_SC_INSERT(
 V_S_ID      IN  STUDENTS.S_ID%TYPE         -- �л� ���̵�
,V_OC_CODE  IN  OPEN_COURSE.OC_CODE%TYPE    -- ������ ���� �ڵ�
,V_SC_DATE  IN  STUDENT_COURSE.SC_CODE%TYPE -- ���� ��û ��¥
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
    
    
    PRC_GRADE_INSERT(TEMP_SC_CODE); -- ������û ���ÿ� ����� ������ ���� ������� �� �л� �������� ���̺� �־��ش�. 
     
    -- ����ó��
    EXCEPTION
        --�л� ���̵� ���ٸ� ����ó��
        WHEN NOT_SID_ERROR   
            THEN RAISE_APPLICATION_ERROR(-20001,'���̵� �������� �ʽ��ϴ�.');
        WHEN NOT_OCCODE_ERROR 
            THEN RAISE_APPLICATION_ERROR(-20008,'������ �������� �ʽ��ϴ�.');
        WHEN CHECK_SC_ERROR
            THEN RAISE_APPLICATION_ERROR(-20019,'������ ������ ��� �л��� �����մϴ�.');
      
        --COMMIT;               
END;
  
 
 
 

--������û ���ÿ� ����� ������ ���� ������� �� �л� �������� ���̺� �־��ִ� ���ν���
CREATE OR REPLACE PROCEDURE PRC_GRADE_INSERT(
V_SC_CODE  IN  STUDENT_COURSE.SC_CODE%TYPE
)
IS

    V_OS_CODE      OPEN_SUBJECT.OS_CODE%TYPE;
    
    --�Է¹��� OS_CODE �� ��ġ�ϴ� ������� Ŀ���� �־��ش�.
    CURSOR CUR_GRADE_SELECT
        IS        
        SELECT OS_CODE
        FROM STUDENT_COURSE SC,OPEN_COURSE OC,OPEN_SUBJECT OS
        WHERE OC.OC_CODE = SC.OC_CODE
          AND OS.OC_CODE = OC.OC_CODE
          AND SC_CODE=V_SC_CODE;
               
BEGIN

         -- Ŀ�� ����
        OPEN CUR_GRADE_SELECT;    
       
        LOOP
        -- OC_CODE�� ��ġ�ϴ� ������� �ϳ��� ������ ��´�
        FETCH CUR_GRADE_SELECT INTO  V_OS_CODE;
        
       
        EXIT WHEN CUR_GRADE_SELECT%NOTFOUND;       
        
        -- ������ ��� �����͵� �ϳ��� �л� �������� ���̺� �־��ش�.
        INSERT INTO GRADE(GRADE_CODE,SC_CODE,OS_CODE) 
        VALUES ('GRD'||TO_CHAR(GRADE_NUM.NEXTVAL), V_SC_CODE, V_OS_CODE);       
        END LOOP;
        CLOSE CUR_GRADE_SELECT;        
  
END;
----------------------------------------------------------------------------------------------------------------------------
-- (22)������ �ڽ��� �����ϴ� ������ �л��� ���
CREATE OR REPLACE PROCEDURE PRC_P_GRADE_VIEW
( V_P_ID  IN PROFESSOR.P_ID%TYPE
, V_OUT OUT SYS_REFCURSOR
)
IS
BEGIN
    
     OPEN V_OUT FOR
    
     
           SELECT  DISTINCT SUB.SUB_NAME"�����", OS.OS_START"���������", OS.OS_END"����������",B.B_NAME"�����", S.S_NAME"�л��̸�",G.S_CHUL"�⼮����",G.S_SILGI"�Ǳ�����",G.S_PILGI"�ʱ�����"
                ,(G.S_CHUL+G.S_SILGI+G.S_PILGI)"����" ,RANK() OVER (PARTITION BY SUB.SUB_CODE ORDER BY  G.S_CHUL+G.S_SILGI+G.S_PILGI DESC )"���"
                 ,(
                        CASE  WHEN DS.D_DATE BETWEEN OS.OS_START AND OS.OS_END THEN'�ߵ�Ż��'
                               ELSE '����'
                               END
                       
                
                )"�ߵ�Ż������"
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

-- ������ �����ϴ� ���� ��� Ȯ��
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
����Ŭ  20/03/11  20/04/10  ����Ŭ�� ����  �ۼ���          1  ����
�ڹ�  20/02/09  20/03/10  �ڹ��� ����  �ۼ���          1  ����
����Ŭ  20/03/11  20/04/10  ����Ŭ�� ����  ������  20  20  23  63  2  �ߵ�Ż��
�ڹ�  20/02/09  20/03/10  �ڹ��� ����  ������  20  20  22  62  2  ����


*/

----------------------------------------------------------------------------------------------------------------------------
SELECT *
FROM STUDENTS;

-- 23.�л��� �ڽ��� ������ �л���, ������, �����, ����Ⱓ, �����, ���, �Ǳ�, �ʱ�, ����, ��� ���
CREATE OR REPLACE PROCEDURE PRC_S_SUB_SELECT
( V_SID  IN STUDENTS.S_ID%TYPE
, V_OUT OUT SYS_REFCURSOR
)
IS
BEGIN
    
     OPEN V_OUT FOR
     
      SELECT S.S_NAME"�л��̸�", SUB.SUB_NAME"�����", OS.OS_START"���������", OS.OS_END"����������",B.B_NAME"�����",G.S_CHUL"�⼮����",G.S_SILGI"�Ǳ�����",G.S_PILGI"�ʱ�����"
                ,(G.S_CHUL+G.S_SILGI+G.S_PILGI)"����" ,RANK() OVER (PARTITION BY SUB.SUB_CODE ORDER BY  G.S_CHUL+G.S_SILGI+G.S_PILGI DESC )"���"
                ,(
                        CASE  WHEN DS.D_DATE BETWEEN OS.OS_START AND OS.OS_END THEN'�ߵ�Ż��'
                               ELSE '����'
                               END
                       
                
                )"�ߵ�Ż������"
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

-- �л��� �ڽ��� ������ ������ ������� Ȯ��
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
����Ŭ        20/02/13  20/02/12  ����Ŭ�� ����  �赿��  20  20  20  60  1  ���� 
�ڹٽ�ũ��Ʈ  20/03/13  20/04/12  �ڹٽ�ũ��Ʈ�� ����  �赿��  20  20  20  60  1  ���� 
*/

-- 24.�ߵ������� �л��� �ڽ��� ������ �л���, ������, �����, ����Ⱓ, �����, ���, �Ǳ�, �ʱ�, ����, ��� ���
CREATE OR REPLACE PROCEDURE PRC_S_SUB_SELECT
( V_SID  IN STUDENTS.S_ID%TYPE
, V_OUT OUT SYS_REFCURSOR
)
IS
BEGIN
    
     OPEN V_OUT FOR
     
      SELECT DISTINCT S.S_NAME"�л��̸�", SUB.SUB_NAME"�����", OS.OS_START"���������", OS.OS_END"����������",B.B_NAME"�����",G.S_CHUL"�⼮����",G.S_SILGI"�Ǳ�����",G.S_PILGI"�ʱ�����"
                ,(G.S_CHUL+G.S_SILGI+G.S_PILGI)"����" ,RANK() OVER (PARTITION BY SUB.SUB_CODE ORDER BY  G.S_CHUL+G.S_SILGI+G.S_PILGI DESC )"���"
                ,(
                        CASE  WHEN DS.D_DATE BETWEEN OS.OS_START AND OS.OS_END THEN'�ߵ�Ż��'
                               ELSE '����'
                               END
                       
                
                )"�ߵ�Ż������"
                FROM STUDENTS S ,STUDENT_COURSE SC,OPEN_COURSE OC,GRADE G,OPEN_SUBJECT OS,SUBJECT SUB,COURSE C,DROP_STUDENTS DS,BOOK B
                WHERE  S.S_ID = V_SID
                   AND S.S_ID = SC.S_ID
                   AND OC.OC_CODE = SC.OC_CODE
                   AND SC.SC_CODE = G.SC_CODE
                   AND OS.OS_CODE = G.OS_CODE
                   AND SUB.SUB_CODE = OS.SUB_CODE
                   AND C.C_CODE=OC.C_CODE
                   AND OS.OS_END <= D_DATE      -- �ߵ�Ż���� ��¥�� ���ؼ� �������� ���� �������� �����ش�.
                   AND DS.SC_CODE = SC.SC_CODE
                   AND B.B_CODE= OS.B_CODE
                   ORDER BY 1;

END;


SELECT *
FROM DROP_STUDENTS;

-----
SET SERVEROUTPUT ON;

--24.�ߵ�Ż���л��� �ڽ��� ������ ������ ������� Ȯ��
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
����Ŭ  20/03/11  20/04/10  ����Ŭ�� ����  ������  20  20  23  63  1  ����
�ڹ�  20/02/09  20/03/10  �ڹ��� ����  ������  20  20  22  62  1  ����
*/
   
SELECT *
FROM SUBJECT;

--------------------------------------------------------------------------------------------------------------------
-- 25. ������ ���� �Է� ���ν���
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
    
    --Ŀ��
    COMMIT;

    EXCEPTION
        WHEN NOT_SUBCODE_ERROR
            THEN RAISE_APPLICATION_ERROR(-20020,'�ش������ �����ϴ�.');
        WHEN NOT_BCODE_ERROR
            THEN RAISE_APPLICATION_ERROR(-20014,'�ش��ϴ� ����� �����ϴ�.');
        WHEN WRONG_DATE_ERROR
            THEN RAISE_APPLICATION_ERROR(-20012,'�ش糯¥�� ��ȿ���� �ʽ��ϴ�.');
         WHEN NOT_OCCODE_ERROR
            THEN RAISE_APPLICATION_ERROR(-20021,'no data found');
       WHEN OTHERS
            THEN ROLLBACK; 
END;


-------------------------------------------------------------------------------------------------------------------
-- �� ���� ���ν��� ����

--1.������ ���� ����
CREATE OR REPLACE PROCEDURE PRO_OC_DELETE
(
    V_OC_CODE IN OPEN_COURSE.OC_CODE%TYPE
)
IS
BEGIN
    
    DELETE
    FROM OPEN_COURSE
    WHERE OC_CODE =V_OC_CODE;
    
    --���߿� �����
   --COMMIT;
   
END;

--2.���ǽ� ���� ���ν���
CREATE OR REPLACE PROCEDURE PRO_ROOM_DELETE
(
    V_R_CODE IN ROOM.R_CODE%TYPE
)
IS
BEGIN
    
    DELETE
    FROM ROOM
    WHERE R_CODE=V_R_CODE;
    
    --���߿� �����
   --COMMIT;
   
END;

--Ȯ��
COMMIT;

EXEC PRO_ROOM_DELETE('R1');

SELECT *
FROM OPEN_COURSE;

SELECT *
FROM ROOM;

-----------------------------------------------------------------------
--3.���� ���� ���ν���
CREATE OR REPLACE PROCEDURE PRO_COURSE_DELETE
(
    V_C_CODE IN COURSE.C_CODE%TYPE
)
IS
BEGIN
    
    DELETE
    FROM COURSE
    WHERE C_CODE=V_C_CODE;
    
    --���߿� �����
   --COMMIT;
   
END;

--Ȯ��
COMMIT;
ROLLBACK;

EXEC PRO_COURSE_DELETE('C1');

SELECT *
FROM COURSE;

SELECT *
FROM OPEN_COURSE;
-------------------------------------------------------------------
--4.���� ���� ���ν���
CREATE OR REPLACE PROCEDURE PRO_SUBJECT_DELETE
(
    V_SUB_CODE IN SUBJECT.SUB_CODE%TYPE
)
IS
BEGIN
    
    DELETE
    FROM SUBJECT
    WHERE SUB_CODE=V_SUB_CODE;
    
    --���߿� �����
   --COMMIT;
   
END;

--Ȯ��
COMMIT;
ROLLBACK;

EXEC PRO_SUBJECT_DELETE('SUB1');

SELECT *
FROM SUBJECT;

SELECT *
FROM OPEN_SUBJECT;
--------------------------------------------------------------------
--5.���� ���� ���ν���
CREATE OR REPLACE PROCEDURE PRO_BOOK_DELETE
(
    V_B_CODE IN BOOK.B_CODE%TYPE
)
IS
BEGIN
    
    DELETE
    FROM BOOK
    WHERE B_CODE=V_B_CODE;
    
    --���߿� �����
   --COMMIT;
   
END;

--Ȯ��
COMMIT;
ROLLBACK;

EXEC PRO_BOOK_DELETE('B1');

SELECT *
FROM BOOK;

SELECT *
FROM OPEN_SUBJECT;
-----------------------------------------------------------------------------------
--6.������ ���� ���� ���ν���
CREATE OR REPLACE PROCEDURE PRO_OS_DELETE
(
    V_OS_CODE IN OPEN_SUBJECT.OS_CODE%TYPE
)
IS
BEGIN
    
    DELETE
    FROM OPEN_SUBJECT
    WHERE OS_CODE=V_OS_CODE;
    
    --���߿� �����
   --COMMIT;
   
END;

--Ȯ��
COMMIT;
ROLLBACK;

EXEC PRO_OS_DELETE('OS1');

SELECT *
FROM SUBJECT;

SELECT *
FROM OPEN_SUBJECT;
----------------------------------------------------------------------------------------------
--7.���� ���� ���ν���
CREATE OR REPLACE PROCEDURE PRO_GRADE_DELETE
(
    V_GRADE_CODE IN GRADE.GRADE_CODE%TYPE
)
IS
BEGIN
    
    DELETE
    FROM GRADE
    WHERE GRADE_CODE=V_GRADE_CODE;
    
   --Ŀ��
   COMMIT;
   
END;

--Ȯ��
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
--8.�л��� �������� ���� ���ν���
CREATE OR REPLACE PROCEDURE PRO_SC_DELETE
(
    V_SC_CODE IN STUDENT_COURSE.SC_CODE%TYPE
)
IS
BEGIN
    
    DELETE
    FROM STUDENT_COURSE
    WHERE SC_CODE=V_SC_CODE;
    
    --Ŀ��
   COMMIT;
   
END;

--Ȯ��
COMMIT;
ROLLBACK;

EXEC PRO_SC_DELETE('SC1');

SELECT *
FROM STUDENT_COURSE ;
-----------------------------------------------------------------------------
--9.�л� ���� ���ν���
CREATE OR REPLACE PROCEDURE PRO_STUDENTS_DELETE
(
    V_S_ID IN STUDENTS.S_ID%TYPE
)
IS
BEGIN
    
    DELETE
    FROM STUDENTS
    WHERE S_ID=V_S_ID;
    
    --Ŀ��
   COMMIT;
   
END;

--Ȯ��
COMMIT;
ROLLBACK;

EXEC PRO_STUDENTS_DELETE('JGY99');

SELECT *
FROM STUDENTS ;

-----------------------------------------------------------------
--10.�ߵ�Ż���л� ���� ���ν���
CREATE OR REPLACE PROCEDURE PRO_DROP_DELETE
(
    V_DS_CODE IN DROP_STUDENTS.DS_CODE%TYPE
)
IS
BEGIN
    
    DELETE
    FROM DROP_STUDENTS
    WHERE DS_CODE=V_DS_CODE;
    
   --Ŀ��
   COMMIT;
   
END;

--Ȯ��
COMMIT;
ROLLBACK;

EXEC PRO_DROP_DELETE('DS1');

SELECT *
FROM DROP_STUDENTS ;
------------------------------------------------------------------------
--11.������ ���� ���ν���
CREATE OR REPLACE PROCEDURE PRO_MANAGER_DELETE
(
    V_M_ID IN MANAGER.M_ID%TYPE
)
IS
BEGIN
    
    DELETE
    FROM MANAGER
    WHERE M_ID=V_M_ID;
    
   --Ŀ��
   COMMIT;
   
END;

--Ȯ��
COMMIT;
ROLLBACK;

EXEC PRO_MANAGER_DELETE('TEAM4');




