-- Migration: Add source_connector column to connections table
-- Date: 2024-01-XX
-- Description: Adds source_connector field to track which output connector was used (output, output-yes, output-no)

-- Add source_connector column
ALTER TABLE connections
ADD COLUMN IF NOT EXISTS source_connector VARCHAR(20);

-- Add index for performance
CREATE INDEX IF NOT EXISTS idx_connections_source_connector ON connections(source_connector);

-- Add comment
COMMENT ON COLUMN connections.source_connector IS 'Type of source connector used: output, output-yes, output-no for decision nodes';
