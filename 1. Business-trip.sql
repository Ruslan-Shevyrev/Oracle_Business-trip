-- test
-- test2
CREATE TABLE TRIP_PURPOSE
   (	"ID" NUMBER NOT NULL , 
	"CREATOR" VARCHAR2(100 ) NOT NULL , 
	"CREATED" DATE NOT NULL , 
	"NAME" VARCHAR2(4000 ) NOT NULL , 
	 CONSTRAINT "TRIP_PURPOSE_PK" PRIMARY KEY ("ID"), 
	 CONSTRAINT "TRIP_PURPOSE_UN" UNIQUE ("NAME")
   );
   
   COMMENT ON TABLE APEX_APP.TRIP_PURPOSE IS 'Цель командировки';
   
   CREATE SEQUENCE SEQ_TRIP_PURPOSE
	 START WITH     1
	 INCREMENT BY   1
	 NOCACHE
	 NOCYCLE;
	 
	 CREATE TRIGGER TRG_TRIP_PURPOSE_I_U
BEFORE INSERT OR UPDATE
ON TRIP_PURPOSE
FOR EACH ROW
BEGIN  
    IF(inserting) THEN
		:NEW.id := SEQ_TRIP_PURPOSE.nextval;
	    :new.created := sysdate;
    	:new.creator := coalesce(v('USER'),sys_context('USERENV','PROXY_USER'),sys_context('USERENV' ,'CURRENT_USER'));
    END IF; 

END TRG_TRIP_PURPOSE_I_U;
/


CREATE TABLE TRIP_JUR_PERS
   (	"ID" NUMBER NOT NULL , 
	"CREATOR" VARCHAR2(100 ) NOT NULL , 
	"CREATED" DATE NOT NULL , 
	"NAME" VARCHAR2(4000 ) NOT NULL , 
	 CONSTRAINT "TRIP_JUR_PERS_PK" PRIMARY KEY ("ID"), 
	 CONSTRAINT "TRIP_JUR_PERS_UN" UNIQUE ("NAME")
   );
   
   COMMENT ON TABLE APEX_APP.TRIP_JUR_PERS IS 'Юридическое лицо для командировок';
   
   CREATE SEQUENCE SEQ_TRIP_JUR_PERS
	 START WITH     1
	 INCREMENT BY   1
	 NOCACHE
	 NOCYCLE;
	 
	 CREATE TRIGGER TRG_TRIP_JUR_PERS_I_U
BEFORE INSERT OR UPDATE
ON TRIP_JUR_PERS
FOR EACH ROW
BEGIN  
    IF(inserting) THEN
		:NEW.id := SEQ_TRIP_JUR_PERS.nextval;
	    :new.created := sysdate;
    	:new.creator := coalesce(v('USER'),sys_context('USERENV','PROXY_USER'),sys_context('USERENV' ,'CURRENT_USER'));
    END IF; 

END TRG_TRIP_PURPOSE_I_U;
/


CREATE TABLE TRIP_TAXI_REASON
   (	"ID" NUMBER NOT NULL , 
	"CREATOR" VARCHAR2(100 ) NOT NULL , 
	"CREATED" DATE NOT NULL , 
	"NAME" VARCHAR2(4000 ) NOT NULL , 
	 CONSTRAINT "TRIP_TAXI_REASON_PK" PRIMARY KEY ("ID"), 
	 CONSTRAINT "TRIP_TAXI_REASON_UN" UNIQUE ("NAME")
   );
   
   COMMENT ON TABLE APEX_APP.TRIP_TAXI_REASON IS 'Причина использования такси';
   
   CREATE SEQUENCE SEQ_TRIP_TAXI_REASON
	 START WITH     1
	 INCREMENT BY   1
	 NOCACHE
	 NOCYCLE;
	 
	 CREATE TRIGGER TRG_TRIP_TAXI_REASON_I_U
BEFORE INSERT OR UPDATE
ON TRIP_TAXI_REASON
FOR EACH ROW
BEGIN  
    IF(inserting) THEN
		:NEW.id := SEQ_TRIP_TAXI_REASON.nextval;
	    :new.created := sysdate;
    	:new.creator := coalesce(v('USER'),sys_context('USERENV','PROXY_USER'),sys_context('USERENV' ,'CURRENT_USER'));
    END IF; 

