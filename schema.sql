CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE TABLE IF NOT EXISTS candidates (
 id integer PRIMARY KEY CHECK (id BETWEEN 1 AND 5),
 name varchar(100) NOT NULL,
 symbol varchar(32) NOT NULL,
 color varchar(16) NOT NULL,
 image_data bytea,
 image_mime varchar(32),
 updated_at timestamptz NOT NULL DEFAULT now()
);
INSERT INTO candidates(id,name,symbol,color) VALUES
(1,'Candidate 1','star','#e9a400'),(2,'Candidate 2','book','#ef3545'),
(3,'Candidate 3','tree','#12af65'),(4,'Candidate 4','lamp','#6f4bf4'),
(5,'Candidate 5','wheel','#1479e9')
ON CONFLICT(id) DO NOTHING;
CREATE TABLE IF NOT EXISTS votes (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 candidate_id integer NOT NULL REFERENCES candidates(id),
 voter_name varchar(120) NOT NULL,
 voter_email varchar(254) NOT NULL,
 voter_dob date NOT NULL,
 cast_at timestamptz NOT NULL DEFAULT now(),
 CONSTRAINT one_vote_per_email UNIQUE(voter_email)
);
CREATE INDEX IF NOT EXISTS votes_cast_idx ON votes(cast_at);
CREATE TABLE IF NOT EXISTS email_codes (
 email varchar(254) PRIMARY KEY,
 code_hash varchar(128) NOT NULL,
 expires_at timestamptz NOT NULL,
 tries integer NOT NULL DEFAULT 0,
 requested_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE IF NOT EXISTS visitor_sessions (
 session_id uuid PRIMARY KEY,
 started_at timestamptz NOT NULL DEFAULT now(),
 last_seen timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS visitors_last_seen_idx ON visitor_sessions(last_seen);

-- Tables are accessed only via the trusted backend PostgreSQL connection.
ALTER TABLE public.candidates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.votes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.email_codes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.visitor_sessions ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.candidates,public.votes,public.email_codes,public.visitor_sessions FROM anon,authenticated;
