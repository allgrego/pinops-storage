-- init-scripts/02-create-providers-schema.sql

-- Create the providers schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS providers;

-- Set the search path to include the providers schema
SET search_path TO providers, public;

-- Create the international_agents table
CREATE TABLE IF NOT EXISTS international_agents (
    agent_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL -- Or TEXT for potentially longer names
);

-- Create the carriers table
CREATE TABLE IF NOT EXISTS carriers (
    carrier_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    type VARCHAR(255) NOT NULL, -- shipping_line, airline TBD
    name VARCHAR(255) NOT NULL -- Or TEXT for potentially longer names
);

-- Example insert
INSERT INTO international_agents (name) VALUES
    ('XPD RD'),
    ('XPD CL'),
    ('LEGEND LOGISTICS CO, LTD'),
    ('Logiven'),
    ('TITAN');


INSERT INTO carriers (name, type) VALUES
    ('Hapag Lloyd', 'shipping_line'),
    ('ZIM Line', 'shipping_line'),
    ('M7 AEROLINEA', 'airline');
