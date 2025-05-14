// netlify/functions/generateGeminiBriefing.js
const fetch = require('node-fetch');

// Cette fonction gère uniquement les requêtes POST.
exports.handler = async (event, context) => {
  // Vérifiez que la méthode est POST
  if (event.httpMethod !== 'POST') {
    return {
      statusCode: 405,
      body: JSON.stringify({ error: 'Method Not Allowed' }),
    };
  }

  // Récupère les données envoyées
  let data;
  try {
    data = JSON.parse(event.body);
  } catch (error) {
    return {
      statusCode: 400,
      body: JSON.stringify({ error: 'Invalid JSON body' }),
    };
  }

  const { battleData } = data;
  if (!battleData) {
    return {
      statusCode: 400,
      body: JSON.stringify({ error: 'battleData is required' }),
    };
  }

  try {
    const apiResponse = await fetch(
      'https://generativelanguage.googleapis.com/v1beta2/models/text-bison-001:generateText',
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
          // Ajoutez une authentification ici si nécessaire.
        },
        body: JSON.stringify({
          prompt: {
            text: `Analyse cette bataille et génère une chronique immersive : ${battleData}`,
          },
          temperature: 0.7,
          maxOutputTokens: 200,
        }),
      }
    );

    const body = await apiResponse.json();

    // Si tout s'est bien passé, renvoyer l'output
    if (apiResponse.ok) {
      return {
        statusCode: 200,
        body: JSON.stringify({
          output:
            body.candidates && body.candidates[0]
              ? body.candidates[0].output
              : 'Aucune chronique générée.',
        }),
      };
    } else {
      return {
        statusCode: 500,
        body: JSON.stringify({
          error: `Erreur Gemini: Code ${apiResponse.status}`,
          details: body,
        }),
      };
    }
  } catch (error) {
    return {
      statusCode: 500,
      body: JSON.stringify({ error: error.message }),
    };
  }
};