-- Complete Database Schema with Invitation System
-- Workflow Manager - Full Database Setup
-- Date: 2024-01-XX

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create enums
DO $$ BEGIN
    CREATE TYPE user_role AS ENUM ('admin', 'user');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE user_status AS ENUM ('pending', 'active', 'inactive');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE node_type AS ENUM ('start', 'process', 'decision', 'end');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE node_status AS ENUM ('not_started', 'in_progress', 'completed');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE task_status AS ENUM ('pending', 'in_progress', 'completed');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE file_type AS ENUM ('image', 'audio', 'document', 'other');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE invitation_status AS ENUM ('pending', 'approved', 'rejected', 'revoked');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Create users table
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL,
    role user_role DEFAULT 'user',
    status user_status DEFAULT 'pending',
    avatar VARCHAR(255),
    invited_by VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create workflows table
CREATE TABLE IF NOT EXISTS workflows (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    metadata JSONB,
    is_public BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_by_id UUID NOT NULL,
    invite_code VARCHAR(20) UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_workflows_created_by_id FOREIGN KEY (created_by_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Create nodes table
CREATE TABLE IF NOT EXISTS nodes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    type node_type NOT NULL,
    status node_status DEFAULT 'not_started',
    progress_percentage INTEGER DEFAULT 0,
    position JSONB NOT NULL,
    style JSONB,
    notes TEXT,
    workflow_id UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_nodes_workflow_id FOREIGN KEY (workflow_id) REFERENCES workflows(id) ON DELETE CASCADE
);

-- Create connections table
CREATE TABLE IF NOT EXISTS connections (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    source_node_id UUID NOT NULL,
    target_node_id UUID NOT NULL,
    label VARCHAR(255),
    style JSONB,
    workflow_id UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_connections_source_node_id FOREIGN KEY (source_node_id) REFERENCES nodes(id) ON DELETE CASCADE,
    CONSTRAINT fk_connections_target_node_id FOREIGN KEY (target_node_id) REFERENCES nodes(id) ON DELETE CASCADE,
    CONSTRAINT fk_connections_workflow_id FOREIGN KEY (workflow_id) REFERENCES workflows(id) ON DELETE CASCADE
);

-- Create tasks table
CREATE TABLE IF NOT EXISTS tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    status task_status DEFAULT 'pending',
    due_date TIMESTAMP WITH TIME ZONE,
    progress_percentage INTEGER DEFAULT 0,
    node_id UUID NOT NULL,
    assigned_to_id UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_tasks_node_id FOREIGN KEY (node_id) REFERENCES nodes(id) ON DELETE CASCADE,
    CONSTRAINT fk_tasks_assigned_to_id FOREIGN KEY (assigned_to_id) REFERENCES users(id) ON DELETE SET NULL
);

-- Create files table
CREATE TABLE IF NOT EXISTS files (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    filename VARCHAR(255) NOT NULL,
    original_name VARCHAR(255) NOT NULL,
    mime_type VARCHAR(100) NOT NULL,
    size INTEGER NOT NULL,
    path VARCHAR(500) NOT NULL,
    type file_type NOT NULL,
    node_id UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_files_node_id FOREIGN KEY (node_id) REFERENCES nodes(id) ON DELETE CASCADE
);

-- Create workflow_invitations table
CREATE TABLE IF NOT EXISTS workflow_invitations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    invite_code VARCHAR(20) NOT NULL,
    workflow_id UUID NOT NULL,
    invited_by_id UUID NOT NULL,
    invited_user_id UUID,
    status invitation_status DEFAULT 'pending',
    message TEXT,
    responded_at TIMESTAMP WITH TIME ZONE,
    is_used BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_workflow_invitations_workflow_id FOREIGN KEY (workflow_id) REFERENCES workflows(id) ON DELETE CASCADE,
    CONSTRAINT fk_workflow_invitations_invited_by_id FOREIGN KEY (invited_by_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_workflow_invitations_invited_user_id FOREIGN KEY (invited_user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT unique_pending_invitation UNIQUE (workflow_id, invited_user_id, status) DEFERRABLE INITIALLY DEFERRED
);

-- Create indexes for performance
-- Users indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_status ON users(status);

-- Workflows indexes
CREATE INDEX idx_workflows_created_by_id ON workflows(created_by_id);
CREATE INDEX idx_workflows_invite_code ON workflows(invite_code);
CREATE INDEX idx_workflows_is_public ON workflows(is_public);
CREATE INDEX idx_workflows_is_active ON workflows(is_active);

-- Nodes indexes
CREATE INDEX idx_nodes_workflow_id ON nodes(workflow_id);
CREATE INDEX idx_nodes_type ON nodes(type);
CREATE INDEX idx_nodes_status ON nodes(status);

-- Connections indexes
CREATE INDEX idx_connections_workflow_id ON connections(workflow_id);
CREATE INDEX idx_connections_source_node_id ON connections(source_node_id);
CREATE INDEX idx_connections_target_node_id ON connections(target_node_id);

-- Tasks indexes
CREATE INDEX idx_tasks_node_id ON tasks(node_id);
CREATE INDEX idx_tasks_assigned_to_id ON tasks(assigned_to_id);
CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_tasks_due_date ON tasks(due_date);

-- Files indexes
CREATE INDEX idx_files_node_id ON files(node_id);
CREATE INDEX idx_files_type ON files(type);

-- Workflow Invitations indexes
CREATE INDEX idx_workflow_invitations_invite_code ON workflow_invitations(invite_code);
CREATE INDEX idx_workflow_invitations_workflow_id ON workflow_invitations(workflow_id);
CREATE INDEX idx_workflow_invitations_invited_by_id ON workflow_invitations(invited_by_id);
CREATE INDEX idx_workflow_invitations_invited_user_id ON workflow_invitations(invited_user_id);
CREATE INDEX idx_workflow_invitations_status ON workflow_invitations(status);
CREATE INDEX idx_workflow_invitations_created_at ON workflow_invitations(created_at);
CREATE INDEX idx_workflow_invitations_workflow_status ON workflow_invitations(workflow_id, status);
CREATE INDEX idx_workflow_invitations_user_status ON workflow_invitations(invited_user_id, status);

-- Create triggers for updated_at columns
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply triggers
CREATE TRIGGER trigger_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_workflows_updated_at BEFORE UPDATE ON workflows FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_nodes_updated_at BEFORE UPDATE ON nodes FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_tasks_updated_at BEFORE UPDATE ON tasks FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER trigger_workflow_invitations_updated_at BEFORE UPDATE ON workflow_invitations FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();