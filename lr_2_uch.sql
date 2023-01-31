Вывести в одном поле фамилии и домашние телефоны
всех потенциальных арендаторов, желающих арендовать дома.

SELECT DISTINCT lname AS tel_and_lname
FROM renter R, viewing V
WHERE R.rno = V.rno 
  AND R.pref_type = 'h'
UNION 
SELECT DISTINCT tel_no
FROM renter R, viewing V
WHERE R.rno = V.rno 
  AND R.pref_type = 'h';

Вывести телефоны владельцев, 
дома или квартиры которых осматривались в ДЕКАБРЕ 2019 года.

SELECT DISTINCT O.tel_no
FROM owner O, viewing V, objects Obj
WHERE V.pno = Obj.pno 
  AND O.ono = Obj.ono 
  AND EXTRACT(MONTH FROM V.date1) = '12' 
  AND EXTRACT(YEAR FROM V.date1) = '2019';

Определить квартиру и дом с минимальной рентной стоимостью в каждом отделении. 
Подписать вычисляемое поле как «Дешевый дом/квартира».

SELECT type_obj, MIN(rent) AS "Дешевый дом/квартира"
FROM objects
GROUP BY type_obj;

Подсчитать среднюю заработную плату сотрудников каждого отделения и количество обслуживаемых в них объектов

SELECT Br.bno, AVG(S.salary) AS average_salary, COUNT(Obj.bno) AS amount
FROM (branch Br LEFT JOIN objects Obj ON Br.bno = Obj.bno) LEFT JOIN staff S ON Br.bno = S.bno 
GROUP BY Br.bno
ORDER by Br.bno;

Обновить одной командой информацию о максимальной рентной стоимости объектов, уменьшив стоимость квартир на 5 %, а стоимость домов увеличив на 7 %.

UPDATE objects O
SET O.rent = (CASE 
                  WHEN O.type_obj = 'f' THEN O.rent*0.95 
                  ELSE O.rent*1.07 
              END);

