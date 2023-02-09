-- 1.	Написать DML-триггер, регистрирующий изменение данных (вставку, обновление, удаление) в одной из таблиц БД. Во вспомогательную таблицу LOG1 записывать, кто, когда (дата и время) и какое именно изменение произвел,
-- для одного из столбцов сохранять старые и новые значения.
-- * DML-триггер, регистрирующий изменение данных (вставку, обновление, удаление) Таблица AGENT

-- Создание вспомогательной таблицы:

CREATE TABLE DML_LOGIC (
    OPER_NAME CHAR(1),
    PK_KEY NUMBER,
    COLUMN_NAME VARCHAR2(20),
    OLD_VALUE VARCHAR2(60),
    NEW_VALUE VARCHAR2(60),
    USERNAME VARCHAR2(50),
    DATEOPER DATE
);

-- Создание процедуры

CREATE
OR REPLACE PROCEDURE DML_LOGGING (
VOPER_NAME IN CHAR,
VPK_KEY IN NUMBER,
VCOLUMN_NAME IN VARCHAR2,
VOLD_VALUE IN VARCHAR2,
VNEW_VALUE IN VARCHAR2
) IS PRAGMA AUTONOMOUS_TRANSACTION;
DATE_AND_TIME DATE;
BEGIN
    IF VOLD_VALUE <> VNEW_VALUE OR VOPER_NAME IN ('I', 'D') THEN
        SELECT
            TO_CHAR(SYSDATE) INTO DATE_AND_TIME
        FROM
            DUAL;
        INSERT INTO DML_LOGIC (
            OPER_NAME,
            PK_KEY,
            COLUMN_NAME,
            OLD_VALUE,
            NEW_VALUE,
            USERNAME,
            DATEOPER
        ) VALUES (
            VOPER_NAME,
            VPK_KEY,
            VCOLUMN_NAME,
            VOLD_VALUE,
            VNEW_VALUE,
            USER,
            DATE_AND_TIME
        );
        COMMIT;
    END IF;
END;
/

-- Создание триггера

CREATE OR REPLACE TRIGGER AGENT_LOG AFTER
    INSERT OR UPDATE OR DELETE ON AGENT FOR EACH ROW
DECLARE
    OP CHAR( 1 ) := 'I';
BEGIN
    CASE
        WHEN INSERTING THEN
            OP := 'I';
            DML_LOGGING( OP, :NEW.ANO, 'fname_lname', NULL, :NEW.FNAME_LNAME );
            DML_LOGGING( OP, :NEW.ANO, 'passport_number', NULL, :NEW.PASSPORT_NUMBER );
            DML_LOGGING( OP, :NEW.ANO, 'tel_no', NULL, :NEW.TEL_NO );
        WHEN UPDATING('fname_lname') OR UPDATING ('passport_number') OR UPDATING ('tel_no') THEN
            OP := 'U';
            DML_LOGGING( OP, :NEW.ANO, 'fname_lname', :OLD.FNAME_LNAME, :NEW.FNAME_LNAME );
            DML_LOGGING( OP, :NEW.ANO, 'passport_number', :OLD.PASSPORT_NUMBER, :NEW.PASSPORT_NUMBER );
            DML_LOGGING ( OP, :NEW.ANO, 'tel_no', :OLD.TEL_NO, :NEW.TEL_NO );
        WHEN DELETING THEN
            OP := 'D';
            DML_LOGGING( OP, :OLD.ANO, 'fname_lname', :OLD.FNAME_LNAME, NULL );
            DML_LOGGING( OP, :OLD.ANO, 'passport_number', :OLD.PASSPORT_NUMBER, NULL );
            DML_LOGGING( OP, :OLD.ANO, 'tel_no', :OLD.TEL_NO, NULL );
        ELSE
            NULL;
    END CASE;
END AGENT_LOG;
/

-- Проверка

INSERT INTO AGENT VALUES (
    AGENT_SEQ.NEXTVAL,
    'Аубакиров Аль-Фараби',
    'N333333',
    '+375(44)000-00-02'
);

UPDATE AGENT
SET
    FNAME_LNAME = 'Койшикарин Рустам'
WHERE
    TEL_NO = '+375(44)000-00-01' 

DELETE AGENT
WHERE
    FNAME_LNAME = 'Койшикарин Рустам'

SELECT
    *
