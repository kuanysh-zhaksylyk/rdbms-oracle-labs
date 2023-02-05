-- Задание к лабораторной работе

-- 1.	Создать процедуру.
-- 2.	Создать функцию.
-- Варианты заданий для написания процедур и функций приведены в прил. 5. Эти задания при необходимости можно усложнить или предложить другие (согласовать с преподавателем) в соответствии с бизнес-логикой варианта задания.
-- При создании следует выполнить следующие минимальные требования к синтаксису:
-- -	использовать явный курсор или курсорную переменную, а также атрибуты курсора;
-- -	использовать пакет DBMS_OUTPUT для вывода результатов работы в SQL*Plus;
-- -	предусмотреть секцию обработки исключительных ситуаций, причем обязательно использовать как предустановленные исключительные ситуации, так и собственные (например, стоит контролировать наличие в БД значений, передаваемых в процедуры и функции как параметры);
-- 3.	Создать локальную программу, изменив код ранее написанной процедуры или функции.
-- 4.	Написать перегруженные программы, используя для этого ранее созданную процедуру или функцию.
-- 5.	Объединить все процедуры и функции, в том числе перегруженные, в пакет.
-- 6.	Написать анонимный PL/SQL-блок, в котором будут вызовы реализованных функций и процедур пакета с различными характерными значениями па-раметров для проверки правильности работы основных задач и обработки ис-ключительных ситуаций.

-- Вариант 13.
-- 1. Написать процедуру изменения мобильного номера продавца по указанной в качестве параметра фамилии.
-- Контролировать, чтобы повторно не был введен тот же номер.

-- подключаем серверный вывод результатов работы в SQLplus

SET SERVEROUTPUT ON

CREATE OR REPLACE PROCEDURE TEL_CH (
	FNAMEDIR IN VARCHAR2,
	NEWTEL IN VARCHAR2
) IS
	TELEP       SELLER.TEL_NO%TYPE;
	SELLERID    SELLER.SNO%TYPE;
	ERR_NO_DATA EXCEPTION;
BEGIN
	SELECT
		TEL_NO,
		SNO INTO TELEP,
		SELLERID
	FROM
		SELLER
	WHERE
		FNAMEDIR=FNAME_DIR;
	IF TELEP <> NEWTEL THEN
		UPDATE SELLER
		SET
			TEL_NO=NEWTEL
		WHERE
			SNO=SELLERID;
		COMMIT;
		DBMS_OUTPUT.PUT_LINE ('Директор '
			||FNAMEDIR
			||': старый телефон  = '
			||TELEP
			||', новый телефон = '
			||NEWTEL);
	ELSE
		RAISE ERR_NO_DATA;
	END IF;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		DBMS_OUTPUT.PUT_LINE('Данный директор не найден');
	WHEN ERR_NO_DATA THEN
		DBMS_OUTPUT.PUT_LINE('Нельзя вводить один и тот же номер, Директор '
			||FNAMEDIR
			||': старый телефон  = '
			||TELEP
			||', новый телефон = '
			||NEWTEL );
END;
/

-- Вызов процедуры

EXEC TEL_CH('Шопанова Салтанат', '+375(44)444-44-44')

-- 2. Создать функцию, подсчитывающую количество сделок, совершенных потенциальными покупателями за текущий день.
-- В вызывающую среду возвращать объекты недвижимости, участвующие в этих сделках.

CREATE OR REPLACE FUNCTION FUNCT (
	DEAL DEALS.DNO%TYPE,
	CUS CUSTOMER.CNO%TYPE
) RETURN NUMBER IS
	CURSOR MAT_CURSOR IS
		SELECT
			OBJECTS1.ONAME AS OBJEKT
		FROM
			DEALS,
			CUSTOMER,
			OBJECTS1
		WHERE
			CUSTOMER.CNO=DEALS.CNO
			AND DEALS.ONO=OBJECTS1.ONO
			AND DEALS.DATE1= TO_CHAR(SYSDATE-11,
			'DD-MON-YYYY');
	PEREMEN    DEALS.DNO%TYPE DEFAULT 0;
	CURSOR_ROW MAT_CURSOR%ROWTYPE;
	ERR EXCEPTION;
	PRAGMA EXCEPTION_INIT( ERR, -20001 );
