-- Rollback Scripts for Invitation System
-- Use these if you need to remove the invitation functionality

-- WARNING: This will delete all invitation data permanently!
-- Make sure to backup your data before running these commands

-- Step 1: Drop workflow_invitations table and related objects
DROP TRIGGER IF EXISTS trigger_workflow_invitations_updated_at ON workflow_invitations;
DROP FUNCTION IF EXISTS update_workflow_invitations_updated_at();
DROP TABLE IF EXISTS workflow_invitations CASCADE;
DROP TYPE IF EXISTS invitation_status CASCADE;

-- Step 2: Remove invite_code column from workflows table
ALTER TABLE workflows DROP COLUMN IF EXISTS invite_code;

-- Step 3: Drop related indexes (these should be auto-dropped with table, but just in case)
DROP INDEX IF EXISTS idx_workflows_invite_code;
DROP INDEX IF EXISTS idx_workflow_invitations_invite_code;
DROP INDEX IF EXISTS idx_workflow_invitations_workflow_id;
DROP INDEX IF EXISTS idx_workflow_invitations_invited_by_id;
DROP INDEX IF EXISTS idx_workflow_invitations_invited_user_id;
DROP INDEX IF EXISTS idx_workflow_invitations_status;
DROP INDEX IF EXISTS idx_workflow_invitations_created_at;
DROP INDEX IF EXISTS idx_workflow_invitations_workflow_status;
DROP INDEX IF EXISTS idx_workflow_invitations_user_status;

-- Verification: Check if everything was removed
SELECT table_name
FROM information_schema.tables
WHERE table_name = 'workflow_invitations';

SELECT column_name
FROM information_schema.columns
WHERE table_name = 'workflows' AND column_name = 'invite_code';

SELECT typname
FROM pg_type
WHERE typname = 'invitation_status';