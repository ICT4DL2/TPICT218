/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
// functions/index.js
const functions = require('firebase-functions');
const fetch = require('node-fetch'); // Installez-le avec `npm install node-fetch`

// Cette fonction sera appelée depuis votre application Flutter.
exports.generateGeminiBriefing = functions.https.onCall(async (data, context) => {
  const battleData = data.battleData || '';

  try {
    const response = await fetch(
      'https://generativelanguage.googleapis.com/v1beta2/models/text-bison-001:generateText', 
      {
        method: "POST",
        headers: {
          'Content-Type': 'application/json',
          // Si nécessaire, ajoutez ici l'Authorization.
          // Dans un environnement Google Cloud, vous pouvez utiliser ADC (Application Default Credentials).
        },
        body: JSON.stringify({
          prompt: {
            text: `Analyse cette bataille et génère une chronique immersive : ${battleData}`
          },
          temperature: 0.7,
          maxOutputTokens: 200,
        })
      }
    );
    const body = await response.json();

    if (response.ok) {
      return { output: body.candidates && body.candidates[0] ? body.candidates[0].output : 'Aucune chronique générée.' };
    } else {
      throw new functions.https.HttpsError('unknown', `Erreur Gemini: Code ${response.status}`, body);
    }
  } catch (error) {
    throw new functions.https.HttpsError('unknown', error.message, error);
  }
});