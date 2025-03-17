-- init-scripts/00-config.sql

-- Enable the uuid-ossp extension in the public schema
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" SCHEMA public;