-- Step-by-Step Update for Existing Database
-- Run these commands in order if you have an existing workflow_manager database

-- Step 1: Add invite_code column to workflows table
ALTER TABLE workflows
ADD COLUMN IF NOT EXISTS invite_code VARCHAR(20) UNIQUE;

-- Step 2: Create invitation_status enum if it doesn't exist
DO $$ BEGIN
    CREATE TYPE invitation_status AS ENUM ('pending', 'approved', 'rejected', 'revoked');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Step 3: Create workflow_invitations table
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

-- Step 4: Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_workflows_invite_code ON workflows(invite_code);
CREATE INDEX IF NOT EXISTS idx_workflow_invitations_invite_code ON workflow_invitations(invite_code);
CREATE INDEX IF NOT EXISTS idx_workflow_invitations_workflow_id ON workflow_invitations(workflow_id);
CREATE INDEX IF NOT EXISTS idx_workflow_invitations_invited_by_id ON workflow_invitations(invited_by_id);
CREATE INDEX IF NOT EXISTS idx_workflow_invitations_invited_user_id ON workflow_invitations(invited_user_id);
CREATE INDEX IF NOT EXISTS idx_workflow_invitations_status ON workflow_invitations(status);
CREATE INDEX IF NOT EXISTS idx_workflow_invitations_created_at ON workflow_invitations(created_at);
CREATE INDEX IF NOT EXISTS idx_workflow_invitations_workflow_status ON workflow_invitations(workflow_id, status);
CREATE INDEX IF NOT EXISTS idx_workflow_invitations_user_status ON workflow_invitations(invited_user_id, status);

-- Step 5: Create trigger for updated_at if it doesn't exist
CREATE OR REPLACE FUNCTION update_workflow_invitations_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS trigger_workflow_invitations_updated_at ON workflow_invitations;
CREATE TRIGGER trigger_workflow_invitations_updated_at
    BEFORE UPDATE ON workflow_invitations
    FOR EACH ROW
    EXECUTE FUNCTION update_workflow_invitations_updated_at();

-- Step 6: Generate invite codes for existing workflows (Optional)
-- This will create invite codes for workflows that don't have them
UPDATE workflows
SET invite_code = UPPER(
    SUBSTRING(MD5(SPLIT_PART((SELECT email FROM users WHERE id = created_by_id), '@', 1)), 1, 8) ||
    '-' ||
    SUBSTRING(REPLACE(id::text, '-', ''), 1, 8)
)
WHERE invite_code IS NULL;

-- Verification queries (run these to check everything is working)
-- Check if invite_code column exists
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'workflows' AND column_name = 'invite_code';

-- Check if workflow_invitations table exists
SELECT table_name
FROM information_schema.tables
WHERE table_name = 'workflow_invitations';

-- Check if indexes were created
SELECT indexname
FROM pg_indexes
WHERE tablename IN ('workflows', 'workflow_invitations')
AND indexname LIKE '%invite%';

-- Sample workflow with invite code
SELECT id, name, invite_code
FROM workflows
WHERE invite_code IS NOT NULL
LIMIT 5;