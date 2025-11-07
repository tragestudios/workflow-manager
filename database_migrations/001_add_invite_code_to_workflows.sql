-- Migration: Add invite_code column to workflows table
-- Date: 2024-01-XX
-- Description: Adds unique invite code functionality to workflows

-- Add invite_code column to workflows table
ALTER TABLE workflows
ADD COLUMN invite_code VARCHAR(20) UNIQUE;

-- Add index for faster lookups
CREATE INDEX idx_workflows_invite_code ON workflows(invite_code);

-- Add comment
COMMENT ON COLUMN workflows.invite_code IS 'Unique invite code for sharing workflow access';

-- Example of updating existing workflows with invite codes (optional)
-- UPDATE workflows
-- SET invite_code = UPPER(
--     SUBSTRING(MD5(SPLIT_PART((SELECT email FROM users WHERE id = created_by_id), '@', 1)), 1, 8) ||
--     '-' ||
--     SUBSTRING(REPLACE(id::text, '-', ''), 1, 8)
-- )
-- WHERE invite_code IS NULL;