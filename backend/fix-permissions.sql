-- PostgreSQL permission fix script
-- Run these commands as postgres superuser

-- Connect to workflow_manager database first
\c workflow_manager;

-- Grant all privileges on the database to workflow_user
GRANT ALL PRIVILEGES ON DATABASE workflow_manager TO workflow_user;

-- Grant usage on public schema
GRANT USAGE ON SCHEMA public TO workflow_user;

-- Grant all privileges on all tables in public schema
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO workflow_user;

-- Grant all privileges on all sequences in public schema (for UUID generation)
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO workflow_user;

-- Grant all privileges on all functions in public schema
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO workflow_user;

-- Set default privileges for future tables
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO workflow_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON SEQUENCES TO workflow_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON FUNCTIONS TO workflow_user;

-- Make workflow_user owner of the database (optional, for full control)
ALTER DATABASE workflow_manager OWNER TO workflow_user;

-- Verify permissions
\dt+
\l workflow_manager