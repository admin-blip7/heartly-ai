/**
 * Netlify Function - Skin Analysis with AILabTools API
 * Securely calls AILabTools API without exposing the key to clients
 */

export async function handler(event, context) {
  // Only allow POST requests
  if (event.httpMethod !== 'POST') {
    return {
      statusCode: 405,
      body: JSON.stringify({ error: 'Method not allowed' })
    };
  }

  try {
    // Parse the incoming request
    const { image } = JSON.parse(event.body);
    
    if (!image) {
      return {
        statusCode: 400,
        body: JSON.stringify({ error: 'No image provided' })
      };
    }

    // Convert base64 to buffer
    const base64Data = image.replace(/^data:image\/\w+;base64,/, '');
    const imageBuffer = Buffer.from(base64Data, 'base64');

    // Create FormData for AILabTools API
    const FormData = require('form-data');
    const formData = new FormData();
    formData.append('image', imageBuffer, {
      filename: 'selfie.jpg',
      contentType: 'image/jpeg'
    });

    // Call AILabTools API
    const response = await fetch('https://www.ailabapi.com/api/portrait/analysis/skin-analysis', {
      method: 'POST',
      headers: {
        'ailabapi-api-key': process.env.AILABTOOLS_API_KEY,
        ...formData.getHeaders()
      },
      body: formData
    });

    const result = await response.json();

    // Check for API errors
    if (result.error_code !== 0) {
      console.error('AILabTools API Error:', result);
      return {
        statusCode: 400,
        body: JSON.stringify({ 
          error: result.error_msg || 'Skin analysis failed',
          details: result.error_detail 
        })
      };
    }

    // Transform AILabTools response to our format
    const transformedResult = transformResults(result);

    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(transformedResult)
    };

  } catch (error) {
    console.error('Function error:', error);
    return {
      statusCode: 500,
      body: JSON.stringify({ 
        error: 'Internal server error',
        message: error.message 
      })
    };
  }
}

/**
 * Transform AILabTools API response to our app format
 */
