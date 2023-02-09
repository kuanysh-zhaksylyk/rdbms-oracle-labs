CREATE TABLE BRANCH(
    BNO INTEGER NOT NULL,
    STREET VARCHAR2(30) NOT NULL,
    CITY VARCHAR2(15) NOT NULL,
    TEL_NO VARCHAR2(17),
    PRIMARY KEY(BNO),
    CONSTRAINT CH_TELNO_BRANCH CHECK(REGEXP_LIKE(TEL_NO, '^\+375\(\d{2}\)\d{3}-\d{2}-\d{2}$')),
    CONSTRAINT UNI_TELNO_BRANCH UNIQUE(TEL_NO)
);

CREATE TABLE STAFF(
    SNO INTEGER NOT NULL,
    FNAME VARCHAR2(20) NOT NULL,
    LNAME VARCHAR2(20) NOT NULL,
    ADDRESS VARCHAR2(60) NOT NULL,
    TEL_NO VARCHAR2(17) NOT NULL,
    POSITION VARCHAR2(40) NOT NULL,
    SEX VARCHAR2(6),
    DOB DATE,
    SALARY NUMBER(5, 2),
    BNO INTEGER,
    PRIMARY KEY(SNO),
    CONSTRAINT CH_TELNO_STAFF CHECK(REGEXP_LIKE(TEL_NO, '^\+375\(\d{2}\)\d{3}-\d{2}-\d{2}$')),
    CONSTRAINT UNI_TELNO_STAFF UNIQUE(TEL_NO),
    CONSTRAINT CH_SEX CHECK(SEX IN('male', 'female')),
    CONSTRAINT BNO_FK_STAFF FOREIGN KEY(BNO) REFERENCES BRANCH
);

CREATE TABLE PROPERTY_FOR_RENT(
    PNO INTEGER NOT NULL,
    STREET VARCHAR2(30) NOT NULL,
    CITY VARCHAR2(15) NOT NULL,
    TYPE_OBJ CHAR(1) NOT NULL,
    ROOMS INTEGER,
    RENT NUMBER(5, 2),
    ONO INTEGER,
    SNO INTEGER,
    BNO INTEGER,
    PRIMARY KEY(PNO),
    CONSTRAINT CH_OBJ_TYPE CHECK(TYPE_OBJ IN('h', 'f')),
    CONSTRAINT SNO_FK_PFRENT FOREIGN KEY(SNO) REFERENCES STAFF,
    CONSTRAINT BNO_FK_PFRENT FOREIGN KEY(BNO) REFERENCES BRANCH
);

CREATE SYNONYM OBJECTS FOR PROPERTY_FOR_RENT;

CREATE TABLE RENTER(
    RNO INTEGER NOT NULL,
    FNAME VARCHAR2(20) NOT NULL,
    LNAME VARCHAR2(20),
    ADDRESS VARCHAR2(60),
    TEL_NO VARCHAR2(17),
    PREF_TYPE CHAR(1),
    MAX_RENT NUMBER(5, 2),
    BNO INTEGER,
    PRIMARY KEY(RNO),
    CONSTRAINT CH_PREF_TYPE CHECK(PREF_TYPE IN('h', 'f')),
    CONSTRAINT CH_TELNO_RENTER CHECK(REGEXP_LIKE(TEL_NO, '^\+375\(\d{2}\)\d{3}-\d{2}-\d{2}$')),
    CONSTRAINT UNI_TELNO_RENTER UNIQUE(TEL_NO),
    CONSTRAINT BNO_FK_RENTER FOREIGN KEY(BNO) REFERENCES BRANCH
);

CREATE TABLE OWNER(
    ONO INTEGER NOT NULL,
    FNAME VARCHAR2(20),
    LNAME VARCHAR2(20),
    ADDRESS VARCHAR2(60),
    TEL_NO VARCHAR2(17),
    PRIMARY KEY(ONO),
    CONSTRAINT CH_TELNO_OWNER CHECK(REGEXP_LIKE(TEL_NO, '^\+375\(\d{2}\)\d{3}-\d{2}-\d{2}$')),
    CONSTRAINT UNI_TELNO_OWNER UNIQUE(TEL_NO)
);

ALTER TABLE PROPERTY_FOR_RENT ADD CONSTRAINT ONO_FK1 FOREIGN KEY(ONO) REFERENCES OWNER;

CREATE TABLE VIEWING(
    RNO INTEGER NOT NULL,
    PNO INTEGER NOT NULL,
    DATE1 DATE NOT NULL,
    COMMENT1 VARCHAR2(300),
    PRIMARY KEY(RNO, PNO),
    CONSTRAINT RNO_FK_VIEWING FOREIGN KEY(RNO) REFERENCES RENTER,
    CONSTRAINT PNO_FK_VIEWING FOREIGN KEY(PNO) REFERENCES PROPERTY_FOR_RENT
);


