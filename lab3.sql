-- В учебной базе данных создать следующие представления:

-- 1.1) с информацией об офисах в Бресте;

CREATE
OR REPLACE VIEW BREST AS
SELECT
  *
FROM
  BRANCH
WHERE
  CITY = 'Брест';

-- 1.2) с информацией об объектах недвижимости минимальной стоимости;

CREATE
OR REPLACE VIEW MINRENTPRISE AS
SELECT
  *
FROM
  PROPERTY_FOR_RENT
WHERE
  RENT IN (
    SELECT
      MIN(RENT)
    FROM
      PROPERTY_FOR_RENT
  );

-- 1.3) с информацией о количестве сделанных осмотров с комментариями;

CREATE
OR REPLACE VIEW COMMENT AS
SELECT
  COUNT(*) AS AMOUNT
FROM
  VIEWING
WHERE
  COMMENT1 IS NOT NULL;

-- 1.4) со сведениями об арендаторах, желающих арендовать 2-комнатные квартиры в тех же городах (поле city), где они проживают (поле address);

CREATE
OR REPLACE VIEW RENTER_CITY AS
SELECT
  *
FROM
  RENTER
WHERE
  RNO IN (
    SELECT
      RNO
    FROM
      RENTER,
      OBJECTS
    WHERE
      RENTER.RNO = OBJECTS.PNO
      AND ROOMS = '3'
      AND TYPE_OBJ = 'f'
  )
  AND SUBSTR(ADDRESS,
  1,
  INSTR(ADDRESS,
  ',',
  1) - 1) IN (
    SELECT
      CITY
    FROM
      OBJECTS
  );

--1.5) со сведениями об отделении с максимальным количеством работающих сотрудников;

CREATE
OR REPLACE VIEW MAX_WORK AS
SELECT
  *
FROM
  BRANCH B
WHERE
  B.BNO IN (
    SELECT
      BNO
    FROM
      STAFF  S
    GROUP BY
      S.BNO
    HAVING
      COUNT(S.BNO) = (
        SELECT
          MAX(COUNT(S.BNO))
        FROM
          STAFF S
        GROUP BY
          S.BNO
      )
  );

-- 1.6) с информацией о сотрудниках и объектах, которые они предлагают в аренду в текущем месяце;

CREATE
OR REPLACE VIEW QUART AS
SELECT
  STAFF.SNO,
  FNAME,
  LNAME,
  TEL_NO,
  STREET,
  CITY,
  TYPE_OBJ,
  ROOMS,
  RENT,
  DATE1
FROM
  STAFF
  INNER JOIN OBJECTS
  ON STAFF.SNO = OBJECTS.SNO
  INNER JOIN VIEWING
  ON OBJECTS.PNO = VIEWING.PNO
  AND TRUNC(DATE1,
  'Q') = TRUNC(SYSDATE,
  'Q')
  AND TRUNC(DATE1,
  'Y') = TRUNC(SYSDATE,
  'Y');

-- 1.7) с информацией о владельцах, чьи дома или квартиры осматривались потенциальными арендаторами более двух раз;

CREATE
OR REPLACE VIEW POPULAR_OWNERS AS
SELECT
  DISTINCT OWNER.ONO,
  OWNER.FNAME,
  OWNER.LNAME,
  OWNER.ADDRESS,
  OWNER.TEL_NO
FROM
  OWNER,
  OBJECTS
WHERE
  OWNER.ONO = OBJECTS.ONO
  AND OBJECTS.PNO IN (
    SELECT
      PNO
    FROM
      VIEWING
    GROUP BY
      PNO
    HAVING
      COUNT(RNO) > 2
  );

-- 1.8 с информацией о собственниках с одинаковыми именами и количеством объектов у них.

CREATE
OR REPLACE VIEW KOLL_ODIN AS
SELECT
  FNAME,
  COUNT(TYPE_OBJ)
FROM
  OWNER,
  OBJECTS
WHERE
  OWNER.FNAME LIKE '%(SELECT fname FROM owner)%'
  AND OWNER.ONO = OBJECTS.ONO
GROUP BY
  FNAME;

-- 1.8.2

SELECT
  DISTINCT OWNER.LNAME,
  COUNT(OWNER.LNAME),
  COUNT(OBJECTS.PNO)
FROM
  OWNER,
  OBJECTS
GROUP BY
  OWNER.LNAME,
  OBJECTS.PNO
HAVING
  COUNT (OWNER.FNAME) > 1;

-- В индивидуальной БД создать:
-- 1)	Горизонтальное обновляемое представление с условием (WHERE);
-- представление с информацией о недвижимостей большой стоимости(>30000) (горизонтальное обновляемое представление)

CREATE
OR REPLACE VIEW EXPENSIVE_OBJECTS AS
SELECT
  *
FROM
  OBJECTS1
WHERE
  PRICE > 30000 WITH CHECK OPTION;

-- checking

INSERT INTO EXPENSIVE_OBJECTS (
  ONAME,
  ADDRESS,
  SQUARE,
  PRICE,
  FLOORS,
  COMMENTS
) VALUES (
  'Игровой клуб2',
  'ул. Тауелдиздик 3',
  '300m^2',
  '30000',
  '2',
  'good'
);

-- 2) Представление с информацией join.... on.... (смешанное необновляемое представление)
-- проверить обновляемость горизонтального представления с фразой WITH CHECK OPTION при помощи одной из инструкций UPDATE, DELETE, INSERT (привести примеры выполняющихся и не выполняющихся инструкций, объяснить);

CREATE
OR REPLACE VIEW DEALS_DEALS AS
SELECT
  deals.price,
  agent.fname_lname
FROM
  deals,
  agent
WHERE
  agent.fname_lname = 'Кайыргельдинов Бахтияр'
  and deals.ano = agent.ano 

-- 3) Создать вертикальное или смешанное необновляемое представление, 
-- предназначенное для работы с основной таблицей БД (в представлении должны содержаться сведения из основной дочерней таблицы и/или корзины (если есть), 
-- но вместо внешних ключей использовать связанные данные родительских таблиц, понятные конечному пользователю представления);

CREATE
OR REPLACE VIEW deals_type AS
SELECT
  d.price || ' ' || t.type AS TYPETYPE
FROM
  deals d,
  type t
WHERE
  t.type = 'Офис'
  and d.tno = t.tno 

-- 4) Доказать необновляемость представления при помощи одной из инструкций UPDATE, DELETE, INSERT. Объяснить причины необновляемости;

UPDATE DEALS_TYPE
SET
  TYPE = 'Купол'
WHERE
  PRICE = 40 INSERT INTO DEALS_TYPE(
    PRICE,
    TYPE
  ) VALUES (
    50,
    'Купол'
  );

DELETE FROM DEALS_DEALS
WHERE
  PRICE = 40 

-- 5) Создать обновляемое представление для работы с одной из родительских таблиц индивидуальной БД и через него разрешить работу с данными только в рабочие дни (с понедельника по пятницу) и в рабочие часы (с 9:00 до 17:00).

CREATE
OR REPLACE VIEW AGENT_VIEW AS SELECT * FROM AGENT
WHERE
  (
    SELECT
      TO_NUMBER(TO_CHAR(SYSDATE,
      'd'))
    FROM
      DUAL
  ) BETWEEN 2
  AND 6
  AND (
    SELECT
      TO_NUMBER(TO_CHAR(SYSDATE,
      'hh24'))
    FROM
      DUAL
  ) BETWEEN 9
  AND 17 WITH CHECK OPTION;