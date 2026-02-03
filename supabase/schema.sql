-- Supabase SQL Schema for Resume Builder
-- Run this in your Supabase SQL Editor to create the required tables

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create resumes table
CREATE TABLE IF NOT EXISTS resumes (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL DEFAULT 'Untitled Resume',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Template configuration (stored as JSON)
    template JSONB NOT NULL DEFAULT '{}'::jsonb,

    -- Profile section
    profile JSONB NOT NULL DEFAULT '{}'::jsonb,

    -- Contact section
    contact JSONB NOT NULL DEFAULT '{}'::jsonb,

    -- Experience section (array of experiences)
    experiences JSONB NOT NULL DEFAULT '[]'::jsonb,

    -- Education section (array of educations)
    educations JSONB NOT NULL DEFAULT '[]'::jsonb,

    -- Skills section (array of skills)
    skills JSONB NOT NULL DEFAULT '[]'::jsonb,

    -- Projects section (array of projects)
    projects JSONB NOT NULL DEFAULT '[]'::jsonb,

    -- Languages section (array of languages)
    languages JSONB NOT NULL DEFAULT '[]'::jsonb,

    -- Hobbies section (array of hobbies)
    hobbies JSONB NOT NULL DEFAULT '[]'::jsonb,

    -- Status fields
    is_draft BOOLEAN NOT NULL DEFAULT true,
    resume_language TEXT NOT NULL DEFAULT 'english',

    -- User association (optional - for future auth)
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_resumes_user_id ON resumes(user_id);
CREATE INDEX IF NOT EXISTS idx_resumes_updated_at ON resumes(updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_resumes_created_at ON resumes(created_at DESC);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to auto-update updated_at
DROP TRIGGER IF EXISTS update_resumes_updated_at ON resumes;
CREATE TRIGGER update_resumes_updated_at
    BEFORE UPDATE ON resumes
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Row Level Security (RLS) Policies
-- Enable RLS
ALTER TABLE resumes ENABLE ROW LEVEL SECURITY;

-- Policy: Allow anonymous access (for app without auth)
-- CAUTION: This allows anyone to read/write all resumes
-- Remove this policy when implementing authentication
CREATE POLICY "Allow anonymous access" ON resumes
    FOR ALL
    USING (true)
    WITH CHECK (true);

-- Alternative: User-based policies (uncomment when using auth)
-- Policy: Users can only see their own resumes
-- CREATE POLICY "Users can view own resumes" ON resumes
--     FOR SELECT
--     USING (auth.uid() = user_id);

-- Policy: Users can insert their own resumes
-- CREATE POLICY "Users can insert own resumes" ON resumes
--     FOR INSERT
--     WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own resumes
-- CREATE POLICY "Users can update own resumes" ON resumes
--     FOR UPDATE
--     USING (auth.uid() = user_id)
--     WITH CHECK (auth.uid() = user_id);

-- Policy: Users can delete their own resumes
-- CREATE POLICY "Users can delete own resumes" ON resumes
--     FOR DELETE
--     USING (auth.uid() = user_id);

-- Sample data structure for reference:
/*
{
  "id": "uuid",
  "title": "My Resume",
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-01T00:00:00Z",
  "template": {
    "id": "uuid",
    "type": "classic",
    "primaryColor": "#2563EB",
    "secondaryColor": "#1E40AF",
    "fontFamily": "Roboto",
    "fontSize": 12.0
  },
  "profile": {
    "id": "uuid",
    "fullName": "John Doe",
    "jobTitle": "Software Engineer",
    "summary": "Experienced developer...",
    "avatarUrl": null
  },
  "contact": {
    "id": "uuid",
    "email": "john@example.com",
    "phone": "+1234567890",
    "website": "https://johndoe.com",
    "linkedIn": "linkedin.com/in/johndoe",
    "github": "github.com/johndoe",
    "city": "New York",
    "country": "USA"
  },
  "experiences": [
    {
      "id": "uuid",
      "companyName": "Tech Corp",
      "position": "Senior Developer",
      "location": "New York, USA",
      "startDate": "2020-01-01T00:00:00Z",
      "endDate": null,
      "isCurrentJob": true,
      "description": "Leading development...",
      "achievements": ["Increased performance by 50%"]
    }
  ],
  "educations": [...],
  "skills": [...],
  "projects": [...],
  "languages": [...],
  "hobbies": [...],
  "is_draft": true,
  "resume_language": "english"
}
*/

