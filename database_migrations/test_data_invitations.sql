-- Test Data for Invitation System
-- Use this to test the invitation functionality

-- Insert test users (if they don't exist)
INSERT INTO users (id, email, name, password, role, status) VALUES
('11111111-1111-1111-1111-111111111111', 'john@example.com', 'John Doe', '$2b$10$hashedpassword1', 'user', 'active'),
('22222222-2222-2222-2222-222222222222', 'jane@example.com', 'Jane Smith', '$2b$10$hashedpassword2', 'user', 'active'),
('33333333-3333-3333-3333-333333333333', 'bob@company.com', 'Bob Wilson', '$2b$10$hashedpassword3', 'user', 'active')
ON CONFLICT (email) DO NOTHING;

-- Insert test workflows with invite codes
INSERT INTO workflows (id, name, description, created_by_id, invite_code) VALUES
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Marketing Campaign Workflow', 'A workflow for managing marketing campaigns', '11111111-1111-1111-1111-111111111111', 'JOHN1234-AAAA1111'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Product Development Process', 'Workflow for new product development', '22222222-2222-2222-2222-222222222222', 'JANE5678-BBBB2222')
ON CONFLICT (id) DO NOTHING;

-- Insert test workflow invitation requests
INSERT INTO workflow_invitations (id, invite_code, workflow_id, invited_by_id, invited_user_id, status, message) VALUES
('dddddddd-dddd-dddd-dddd-dddddddddddd', 'JOHN1234-AAAA1111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', '33333333-3333-3333-3333-333333333333', 'pending', 'Hi, I would like to collaborate on this marketing campaign.'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'JANE5678-BBBB2222', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'approved', 'Requesting access to product development workflow.')
ON CONFLICT (id) DO NOTHING;

-- Verification queries
-- Check workflows with invite codes
SELECT w.name, w.invite_code, u.name as owner_name, u.email as owner_email
FROM workflows w
JOIN users u ON w.created_by_id = u.id;

-- Check pending invitations
SELECT
    wi.invite_code,
    w.name as workflow_name,
    owner.name as workflow_owner,
    requester.name as requester_name,
    wi.status,
    wi.created_at
FROM workflow_invitations wi
JOIN workflows w ON wi.workflow_id = w.id
JOIN users owner ON wi.invited_by_id = owner.id
LEFT JOIN users requester ON wi.invited_user_id = requester.id
ORDER BY wi.created_at DESC;

-- Check invitation statistics
SELECT
    status,
    COUNT(*) as count
FROM workflow_invitations
GROUP BY status;

-- Example queries for the application

-- 1. Get pending invitations for a workflow owner
SELECT
    wi.id,
    wi.invite_code,
    wi.message,
    wi.created_at,
    u.name as requester_name,
    u.email as requester_email
FROM workflow_invitations wi
JOIN users u ON wi.invited_user_id = u.id
WHERE wi.invited_by_id = '11111111-1111-1111-1111-111111111111'
AND wi.status = 'pending'
ORDER BY wi.created_at DESC;

-- 2. Get user's received invitations
SELECT
    wi.id,
    wi.status,
    wi.created_at,
    wi.responded_at,
    w.name as workflow_name,
    owner.name as workflow_owner
FROM workflow_invitations wi
JOIN workflows w ON wi.workflow_id = w.id
JOIN users owner ON wi.invited_by_id = owner.id
WHERE wi.invited_user_id = '33333333-3333-3333-3333-333333333333'
ORDER BY wi.created_at DESC;

-- 3. Find workflow by invite code
SELECT
    w.id,
    w.name,
    w.description,
    u.name as owner_name,
    u.email as owner_email
FROM workflows w
JOIN users u ON w.created_by_id = u.id
WHERE w.invite_code = 'JOHN1234-AAAA1111';