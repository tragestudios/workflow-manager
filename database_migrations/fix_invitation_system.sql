-- Complete fix for invitation system
-- Run this to fix the current issues

-- Step 1: Fix unique constraint issue
ALTER TABLE workflow_invitations
DROP CONSTRAINT IF EXISTS unique_pending_invitation;

-- Create a partial unique index that only applies to pending invitations
CREATE UNIQUE INDEX IF NOT EXISTS unique_pending_invitation_only
ON workflow_invitations (workflow_id, invited_user_id)
WHERE status = 'pending';

-- Step 2: Create workflow_members table
DO $$ BEGIN
    CREATE TYPE member_role AS ENUM ('owner', 'admin', 'member');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

CREATE TABLE IF NOT EXISTS workflow_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workflow_id UUID NOT NULL,
    user_id UUID NOT NULL,
    role member_role DEFAULT 'member',
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

-- Step 3: Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_workflow_members_workflow_id ON workflow_members(workflow_id);
CREATE INDEX IF NOT EXISTS idx_workflow_members_user_id ON workflow_members(user_id);
CREATE INDEX IF NOT EXISTS idx_workflow_members_role ON workflow_members(role);

-- Step 4: Insert existing workflow owners as members
INSERT INTO workflow_members (workflow_id, user_id, role)
SELECT id, created_by_id, 'owner'
FROM workflows
ON CONFLICT (workflow_id, user_id) DO NOTHING;

-- Step 5: Create trigger for updated_at
CREATE OR REPLACE FUNCTION update_workflow_members_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS trigger_workflow_members_updated_at ON workflow_members;
CREATE TRIGGER trigger_workflow_members_updated_at
    BEFORE UPDATE ON workflow_members
    FOR EACH ROW
    EXECUTE FUNCTION update_workflow_members_updated_at();

-- Verification queries
SELECT 'Workflows with members count:' as info;
SELECT w.name, COUNT(wm.id) as member_count
FROM workflows w
LEFT JOIN workflow_members wm ON w.id = wm.workflow_id
GROUP BY w.id, w.name
ORDER BY member_count DESC;

SELECT 'Total invitation count by status:' as info;
SELECT status, COUNT(*) as count
FROM workflow_invitations
GROUP BY status;