CREATE SEQUENCE BRANCH_SEQ START WITH 1 INCREMENT BY 1;

CREATE SEQUENCE STAFF_SEQ START WITH 1 INCREMENT BY 1;

CREATE SEQUENCE PROPERTY_FOR_RENT_SEQ START WITH 1 INCREMENT BY 1;

CREATE SEQUENCE RENTER_SEQ START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER SEQ_BRANCH BEFORE
    INSERT ON BRANCH FOR EACH ROW
BEGIN
    SELECT
        BRANCH_SEQ.NEXTVAL INTO :NEW.BNO
    FROM
        DUAL;
END SEQ_BRANCH;

BEGIN
    INSERT INTO BRANCH(
        STREET,
        CITY,
        TEL_NO
    ) VALUES(
        'Ленина 42',
        'Минск',
        '+375(29)221-11-71'
    );
    INSERT INTO BRANCH(
        STREET,
        CITY,
        TEL_NO
    ) VALUES(
        'Якуба Коласа 13',
        'Минск',
        '+375(33)222-11-71'
    );
    INSERT INTO BRANCH(
        STREET,
        CITY,
        TEL_NO
    ) VALUES(
        'Пролетарская 17',
        'Брест',
        '+375(25)223-11-71'
    );
    INSERT INTO BRANCH (
        STREET,
        CITY,
        TEL_NO
    )VALUES(
        'Совецкая',
        'Брест',
        '+375(29)224-11-71'
    );
    INSERT INTO BRANCH (
        STREET,
        CITY,
        TEL_NO
    )VALUES(
        'Комсомольская 764',
        'Витебск',
        '+375(29)225-11-71'
    );
    INSERT INTO BRANCH (
        STREET,
        CITY,
        TEL_NO
    )VALUES(
        'Янки Купалы 123',
        'Гомель',
        '+375(29)226-11-71'
    );
    INSERT INTO BRANCH(
        STREET,
        CITY,
        TEL_NO
    ) VALUES(
        'Максима Танка 64',
        'Гродно',
        '+375(29)227-11-71'
    );
    INSERT INTO BRANCH (
        STREET,
        CITY,
        TEL_NO
    )VALUES(
        'Ленина 88',
        'Могилев',
        '+375(29)228-11-71'
    );
    INSERT INTO BRANCH (
        STREET,
        CITY,
        TEL_NO
    )VALUES(
        'Машерова 44',
        'Могилев',
        '+375(33)229-11-71'
    );
    INSERT INTO BRANCH (
        STREET,
        CITY,
        TEL_NO
    )VALUES(
        'Октябрьская 58',
        'Витебск',
        '+375(29)230-11-71'
    );
    INSERT INTO BRANCH (
        STREET,
        CITY,
        TEL_NO
    )VALUES(
        'Октябрьская 102',
        'Гродно',
        '+375(29)255-11-71'
    );
END;
/

INSERT INTO STAFF VALUES(
    STAFF_SEQ.NEXTVAL,
    'Якубов',
    'Виктор',
    'Минск, Горького 19',
    '+375(25)225-11-71',
    'director',
    'male',
    TO_DATE('17.03.86', 'dd.mm.yy'),
    300,
    1
);

INSERT INTO STAFF VALUES(
    STAFF_SEQ.NEXTVAL,
    'Якубова',
    'Анна',
    'Брест, Горького 19',
    '+375(29)225-11-71',
    'manager',
    'female',
    TO_DATE('22.09.87', 'dd.mm.yy'),
    250,
    2
);

INSERT INTO STAFF VALUES(
    STAFF_SEQ.NEXTVAL,
    'Шевцов',
    'Дмитрий',
    'Гомель, Красноармейская 14',
    '+375(33)225-11-71',
    'seller',
    'male',
    TO_DATE('25.04.90', 'dd.mm.yy'),
    800,
    2
);

INSERT INTO STAFF VALUES(
    STAFF_SEQ.NEXTVAL,
    'Карпеш',
    'Елизавета',
    'Гродно, Притыцкого 33',
    '+375(29)221-11-71',
    'manager',
    'female',
    TO_DATE('30.12.91', 'dd.mm.yy'),
    200,
    3
);

INSERT INTO STAFF VALUES(
    STAFF_SEQ.NEXTVAL,
    'Самсонова',
    'Дарья',
    'Могилев, Советская 12',
    '+375(29)225-12-71',
    'manager',
    'female',
    TO_DATE('30.08.78', 'dd.mm.yy'),
    280,
    5
);

