6.2

-- * Uспользуя встроенный динамический SQL, процедуру создания в БД нового объекта (представления или таблицы) на основе существующей таблицы.
-- * Uмя нового объекта должно формироваться динамически и проверяться на существование в словаре данных.
-- * В качестве входных параметров указать тип нового объекта, исходную таблицу, столбцы и количество строк, которые будут использоваться в запросе.


CREATE OR REPLACE PROCEDURE NEW_OBJECT_BD (
    TYPE_OF IN VARCHAR2,
    REF_TAB IN VARCHAR2,
    COL_LIST IN VARCHAR2,
    REC_COUNT IN INTEGER
) IS
    NEW_OBJ_NAME VARCHAR2(120);
    SELECT_REC   VARCHAR2(200);
BEGIN
    IF UPPER(TYPE_OF) NOT IN ( 'VIEW', 'TABLE' ) THEN
        RAISE_APPLICATION_ERROR( -20001, 'Указанный тип не является таблицей или представлением' );
    END IF;
    IF NOT CHECK_EXIST_TABLE(REF_TAB) THEN
        RAISE_APPLICATION_ERROR( -20002, 'Таблицы не существует' );
    END IF;
    IF NOT CHECK_EXIST_COLUMN_IN_TABLE(REF_TAB, COL_LIST) THEN
        RAISE_APPLICATION_ERROR( -20003, 'Не существует столбца' );
    END IF;
    NEW_OBJ_NAME := REF_TAB
        || '_'
        || TYPE_OF
        || '_'
        || DBMS_SESSION.UNIQUE_SESSION_ID;
    SELECT_REC := 'SELECT '
        || COL_LIST
        || ' FROM '
        || REF_TAB;
    CASE UPPER(TYPE_OF)
        WHEN 'VIEW' THEN
            SELECT_REC := SELECT_REC;
        WHEN 'TABLE' THEN
            SELECT_REC := '('
                || SELECT_REC
                || ')';
    END CASE;
    EXECUTE IMMEDIATE 'CREATE '
        || TYPE_OF
        || ' '
        || NEW_OBJ_NAME
        || ' AS '
        || SELECT_REC;
END;
/

CREATE OR REPLACE FUNCTION CHECK_EXIST_TABLE (
    TAB_NAME IN VARCHAR2
) RETURN BOOLEAN IS
    TAB INTEGER;
BEGIN
    SELECT
        1 INTO TAB
    FROM
        USER_TABLES
    WHERE
        TABLE_NAME = UPPER(TAB_NAME);
    RETURN TRUE;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN FALSE;
END;
/

CREATE OR REPLACE FUNCTION CHECK_EXIST_COLUMN_IN_TABLE (
    TAB_NAME IN VARCHAR2,
    COL_LIST IN VARCHAR2
) RETURN BOOLEAN IS
    L_TABLEN BINARY_INTEGER;
    L_TAB    DBMS_UTILITY.UNCL_ARRAY;
    CURSOR NAMES_EXISTING IS
        SELECT
            COLUMN_NAME
        FROM
            USER_TAB_COLUMNS
        WHERE
            TABLE_NAME = UPPER(TAB_NAME);
    MATCH    BOOLEAN;
BEGIN
    DBMS_UTILITY.COMMA_TO_TABLE(
        LIST => COL_LIST,
        TABLEN => L_TABLEN,
        TAB => L_TAB
    );
    FOR I IN 1..L_TABLEN LOOP
        FOR NAME_EXIST IN NAMES_EXISTING LOOP
            IF UPPER(TRIM(L_TAB(I))) = NAME_EXIST.COLUMN_NAME THEN
                MATCH := TRUE;
                EXIT;
            ELSE
                MATCH := FALSE;
            END IF;
        END LOOP;
        IF NOT MATCH THEN
            RETURN FALSE;
        END IF;
    END LOOP;
    RETURN TRUE;
END;
/

-- Проверка


BEGIN
    NEW_OBJECT_BD(
        TYPE_OF => 'table',
        REF_TAB => 'agent'
    );
END;
/

BEGIN
    NEW_OBJECT_BD( 'table', 'agent', 'ano1, f', 2 );
END;
/

BEGIN
    IF CHECK_EXIST_COLUMN_IN_TABLE( 'agent', 'ano, fname_lname, hhahha' ) THEN
        DBMS_OUTPUT.PUT_LINE('1+');
    END IF;
    IF NOT CHECK_EXIST_COLUMN_IN_TABLE( 'agent', 'kek' ) THEN
        DBMS_OUTPUT.PUT_LINE('2+');
    END IF;
END;
/

DECLARE
    TIME2 NUMBER;
BEGIN
    TIME2 := CHECK_EXIST_TABLE('agent');
END;
/

6.3

-- Создать функцию, которая принимает в качестве параметра имя таблицы и имя поля в этой таблице
-- и возвращает среднее арифметическое по этому полю.
-- В том случае, если тип поля не позволяет посчитать среднее арифметическое, функция должна возвращать null.

CREATE OR REPLACE FUNCTION STAT_PROC1 (
    TAB_NAME IN VARCHAR2,
    COL_NAME IN VARCHAR2
) RETURN NUMBER IS
    COL     VARCHAR2(100);
    TAB     VARCHAR2(100);
    AVG_COL INTEGER;
BEGIN
    SELECT
        COLUMN_NAME,
        TABLE_NAME INTO COL,
        TAB
    FROM
        ALL_TAB_COLUMNS
    WHERE
        OWNER = USER
        AND TABLE_NAME = UPPER(TAB_NAME)
        AND COLUMN_NAME = UPPER(COL_NAME);
    EXECUTE IMMEDIATE 'SELECT AVG ('
        || COL
        ||') FROM '
        || TAB INTO AVG_COL;
    DBMS_OUTPUT.PUT_LINE('Имя поля: '
        || COL);
    DBMS_OUTPUT.PUT_LINE('Средняя арифметическая: '
        || AVG_COL);
    RETURN AVG_COL;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Нет такой таблицы или поля');
    WHEN INVALID_NUMBER THEN
        DBMS_OUTPUT.PUT_LINE('null');
        RETURN NULL;
END;
/

-- Проверка

DECLARE
    TIME2 NUMBER;
BEGIN
    TIME2 := STAT_PROC1('deals', 'fname_lname_notary');
END;
/

DECLARE
    TIME2 NUMBER;
BEGIN
    TIME2 := STAT_PROC1('deals', 'fname_lname');
END;
/