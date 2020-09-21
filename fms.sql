CREATE TABLESPACE fms_db DATAFILE ’fms_db . dbf ’ SIZE 200M;

CREATE USER brug_dba DEFAULT TABLESPACE fms_db identified by 12345;
GRANT DBA , CONNECT , RESOURCE , UNLIMITED TABLESPACE TO brug_dba ;

CREATE ROLE Pilot ;
GRANT CONNECT TO pilot;
GRANT SELECT, DELETE, UPDATE ON brug_dba.FLIGHTS TO pilot; 
GRANT SELECT, INSERT, DELETE, UPDATE ON brug_dba.ALTERNATES TO pilot;
GRANT SELECT, INSERT, DELETE, UPDATE ON brug_dba.CREWS TO pilot;

CREATE ROLE Airline_company;
GRANT CONNECT TO Airline_company;
GRANT SELECT, INSERT, DELETE, UPDATE ON brug_dba.FLIGHTS TO Airline_company;
GRANT SELECT, UPDATE ON brug_dba.AIRCRAFTS TO Airline_company;
GRANT SELECT, ALTER ON brug_dba.FLIGHTS_Counter_seq TO Airline_company;

CREATE ROLE ATC_unit;
GRANT CONNECT TO ATC_unit;
GRANT SELECT, UPDATE ON brug_dba.FLIGHTS TO ATC_unit;
GRANT SELECT ON brug_dba.AIRLINES TO ATC_unit;
GRANT SELECT ON brug_dba.CONCTACTS TO ATC_unit;
GRANT SELECT ON brug_dba.WORKINGS TO ATC_unit;
GRANT SELECT ON brug_dba.OWNINGS TO ATC_unit;
GRANT SELECT ON brug_dba.ABILITATIONS TO ATC_unit;
GRANT SELECT, UPDATE ON brug_dba.AIRPORTS TO ATC_unit;

