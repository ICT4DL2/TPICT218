// api/generateGeminiBriefing.js

// Vérifiez que vous avez bien installé 'node-fetch'
// (dans votre package.json, ajoutez node-fetch et exécutez "npm install")
const fetch = require('node-fetch');

module.exports = async (req, res) => {
  // Autoriser uniquement les requêtes POST
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method Not Allowed' });
  }

  const { battleData } = req.body || {};
  if (!battleData) {
    return res.status(400).json({ error: 'battleData is required' });
  }

  try {
    const apiResponse = await fetch(
      'https://generativelanguage.googleapis.com/v1beta2/models/text-bison-001:generateText',
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
          // Si nécessaire, ajoutez ici une authentification sécurisée
        },
        body: JSON.stringify({
          prompt: {
            text: `Analyse cette bataille et génère une chronique immersive : ${battleData}`
          },
          temperature: 0.7,
          maxOutputTokens: 200
        })
      }
    );

    const body = await apiResponse.json();
    if (apiResponse.ok) {
      res.status(200).json({
        output:
          body.candidates && body.candidates[0]
            ? body.candidates[0].output
            : 'Aucune chronique générée.'
      });
    } else {
      res.status(500).json({
        error: `Erreur Gemini: Code ${apiResponse.status}`,
        details: body
      });
    }
  } catch (error) {
    res.status(500).json({
      error: error.message
    });
  }
};