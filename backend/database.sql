-- Workflow Manager Database Schema
-- PostgreSQL Database Creation Script

-- Create database (run this separately as superuser)
-- CREATE DATABASE workflow_manager;
-- CREATE USER workflow_user WITH PASSWORD 'workflow_pass';
-- GRANT ALL PRIVILEGES ON DATABASE workflow_manager TO workflow_user;

-- Connect to workflow_manager database before running the rest

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'user' CHECK (role IN ('admin', 'user')),
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'active', 'inactive')),
    avatar TEXT,
    invited_by UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (invited_by) REFERENCES users(id) ON DELETE SET NULL
);

-- Workflows table
CREATE TABLE workflows (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    metadata JSONB,
    is_public BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_by_id UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (created_by_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Nodes table
CREATE TABLE nodes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    type VARCHAR(20) NOT NULL DEFAULT 'process' CHECK (type IN ('start', 'process', 'decision', 'end')),
    status VARCHAR(20) NOT NULL DEFAULT 'not_started' CHECK (status IN ('not_started', 'in_progress', 'completed')),
    progress_percentage DECIMAL(5,2) DEFAULT 0 CHECK (progress_percentage >= 0 AND progress_percentage <= 100),
    position JSONB,
    style JSONB,
    notes TEXT,
    workflow_id UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (workflow_id) REFERENCES workflows(id) ON DELETE CASCADE
);

-- Connections table
CREATE TABLE connections (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    source_node_id UUID NOT NULL,
    target_node_id UUID NOT NULL,
    label VARCHAR(255),
    style JSONB,
    workflow_id UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (source_node_id) REFERENCES nodes(id) ON DELETE CASCADE,
    FOREIGN KEY (target_node_id) REFERENCES nodes(id) ON DELETE CASCADE,
    FOREIGN KEY (workflow_id) REFERENCES workflows(id) ON DELETE CASCADE,

    -- Prevent self-referencing connections
    CHECK (source_node_id != target_node_id)
);

-- Tasks table
CREATE TABLE tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed')),
    due_date TIMESTAMP WITH TIME ZONE,
    progress_percentage DECIMAL(5,2) DEFAULT 0 CHECK (progress_percentage >= 0 AND progress_percentage <= 100),
    node_id UUID NOT NULL,
    assigned_to_id UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (node_id) REFERENCES nodes(id) ON DELETE CASCADE,
    FOREIGN KEY (assigned_to_id) REFERENCES users(id) ON DELETE SET NULL
);

-- Files table
CREATE TABLE files (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    filename VARCHAR(255) NOT NULL,
    original_name VARCHAR(255) NOT NULL,
    mime_type VARCHAR(100) NOT NULL,
    size INTEGER NOT NULL,
    path TEXT NOT NULL,
    type VARCHAR(20) NOT NULL DEFAULT 'other' CHECK (type IN ('image', 'audio', 'document', 'other')),
    node_id UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (node_id) REFERENCES nodes(id) ON DELETE CASCADE
);

-- Indexes for better performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_workflows_created_by ON workflows(created_by_id);
CREATE INDEX idx_workflows_active ON workflows(is_active);
CREATE INDEX idx_nodes_workflow ON nodes(workflow_id);
CREATE INDEX idx_nodes_type ON nodes(type);
CREATE INDEX idx_nodes_status ON nodes(status);
CREATE INDEX idx_connections_workflow ON connections(workflow_id);
CREATE INDEX idx_connections_source ON connections(source_node_id);
CREATE INDEX idx_connections_target ON connections(target_node_id);
CREATE INDEX idx_tasks_node ON tasks(node_id);
CREATE INDEX idx_tasks_assigned_to ON tasks(assigned_to_id);
CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_files_node ON files(node_id);
CREATE INDEX idx_files_type ON files(type);