CREATE TABLE FLIGHTS(
    Counter number primary key,
    AirlineID varchar(15) NOT NULL,
    IDnumber char(4) NOT NULL,
    TakeOffDate TIMESTAMP WITH TIME ZONE,
    LNDdate TIMESTAMP WITH TIME ZONE, 
    IFFcode char(4) NOT NULL,
    Activity varchar(3),
    Status varchar(20),
    ATMauthorization varchar(10) NOT NULL,
    Responsible varchar(25),
    Aircraft char(6),
    Airline varchar(30),
    Departure char(4) NOT NULL,
    Arrival char(4) NOT NULL,
    Authorization varchar(15)
);
CREATE SEQUENCE FLIGHTS_Counter_seq MINVALUE 1 INCREMENT BY 1 START WITH 1 NOCYCLE;
CREATE TABLE AIRCRAFTS(
    ICAOcode char(6) primary key,
    Model varchar(10) NOT NULL,
    Manufacturer varchar(50),
    Category varchar(20) NOT NULL,
    Dimensions varchar(10) NOT NULL,
    MTOW int NOT NULL,
    Passengers int
);
CREATE TABLE AIRPORTS(
    ICAOcode char(4) primary key,
    IATAcode char(3) UNIQUE,
    Name varchar(50) UNIQUE NOT NULL,
    KindOfTraffic varchar(20),
    Latitude varchar(20),
    Longitude varchar(20),
    ColorCode varchar(10) NOT NULL,
    ATCunit varchar(30),
    City varchar(15)
);
CREATE TABLE CATEGORIES(
    Category varchar(30) primary key
);
CREATE TABLE SERVICES(
    Service varchar(30) primary key
);
CREATE TABLE RWYs(
    Heading int,
    Position char(1),
    Airport char(4),
    TORA int NOT NULL,
    TODA int NOT NULL,
    ASDA int NOT NULL,
    LDA int NOT NULL,
    EMDA int NOT NULL,
    foreign key (Airport) REFERENCES AIRPORTS(ICAOcode)
    on delete CASCADE,
    primary key (Heading, Position, Airport)
);
CREATE TABLE ICAO_REGIONS(
    ICAOregion varchar(15) primary key
);
CREATE TABLE CITIES(
    Name varchar(15) primary key,
    Country varchar(30),
    ICAOregion varchar(15),
    foreign key (ICAOregion) REFERENCES ICAO_REGIONS(ICAOregion)
);
CREATE TABLE PERSONNEL(
    SSN varchar(25) primary key,
    Name varchar(15) NOT NULL,
    Surname varchar(15) NOT NULL,
    DateofBirth date NOT NULL,
    PlaceofBirth varchar(15) NOT NULL,
    Lastflighttime TIMESTAMP,
    Type varchar(20),
    foreign key (PlaceOfBirth) REFERENCES CITIES(Name)
);
CREATE TABLE STOPOVERS(
    Flight number,
    Airport char(4),
    TakeOffTime TIMESTAMP,
    LNDtime TIMESTAMP,
    primary key (Flight, Airport),
    foreign key (Flight) REFERENCES FLIGHTS(Counter),
    foreign key (Airport) REFERENCES AIRPORTS(ICAOcode)
);
CREATE TABLE CREWS(
    Flight number,
    Person varchar(25),
    Role varchar(20),
    primary key (Flight, Person),
    foreign key (Flight) REFERENCES FLIGHTS(Counter),
    foreign key (Person) REFERENCES PERSONNEL(SSN)
);
CREATE TABLE AIRLINES(
    IDcode varchar(15) primary key,
    Name varchar(30) UNIQUE NOT NULL,
    Website varchar(30),
    HomeCountry varchar(30)
);
CREATE TABLE OWNINGS(
    Aircraft char(6),
    Airline varchar(15),
    primary key (Aircraft, Airline),
    foreign key (Aircraft) REFERENCES AIRCRAFTS(ICAOcode),
    foreign key (Airline) REFERENCES AIRLINES(IDcode)
);
CREATE TABLE RELATINGS(
    Airport char(4),
    Category varchar(30),
    primary key (Airport, Category),
    foreign key (Airport) REFERENCES AIRPORTS(ICAOcode),
    foreign key (Category) REFERENCES CATEGORIES(Category)
);
CREATE TABLE PROVIDINGS(
    Airport char(4),
    Service varchar(30),
    primary key (Airport, Service),
    foreign key (Airport) REFERENCES AIRPORTS(ICAOcode),
    foreign key (Service) REFERENCES SERVICES(Service)
);
CREATE TABLE ALTERNATES(
    Flight number,
    Airport char(4),
    primary key (Flight, Airport),
    foreign key (Airport) REFERENCES AIRPORTS(ICAOcode),
    foreign key (Flight) REFERENCES FLIGHTS(counter)
);
CREATE TABLE  HUBS(
    Airport char(4),
    Airline varchar(15),
    primary key (Airport, Airline),
    foreign key (Airport) REFERENCES AIRPORTS(ICAOcode),
    foreign key (Airline) REFERENCES AIRLINES(IDcode)
);
CREATE TABLE  SUITABILITIES(
    Airport char(4),
    Aircraft char(6),
    primary key (Airport, Aircraft),
    foreign key (Airport) REFERENCES AIRPORTS(ICAOcode),
    foreign key (Aircraft) REFERENCES AIRCRAFTS(ICAOcode)
);
CREATE TABLE  WORKINGS(
    Person varchar(25),
    Airline varchar(15),
    primary key (Person, Airline),
    foreign key (Airline) REFERENCES AIRLINES(IDcode),
    foreign key (Person) REFERENCES PERSONNEL(SSN)
);
CREATE TABLE  ABILITATIONS(
    Person varchar(25),
    Aircraft char(6),
    primary key (Person, Aircraft),
    foreign key (Aircraft) REFERENCES AIRCRAFTS(ICAOcode),
    foreign key (Person) REFERENCES PERSONNEL(SSN)
);
CREATE TABLE QUALIFICATIONS(
    Qualification varchar(30) primary key
);
CREATE TABLE QUALIFYING(
    Person varchar(25),
    Qualification varchar(30),
    primary key (Person, Qualification),
    foreign key (Person) REFERENCES PERSONNEL(SSN),
    foreign key (Qualification) REFERENCES QUALIFICATIONS(Qualification)
);
CREATE TABLE HEADQUARTERS(
    Airline varchar(15),
    City varchar(15),
    primary key (Airline, City),
    foreign key (Airline) REFERENCES AIRLINES(IDcode),
    foreign key (City) REFERENCES CITIES(Name)
);
CREATE TABLE ATC_UNITS(
    ICAOregion varchar(15) primary key,
    City varchar(15),
    foreign key (ICAOregion) REFERENCES ICAO_REGIONS(ICAOregion),
    foreign key (City) REFERENCES CITIES(Name)
);
CREATE TABLE CONTACTS(
    Airline varchar(15) primary key,
    Administrative varchar(15) UNIQUE NOT NULL,
    Emergency varchar(15) UNIQUE NOT NULL,
    foreign key (Airline) REFERENCES AIRLINES(IDcode)
);

ALTER TABLE FLIGHTS
ADD CONSTRAINT FK_FLI_PER foreign key (Responsible)
REFERENCES PERSONNEL(SSN);

ALTER TABLE FLIGHTS
ADD CONSTRAINT FK_FLI_ACFT foreign key (Aircraft)
REFERENCES AIRCRAFTS(ICAOcode);

ALTER TABLE FLIGHTS
ADD CONSTRAINT FK_FLI_ALN foreign key (Airline) REFERENCES AIRLINES(Name);

ALTER TABLE FLIGHTS
ADD CONSTRAINT FK_FLI_ALNID foreign key (AirlineID) REFERENCES AIRLINES(IDcode);

ALTER TABLE FLIGHTS
ADD CONSTRAINT FK_FLI_DEP foreign key (Departure)
REFERENCES AIRPORTS(ICAOcode);

ALTER TABLE FLIGHTS
ADD CONSTRAINT FK_FLI_ARR foreign key (Arrival)
REFERENCES AIRPORTS(ICAOcode);

ALTER TABLE FLIGHTS
ADD CONSTRAINT FK_FLI_AUT foreign key (Authorization)
REFERENCES ATC_UNITS(ICAOregion);

ALTER TABLE AIRPORTS
ADD CONSTRAINT FK_APT_ATC foreign key (ATCunit)
REFERENCES ATC_UNITS(ICAOregion)
on delete SET NULL;

ALTER TABLE AIRPORTS 
ADD CONSTRAINT FK_APT_CIT foreign key (City)
REFERENCES CITIES(Name)
on delete SET NULL;
