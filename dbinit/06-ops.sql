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
    (0, 'Closed'),
    (1, 'Opened'),
    (2, 'Pending'),
    (3, 'Pending for quotation'),
    (4, 'In transit'),
    (5, 'On destination'),
    (6, 'In warehouse'),
    (7, 'Prealerted'),
    (8, 'Cancelled');

-- Create the op_file table
CREATE TABLE IF NOT EXISTS ops.op_files (
    op_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    -- Op specs
    op_type VARCHAR(100), -- 'maritime', 'air', 'road', 'train', 'other'
    status_id SERIAL REFERENCES ops.op_status(status_id) NOT NULL,
    client_id UUID REFERENCES clients.clients(client_id) NOT NULL,
    -- Carrier
    carrier_id UUID REFERENCES carriers.carriers(carrier_id), 
    -- Locations
    origin_location VARCHAR(100), 
    origin_country_id INTEGER REFERENCES geodata.countries(country_id) ON DELETE SET NULL ON UPDATE CASCADE,
    destination_location VARCHAR(100), 
    destination_country_id INTEGER REFERENCES geodata.countries(country_id) ON DELETE SET NULL ON UPDATE CASCADE,
    -- Schedules
    estimated_time_departure DATE, -- ETD
    actual_time_departure DATE, -- ATD
    estimated_time_arrival DATE, -- ETA
    actual_time_arrival DATE, -- ATA
    -- Cargo properties
    cargo_description TEXT,
    gross_weight_value NUMERIC, -- The value of gross weight
    gross_weight_unit VARCHAR(20), -- e.g., "kg", "lbs"
    volume_value NUMERIC,      -- The value of volume
    volume_unit VARCHAR(20),   -- e.g., "m3", "L", "ft3"
    -- Op Details
    incoterm VARCHAR(40), -- e.g., "FOB", "CIF", "EXW"
    modality VARCHAR(100),
    master_transport_doc VARCHAR(100), -- MBL/MAWB
    house_transport_doc VARCHAR(100), -- HBL/HAWB
    voyage VARCHAR(100),
    -- Users related
    creator_user_id UUID REFERENCES users.users(user_id) ON DELETE SET NULL,
    asignee_user_id UUID REFERENCES users.users(user_id) ON DELETE SET NULL,
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create the Ops file comments table
CREATE TABLE IF NOT EXISTS ops.op_file_comments (
    comment_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    op_id UUID REFERENCES ops.op_files(op_id) ON DELETE CASCADE NOT NULL,
    author_user_id UUID REFERENCES users.users(user_id) ON DELETE SET NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create the Ops file cargo packages table
CREATE TABLE IF NOT EXISTS ops.op_file_cargo_packages (
    package_id SERIAL PRIMARY KEY NOT NULL,
    op_id UUID REFERENCES ops.op_files(op_id) ON DELETE CASCADE NOT NULL,
    quantity NUMERIC,
    units VARCHAR(50) NOT NULL, -- e.g., "boxes", "pallets", "units"
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create a junction table for op_file and partners link (many-to-many relationship)
CREATE TABLE IF NOT EXISTS ops.op_file_partner_link (
    op_id UUID REFERENCES ops.op_files(op_id) ON DELETE CASCADE,
    partner_id UUID REFERENCES partners.partners(partner_id) ON DELETE CASCADE,
    PRIMARY KEY (op_id, partner_id)
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
