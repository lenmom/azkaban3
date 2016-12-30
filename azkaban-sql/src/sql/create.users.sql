CREATE TABLE users (
	name VARCHAR(64) NOT NULL,
	password VARCHAR(64) NOT NULL,
	roles VARCHAR(128) DEFAULT NULL,
	groups VARCHAR(128) DEFAULT NULL,
	email VARCHAR(64) DEFAULT NULL,
	proxy VARCHAR(128) DEFAULT NULL,
	PRIMARY KEY (name)
);

CREATE INDEX user_key ON users(name, password);