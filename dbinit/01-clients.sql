-- Create the clients schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS clients;

-- Set the search path to include the clients schema
SET search_path TO clients, public;

-- Create the clients table
CREATE TABLE IF NOT EXISTS clients (
    client_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) UNIQUE NOT NULL -- Or TEXT for potentially longer names
);

-- Example insert
INSERT INTO clients (name) VALUES
    ('Distribuidora La Rápida, C.A'),
    ('SNC Energía, C.A.'),
    ('Tecno Center C.A'),
    ('Comercializadora Alaska'),
    ('Jabonería Caracas, C.A'),
    ('Antony Supply AFG, C.A');