-- Update triggers for updated_at timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_workflows_updated_at BEFORE UPDATE ON workflows
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_nodes_updated_at BEFORE UPDATE ON nodes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tasks_updated_at BEFORE UPDATE ON tasks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Sample data (optional)
-- Insert a test admin user
INSERT INTO users (email, name, password, role, status) VALUES
('admin@example.com', 'Admin User', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj0.X.PzKjHi', 'admin', 'active');
-- Password is 'password123'

-- Insert a test regular user
INSERT INTO users (email, name, password, role, status) VALUES
('user@example.com', 'Test User', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj0.X.PzKjHi', 'user', 'active');
-- Password is 'password123'

-- Insert a sample workflow
INSERT INTO workflows (name, description, created_by_id) VALUES
('Sample Workflow', 'A sample workflow for testing', (SELECT id FROM users WHERE email = 'admin@example.com'));

-- Insert sample nodes
INSERT INTO nodes (name, description, type, position, workflow_id) VALUES
('Start', 'Workflow start point', 'start', '{"x": 100, "y": 100}', (SELECT id FROM workflows WHERE name = 'Sample Workflow')),
('Process Data', 'Process the input data', 'process', '{"x": 300, "y": 100}', (SELECT id FROM workflows WHERE name = 'Sample Workflow')),
('Review', 'Review the results', 'decision', '{"x": 500, "y": 100}', (SELECT id FROM workflows WHERE name = 'Sample Workflow')),
('End', 'Workflow end point', 'end', '{"x": 700, "y": 100}', (SELECT id FROM workflows WHERE name = 'Sample Workflow'));

-- Insert sample connections
INSERT INTO connections (source_node_id, target_node_id, workflow_id) VALUES
((SELECT id FROM nodes WHERE name = 'Start'), (SELECT id FROM nodes WHERE name = 'Process Data'), (SELECT id FROM workflows WHERE name = 'Sample Workflow')),
((SELECT id FROM nodes WHERE name = 'Process Data'), (SELECT id FROM nodes WHERE name = 'Review'), (SELECT id FROM workflows WHERE name = 'Sample Workflow')),
((SELECT id FROM nodes WHERE name = 'Review'), (SELECT id FROM nodes WHERE name = 'End'), (SELECT id FROM workflows WHERE name = 'Sample Workflow'));

-- Insert sample tasks
INSERT INTO tasks (title, description, node_id, assigned_to_id) VALUES
('Setup Environment', 'Setup the development environment', (SELECT id FROM nodes WHERE name = 'Process Data'), (SELECT id FROM users WHERE email = 'user@example.com')),
('Test Implementation', 'Test the implemented solution', (SELECT id FROM nodes WHERE name = 'Review'), (SELECT id FROM users WHERE email = 'user@example.com'));

-- Views for easier querying
CREATE VIEW workflow_summary AS
SELECT
    w.id,
    w.name,
    w.description,
    w.is_public,
    w.is_active,
    w.created_at,
    w.updated_at,
    u.name as created_by_name,
    u.email as created_by_email,
    COUNT(DISTINCT n.id) as node_count,
    COUNT(DISTINCT c.id) as connection_count,
    COUNT(DISTINCT t.id) as task_count
FROM workflows w
LEFT JOIN users u ON w.created_by_id = u.id
LEFT JOIN nodes n ON w.id = n.workflow_id
LEFT JOIN connections c ON w.id = c.workflow_id
LEFT JOIN tasks t ON n.id = t.node_id
GROUP BY w.id, u.name, u.email;

-- Node progress view
CREATE VIEW node_progress AS
SELECT
    n.id,
    n.name,
    n.type,
    n.status,
    n.workflow_id,
    COUNT(t.id) as total_tasks,
    COUNT(CASE WHEN t.status = 'completed' THEN 1 END) as completed_tasks,
    CASE
        WHEN COUNT(t.id) = 0 THEN 0
        ELSE ROUND((COUNT(CASE WHEN t.status = 'completed' THEN 1 END) * 100.0 / COUNT(t.id)), 2)
    END as calculated_progress
FROM nodes n
LEFT JOIN tasks t ON n.id = t.node_id
GROUP BY n.id, n.name, n.type, n.status, n.workflow_id;

-- Database information
COMMENT ON DATABASE workflow_manager IS 'Workflow Manager Application Database';
COMMENT ON TABLE users IS 'User accounts and authentication information';
COMMENT ON TABLE workflows IS 'Workflow definitions and metadata';
COMMENT ON TABLE nodes IS 'Individual nodes within workflows';
COMMENT ON TABLE connections IS 'Connections between workflow nodes';
COMMENT ON TABLE tasks IS 'Tasks associated with workflow nodes';
COMMENT ON TABLE files IS 'File attachments for workflow nodes';