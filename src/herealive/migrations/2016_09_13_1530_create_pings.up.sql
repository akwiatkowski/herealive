create table pings
  (
    id serial,
    user_id integer REFERENCES users,
    created_at timestamp,
    updated_at timestamp,
    lat float,
    lon float,
    manually boolean DEFAULT false NOT NULL,

    primary key(id)
  )
;
