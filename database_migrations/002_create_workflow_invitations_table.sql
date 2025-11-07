-- Migration: Create workflow_invitations table
-- Date: 2024-01-XX
-- Description: Creates table for managing workflow invitation system

-- Create enum for invitation status
DO $$ BEGIN
    CREATE TYPE invitation_status AS ENUM ('pending', 'approved', 'rejected', 'revoked');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Create workflow_invitations table
CREATE TABLE IF NOT EXISTS workflow_invitations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
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

    -- Foreign key constraints
    CONSTRAINT fk_workflow_invitations_workflow_id
        FOREIGN KEY (workflow_id) REFERENCES workflows(id) ON DELETE CASCADE,
    CONSTRAINT fk_workflow_invitations_invited_by_id
        FOREIGN KEY (invited_by_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_workflow_invitations_invited_user_id
        FOREIGN KEY (invited_user_id) REFERENCES users(id) ON DELETE CASCADE,

    -- Unique constraint to prevent duplicate pending invitations
    CONSTRAINT unique_pending_invitation
        UNIQUE (workflow_id, invited_user_id, status)
        DEFERRABLE INITIALLY DEFERRED
);

-- Create indexes for performance
CREATE INDEX idx_workflow_invitations_invite_code ON workflow_invitations(invite_code);
CREATE INDEX idx_workflow_invitations_workflow_id ON workflow_invitations(workflow_id);
CREATE INDEX idx_workflow_invitations_invited_by_id ON workflow_invitations(invited_by_id);
CREATE INDEX idx_workflow_invitations_invited_user_id ON workflow_invitations(invited_user_id);
CREATE INDEX idx_workflow_invitations_status ON workflow_invitations(status);
CREATE INDEX idx_workflow_invitations_created_at ON workflow_invitations(created_at);

-- Composite index for common queries
CREATE INDEX idx_workflow_invitations_workflow_status ON workflow_invitations(workflow_id, status);
CREATE INDEX idx_workflow_invitations_user_status ON workflow_invitations(invited_user_id, status);

-- Add comments
COMMENT ON TABLE workflow_invitations IS 'Manages workflow invitation requests and approvals';
COMMENT ON COLUMN workflow_invitations.invite_code IS 'The invite code used to request access';
COMMENT ON COLUMN workflow_invitations.workflow_id IS 'Reference to the workflow being requested';
COMMENT ON COLUMN workflow_invitations.invited_by_id IS 'User who owns the workflow (approver)';
COMMENT ON COLUMN workflow_invitations.invited_user_id IS 'User requesting access to workflow';
COMMENT ON COLUMN workflow_invitations.status IS 'Current status of the invitation request';
COMMENT ON COLUMN workflow_invitations.message IS 'Optional message from requester';
COMMENT ON COLUMN workflow_invitations.responded_at IS 'When the invitation was approved/rejected';
COMMENT ON COLUMN workflow_invitations.is_used IS 'Whether the invitation has been used/activated';

-- Create trigger for updated_at
CREATE OR REPLACE FUNCTION update_workflow_invitations_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER trigger_workflow_invitations_updated_at
    BEFORE UPDATE ON workflow_invitations
    FOR EACH ROW
    EXECUTE FUNCTION update_workflow_invitations_updated_at();