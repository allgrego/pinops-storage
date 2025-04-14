-- Create the users schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS users;

-- Set the search path to include the users schema
SET search_path TO users, public;

-- Create the users roles table
CREATE TABLE IF NOT EXISTS users.roles (
    role_id VARCHAR(50) PRIMARY KEY NOT NULL,
    role_name VARCHAR(255) UNIQUE NOT NULL
);

-- Insert default user roles
INSERT INTO users.roles (role_id, role_name) VALUES
    ('admin', 'Admin'),
    ('ops_manager', 'Operations Manager'),
    ('traffic_operator', 'Traffic operator'),
    ('seller', 'Seller');

-- Create the users table
CREATE TABLE IF NOT EXISTS users.users (
    user_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    role_id VARCHAR(50) REFERENCES users.roles(role_id) ON DELETE SET NULL,
    hashed_password VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    disabled BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Insert default users
INSERT INTO users.users (name, role_id, hashed_password, email) VALUES
    ('The Admin', 'admin', '$2y$10$9jYCtDJqRV/vYDnT3kIJHOlxmtdaL2Rcz2nw0A2vXlFq4sP3ADDFW', 'admin@pinopslogistics.com'),
    ('Ops Manager User', 'ops_manager', '$2y$10$9jYCtDJqRV/vYDnT3kIJHOlxmtdaL2Rcz2nw0A2vXlFq4sP3ADDFW', 'ops_manager@pinopslogistics.com'),
    ('Traffic Operator User', 'traffic_operator', '$2y$10$9jYCtDJqRV/vYDnT3kIJHOlxmtdaL2Rcz2nw0A2vXlFq4sP3ADDFW', 'traffic_operator@pinopslogistics.com'),
    ('Seller User', 'seller', '$2y$10$9jYCtDJqRV/vYDnT3kIJHOlxmtdaL2Rcz2nw0A2vXlFq4sP3ADDFW', 'seller@pinopslogistics.com');