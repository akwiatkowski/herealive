ALTER TABLE users ADD COLUMN public_handle text;
CREATE EXTENSION pgcrypto;
UPDATE users SET public_handle = md5(random()::text);
