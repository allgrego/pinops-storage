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
    ('The Admin', 'admin', '286ccf02f387c6e1cb84892c08341e69:cf1fc3ef5ad70c3c113f1145b6986d9a915695708bb3680683fc2de4a024b722', 'admin@pinopslogistics.com'),
    ('Ops Manager User', 'ops_manager', '286ccf02f387c6e1cb84892c08341e69:cf1fc3ef5ad70c3c113f1145b6986d9a915695708bb3680683fc2de4a024b722', 'ops_manager@pinopslogistics.com'),
    ('Traffic Operator User', 'traffic_operator', '286ccf02f387c6e1cb84892c08341e69:cf1fc3ef5ad70c3c113f1145b6986d9a915695708bb3680683fc2de4a024b722', 'traffic_operator@pinopslogistics.com'),
    ('Seller User', 'seller', '286ccf02f387c6e1cb84892c08341e69:cf1fc3ef5ad70c3c113f1145b6986d9a915695708bb3680683fc2de4a024b722', 'seller@pinopslogistics.com');