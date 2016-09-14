ALTER TABLE users ALTER COLUMN created_at SET NOT NULL;
ALTER TABLE users ALTER COLUMN created_at SET DEFAULT (now() at time zone 'utc');

ALTER TABLE users ALTER COLUMN updated_at SET NOT NULL;
ALTER TABLE users ALTER COLUMN updated_at SET DEFAULT (now() at time zone 'utc');

ALTER TABLE pings ALTER COLUMN created_at SET NOT NULL;
ALTER TABLE pings ALTER COLUMN created_at SET DEFAULT (now() at time zone 'utc');

ALTER TABLE pings ALTER COLUMN updated_at SET NOT NULL;
ALTER TABLE pings ALTER COLUMN updated_at SET DEFAULT (now() at time zone 'utc');