INSERT INTO STAFF VALUES(
    STAFF_SEQ.NEXTVAL,
    'Шостак',
    'Руслан',
    'Минск, Ленина 13',
    '+375(29)225-31-71',
    'manager',
    'male',
    TO_DATE('04.05.96', 'dd.mm.yy'),
    190,
    6
);

INSERT INTO STAFF VALUES(
    STAFF_SEQ.NEXTVAL,
    'Минич',
    'Виктор',
    'Гродно, Хлебобулочная 33',
    '+375(29)225-41-71',
    'seller',
    'male',
    TO_DATE('12.08.88', 'dd.mm.yy'),
    700,
    6
);

INSERT INTO STAFF VALUES(
    STAFF_SEQ.NEXTVAL,
    'Потапенко',
    'Максим',
    'Минск, Беспощадня 19',
    '+375(29)225-51-71',
    'seller',
    'male',
    TO_DATE('25.06.80', 'dd.mm.yy'),
    900,
    7
);

INSERT INTO STAFF VALUES(
    STAFF_SEQ.NEXTVAL,
    'Кенда',
    'Яна',
    'Витебск, Пролетарская 73',
    '+375(29)225-22-71',
    'seeller',
    'male',
    TO_DATE('17.03.86', 'dd.mm.yy'),
    300,
    8
);

INSERT INTO OWNER(
    ONO,
    FNAME,
    LNAME,
    ADDRESS,
    TEL_NO
)
    SELECT
        STAFF_SEQ.NEXTVAL,
        FNAME,
        LNAME,
        ADDRESS,
        TEL_NO
    FROM
        STAFF;

BEGIN
    INSERT INTO OBJECTS VALUES (
        PROPERTY_FOR_RENT_SEQ.NEXTVAL,
        'Якуба Коласа 43',
        'Минск',
        'h',
        2,
        600,
        12,
        3,
        1
    );
    INSERT INTO OBJECTS VALUES (
        PROPERTY_FOR_RENT_SEQ.NEXTVAL,
        'Пролетарская 13',
        'Минск',
        'f',
        3,
        500,
        13,
        5,
        1
    );
    INSERT INTO OBJECTS VALUES (
        PROPERTY_FOR_RENT_SEQ.NEXTVAL,
        'Совецкая 77',
        'Брест',
        'f',
        4,
        100,
        14,
        3,
        3
    );
    INSERT INTO OBJECTS VALUES (
        PROPERTY_FOR_RENT_SEQ.NEXTVAL,
        'Янки купалы 105',
        'Гомель',
        'h',
        4,
        400,
        14,
        6,
        6
    );
    INSERT INTO RENTER VALUES(
        RENTER_SEQ.NEXTVAL,
        'Иванов',
        'Иван',
        'Минск, Минина 5',
        '+375(29)225-11-71',
        'h',
        500,
        1
    );
    INSERT INTO RENTER VALUES(
        RENTER_SEQ.NEXTVAL,
        'Петров',
        'Петр',
        'Брест, Малорийская 76',
        '+375(29)225-11-72',
        'f',
        400,
        1
    );
    INSERT INTO RENTER VALUES(
        RENTER_SEQ.NEXTVAL,
        'Козяк',
        'Инокентий',
        'Гродно, Пролетарская 666',
        '+375(29)225-11-73',
        'h',
        900,
        3
    );
    INSERT INTO RENTER VALUES(
        RENTER_SEQ.NEXTVAL,
        'Алексеев',
        'Максим',
        'Могилев, Болотная 9',
        '+375(29)225-11-74',
        'f',
        700,
        3
    );
    INSERT INTO RENTER VALUES(
        RENTER_SEQ.NEXTVAL,
        'Романов',
        'Роман',
        'Гомель, Советская 73',
        '+375(29)225-11-75',
        'h',
        500,
        6
    );
END;
/

BEGIN
    INSERT INTO VIEWING VALUES(
        1,
        6,
        TO_DATE('03.12.19', 'dd.mm.yy'),
        'ok'
    );
    INSERT INTO VIEWING VALUES(
        1,
        5,
        TO_DATE('03.10.20', 'dd.mm.yy'),
        'good'
    );
    INSERT INTO VIEWING VALUES(
        2,
        3,
        TO_DATE('15.08.20', 'dd.mm.yy'),
        ''
    );
    INSERT INTO VIEWING VALUES(
        4,
        3,
        TO_DATE('16.08.19', 'dd.mm.yy'),
        'bad'
    );
    INSERT INTO VIEWING VALUES(
        5,
        4,
        TO_DATE('04.12.20', 'dd.mm.yy'),
        ''
    );
END;
/