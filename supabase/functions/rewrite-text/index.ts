
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
    // Handle CORS
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders })
    }

    try {
        const { text } = await req.json()
        const apiKey = Deno.env.get('GEMINI_API_KEY')

        if (!apiKey) {
            throw new Error('GEMINI_API_KEY is not set')
        }

        if (!text) {
            throw new Error('Text is required')
        }

        // Using available model: Gemini 2.5 Flash
        const response = await fetch(
            `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${apiKey}`,
            {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    contents: [{ parts: [{ text: `Rewrite the following resume text to be more professional, concise, and impactful. Maintain the original language of the input (if Thai, keep Thai). Result only, no explanations:\n\n${text}` }] }]
                }),
            }
        )

        const data = await response.json()
        const rewritten = data.candidates?.[0]?.content?.parts?.[0]?.text || ''

        if (!rewritten) {
            console.error('Gemini API Error:', JSON.stringify(data))
            throw new Error('Failed to generate text from AI')
        }

        return new Response(
            JSON.stringify({ rewritten: rewritten.trim() }),
            {
                headers: { ...corsHeaders, 'Content-Type': 'application/json' },
                status: 200,
            }
        )

    } catch (error) {
        return new Response(
            JSON.stringify({ error: error.message }),
            {
                headers: { ...corsHeaders, 'Content-Type': 'application/json' },
                status: 400,
            }
        )
    }
})
