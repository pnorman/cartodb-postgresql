set client_min_messages to error;
\set VERBOSITY default

-- See the dice
SELECT setseed(0.5);

CREATE TABLE big(a int);
-- Try the legacy interface
-- See https://github.com/CartoDB/cartodb-postgresql/issues/13
CREATE TRIGGER test_quota BEFORE UPDATE OR INSERT ON big
      EXECUTE PROCEDURE CDB_CheckQuota(1, 1, 'public');
INSERT INTO big VALUES (1); -- allowed, check runs before
INSERT INTO big VALUES (2); -- disallowed, quota exceeds before
SELECT CDB_SetUserQuotaInBytes(0);
SELECT CDB_CartodbfyTable('big');
INSERT INTO big SELECT generate_series(2049,4096);
INSERT INTO big SELECT generate_series(4097,6144);
INSERT INTO big SELECT generate_series(6145,8192);
-- Test for #108: https://github.com/CartoDB/cartodb-postgresql/issues/108
SELECT CDB_UserDataSize();
SELECT cartodb._CDB_total_relation_size('public', 'big');
SELECT cartodb._CDB_total_relation_size('public', 'nonexistent_table_name');
-- END Test for #108
SELECT setseed(0.9);
SELECT CDB_SetUserQuotaInBytes(2);
INSERT INTO big VALUES (8193);
SELECT CDB_SetUserQuotaInBytes(0);
INSERT INTO big VALUES (8194);
DROP TABLE big;
set client_min_messages to NOTICE;
DROP FUNCTION _CDB_UserQuotaInBytes();
