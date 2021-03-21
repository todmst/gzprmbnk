CREATE TABLE message (
  created TIMESTAMP NOT NULL,
  id VARCHAR(255) NOT NULL,
  int_id CHAR(16) NOT NULL,
  str VARCHAR(1000) NOT NULL,
  address VARCHAR(1000),
  status TINYINT(1),
  CONSTRAINT message_id_pk PRIMARY KEY(id)
);

CREATE INDEX log_address_idx ON message(address);
CREATE INDEX message_created_idx ON message (created);
CREATE INDEX message_int_id_idx ON message (int_id);

CREATE TABLE log (
  created TIMESTAMP NOT NULL,
  int_id CHAR(16) NOT NULL,
  str VARCHAR(1000),
  address VARCHAR(1000)
);

CREATE INDEX log_address_idx ON log(address);
CREATE INDEX message_created_idx ON log (created);
CREATE INDEX message_int_id_idx ON log (int_id);
