-- init-scripts/03-create-ops-schema.sql

-- Create the ops schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS ops;

-- Set the search path to include the ops schema
SET search_path TO ops, public; -- Include providers schema for foreign keys

-- Create the op_status table
CREATE TABLE IF NOT EXISTS ops.op_status (
    status_id SERIAL PRIMARY KEY NOT NULL,
    status_name VARCHAR(50) UNIQUE NOT NULL
);

-- Insert initial statuses
INSERT INTO ops.op_status (status_id, status_name) VALUES
    (1, 'Opened'),
    (2, 'In transit'),
    (3, 'On destination'),
    (4, 'In warehouse'),
    (5, 'Prealerted'),
    (6, 'Closed');

-- Create the op_file table
CREATE TABLE IF NOT EXISTS ops.op_files (
    op_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    -- Op specs
    op_type VARCHAR(100), -- 'maritime', 'air', 'road', 'train'
    status_id SERIAL REFERENCES ops.op_status(status_id) NOT NULL,
    client_id UUID REFERENCES clients.clients(client_id) NOT NULL,
    -- Providers
    carrier_id UUID REFERENCES providers.carriers(carrier_id), -- Assuming you have a carriers table
    -- Locations
    origin_location VARCHAR(100), 
    origin_country VARCHAR(100), 
    destination_location VARCHAR(100), 
    destination_country VARCHAR(100), 
    -- Schedules
    estimated_time_departure DATE, -- ETD
    actual_time_departure DATE, -- ATD
    estimated_time_arrival DATE, -- ETA
    actual_time_arrival DATE, -- ATA
    -- Cargo properties
    cargo_description TEXT,
    units_quantity NUMERIC, -- The number of units
    units_type VARCHAR(50),  -- e.g., "boxes", "pallets", "units"
    gross_weight_value NUMERIC, -- The value of gross weight
    gross_weight_unit VARCHAR(20), -- e.g., "kg", "lbs"
    volume_value NUMERIC,      -- The value of volume
    volume_unit VARCHAR(20),   -- e.g., "m3", "L", "ft3"
    -- Op Details
    incoterm VARCHAR(16),
    modality VARCHAR(100),
    master_transport_doc VARCHAR(100), -- MBL/MAWB
    house_transport_doc VARCHAR(100), -- HBL/HAWB
    voyage VARCHAR(100),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION ops.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically update updated_at
CREATE OR REPLACE TRIGGER update_op_file_modtime
BEFORE UPDATE ON ops.op_files
FOR EACH ROW
EXECUTE FUNCTION ops.update_updated_at_column();

-- Create the Ops file comments table
CREATE TABLE IF NOT EXISTS ops.op_file_comments (
    comment_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    op_id UUID REFERENCES ops.op_files(op_id) ON DELETE CASCADE NOT NULL,
    author VARCHAR(100),
    content TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create a junction table for op_file and international_agents link (many-to-many relationship)
CREATE TABLE IF NOT EXISTS ops.op_file_agent_link (
    op_id UUID REFERENCES ops.op_files(op_id) ON DELETE CASCADE,
    agent_id UUID REFERENCES providers.international_agents(agent_id) ON DELETE CASCADE,
    PRIMARY KEY (op_id, agent_id)
);