END TRG_TRIP_TAXI_REASON_I_U;
/

CREATE OR REPLACE FORCE VIEW "PARUS_STR_STORUD_LIST_COMB ("RN", "AGNABBR", "AGNNAME", "AGNIDNUMB", "AGNFAMILYNAME", "AGNFIRSTNAME", "AGNLASTNAME", "BIRTHDAY", "JOB_BEGIN_DATE", "DEPTRN", "PSDEP_CODE", "PSDEP_NAME", "AGNLISTRN", "TYPE_POSITION", "TAB_NUMBER", "MOBILE_PERSONAL", "MOBILE_WORKER") AS 
  SELECT  rn,
            agnabbr,
            agnname,
            agnidnumb,
            agnfamilyname,
            agnfirstname,
            agnlastname,
            birthday,
            JOB_BEGIN_DATE,
            deptrn,
            psdep_code,
            psdep_name,
            agnlistrn,
            type_position,
            tab_number,
            case when length(Mobile_personal) = 10 then
                '+7 ('||substr(Mobile_personal,1,3)||') '||substr(Mobile_personal,4,3)||'-'||substr(Mobile_personal,7,2)||'-'||substr(Mobile_personal,9,2)
            end as Mobile_personal,
            case when length(Mobile_worker) = 10 then     
                '+7 ('||substr(Mobile_worker,1,3)||') '||substr(Mobile_worker,4,3)||'-'||substr(Mobile_worker,7,2)||'-'||substr(Mobile_worker,9,2) 
            end as Mobile_worker
      FROM (SELECT p.rn,
                   a.agnabbr,
                   a.agnname,
                   a.agnidnumb,
                   a.agnfamilyname,
                   a.agnfirstname,
                   a.agnlastname,
                   a.AGNBURN                              AS birthday,
                   p.jobbegin_date                        AS job_begin_date,
                   f.deptrn,
                   c.psdep_code,
                   c.psdep_name,
                   a.rn                                   AS agnlistrn,
                   p.TAB_NUMB                             AS tab_number,
                   UPPER (cl.code)                        AS type_position,
                   COUNT (1) OVER (PARTITION BY p.rn)     AS cnt_position,
                   regexp_replace(regexp_replace(trim(a.telex),'[^0-9]'),'^[78]')  AS Mobile_personal, -- личный мобильный
                   regexp_replace(regexp_replace(trim(a.phone2),'[^0-9]'),'^[78]') AS Mobile_worker    -- рабочий мобильный
              FROM clnpersons@par02500     p,
                   clnpspfm@par02500       f,
                   agnlist@par02500        a,
                   CLNPSDEP@par02500       c,
                   CLNPSPFMTYPES@par02500  cl
             WHERE     p.rn = f.persrn
                   AND SYSDATE BETWEEN f.begeng
                                   AND NVL (
                                           endeng,
                                           TO_DATE ('31.12.2100',
                                                    'dd.mm.yyyy'))
                   AND a.rn = p.pers_agent
                   AND c.rn = f.PSDEPRN
                   AND f.clnpspfmtypes = cl.rn);


