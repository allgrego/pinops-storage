-- Create the clients schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS clients;

-- Set the search path to include the clients schema
SET search_path TO clients, public;

-- Create the clients table
CREATE TABLE IF NOT EXISTS clients.clients (
    client_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) UNIQUE NOT NULL,    
    tax_id VARCHAR(100) UNIQUE,
    address TEXT,
    contact_name VARCHAR(255),
    contact_email VARCHAR(255),
    contact_phone VARCHAR(100),
    disabled BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
