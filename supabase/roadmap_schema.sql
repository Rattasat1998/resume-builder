-- Create user_roadmaps table
CREATE TABLE IF NOT EXISTS user_roadmaps (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    target_job_title TEXT NOT NULL,
    target_company TEXT,
    current_level TEXT NOT NULL,
    steps JSONB NOT NULL DEFAULT '[]'::jsonb,
    motivation_message TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_user_roadmaps_user_id ON user_roadmaps(user_id);
CREATE INDEX IF NOT EXISTS idx_user_roadmaps_created_at ON user_roadmaps(created_at DESC);

-- Create trigger to auto-update updated_at
DROP TRIGGER IF EXISTS update_user_roadmaps_updated_at ON user_roadmaps;
CREATE TRIGGER update_user_roadmaps_updated_at
    BEFORE UPDATE ON user_roadmaps
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Enable RLS
ALTER TABLE user_roadmaps ENABLE ROW LEVEL SECURITY;

-- Policy: Allow anonymous access (consistent with existing schema for dev)
CREATE POLICY "Allow anonymous access" ON user_roadmaps
    FOR ALL
    USING (true)
    WITH CHECK (true);

-- Alternative: User-based policies (uncomment when ready for strict auth)
-- CREATE POLICY "Users can view own roadmaps" ON user_roadmaps
--     FOR SELECT
--     USING (auth.uid() = user_id);

-- CREATE POLICY "Users can insert own roadmaps" ON user_roadmaps
--     FOR INSERT
--     WITH CHECK (auth.uid() = user_id);

-- CREATE POLICY "Users can update own roadmaps" ON user_roadmaps
--     FOR UPDATE
--     USING (auth.uid() = user_id)
--     WITH CHECK (auth.uid() = user_id);

-- CREATE POLICY "Users can delete own roadmaps" ON user_roadmaps
--     FOR DELETE
--     USING (auth.uid() = user_id);
