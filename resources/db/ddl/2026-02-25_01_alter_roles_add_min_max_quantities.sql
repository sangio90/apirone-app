ALTER TABLE membership.roles
ADD COLUMN min_quantity INTEGER default 1;

ALTER TABLE membership.roles
ADD COLUMN max_quantity INTEGER default 1;