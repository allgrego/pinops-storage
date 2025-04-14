-- Create the carriers schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS carriers;

-- Set the search path to include the carriers schema
SET search_path TO carriers, public;

-- Create the op_status table
CREATE TABLE IF NOT EXISTS carriers.carrier_types (
    carrier_type_id VARCHAR(50) PRIMARY KEY NOT NULL,
    name VARCHAR(50) UNIQUE NOT NULL,
    description VARCHAR(255)
);

-- Insert default types
INSERT INTO carriers.carrier_types (carrier_type_id, name, description) VALUES
    ('shipping_line', 'Shipping Line', NULL),
    ('airline', 'Airlilne', NULL),
    ('insurer', 'Cargo insurance company ', NULL),
    ('road_freight_local', 'Local Trucking Company', NULL),
    ('road_freight_international', 'International Trucking Company', NULL),
    ('courier', 'Courier', NULL),
    ('railway_company', 'Railway Company', NULL),
    ('other', 'Other', 'Other types of carriers');


-- Create the carriers table
CREATE TABLE IF NOT EXISTS carriers.carriers (
    carrier_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    carrier_type_id VARCHAR(50) REFERENCES carriers.carrier_types(carrier_type_id) ON DELETE SET NULL,
    name VARCHAR(255) UNIQUE NOT NULL, -- Or TEXT for potentially longer names
    tax_id VARCHAR(100) UNIQUE,
    disabled BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create the carriers contacts table
CREATE TABLE IF NOT EXISTS carriers.carrier_contacts (
    carrier_contact_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    carrier_id UUID REFERENCES carriers.carriers(carrier_id) ON DELETE CASCADE,
    name VARCHAR(255) UNIQUE NOT NULL,
    position VARCHAR(255),
    email VARCHAR(255),
    mobile VARCHAR(100),
    phone VARCHAR(100),
    disabled BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);


-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION carriers.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically update updated_at on carriers
CREATE OR REPLACE TRIGGER update_carrier_modtime
BEFORE UPDATE ON carriers.carriers
FOR EACH ROW
EXECUTE FUNCTION carriers.update_updated_at_column();

-- Trigger to automatically update updated_at on carriers contacts
CREATE OR REPLACE TRIGGER update_carrier_contact_modtime
BEFORE UPDATE ON carriers.carrier_contacts
FOR EACH ROW
EXECUTE FUNCTION carriers.update_updated_at_column();
