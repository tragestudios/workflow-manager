-- Fix unique constraint issue
-- The current constraint prevents multiple statuses for same user-workflow combination

-- Drop the existing constraint
ALTER TABLE workflow_invitations
DROP CONSTRAINT IF EXISTS unique_pending_invitation;

-- Add a new constraint that only applies to pending invitations
-- This allows the same user to have multiple invitation records with different statuses
CREATE UNIQUE INDEX unique_pending_invitation_only
ON workflow_invitations (workflow_id, invited_user_id)
WHERE status = 'pending';

-- This ensures:
-- 1. A user can only have ONE pending invitation per workflow
-- 2. But can have approved/rejected invitations as well
-- 3. Prevents duplicate pending requests