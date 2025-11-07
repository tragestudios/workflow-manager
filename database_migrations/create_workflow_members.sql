-- Create workflow_members table for tracking approved users

CREATE TABLE IF NOT EXISTS workflow_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workflow_id UUID NOT NULL,
    user_id UUID NOT NULL,
    role VARCHAR(20) DEFAULT 'member', -- 'owner', 'admin', 'member'
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    -- Foreign key constraints
    CONSTRAINT fk_workflow_members_workflow_id
        FOREIGN KEY (workflow_id) REFERENCES workflows(id) ON DELETE CASCADE,
    CONSTRAINT fk_workflow_members_user_id
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,

    -- Unique constraint to prevent duplicate memberships
    CONSTRAINT unique_workflow_member
        UNIQUE (workflow_id, user_id)
);

-- Create indexes for performance
CREATE INDEX idx_workflow_members_workflow_id ON workflow_members(workflow_id);
CREATE INDEX idx_workflow_members_user_id ON workflow_members(user_id);
CREATE INDEX idx_workflow_members_role ON workflow_members(role);

-- Add comments
COMMENT ON TABLE workflow_members IS 'Tracks users who have access to workflows';
COMMENT ON COLUMN workflow_members.role IS 'User role in the workflow: owner, admin, member';

-- Insert existing workflow owners as members
INSERT INTO workflow_members (workflow_id, user_id, role)
SELECT id, created_by_id, 'owner'
FROM workflows
ON CONFLICT (workflow_id, user_id) DO NOTHING;

-- Create trigger for updated_at
CREATE OR REPLACE FUNCTION update_workflow_members_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER trigger_workflow_members_updated_at
    BEFORE UPDATE ON workflow_members
    FOR EACH ROW
    EXECUTE FUNCTION update_workflow_members_updated_at();