BEGIN
	SELECT
		COUNT(*) INTO PEREMEN
	FROM
		DEALS,
		CUSTOMER,
		OBJECTS1
	WHERE
		CUSTOMER.CNO=DEALS.CNO
		AND DEALS.ONO=OBJECTS1.ONO
		AND DEALS.DATE1= TO_CHAR(SYSDATE-11,
		'DD-MON-YYYY');
	OPEN MAT_CURSOR;
	FETCH MAT_CURSOR INTO CURSOR_ROW;
	IF MAT_CURSOR%NOTFOUND THEN
		RAISE ERR;
	END IF;
	WHILE MAT_CURSOR%FOUND LOOP
		DBMS_OUTPUT.PUT_LINE ('OBJECT: '
			|| CURSOR_ROW.OBJEKT );
		FETCH MAT_CURSOR INTO CURSOR_ROW;
	END LOOP;
	CLOSE MAT_CURSOR;
	DBMS_OUTPUT.PUT_LINE ('Колличество договоров на текущий день: '
		|| PEREMEN);
	RETURN NULL;
EXCEPTION -- начало обработчика исключений основной программы
	WHEN TIMEOUT_ON_RESOURCE THEN
		RAISE_APPLICATION_ERROR(-20002, 'Превышен интервал ожидания');
	WHEN VALUE_ERROR THEN
		RAISE_APPLICATION_ERROR(-20004, 'Ошибка в операции преобразования или математической операции!');
	WHEN ERR THEN
		RAISE_APPLICATION_ERROR(-20001, 'Нет объектов которые учавствовали в сделках на тот период');
END;
/

-- Вызов функции

SELECT
	FUNCT
FROM
	DUAL;

-- 3. Создать локальную программу, изменив код ранее написанной процедуры или функции.

CREATE OR REPLACE PROCEDURE TEL_CH_CH (
	FNAMEDIR IN VARCHAR2,
	NEWTEL IN VARCHAR2
) IS
	TELEP       SELLER.TEL_NO%TYPE;
	SELLERID    SELLER.SNO%TYPE;
	ERR_NO_DATA EXCEPTION;
	FUNCTION WRONGTELE (
		TEL_NO IN VARCHAR2
	) RETURN BOOLEAN IS
		WRONGTELE BOOLEAN DEFAULT FALSE;
	BEGIN
		IF TEL_NO = '+375(29)555-55-55' THEN
			RETURN TRUE;
		END IF;
	END WRONGTELE;
BEGIN
	SELECT
		TEL_NO,
		SNO INTO TELEP,
		SELLERID
	FROM
		SELLER
	WHERE
		FNAMEDIR=FNAME_DIR;
	IF TELEP <> NEWTEL THEN
		UPDATE SELLER
		SET
			TEL_NO=NEWTEL
		WHERE
			SNO=SELLERID;
		IF WRONGTELE(NEWTEL)THEN
			RAISE_APPLICATION_ERROR(-20001, ' Данный номер нельзя водить!'
				||SQLCODE
				||' -ERROR- '
				||SQLERRM);
		END IF;
		COMMIT;
		DBMS_OUTPUT.PUT_LINE ('Директор '
			||FNAMEDIR
			||': старый телефон  = '
			||TELEP
			||', новый телефон = '
			||NEWTEL);
	ELSE
		RAISE ERR_NO_DATA;
	END IF;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		DBMS_OUTPUT.PUT_LINE('Данный директор не найден');
	WHEN ERR_NO_DATA THEN
		DBMS_OUTPUT.PUT_LINE('Нельзя вводить один и тот же номер, Директор '
			||FNAMEDIR
			||': старый телефон  = '
			||TELEP
			||', старый телефон = '
			||NEWTEL );
END;
/

EXEC TEL_CH_CH('Шопанова Салтанат', '+375(29)555-55-55')

-- 4. Написать перегруженные программы, используя для этого ранее созданную процедуру или функцию.

CREATE OR REPLACE PROCEDURE TEL_CH (
	SELLERID IN NUMBER,
	NEWTEL IN VARCHAR2
) IS
	TELEP       SELLER.TEL_NO%TYPE;
	FNAMEDIR    SELLER.FNAME_DIR%TYPE;
	ERR_NO_DATA EXCEPTION;
BEGIN
	SELECT
		TEL_NO,
		FNAME_DIR INTO TELEP,
		FNAMEDIR
	FROM
		SELLER
	WHERE
		SELLERID=SNO;
	IF TELEP <> NEWTEL THEN
		UPDATE SELLER
		SET
			TEL_NO=NEWTEL
		WHERE
			FNAME_DIR=FNAMEDIR;
		COMMIT;
		DBMS_OUTPUT.PUT_LINE ('Номер'
			||SELLERID
			||': старый телефон  = '
			||TELEP
			||', новый телефон = '
			||NEWTEL);
	ELSE
		RAISE ERR_NO_DATA;
	END IF;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		DBMS_OUTPUT.PUT_LINE('Данный директор не найден');
	WHEN ERR_NO_DATA THEN
		DBMS_OUTPUT.PUT_LINE('Нельзя вводить один и тот же номер');
