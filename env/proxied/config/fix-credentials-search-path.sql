CREATE ROLE credentials_user WITH LOGIN PASSWORD 'Str0ngP@ss!';
ALTER ROLE credentials_user SET search_path TO credentials;
GRANT ALL ON SCHEMA credentials TO credentials_user;
GRANT ALL ON ALL TABLES IN SCHEMA credentials TO credentials_user;
GRANT ALL ON ALL SEQUENCES IN SCHEMA credentials TO credentials_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA credentials GRANT ALL ON TABLES TO credentials_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA credentials GRANT ALL ON SEQUENCES TO credentials_user;
