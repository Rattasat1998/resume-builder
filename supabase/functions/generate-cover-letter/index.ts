
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
    if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })

    try {
        const { resumeData, jobDescription, language } = await req.json()
        const apiKey = Deno.env.get('GEMINI_API_KEY')
        if (!apiKey) throw new Error('GEMINI_API_KEY is not set')

        // Construct the prompt
        let prompt = `You are a professional Career Coach and Resume Writer. 
    Using the provided Candidate's Resume Data and the Target Job Description, write a tailored, professional, and persuasive Cover Letter.
    
    Tone: Professional, Confident, and Enthusiastic.
    Language: ${language || 'English'} (Matches the job description language if not specified).
    
    CANDIDATE RESUME DATA:
    ${JSON.stringify(resumeData)}
    
    TARGET JOB DESCRIPTION:
    ${jobDescription}
    
    Output ONLY the body of the cover letter. Do not include placeholders like [Your Name] or [Date] at the top, just start with "Dear Hiring Manager," or similar professional salutation.`;

        // Use Gemini 2.5 Flash
        const response = await fetch(
            `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${apiKey}`,
            {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    contents: [{ parts: [{ text: prompt }] }]
                }),
            }
        )

        const data = await response.json()
        const coverLetter = data.candidates?.[0]?.content?.parts?.[0]?.text || ''

        if (!coverLetter) {
            console.error('Gemini API Error:', JSON.stringify(data));
            throw new Error('Failed to generate cover letter');
        }

        return new Response(JSON.stringify({ coverLetter: coverLetter.trim() }), {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status: 200,
        })
    } catch (error) {
        return new Response(JSON.stringify({ error: error.message }), {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status: 400,
        })
    }
})
