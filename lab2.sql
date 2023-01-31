--Вариант 5:

--Task 1
--Вывести в одном поле ФИО и адреса сотрудников, родившихся до мая 1980 года.

SELECT
  'ф.'|| FNAME || ', и.' || LNAME || ', год.' || DOB || ', адрес.' || ADDRESS
FROM
  STAFF
WHERE
  DOB < TO_DATE('01-MAY-80',
  'dd-mon-yy');

--Task 2
--Подсчитать и вывести, сколько сотрудников работает в отделениях в Бресте. Подписать вычисляемое поле как «Количество».

SELECT
  COUNT(*) AS KOLL
FROM
  BRANCH B,
  STAFF S
WHERE
  B.BNO=S.BNO
  AND CITY='Брест'

--Task 3
--Подсчитать количество арендаторов, осмотревших 3- и 4-комнатные объекты недвижимости. Вывести в запросе количество комнат для каждого типа объекта и количество арендаторов.

SELECT
  OBJECTS.ROOMS,
  OBJECTS.TYPE_OBJ,
  COUNT(OBJECTS.ROOMS) AS KOLL_OBJECTOV,
  COUNT(RENTER.RNO) AS OBSH_KOL_ARENDATOR
FROM
  RENTER
  INNER JOIN VIEWING
  ON VIEWING.RNO = RENTER.RNO
  INNER JOIN OBJECTS
  ON OBJECTS.PNO=VIEWING.PNO
WHERE
  OBJECTS.ROOMS>='3'
GROUP BY
  OBJECTS.TYPE_OBJ,
  OBJECTS.ROOMS

--Task 4
--Вывести информацию о владельцах и количестве объектов у каждого при условии, что они сдают более двух квартир в разных отделениях.

SELECT
  RENTER.PREF_TYPE,
  COUNT(OBJECTS.ROOMS) AS KOLL_KOMNAT,
  COUNT(RENTER.RNO) AS OBSH_KOL_ARENDATOR
FROM
   RENTER
  INNER JOIN VIEWING
  ON VIEWING.RNO = RENTER.RNO
  INNER JOIN OBJECTS
  ON OBJECTS.PNO=VIEWING.PNO
  INNER JOIN PROPERTY_FOR_RENT
  ON PROPERTY_FOR_RENT.PNO = VIEWING.PNO
WHERE
  PROPERTY_FOR_RENT.ROOMS>='3'
GROUP BY
   RENTER.PREF_TYPE

--4.2

SELECT
  COUNT(OBJECTS.PNO) AS KOLL_OBJ,
  OWNER.ONO,
  OWNER.FNAME,
  OWNER.LNAME
FROM
  OBJECTS
  INNER JOIN OWNER
  ON OWNER.ONO=OBJECTS.ONO
  INNER JOIN BRANCH
  ON BRANCH.BNO=OBJECTS.BNO
GROUP BY
  OWNER.ONO,
  OWNER.FNAME,
  OWNER.LNAME
HAVING
  COUNT(OBJECTS.PNO)=2;

--4.3

SELECT
  PROPERTY_FOR_RENT.PNO,
  BRANCH.STREET,
  OWNER.ONO,
  OWNER.FNAME,
  OWNER.LNAME
FROM
  OWNER
  INNER JOIN PROPERTY_FOR_RENT
  ON PROPERTY_FOR_RENT.ONO=OWNER.ONO
  INNER JOIN BRANCH
  ON BRANCH.BNO=PROPERTY_FOR_RENT.BNO
  INNER JOIN STAFF
  ON STAFF.SNO=PROPERTY_FOR_RENT.SNO
WHERE
  PROPERTY_FOR_RENT.PNO>='3'
 
-- Обновить одной командой информацию о максимальной рентной стоимости объектов, уменьшив стоимость квартир на 5 %, а стоимость домов увеличив на 7 %.

UPDATE OBJECTS O SET O.RENT = (
  CASE
    WHEN O.TYPE_OBJ = 'f' THEN
      O.RENT*0.95
    ELSE
      O.RENT*1.07
  END);

-- Написать запросы по индивидуальной базе данных:
-- условный запрос, итоговый запрос,
-- параметрический запрос,
-- запрос на объединение,
-- запрос с использовани-ем условия по полю с типом дата.

-- 5 запросов по своей БД
-- 1. «Список объектов, предлагаемых к продаже» (условная выборка);

SELECT
  *
FROM
  OBJECTS1
WHERE
  SQUARE<'500';

-- 2. «Сальдо по видам объектов» (итоговый запрос);

SELECT
  TYPE_OBJECTS.TYPE,
  AVG(DEALS.PRICE) AS AVG_PRICE,
  COUNT(DEALS.DNO) AS OBSH_KOL_DOG
FROM
  TYPE_OBJECTS
  INNER JOIN DEALS
  ON TYPE_OBJECTS.TNO = DEALS.TNO
GROUP BY
  TYPE_OBJECTS.TYPE
ORDER BY
  AVG_PRICE;

-- 3. «Объекты заданной стоимости» (параметрический запрос);

SELECT
  *
FROM
  OBJECTS1
WHERE
  OBJECTS1.PRICE=&VVEDITE_CENU;

-- 4. «Общий список покупателей и продавцов с количеством сделок» (запрос на объединение);

SELECT
  CONCAT ('customer',
  SELLER.FNAME_DIR),
  COUNT(DEALS.DNO)
FROM
  SELLER,
  DEALS