FROM
    DML_LOGIC

 -- 2. Написать DDL-триггер, протоколирующий действия пользователей по созданию, изменению и удалению таблиц в схеме во вспомогательную таблицу LOG2 в определенное время и запрещающий эти действия в другое время.
 -- * DDL-триггер, протоколирующий действия пользователей
 -- Создание вспомогательной таблицы

CREATE TABLE DDL_LOG ( OPER_NAME VARCHAR2(20),
    OBJ_NAME VARCHAR2(20),
    OBJ_TYPE VARCHAR2(20),
    USERNAME VARCHAR2(20),
    DATEOPER DATE );

-- Создание процедуры

CREATE OR REPLACE PROCEDURE DDL_LOGGING (
    VOPER_NAME IN VARCHAR2,
    VOBJ_NAME IN VARCHAR2,
    VOBJ_TYPE IN VARCHAR2
) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    IF VOPER_NAME IN ('CREATE', 'ALTER', 'DROP') THEN
        INSERT INTO DDL_LOG (
            OPER_NAME,
            OBJ_NAME,
            OBJ_TYPE,
            USERNAME,
            DATEOPER
        ) VALUES (
            VOPER_NAME,
            VOBJ_NAME,
            VOBJ_TYPE,
            USER,
            SYSDATE
        );
        COMMIT;
    END IF;
END;
/

-- Создание триггера

CREATE OR REPLACE TRIGGER CHANGES_USER BEFORE CREATE OR ALTER OR DROP ON SCHEMA
BEGIN
    IF TO_NUMBER( TO_CHAR(SYSDATE, 'HH24') ) BETWEEN 8 AND 20 THEN
        CASE ORA_SYSEVENT
            WHEN 'CREATE' THEN
                DDL_LOGGING( ORA_SYSEVENT, ORA_DICT_OBJ_NAME, ORA_DICT_OBJ_TYPE );
            WHEN 'ALTER' THEN
                DDL_LOGGING( ORA_SYSEVENT, ORA_DICT_OBJ_NAME, ORA_DICT_OBJ_TYPE );
            WHEN 'DROP' THEN
                DDL_LOGGING( ORA_SYSEVENT, ORA_DICT_OBJ_NAME, ORA_DICT_OBJ_TYPE );
            ELSE
                NULL;
        END CASE;
    ELSE
        RAISE_APPLICATION_ERROR( -20000, 'Вы попали во временной промежуток, когда запрещено выполнять DDL операции.' );
    END IF;
END CHANGES_USER;
/

-- Проверка

CREATE TABLE TEST_TB (
    NUMM INTEGER
);

-- ALTER TABLE TEST_TB MODIFY NUMM CHAR(1);
-- DROP TABLE TEST_TB;
-- END;
-- /

SELECT
    *
FROM
    DDL_LOG;

-- 3. Написать системный триггер, добавляющий запись во вспомогательную таблицу LOG3,
-- когда пользователь подключается или отключается. В таблицу логов записывается имя пользователя (USER), тип активности (LOGON или LOGOFF),
-- дата (SYSDATE), количество записей в основной таблице БД.
-- * Системный триггер, добавляющий запись во вспомогательную таблицу LOG3, когда пользователь подключается или отключается.

-- Создание таблицы логов

CREATE TABLE CONNECTION_LOG (
    USER_NAME VARCHAR2(30),
    STATUS_CONNECTION VARCHAR2(10),
    DATE_LOG DATE,
    ROW_COUNT INTEGER
);

-- Создание триггера LOGON

