-- Create the partners schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS partners;

-- Set the search path to include the partners schema
SET search_path TO partners, public;

-- Create the op_status table
CREATE TABLE IF NOT EXISTS partners.partner_types (
    partner_type_id VARCHAR(50) PRIMARY KEY NOT NULL,
    name VARCHAR(50) UNIQUE NOT NULL,
    description VARCHAR(255)
);

-- Insert default types
INSERT INTO partners.partner_types (partner_type_id, name, description) VALUES
    ('logistics_operator', 'International logistics operator', 'Freight forwarders, brokers, etc.'),
    ('port_agent', 'Port agent', NULL),
    ('insurer', 'Cargo insurance company ', NULL),
    ('coloader', 'Co-loader', NULL),
    ('customs_broker', 'Customs broker', NULL),
    ('warehouse', 'Warehouse', 'Warehouses and storage facilities'),
    ('other', 'Other', 'Other types of partners');


-- Create the partners table
CREATE TABLE IF NOT EXISTS partners.partners (
    partner_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    partner_type_id VARCHAR(50) REFERENCES partners.partner_types(partner_type_id) ON DELETE SET NULL,
    name VARCHAR(255) UNIQUE NOT NULL, -- Or TEXT for potentially longer names
    tax_id VARCHAR(100) UNIQUE,
    webpage VARCHAR(255),
    country_id INTEGER REFERENCES geodata.countries(country_id) ON DELETE SET NULL,
    disabled BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create the partners contacts table
CREATE TABLE IF NOT EXISTS partners.partner_contacts (
    partner_contact_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    partner_id UUID REFERENCES partners.partners(partner_id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    position VARCHAR(255),
    email VARCHAR(255),
    mobile VARCHAR(100),
    phone VARCHAR(100),
    disabled BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);


-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION partners.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically update updated_at on partners
CREATE OR REPLACE TRIGGER update_partner_modtime
BEFORE UPDATE ON partners.partners
FOR EACH ROW
EXECUTE FUNCTION partners.update_updated_at_column();

-- Trigger to automatically update updated_at on partners contacts
CREATE OR REPLACE TRIGGER update_partner_contact_modtime
BEFORE UPDATE ON partners.partner_contacts
FOR EACH ROW
EXECUTE FUNCTION partners.update_updated_at_column();