GROUP BY
  SELLER.FNAME_DIR,
  DEALS.DNO UNION ALL
SELECT
  CONCAT('customer',
  CUSTOMER.FNAME_DIR),
  COUNT(DEALS.DNO)
FROM
  CUSTOMER,
  DEALS
GROUP BY
  CUSTOMER.FNAME_DIR,
  DEALS.DNO

-- 4.2

SELECT
  SELLER.FNAME_DIR AS SELLER,
  CUSTOMER.FNAME_DIR AS CUSTOMER,
  COUNT(DEALS.DNO) AS KOL_DOG
FROM
  SELLER
  INNER JOIN DEALS
  ON SELLER.SNO=DEALS.SNO
  INNER JOIN CUSTOMER
  ON CUSTOMER.CNO=DEALS.CNO
GROUP BY
  SELLER.FNAME_DIR,
  CUSTOMER.FNAME_DIR

-- 5. «Количество сделок по районам и по годам» (запрос по полю с типом дата).

SELECT
  TYPE_OBJECTS.TYPE,
  COUNT(DEALS.DNO) AS KOL,
  EXTRACT(YEAR
FROM
  DEALS.DATE1) AS PO_GODAM
FROM
  TYPE_OBJECTS
  INNER JOIN DEALS
  ON DEALS.TNO=TYPE_OBJECTS.TNO
GROUP BY
  TYPE_OBJECTS.TYPE,
  EXTRACT(YEAR FROM DEALS.DATE1)
ORDER BY
  PO_GODAM ASC

-- 5.2

SELECT*
FROM
(
SELECT
  TYPE_OBJECTS.TYPE,
  DEALS.DATE1
FROM
  TYPE_OBJECTS
  JOIN DEALS
  ON DEALS.TNO = TYPE_OBJECTS.TNO PIVOT (COUNT(DEALS.DATE1) FOR DATE1 IN (2019)) AS QUAN)
 
-- Для своего варианта самостоятельно придумать задание и реализовать следу-ющие типы запросов:
-- внутренним соединением таблиц, используя стандартный синтаксис SQL (JOIN…ON, JOIN…USING или NATURAL JOIN), который не применялся в предыдущих запросах;
-- внешним соединением таблиц, используя FULL JOIN, LEFT JOIN или RIGHT JOIN, при этом обязательным является наличие в БД данных, которые будут выводиться именно с выбранным оператором внешнего соединения;
-- использованием предиката IN с подзапросом;
-- с использованием предиката ANY/ALL с подзапросом;
-- с использованием предиката EXISTS/NOT EXISTS с подзапросом.
-- с внутренним соединением таблиц, используя стандартный синтаксис SQL (JOIN…ON, JOIN…USING или NATURAL JOIN),
-- который не применялся в предыдущих запросах ***
-- Показать агентов и их даты сделок:

SELECT
  ANO,
  FNAME_LNAME,
  DATE1
FROM
  DEALS
  NATURAL JOIN AGENT

-- С внешним соединением таблиц, используя FULL JOIN, LEFT JOIN или RIGHT JOIN, при этом обязательным является наличие в БД данных,
-- Которые будут выводится именно с выбранным оператором внешнего соединения
-- Вывести список ФИО в лице директоров организаций, продавших объекты до мая 2019 года:

SELECT
  SELLER.FNAME_DIR,
  DEALS.DNO,
  DEALS.SNO,
  DEALS.DATE1
FROM
  SELLER
LEFT JOIN DEALS
  ON SELLER.SNO=DEALS.SNO
WHERE
  DEALS.DATE1 < TO_DATE('01-MAY-2019', 'dd-mon-yy');

-- С использованием предиката IN с подзапросом
-- Запрос вывести нотариусов которые работали с типом объектов торговый зал

SELECT
  FNAME_LNAME_NOTARY
FROM
  DEALS
WHERE
  TNO IN (
    SELECT
      TNO
    FROM
      TYPE_OBJECTS
    WHERE
      TYPE= 'Торговый зал'
  );

-- С использованием предиката ANY/ALL с подзапросом;
-- Вывести покупателей с объектами которые хотя бы один продался за 500 у.е.

SELECT
  *
FROM
  DEALS
WHERE
  PRICE >ALL(
    SELECT
      PRICE
    FROM
      DEALS
    WHERE
      PRICE='500'
  )

SELECT
  *
FROM
  DEALS
WHERE
  PRICE <ANY(
    SELECT
      PRICE
    FROM
      DEALS
    WHERE
      PRICE='500'
  )

-- Вывести список объектов, которые цена равна 500 у.е.

SELECT
  ONAME
FROM
  OBJECTS1
WHERE
  PRICE >ANY(
    SELECT
      PRICE
    FROM
      DEALS
  )
 
-- С использованием предиката EXISTS/NOT EXISTS с подзапросом.
-- Продавцы, которые были обслужены 41 и 42 агентом:

SELECT
  SNO
FROM
  DEALS
WHERE
  ANO='41'
  AND EXISTS (
    SELECT
      ONO
    FROM
      DEALS
    WHERE
      ANO='42'
      AND SNO=DEALS.SNO
  ) NOT EXIST
 
-- Продавцы, которые были обслужаны 43 агентом, но не обслужаны 45 агентом

SELECT
  *
FROM
  OBJECTS1
WHERE
  NOT EXISTS (
    SELECT
      *
    FROM
      DEALS
    WHERE
    DEALS.ONO=OBJECTS1.ONO
  )