CREATE TABLE "TRIP" 
   (	"ID" NUMBER NOT NULL , 
	"DOCUMENT_ID" NUMBER NOT NULL , 
	"CREATOR" VARCHAR2(100 ) NOT NULL , 
	"CREATED" DATE NOT NULL , 
	"TRIP_PURPOSE_ID" NUMBER NOT NULL , 
	"TRIP_JUR_PERS_ID" NUMBER NOT NULL , 
	"COUNTRY" VARCHAR2(300 ), 
	"REGION" VARCHAR2(300 ), 
	"LOCALITY" VARCHAR2(300 ), 
	"TAXI" NUMBER DEFAULT 0 NOT NULL , 
	"TRIP_TAXI_REASON_ID" NUMBER, 
	"DEP_POSITION" VARCHAR2(4000 ), 
	"DEPUTY" VARCHAR2(100 ), 
	"COST_DAY" NUMBER, 
	"COST_DAY_SK" NUMBER, 
	"COST_TRANSIT" NUMBER, 
	"COST_RESIDENCE" NUMBER, 
	"COST_OTHER" NUMBER, 
	"COST_OTHER_NOTE" VARCHAR2(4000 ), 
	"STAFF_DATE" DATE, 
	"ACCOUNTANT_DATE" DATE, 
	"LEADER_SIGN_DATE" DATE, 
	"DEPARTMENT" VARCHAR2(4000 ), 
	"SELF_SIGN" NUMBER DEFAULT 0 NOT NULL , 
	"SELF_SIGN_DATE" DATE, 
	"IS_END" NUMBER DEFAULT null,
	"LEAD_APPROVED_DATE" DATE,
	 CONSTRAINT "BUSINESS_TRIP_PK" PRIMARY KEY ("ID"), 
	 CONSTRAINT "FK_DOCUMENTS" FOREIGN KEY ("DOCUMENT_ID")
	  REFERENCES "APEX_APP"."DOCUMENTS" ("ID") , 
	 CONSTRAINT "FK_TRIP_PURPOSE" FOREIGN KEY ("TRIP_PURPOSE_ID")
	  REFERENCES "APEX_APP"."TRIP_PURPOSE" ("ID") , 
	 CONSTRAINT "FK_TRIP_JUR_PERS" FOREIGN KEY ("TRIP_JUR_PERS_ID")
	  REFERENCES "APEX_APP"."TRIP_JUR_PERS" ("ID"), 
	 CONSTRAINT "FK_TRIP_TAXI_REASON" FOREIGN KEY ("TRIP_TAXI_REASON_ID")
	  REFERENCES "APEX_APP"."TRIP_TAXI_REASON" ("ID") 
   );

COMMENT ON COLUMN APEX_APP.TRIP.COUNTRY IS 'Страна';
COMMENT ON COLUMN APEX_APP.TRIP.REGION IS 'Область';
COMMENT ON COLUMN APEX_APP.TRIP.LOCALITY IS 'Населенный пункт';
COMMENT ON COLUMN APEX_APP.TRIP.TAXI IS 'Использование такси 0- нет; 1 - да';
COMMENT ON COLUMN APEX_APP.TRIP.DEP_POSITION IS 'Должность';
COMMENT ON COLUMN APEX_APP.TRIP.DEPUTY IS 'Заместитель';
COMMENT ON COLUMN APEX_APP.TRIP.COST_DAY IS 'Суточные';
COMMENT ON COLUMN APEX_APP.TRIP.COST_DAY_SK IS 'Суточные Sk';
COMMENT ON COLUMN APEX_APP.TRIP.COST_TRANSIT IS 'Проезд';
COMMENT ON COLUMN APEX_APP.TRIP.COST_RESIDENCE IS 'Проживание';
COMMENT ON COLUMN APEX_APP.TRIP.COST_OTHER IS 'Другие расходы';
COMMENT ON COLUMN APEX_APP.TRIP.COST_OTHER_NOTE IS 'Примечание к другим расходам';
COMMENT ON COLUMN APEX_APP.TRIP.STAFF_DATE IS 'Дата обработки ОК';
COMMENT ON COLUMN APEX_APP.TRIP.ACCOUNTANT_DATE IS 'Дата обработки Сотрудником бухгалтерии';
COMMENT ON COLUMN APEX_APP.TRIP.LEADER_SIGN_DATE IS 'Дата подписания руководителем';
COMMENT ON COLUMN APEX_APP.TRIP.DEPARTMENT IS 'Подразделение';
COMMENT ON COLUMN APEX_APP.TRIP.SELF_SIGN IS 'С приказом ознакомлен 0- нет; 1 - да';
COMMENT ON COLUMN APEX_APP.TRIP.SELF_SIGN_DATE IS 'Дата ознакомления с приказом';
COMMENT ON COLUMN APEX_APP.TRIP.IS_END IS 'Завершена null - процесс не начат; 0- нет; 1 - да';

   CREATE SEQUENCE SEQ_TRIP_ID
	 START WITH     1
	 INCREMENT BY   1
	 NOCACHE
	 NOCYCLE;

CREATE TRIGGER TRG_TRIP_I_U
BEFORE INSERT OR UPDATE
ON TRIP
FOR EACH ROW
BEGIN  
    IF(inserting) THEN
		:NEW.id := SEQ_TRIP_ID.nextval;
	    :new.created := sysdate;
    	:new.creator := coalesce(v('USER'),sys_context('USERENV','PROXY_USER'),sys_context('USERENV' ,'CURRENT_USER'));
    END IF; 

	NULL;
END TRG_TRIP_I_U;
/
