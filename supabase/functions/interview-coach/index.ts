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
        console.log("Interview Coach Function v3.0 - Robust Model Fallback");
        const {
            jobPosition,
            conversationHistory,
            practiceLanguage,
            action,
            yearsOfExperience,
            location,
            currentLevel,
            targetCompany
        } = await req.json()
        const apiKey = Deno.env.get('GEMINI_API_KEY')

        if (!apiKey) {
            throw new Error('GEMINI_API_KEY is not set')
        }

        if (!jobPosition) {
            throw new Error('Job position is required')
        }

        const langInstruction = practiceLanguage === 'th'
            ? 'Respond in Thai language only.'
            : 'Respond in English only.'

        let prompt: string

        // Handle hint request
        if (action === 'hint') {
            prompt = `You are an expert career coach helping someone prepare for a job interview for the position of "${jobPosition}".
${langInstruction}

The current interview question is:
${conversationHistory}

Provide helpful tips on how to answer this question effectively. Include:
1. Key points to mention
2. What the interviewer is looking for
3. A brief example structure for the answer

Keep your response concise and practical (2-3 short paragraphs).`
        } else if (action === 'score') {
            // Generate interview score and summary
            prompt = `You are an expert HR interviewer evaluating a mock interview for the position of "${jobPosition}".
${langInstruction}

Here is the complete interview conversation:
${conversationHistory}

Analyze the candidate's performance and provide:
1. An overall score from 0-100
2. Scores for each category (0-100): Communication, Relevance, Confidence, Structure
3. 2-3 key strengths
4. 2-3 areas for improvement
5. A brief overall assessment (2-3 sentences)

Format your response EXACTLY as (use numbers only for scores):
[OverallScore]: 85
[Communication]: 80
[Relevance]: 90
[Confidence]: 85
[Structure]: 75
[Strengths]: 
- First strength
- Second strength
- Third strength
[Improvements]:
- First improvement area
- Second improvement area
- Third improvement area
[Assessment]: Your overall assessment here in 2-3 sentences.`
        } else if (action === 'salary') {
            // Estimate salary
            // yearsOfExperience and location are already destructured at the top

            prompt = `You are an expert HR compensation analyst.
${langInstruction}

Estimate the monthly salary range for the position of "${jobPosition}" with ${yearsOfExperience} years of experience in "${location}".

Provide:
1. Minimum monthly salary (in local currency based on location, e.g., THB for Bangkok)
2. Maximum monthly salary
3. Median monthly salary
4. 3 key factors influencing this salary
5. Market trend (Increasing/Stable/Decreasing)

Format your response EXACTLY as (use numbers only for salary values, no commas):
[Min]: 25000
[Max]: 45000
[Median]: 35000
[Currency]: THB
[Factors]:
- Factor 1
- Factor 2
- Factor 3
[Trend]: Stable`
        } else if (action === 'roadmap') {
            // currentLevel and targetCompany are already destructured at the top

            prompt = `You are an expert career coach.
${langInstruction}

Create a personalized 5-step career roadmap for a "${currentLevel}" aspiring to become a "${jobPosition}"${targetCompany ? ' at ' + targetCompany : ''}.

For each step, provide:
1. Title
2. Actionable description
3. Estimated weeks to complete

Also provide a short, inspiring motivation message.

Format your response EXACTLY as JSON:
{
  "steps": [
    {
      "title": "Step Title",
      "description": "Step Description",
      "estimated_weeks": 4
    }
  ],
  "motivation": "Your motivation message"
}`;
        } else if (!conversationHistory || conversationHistory.length === 0) {
            // First question - generate welcome and opening question
            prompt = `You are an expert job interviewer for the position of "${jobPosition}".
${langInstruction}

Generate a welcoming message and ask the first interview question. The question should be an opening question like "Tell me about yourself" or "Why are you interested in this role?".

Format your response EXACTLY as:
[Welcome]: Your welcoming message here
[Question]: Your interview question here`
        } else {
            // Continue conversation - provide feedback and next question
            prompt = `You are an expert job interviewer for the position of "${jobPosition}".
${langInstruction}

Here is the conversation so far:
${conversationHistory}

Based on the candidate's last answer:
1. Provide brief, constructive feedback on their answer (1-2 sentences)
2. Ask the next relevant interview question

Format your response EXACTLY as:
[Feedback]: Your feedback here
[Question]: Your next question here`
        }

        const models = [
            'gemini-1.5-flash',
            'gemini-1.5-pro',
            'gemini-pro',
            'gemini-1.0-pro'
        ];

        let response;
        let lastError;
        let usedModel;

        for (const model of models) {
            try {
                console.log(`Attempting with model: ${model}`);
                const res = await fetch(
                    `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`,
                    {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({
                            contents: [{ parts: [{ text: prompt }] }]
                        }),
                    }
                );

                if (res.status === 200) {
                    response = res;
                    usedModel = model;
                    console.log(`Success with model: ${model}`);
                    break;
                } else {
                    const data = await res.json();
                    lastError = data.error?.message || JSON.stringify(data.error);
                    console.warn(`Failed with model ${model}: ${lastError}`);
                }
            } catch (e) {
                console.error(`Error with model ${model}:`, e);
                lastError = e instanceof Error ? e.message : String(e);
            }
        }

        if (!response) {
            throw new Error(`All models failed. Last error: ${lastError}`);
        }

        const data = await response.json()
        const aiResponse = data.candidates?.[0]?.content?.parts?.[0]?.text || ''

        if (!aiResponse) {
            console.error('Gemini API Error:', JSON.stringify(data))
            const errorMessage = data.error?.message || JSON.stringify(data.error) || 'Unknown Gemini API Error';
            throw new Error(`Gemini Error: ${errorMessage}`)
        }

        // Handle action responses
        if (action === 'roadmap') {
            // Clean up Markdown code blocks if present
            const jsonStr = aiResponse.replace(/```json\n?|\n?```/g, '').trim();
            try {
                const roadmapData = JSON.parse(jsonStr);
                return new Response(
                    JSON.stringify({ roadmap: roadmapData }),
                    {
                        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
                        status: 200,
                    }
                )
            } catch (e) {
                console.error('Failed to parse roadmap JSON:', aiResponse);
                throw new Error('Failed to parse AI response');
            }
        }

        // Handle hint response
        if (action === 'hint') {
            return new Response(
                JSON.stringify({ hint: aiResponse.trim() }),
                {
                    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
                    status: 200,
                }
            )
        }

        // Handle score response
        if (action === 'score') {
            const overallScore = aiResponse.match(/\[OverallScore\]:?\s*(\d+)/)?.[1] || '0'
            const communication = aiResponse.match(/\[Communication\]:?\s*(\d+)/)?.[1] || '0'
            const relevance = aiResponse.match(/\[Relevance\]:?\s*(\d+)/)?.[1] || '0'
            const confidence = aiResponse.match(/\[Confidence\]:?\s*(\d+)/)?.[1] || '0'
            const structure = aiResponse.match(/\[Structure\]:?\s*(\d+)/)?.[1] || '0'

            const strengthsMatch = aiResponse.match(/\[Strengths\]:?\s*((?:- .+\n?)+)/)
            const strengths = strengthsMatch
                ? strengthsMatch[1].split('\n').filter(line => line.trim().startsWith('-')).map(line => line.replace(/^- /, '').trim())
                : []

            const improvementsMatch = aiResponse.match(/\[Improvements\]:?\s*((?:- .+\n?)+)/)
            const improvements = improvementsMatch
                ? improvementsMatch[1].split('\n').filter(line => line.trim().startsWith('-')).map(line => line.replace(/^- /, '').trim())
                : []

            const assessmentMatch = aiResponse.match(/\[Assessment\]:?\s*(.+)/s)
            const assessment = assessmentMatch?.[1]?.trim() || ''

            return new Response(
                JSON.stringify({
                    score: {
                        overall: parseInt(overallScore),
                        breakdown: {
                            communication: parseInt(communication),
                            relevance: parseInt(relevance),
                            confidence: parseInt(confidence),
                            structure: parseInt(structure)
                        },
                        strengths,
                        improvements,
                        assessment
                    }
                }),
                {
                    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
                    status: 200,
                }
            )
        }

        // Handle salary response
        if (action === 'salary') {
            const min = aiResponse.match(/\[Min\]:?\s*(\d+)/)?.[1] || '0'
            const max = aiResponse.match(/\[Max\]:?\s*(\d+)/)?.[1] || '0'
            const median = aiResponse.match(/\[Median\]:?\s*(\d+)/)?.[1] || '0'
            const currency = aiResponse.match(/\[Currency\]:?\s*(.+)/)?.[1]?.trim() || ''
            const trend = aiResponse.match(/\[Trend\]:?\s*(.+)/)?.[1]?.trim() || ''

            const factorsMatch = aiResponse.match(/\[Factors\]:?\s*((?:- .+\n?)+)/)
            const factors = factorsMatch
                ? factorsMatch[1].split('\n').filter(line => line.trim().startsWith('-')).map(line => line.replace(/^- /, '').trim())
                : []

            return new Response(
                JSON.stringify({
                    salary: {
                        min: parseInt(min),
                        max: parseInt(max),
                        median: parseInt(median),
                        currency,
                        trend,
                        factors
                    }
                }),
                {
                    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
                    status: 200,
                }
            )
        }

        // Parse the response for interview flow
        const welcomeMatch = aiResponse.match(/\[Welcome\]:?\s*(.+?)(?=\[Question\]|$)/s)
        const feedbackMatch = aiResponse.match(/\[Feedback\]:?\s*(.+?)(?=\[Question\]|$)/s)
        const questionMatch = aiResponse.match(/\[Question\]:?\s*(.+)/s)

        return new Response(
            JSON.stringify({
                welcome: welcomeMatch?.[1]?.trim() || null,
                feedback: feedbackMatch?.[1]?.trim() || null,
                question: questionMatch?.[1]?.trim() || aiResponse.trim(),
            }),
            {
                headers: { ...corsHeaders, 'Content-Type': 'application/json' },
                status: 200,
            }
        )


    } catch (error: unknown) {
        const message = error instanceof Error ? error.message : 'Unknown error'
        return new Response(
            JSON.stringify({ error: message }),
            {
                headers: { ...corsHeaders, 'Content-Type': 'application/json' },
                status: 400,
            }
        )
    }
})