CREATE
OR REPLACE TRIGGER TRIG_LOGON
AFTER
LOGON ON SCHEMA DECLARE ROW_COUNT NUMBER;
BEGIN
    SELECT
        COUNT(*) INTO ROW_COUNT
    FROM
        DEALS;
    INSERT INTO CONNECTION_LOG VALUES (
        ORA_LOGIN_USER,
        ORA_SYSEVENT,
        SYSDATE,
        ROW_COUNT
    );
    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT = ''DD.MM.YY HH24:MI:SS''';
    EXECUTE IMMEDIATE 'set linesize 500';
END;
/

-- Создание триггера LOGOFF

CREATE OR REPLACE TRIGGER TRIG_LOGOFF BEFORE LOGOFF ON SCHEMA
DECLARE
    ROW_COUNT NUMBER;
BEGIN
    SELECT
        COUNT(*) INTO ROW_COUNT
    FROM
        DEALS;
    INSERT INTO CONNECTION_LOG VALUES (
        ORA_LOGIN_USER,
        ORA_SYSEVENT,
        SYSDATE,
        ROW_COUNT
    );
END;
/

-- 6.	Написать триггер INSTEAD OF для работы с необновляемым представлением, созданным после выполнения п. 2.4 задания к лабораторной работе №3, проверить DML-командами возможность обновления представления после включения триггера
-- (логика работы триггера определяется спецификой предметной области ваианта).
-- Создание необновляемого представления

CREATE OR REPLACE VIEW N AS
    SELECT
        SELLER.ONAME,
        DEALS.FNAME_LNAME_NOTARY,
        DEALS.PRICE,
        SELLER.SNO,
        DEALS.DNO
    FROM
        DEALS,
        SELLER
    WHERE
        SELLER.ONAME = 'ASTEL'
        AND DEALS.SNO = SELLER.SNO 

-- * Триггер INSTEAD OF для работы с необновляемым представлением.
-- UPDATE trigger

CREATE
OR REPLACE TRIGGER INSTEAD_OF_TRIGGER INSTEAD OF UPDATE
    ON N FOR EACH ROW BEGIN IF UPDATING THEN 
    UPDATE DEALS SET FNAME_LNAME_NOTARY = :NEW.FNAME_LNAME_NOTARY,
        PRICE = :NEW.PRICE
    WHERE
        PRICE = :OLD.PRICE;
END IF;
END;
/

-- Проверка

UPDATE N
SET
    PRICE = 60
WHERE
    ONAME = 'ASTEL' 

-- INSERT trigger

CREATE
OR REPLACE TRIGGER INSTEAD_OF_TRIGGER1 INSTEAD OF INSERT ON N FOR EACH ROW DECLARE L_CUSTOMER_ID NUMBER;
BEGIN
    IF INSERTING THEN
        INSERT INTO SELLER (
            ONAME,
            SNO
        ) VALUES (
            :NEW.ONAME,
            :NEW.SNO
        ) RETURNING SNO INTO L_CUSTOMER_ID;
        INSERT INTO DEALS (
            FNAME_LNAME_NOTARY,
            PRICE,
            DNO,
            SNO
        ) VALUES (
            :NEW.FNAME_LNAME_NOTARY,
            :NEW.PRICE,
            :NEW.DNO,
            L_CUSTOMER_ID
        );
    END IF;
END;
/

-- Проверка

INSERT INTO N (
    ONAME,
    PRICE,
    SNO,
    DNO,
    FNAME_LNAME_NOTARY
) VALUES (
    'ASTEL',
    50,
    90,
    66,
    'kuka'
);

-- --------
-- IF deleting THEN
--         DELETE FROM provider
--         WHERE
--             name = :old.name;
--     END IF;
-- END;
-- /

-- 4.	Написать триггеры, реализующие бизнес-логику (ограничения) в заданной вариантом предметной области. Три задания приведены в прил. 6. 
-- Количество и тип триггеров (строковый или операторный, выполняется AFTER или BEFORE) определять самостоятельно исходя из сути заданий и имеющейся схемы БД; 
-- учесть, что в некоторых вариантах первые два задания могут быть выполнены в рамках одного триггера, а также возможно возникновение мутации, что приведет к совмещению данного пункта лабораторной работы со следующим. 
-- Третий пункт задания предполагает использование планировщика задач, который обязательно должен быть настроен на многократный запуск с использованием частоты, интервала и спецификаторов.

-- Вариант 13
-- 1.	В случае обращения в дальнейшем в компанию, комиссия на 50% меньше. По критериям: После 1 успешной сделки.
-- insert сделки, если seller обращается во второй раз, то вычитывать комиссию на 50% меньше у seller, фильтрировать сделки по тарифам и выплачивать риеэлтору
-- 2.	Четкий график показов объектов. График показов объектов в будние дни с 10:00 до  19:00. В выходные дни с 10:00 до 15:00.
-- Если открыть объекты не в тот день, то вызвать ошибку RAISE APPLICATION ERROR
-- 3.	Фиксированный тариф:
-- 3 категории:
-- 1) Объект до 40000 у.е.,
-- 2) От 40000 у.е. до 70000 у.е.,
-- 3) От 70000 у.е. и выше.
-- 4.	Каждый день обновлять таблицу-отчет, содержащую тип недвижимости, тип сделки, количество объектов, сумму сделок, дату.
-- Отбирать недвижимости по типу объекта. Каждый день добавлять по 2-3 записи со сделок в таблицу-отчет. Запускать shedule на каждый день

CREATE OR REPLACE TRIGGER OBJECT_CHANGE BEFORE
    INSERT ON DEALS FOR EACH ROW
DECLARE
    COUNT_DEALS INTEGER DEFAULT 0;
BEGIN
    IF :NEW.PRICE < 500 THEN
        :NEW.PRICE := :NEW.PRICE * 1.07;
    END IF;
    IF :NEW.PRICE BETWEEN 500 AND 700 THEN
        :NEW.PRICE := :NEW.PRICE * 1.05;
    END IF;
    IF :NEW.PRICE > 700 THEN
        :NEW.PRICE := :NEW.PRICE * 1.03;
    END IF;
    SELECT
        COUNT(DEALS.SNO) INTO COUNT_DEALS
    FROM
        DEALS
    WHERE
        SNO = :NEW.SNO;
    IF COUNT_DEALS > 1 THEN
        :NEW.PRICE := :NEW.PRICE * 0.99;
    END IF;
END;
/

-- Проверка

INSERT INTO DEALS(
    ANO,
    SNO,
    CNO,
    ONO,
    TNO,
    DATE1,
    PRICE,
    FNAME_LNAME_NOTARY,
    COMMENT1
) VALUES (
    '41',
    '46',
    '96',
    '2',
    '4',
    TO_DATE('03.04.21', 'DD.MM.YY'),
    600,
    'АМАНОВ РАУАН',
    'NO COMMENTS'
);

-- 2.

CREATE OR REPLACE TRIGGER OBJECTS_IN BEFORE
    INSERT ON OBJECTS1 FOR EACH ROW
BEGIN
    IF :NEW.VIEW_TIME BETWEEN TO_CHAR( TO_DATE('10:00:00', 'hh24:mi:ss') ) AND TO_CHAR( TO_DATE('19:00:00', 'hh24:mi:ss') ) THEN
        :NEW.VIEW_TIME := :NEW.VIEW_TIME;
    ELSE
        RAISE_APPLICATION_ERROR( -20000, 'Вы попали во временной промежуток, когда запрещено модифицировать данные' );
    END IF;
END;
/

-- Проверка

INSERT INTO OBJECTS1 (
    ONAME,
    ADDRESS,
    SQUARE,
    PRICE,
    FLOORS,
    COMMENTS,
    VIEW_TIME
) VALUES (
    'Магазин одежды Башмачок',
    'Ул. Мангилик ел 54/1',
    '400m^2',
    400,
    '1',
    'no comments',
    TO_DATE('19:05:44', 'hh24:mi:ss')
);

-- 5. Самостоятельно или при помощи преподавателя составить задание на триггер, который будет вызывать мутацию таблиц, и решить эту проблему одним из двух способов (при помощи переменных пакета и двух триггеров или при помощи COMPAUND-триггера).
--  Создать триггер, который при добавлении сделки должен увеличивать стоимость всех сделок на 1, а при удалении – отнимать 1. Такой триггер вызывает мутацию таблицы:

CREATE OR REPLACE TRIGGER MUTT AFTER
INSERT OR DELETE ON DEALS FOR EACH ROW
DECLARE
    CURSOR OOO IS
        SELECT
            PRICE
        FROM
            DEALS;
    ITER OOO % ROWTYPE;
    CCC  INTEGER := 1;
BEGIN
    SELECT
        COUNT(*) INTO CCC
    FROM
        DEALS;
    CASE
        WHEN INSERTING THEN
            NULL;
        WHEN DELETING THEN
            CCC := -1;
    END CASE;
    FETCH OOO INTO ITER;
    WHILE OOO % FOUND LOOP
        UPDATE DEALS
        SET
            PRICE = ITER.PRICE + CCC;
        FETCH OOO INTO ITER;
    END LOOP;
END;
/

-- Проверка

ERROR AT LINE 1: ORA -04091: TABLE BARGAIN.ACTIVEDEALS IS MUTATING, TRIGGER / FUNCTION MAY NOT SEE IT ORA -06512: AT "BARGAIN.MUTT", LINE 6 ORA -04088: ERROR DURING EXECUTION OF TRIGGER 'BARGAIN.MUTT' ALTER TRIGGER MUTT DISABLE ALTER TRIGGER COMP_MUTT DISABLE -- Создание COMPUND триггера для решения этой проблемы:

-- Создание COMPOUND триггера

CREATE OR REPLACE TRIGGER COMP_MUTT FOR
INSERT OR DELETE ON DEALS
COMPOUND TRIGGER
    CURSOR OOO IS
        SELECT
            PRICE,
            DNO
        FROM
            DEALS;
    ITER   OOO % ROWTYPE;
    CCC1   INTEGER := 0;
    CCC2   INTEGER := 0;
    BEFORE STATEMENT IS
    BEGIN
        SELECT
            COUNT(*) INTO CCC1
        FROM
            DEALS;
    END BEFORE STATEMENT;
    AFTER STATEMENT IS
    BEGIN
        SELECT
            COUNT(*) INTO CCC2
        FROM
            DEALS;
        OPEN OOO;
        FETCH OOO INTO ITER;
        WHILE OOO % FOUND LOOP
            UPDATE DEALS
            SET
                PRICE = ITER.PRICE + (
                    CCC2 - CCC1
                )
            WHERE
                DNO = ITER.DNO;
            FETCH OOO INTO ITER;
        END LOOP;
    END AFTER STATEMENT;
END;
/

-- Проверка

INSERT INTO DEALS(
    ANO,
    SNO,
    CNO,
    ONO,
    TNO,
    DATE1,
    PRICE,
    FNAME_LNAME_NOTARY,
    COMMENT1
) VALUES (
    '41',
    '46',
    '96',
    '2',
    '2',
    TO_DATE('03.04.21', 'DD.MM.YY'),
    500,
    'АМАНОВ РАУАН',
    'NO COMMENTS'
);

-- 4. Каждый день обновлять таблицу-отчет, содержащую тип недвижимости, тип сделки, количество объектов, сумму сделок, дату.
-- Отбирать недвижимости по типу объекта. Каждый день добавлять по 2-3 записи со сделок в таблицу-отчет. Запускать shedule на каждый день

-- Планировщик задач:
-- Создание хранимой процедуры для планировщика:

CREATE OR REPLACE PROCEDURE DELETE_CLIENT_PROCEDURE(
    FNAMEARG IN CLIENT.FNAME%TYPE
) IS
    CURSOR C1 IS
        SELECT
            C_ID CID
        FROM
            CLIENT CL
        WHERE
            CL.FNAME = FNAMEARG;
    LISTEMP C1%ROWTYPE;
BEGIN
    OPEN C1;
    FETCH C1 INTO LISTEMP;
    IF C1%NOTFOUND THEN
        RAISE NO_DATA_FOUND;
    END IF;
    MERGE INTO CHECK_COPY1 CC USING (
        SELECT
            NUMBER_CH,
            DATA,
            S_ID,
            F_ID,
            C_ID,
            FUEL_NUM
        FROM
            CHECK1 CH1
        WHERE
            CH1.C_ID = LISTEMP.CID
    ) C1 ON (C1.NUMBER_CH = CC.NUMBER_CH) WHEN MATCHED THEN UPDATE SET CC.DATA = C1.DATA, CC.S_ID = C1.S_ID, CC.F_ID = C1.F_ID, CC.C_ID = C1.C_ID, CC.FUEL_NUM = C1.FUEL_NUM WHEN NOT MATCHED THEN INSERT (CC.NUMBER_CH, CC.DATA, CC.S_ID, CC.F_ID, CC.C_ID, CC.FUEL_NUM) VALUES (C1.NUMBER_CH, C1.DATA, C1.S_ID, C1.F_ID, C1.C_ID, C1.FUEL_NUM);
    DELETE FROM CHECK1
    WHERE
        C_ID = LISTEMP.CID;
    CLOSE C1;
    DELETE FROM CLIENT CL
    WHERE
        CL.C_ID = LISTEMP.CID;
    DBMS_OUTPUT.PUT_LINE ('Данный клиент удален');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Клиент с указанной фамилией не найден');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001, 'An error was encountered - '
            ||SQLCODE
            ||' -ERROR- '
            ||SQLERRM);
END;
/

-- Создание таблицы-отчета

CREATE TABLE OTCHET_DEALS(
    OTCHET_ID NUMBER GENERATED ALWAYS AS IDENTITY,
    DNO INTEGER NOT NULL,
    ANO INTEGER NOT NULL,
    SNO INTEGER NOT NULL,
    CNO INTEGER NOT NULL,
    ONO INTEGER NOT NULL,
    TNO INTEGER NOT NULL,
    DATE1 DATE NOT NULL,
    PRICE NUMBER (10, 2) NULL,
    FNAME_LNAME_NOTARY VARCHAR(60),
    COMMENT1 VARCHAR2(300)
);

-- ЗАПРОС С GROUP BY ТИП ОБЪЕКТА

CREATE OR REPLACE PROCEDURE DELETE_TYPE_PROCEDURE(
    TYPEARG IN TYPE_OBJECTS.TYPE%TYPE
) IS
    CURSOR C1 IS
        SELECT
            TNO TNOTYPE
        FROM
            TYPE_OBJECTS
        WHERE
            TYPE_OBJECTS.TYPE = TYPEARG;
    LISTEMP C1%ROWTYPE;
BEGIN
    OPEN C1;
    FETCH C1 INTO LISTEMP;
    IF C1%NOTFOUND THEN
        RAISE NO_DATA_FOUND;
    END IF;
    MERGE INTO OTCHET_DEALS USING (
        SELECT
            DNO,
            ANO,
            SNO,
            CNO,
            TNO,
            DATE1,
            PRICE,
            FNAME_LNAME_NOTARY
        FROM
            DEALS
        WHERE
            DEALS.TNO = LISTEMP.TNOTYPE
    ) C1 ON (C1.DNO = OTCHET_DEALS.DNO) WHEN MATCHED THEN UPDATE SET OTCHET_DEALS.ANO = C1.ANO, OTCHET_DEALS.SNO = C1.SNO, OTCHET_DEALS.CNO = C1.CNO, OTCHET_DEALS.TNO=C1.TNO, OTCHET_DEALS.DATE1 = C1.DATE1, OTCHET_DEALS.PRICE = C1.PRICE, OTCHET_DEALS.FNAME_LNAME_NOTARY = C1.FNAME_LNAME_NOTARY WHEN NOT MATCHED THEN INSERT (OTCHET_DEALS.DNO, OTCHET_DEALS.ANO, OTCHET_DEALS.SNO, OTCHET_DEALS.CNO, OTCHET_DEALS.TNO, OTCHET_DEALS.DATE1, OTCHET_DEALS.PRICE, OTCHET_DEALS.FNAME_LNAME_NOTARY) VALUES (C1.DNO, C1.ANO, C1.SNO, C1.CNO, C1.TNO, C1.DATE1, C1.PRICE, C1.FNAME_LNAME_NOTARY);
    CLOSE C1;
    DBMS_OUTPUT.PUT_LINE ('Данная сделка удалена');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Данный тип объекта не найден');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001, 'An error was encountered - '
            ||SQLCODE
            ||' -ERROR- '
            ||SQLERRM);
END;
/

-- Проверка

BEGIN
    DELETE_TYPE_PROCEDURE('Торговый зал');
END;
/

INSERT INTO DEALS(
    ANO,
    SNO,
    CNO,
    ONO,
    TNO,
    DATE1,
    PRICE,
    FNAME_LNAME_NOTARY,
    COMMENT1
) VALUES(
    '41',
    '46',
    '96',
    '2',
    '2',
    TO_DATE('03.04.21', 'dd.mm.yy'),
    600,
    'Аманов Рауан',
    'no comments'
);

-- Создание JOB'a

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
        JOB_NAME = > 'analog_job',
        JOB_TYPE = > 'STORED_PROCEDURE',
        JOB_ACTION = > 'delete_type_procedure',
        NUMBER_OF_ARGUMENTS = > 1,
        START_DATE = > SYSTIMESTAMP + INTERVAL '100' SECOND,
        END_DATE = > SYSTIMESTAMP + INTERVAL '1' MONTH,
        REPEAT_INTERVAL = > 'FREQ=MINUTELY;INTERVAL=2;BYSECOND=0;',
        AUTO_DROP = > FALSE,
        ENABLED = > FALSE
    );
END;
/

BEGIN
    DBMS_SCHEDULER.SET_JOB_ARGUMENT_VALUE(
        JOB_NAME = > 'analog_job',
        ARGUMENT_POSITION = > 1,
        ARGUMENT_VALUE = > 'Павильон'
    );
END;
/

BEGIN
    DBMS_SCHEDULER.SET_JOB_ARGUMENT_VALUE(
        JOB_NAME = > 'analog_job',
        ARGUMENT_POSITION = > 1,
        ARGUMENT_VALUE = > 'Павильон'
    );
END;
/

BEGIN
    DBMS_SCHEDULER.DROP_JOB ('analog_job');
END;
/

BEGIN
    DBMS_SCHEDULER.ENABLE ('analog_job');
END;
/

BEGIN
    DBMS_SCHEDULER.RUN_JOB('analog_job');
END;
/