DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS exercises;
DROP TABLE IF EXISTS completions;
DROP TABLE IF EXISTS sessions;

CREATE TABLE IF NOT EXISTS users (
    id TEXT PRIMARY KEY,
    username TEXT NOT NULL UNIQUE,
    password TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS exercises (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL UNIQUE, -- Why would multiple exercises be called the same thing
    description TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS completions (
    user_id TEXT NOT NULL,
    exercise_id TEXT NOT NULL,
    completion REAL NOT NULL
);

CREATE TABLE IF NOT EXISTS sessions (
    user_id TEXT NOT NULL UNIQUE, -- Why would a user have multiple sessions
    session_id TEXT NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