function transformResults(apiResult) {
  const result = apiResult.result;
  
  // Calculate overall skin score (0-100)
  const metrics = [];
  
  // Wrinkles & Lines
  if (result.forehead_wrinkle) {
    metrics.push({
      name: 'Arrugas Frente',
      score: result.forehead_wrinkle.value === 0 ? 85 : 25,
      confidence: result.forehead_wrinkle.confidence,
      icon: '〰️',
      category: 'wrinkles'
    });
  }
  
  if (result.crows_feet) {
    metrics.push({
      name: 'Patas de Gallo',
      score: result.crows_feet.value === 0 ? 80 : 30,
      confidence: result.crows_feet.confidence,
      icon: '👁️',
      category: 'wrinkles'
    });
  }
  
  if (result.eye_finelines) {
    metrics.push({
      name: 'Líneas Finas',
      score: result.eye_finelines.value === 0 ? 82 : 28,
      confidence: result.eye_finelines.confidence,
      icon: '✨',
      category: 'wrinkles'
    });
  }
  
  if (result.glabella_wrinkle) {
    metrics.push({
      name: 'Líneas Entrecejo',
      score: result.glabella_wrinkle.value === 0 ? 85 : 25,
      confidence: result.glabella_wrinkle.confidence,
      icon: '😤',
      category: 'wrinkles'
    });
  }
  
  if (result.nasolabial_fold) {
    metrics.push({
      name: 'Surcos Nasolabiales',
      score: result.nasolabial_fold.value === 0 ? 83 : 27,
      confidence: result.nasolabial_fold.confidence,
      icon: '😊',
      category: 'wrinkles'
    });
  }
  
  // Eye Problems
  if (result.dark_circle) {
    metrics.push({
      name: 'Ojeras',
      score: result.dark_circle.value === 0 ? 85 : 35,
      confidence: result.dark_circle.confidence,
      icon: '🌑',
      category: 'eyes'
    });
  }
  
  if (result.eye_pouch) {
    metrics.push({
      name: 'Bolsas en Ojos',
      score: result.eye_pouch.value === 0 ? 82 : 30,
      confidence: result.eye_pouch.confidence,
      icon: '👁️',
      category: 'eyes'
    });
  }
  
  // Pores
  const avgPores = calculateAveragePores(result);
  metrics.push({
    name: 'Poros',
    score: avgPores,
    confidence: 0.85,
    icon: '⚫',
    category: 'texture'
  });
  
  // Blackheads
  if (result.blackhead) {
    metrics.push({
      name: 'Puntos Negros',
      score: result.blackhead.value === 0 ? 80 : 35,
      confidence: result.blackhead.confidence,
      icon: '⬛',
      category: 'texture'
    });
  }
  
  // Acne
  if (result.acne) {
    metrics.push({
      name: 'Acné',
      score: result.acne.value === 0 ? 85 : 25,
      confidence: result.acne.confidence,
      icon: '🔴',
      category: 'spots'
    });
  }
  
  // Skin Spots
  if (result.skin_spot) {
    metrics.push({
      name: 'Manchas',
      score: result.skin_spot.value === 0 ? 82 : 28,
      confidence: result.skin_spot.confidence,
      icon: '🎨',
      category: 'spots'
    });
  }
  
  // Skin Type
  if (result.skin_type) {
    const skinTypes = ['Piel Grasa', 'Piel Seca', 'Piel Normal', 'Piel Mixta'];
    const skinTypeIndex = result.skin_type.skin_type;
    const skinTypeConfidence = result.skin_type.details?.[skinTypeIndex]?.confidence || 0.8;
    
    metrics.push({
      name: 'Tipo de Piel',
      score: Math.round(skinTypeConfidence * 100),
      confidence: skinTypeConfidence,
      icon: '💧',
      category: 'type',
      value: skinTypes[skinTypeIndex]
    });
  }
  
  // Calculate overall score
  const overallScore = Math.round(
    metrics.reduce((sum, m) => sum + m.score, 0) / metrics.length
  );
  
  // Determine ranking percentile (simulated based on score)
  const rankingPercentile = calculateRanking(overallScore);
  
  return {
    success: true,
    faceDetected: !!apiResult.face_rectangle,
    faceRectangle: apiResult.face_rectangle,
    overallScore,
    metrics,
    skinType: result.skin_type ? {
      type: ['Oily', 'Dry', 'Normal', 'Combination'][result.skin_type.skin_type],
      confidence: result.skin_type.details?.[result.skin_type.skin_type]?.confidence || 0
    } : null,
    rankingPercentile,
    warnings: apiResult.warning || [],
    rawResult: apiResult // Include full result for debugging
  };
}

/**
 * Calculate average pore score across face regions
 */
function calculateAveragePores(result) {
  const poreRegions = ['pores_forehead', 'pores_left_cheek', 'pores_right_cheek', 'pores_jaw'];
  let totalScore = 0;
  let count = 0;
  
  poreRegions.forEach(region => {
    if (result[region]) {
      totalScore += result[region].value === 0 ? 80 : 30;
      count++;
    }
  });
  
  return count > 0 ? Math.round(totalScore / count) : 70;
}

/**
 * Calculate ranking percentile based on score
 */
function calculateRanking(score) {
  // Simple formula: higher score = better ranking
  if (score >= 80) return Math.floor(Math.random() * 10) + 5; // Top 5-15%
  if (score >= 70) return Math.floor(Math.random() * 15) + 15; // Top 15-30%
  if (score >= 60) return Math.floor(Math.random() * 20) + 30; // Top 30-50%
  if (score >= 50) return Math.floor(Math.random() * 20) + 50; // Top 50-70%
  return Math.floor(Math.random() * 20) + 70; // Top 70-90%
}
