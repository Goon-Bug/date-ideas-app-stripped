CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    icon VARCHAR(255),
    email_verified BOOLEAN DEFAULT false,
    verification_jwt VARCHAR(512),
    jwt_expiration TIMESTAMPTZ,
    role VARCHAR(50) DEFAULT 'user',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    token_count INTEGER DEFAULT 0
);

INSERT INTO users (username, email, password, role, token_count, email_verified)
VALUES (
    'admin', 
    'admin@example.com', 
    '$2b$12$jEtVoOvutLsgw6yHyut5BOjvNtELK1.IUdfY/1YepVOc0ntl25EfS', 
    'admin',
    99,
    true
);

CREATE TABLE revoked_tokens (
    id SERIAL PRIMARY KEY,                       -- Unique identifier for each revoked token entry
    jti VARCHAR(255) NOT NULL UNIQUE,            -- JSON Web Token Identifier (jti), must be unique
    user_id INT NOT NULL,                         -- ID of the user associated with the token
    revoked_at TIMESTAMP DEFAULT NOW(),          -- Timestamp when the token was revoked
    expires_at TIMESTAMP,                         -- Optional: expiration time of the token
    reason VARCHAR(255),                          -- Optional: reason for revocation (e.g., 'logout', 'password change')
    CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES users(id) -- Foreign key to users table
);