END;
/

-- Вызов перегруженной процедуры

EXEC TEL_CH('Шопанова Салтанат', '+375(44)444-44-44')

-- 5.	Объединить все процедуры и функции, в том числе перегруженные, в пакет.
-- Пакет

CREATE OR REPLACE PACKAGE PACK2 IS
	PROCEDURE TEL_CH (
		SELLERID IN INTEGER,
		NEWTEL IN VARCHAR2
	);
	PROCEDURE TEL_CH (
		FNAMEDIR IN VARCHAR2,
		NEWTEL IN VARCHAR2
	);
	FUNCTION FUNCT RETURN NUMBER;
	PROCEDURE TEL_CH_CH (
		FNAMEDIR IN VARCHAR2,
		NEWTEL IN VARCHAR2
	);
END PACK2;
/

-- Тело пакета

CREATE OR REPLACE PACKAGE BODY PACK2 IS
	PROCEDURE TEL_CH (
		FNAMEDIR IN VARCHAR2,
		NEWTEL IN VARCHAR2
	) IS
		TELEP       SELLER.TEL_NO%TYPE;
		SELLERID    SELLER.SNO%TYPE;
		ERR_NO_DATA EXCEPTION;
	BEGIN
		SELECT
			TEL_NO,
			SNO INTO TELEP,
			SELLERID
		FROM
			SELLER
		WHERE
			FNAMEDIR=FNAME_DIR;
		IF TELEP <> NEWTEL THEN
			UPDATE SELLER
			SET
				TEL_NO=NEWTEL
			WHERE
				SNO=SELLERID;
			COMMIT;
			DBMS_OUTPUT.PUT_LINE ('Директор '
				||FNAMEDIR
				||': старый телефон  = '
				||TELEP
				||', новый телефон = '
				||NEWTEL);
		ELSE
			RAISE ERR_NO_DATA;
		END IF;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			DBMS_OUTPUT.PUT_LINE('Данный директор не найден');
		WHEN ERR_NO_DATA THEN
			DBMS_OUTPUT.PUT_LINE('Нельзя вводить один и тот же номер, Директор '
				||FNAMEDIR
				||': старый телефон  = '
				||TELEP
				||', старый телефон = '
				||NEWTEL);
	END TEL_CH;
	PROCEDURE TEL_CH (
		SELLERID IN INTEGER,
		NEWTEL IN VARCHAR2
	) IS
		TELEP       SELLER.TEL_NO%TYPE;
		FNAMEDIR    SELLER.FNAME_DIR%TYPE;
		ERR_NO_DATA EXCEPTION;
	BEGIN
		SELECT
			TEL_NO,
			FNAME_DIR INTO TELEP,
			FNAMEDIR
		FROM
			SELLER
		WHERE
			SELLERID=SNO;
		IF TELEP <> NEWTEL THEN
			UPDATE SELLER
			SET
				TEL_NO=NEWTEL
			WHERE
				FNAME_DIR=FNAMEDIR;
			COMMIT;
			DBMS_OUTPUT.PUT_LINE ('Номер'
				||SELLERID
				||': старый телефон  = '
				||TELEP
				||', новый телефон = '
				||NEWTEL);
		ELSE
			RAISE ERR_NO_DATA;
		END IF;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			DBMS_OUTPUT.PUT_LINE('Данный номер директора не найден');
		WHEN ERR_NO_DATA THEN
			DBMS_OUTPUT.PUT_LINE('Нельзя вводить один и тот же номер, Номер'
				||SELLERID
				||': старый телефон  = '
				||TELEP
				||', старый телефон = '
				||NEWTEL);
	END TEL_CH;
	FUNCTION FUNCT RETURN NUMBER IS
		CURSOR MAT_CURSOR IS
			SELECT
				OBJECTS1.ONAME AS OBJEKT
			FROM
				DEALS,
				CUSTOMER,
				OBJECTS1
			WHERE
				CUSTOMER.CNO=DEALS.CNO
				AND DEALS.ONO=OBJECTS1.ONO
				AND DEALS.DATE1= TO_CHAR(SYSDATE-11,
				'DD-MON-YYYY');
		PEREMEN    DEALS.DNO%TYPE DEFAULT 0;
		CURSOR_ROW MAT_CURSOR%ROWTYPE;
		ERR EXCEPTION;
		PRAGMA EXCEPTION_INIT( ERR, -20001 );
	BEGIN
		SELECT
			COUNT(*) INTO PEREMEN
		FROM
			DEALS,
			CUSTOMER,
			OBJECTS1
		WHERE
			CUSTOMER.CNO=DEALS.CNO
			AND DEALS.ONO=OBJECTS1.ONO
			AND DEALS.DATE1= TO_CHAR(SYSDATE-11,
			'DD-MON-YYYY');
		OPEN MAT_CURSOR;
		FETCH MAT_CURSOR INTO CURSOR_ROW;
		IF MAT_CURSOR%NOTFOUND THEN
			RAISE ERR;
		END IF;
		WHILE MAT_CURSOR%FOUND LOOP
			DBMS_OUTPUT.PUT_LINE ('OBJECT: '
				|| CURSOR_ROW.OBJEKT );
			FETCH MAT_CURSOR INTO CURSOR_ROW;
		END LOOP;
		CLOSE MAT_CURSOR;
		DBMS_OUTPUT.PUT_LINE ('Колличество договоров на текущий день: '
			|| PEREMEN);
		RETURN NULL;
	EXCEPTION -- начало обработчика исключений основной программы
		WHEN TIMEOUT_ON_RESOURCE THEN
			RAISE_APPLICATION_ERROR(-20002, 'Превышен интервал ожидания');
		WHEN VALUE_ERROR THEN
			RAISE_APPLICATION_ERROR(-20004, 'Ошибка в операции преобразования или математической операции!');
		WHEN ERR THEN
			RAISE_APPLICATION_ERROR(-20001, 'Нет объектов которые учавствовали в сделках на тот период');
	END FUNCT;
	PROCEDURE TEL_CH_CH (
		FNAMEDIR IN VARCHAR2,
		NEWTEL IN VARCHAR2
	) IS
		TELEP       SELLER.TEL_NO%TYPE;
		SELLERID    SELLER.SNO%TYPE;
		ERR_NO_DATA EXCEPTION;
		FUNCTION WRONGTELE (
			TEL_NO IN VARCHAR2
		) RETURN BOOLEAN IS
			WRONGTELE BOOLEAN DEFAULT FALSE;
		BEGIN
			IF TEL_NO = '+375(29)555-55-55' THEN
				RETURN TRUE;
			END IF;
		END WRONGTELE;
	BEGIN
		SELECT
			TEL_NO,
			SNO INTO TELEP,
			SELLERID
		FROM
			SELLER
		WHERE
			FNAMEDIR=FNAME_DIR;
		IF TELEP <> NEWTEL THEN
			UPDATE SELLER
			SET
				TEL_NO=NEWTEL
			WHERE
				SNO=SELLERID;
			IF WRONGTELE(NEWTEL)THEN
				RAISE_APPLICATION_ERROR(-20001, ' Данный номер нельзя водить!'
					||SQLCODE
					||' -ERROR- '
					||SQLERRM);
			END IF;
			COMMIT;
			DBMS_OUTPUT.PUT_LINE ('Директор '
				||FNAMEDIR
				||': старый телефон  = '
				||TELEP
				||', новый телефон = '
				||NEWTEL);
		ELSE
			RAISE ERR_NO_DATA;
		END IF;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			DBMS_OUTPUT.PUT_LINE('Данный директор не найден');
		WHEN ERR_NO_DATA THEN
			DBMS_OUTPUT.PUT_LINE('Нельзя вводить один и тот же номер, Директор '
				||FNAMEDIR
				||': старый телефон  = '
				||TELEP
				||', старый телефон = '
				||NEWTEL );
	END TEL_CH_CH;
END PACK2;
/

-- 6.	Написать анонимный PL/SQL-блок, в котором будут вызовы реализованных функций и процедур пакета с различными характерными значениями па-раметров для проверки правильности работы основных задач и обработки ис-ключительных ситуаций.

BEGIN
	PACK1.TEL_CH;
	DECLARE
		TIME NUMBER;
	BEGIN
		DBMS_OUTPUT.PUT_LINE('Процедура нормальная:');
		PACK2.TEL_CH('Адырбаева Алтынай', '+375(44)333-55-00');
		DBMS_OUTPUT.PUT_LINE('Процедура (Если был введен неверный директор):');
		PACK2.TEL_CH('Шопанов Жаксыбай', '+375(29)222-55-44');
		DBMS_OUTPUT.PUT_LINE('Процедура (Если телефон был введен дважды):');
		PACK2.TEL_CH('Адырбаева Алтынай', '+375(44)333-55-00');
		DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');
		DBMS_OUTPUT.PUT_LINE('Процедура перегруз. нормальная:');
		PACK2.TEL_CH(50, '+375(29)222-55-00');
		DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');
		TIME := FUNCT;
		DBMS_OUTPUT.PUT_LINE(TIME);
	END;
/