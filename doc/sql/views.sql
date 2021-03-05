-- sql views for freeradius

CREATE OR REPLACE VIEW radcheck_alt AS SELECT
  id,
  username,
  attribute AS attr,
  op,
  value FROM radcheck;

CREATE OR REPLACE VIEW radreply_alt AS SELECT
  id,
  username,
  attribute AS attr,
  op,
  value FROM radreply;

CREATE OR REPLACE VIEW radgroupcheck_alt AS SELECT
  id,
  groupname,
  attribute AS attr,
  op,
  value FROM radgroupcheck;

CREATE OR REPLACE VIEW radgroupreply_alt AS SELECT
  id,
  groupname,
  attribute AS attr,
  op,
  value FROM radgroupreply;

