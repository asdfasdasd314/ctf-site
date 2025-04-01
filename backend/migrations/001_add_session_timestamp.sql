-- Create new sessions table with timestamp
CREATE TABLE sessions_new (
    user_id TEXT NOT NULL UNIQUE,
    session_id TEXT NOT NULL PRIMARY KEY UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Copy data from old table to new table
INSERT INTO sessions_new (user_id, session_id, created_at)
SELECT user_id, session_id, CURRENT_TIMESTAMP
FROM sessions;

-- Drop the old table
DROP TABLE sessions;

-- Rename the new table to the original name
ALTER TABLE sessions_new RENAME TO sessions; 