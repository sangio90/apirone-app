CREATE TABLE public.roles_permissions (
    role_permission_id SERIAL PRIMARY KEY,
    role_id VARCHAR(50),
    permission_id VARCHAR(50),
    created_at timestamp DEFAULT now(),
    CONSTRAINT role_id_permission_id_uk UNIQUE (role_id, permission_id)
);

ALTER TABLE roles_permissions owner TO apiruser;