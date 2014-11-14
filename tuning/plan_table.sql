DROP TABLE plan_table;

CREATE TABLE PLAN_TABLE (
  STATEMENT_ID                    VARCHAR2(30),
  TIMESTAMP                       DATE,
  REMARKS                         VARCHAR2(80),
  OPERATION                       VARCHAR2(30),
  OPTIONS                         VARCHAR2(30),
  OBJECT_NODE                     VARCHAR2(128),
  OBJECT_OWNER                    VARCHAR2(30),
  OBJECT_NAME                     VARCHAR2(30),
  OBJECT_INSTANCE                 NUMBER(38),
  OBJECT_TYPE                     VARCHAR2(30),
  OPTIMIZER                       VARCHAR2(255),
  SEARCH_COLUMNS                  NUMBER,
  ID                              NUMBER(38),
  PARENT_ID                       NUMBER(38),
  POSITION                        NUMBER(38),
  COST                            NUMBER(38),
  CARDINALITY                     NUMBER(38),
  BYTES                           NUMBER(38),
  OTHER_TAG                       VARCHAR2(255),
  PARTITION_START                 VARCHAR2(255),
  PARTITION_STOP                  VARCHAR2(255),
  PARTITION_ID                    NUMBER(38),
  OTHER                           LONG,
  DISTRIBUTION                    VARCHAR2(30)
        ,cpu_cost           numeric
        ,io_cost            numeric
        ,temp_space         numeric
        ,access_predicates  varchar2(4000)
        ,filter_predicates  varchar2(4000)
        ,projection         varchar2(4000)
        ,time               numeric
        ,qblock_name        varchar2(30)
)
/
