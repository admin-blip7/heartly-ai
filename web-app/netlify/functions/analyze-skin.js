/**
 * Netlify Function - Skin Analysis PRO with AILabTools API
 * Advanced skin analysis with detailed metrics, maps, and marks
 */

const fetch = require('node-fetch');
const FormData = require('form-data');

export async function handler(event, context) {
  if (event.httpMethod !== 'POST') {
    return {
      statusCode: 405,
      body: JSON.stringify({ error: 'Method not allowed' })
    };
  }

  try {
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
    const formData = new FormData();
    formData.append('image', imageBuffer, {
      filename: 'selfie.jpg',
      contentType: 'image/jpeg'
    });
    
    // Request visualization maps
    formData.append('return_maps', 'red_area,brown_area,texture_enhanced_pores,texture_enhanced_lines,water_area,rough_area');
    
    // Request detailed marks/coordinates
    formData.append('return_marks', 'wrinkle_mark,dark_circle_outline,sensitivity_mark,melanin_mark');

    // Call AILabTools PRO API
    const response = await fetch('https://www.ailabapi.com/api/portrait/analysis/skin-analysis-pro', {
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

    // Transform PRO API response to our format
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
 * Transform AILabTools PRO API response to our app format
 */
function transformResults(apiResult) {
  const result = apiResult.result;
  const metrics = [];
  
  // WRINKLES & LINES - Using severity scores from PRO API
  if (result.forehead_wrinkle) {
    const severity = result.forehead_wrinkle_severity || 0;
    metrics.push({
      name: 'Arrugas Frente',
      score: calculateScoreFromSeverity(severity),
      confidence: result.forehead_wrinkle.confidence || 0.9,
      icon: '〰️',
      category: 'wrinkles',
      severity: severity,
      hasWrinkles: result.forehead_wrinkle.value === 1
    });
  }
  
  if (result.crows_feet) {
    const severity = result.crows_feet_severity || 0;
    metrics.push({
      name: 'Patas de Gallo',
      score: calculateScoreFromSeverity(severity),
      confidence: result.crows_feet.confidence || 0.9,
      icon: '👁️',
      category: 'wrinkles',
      severity: severity,
      hasWrinkles: result.crows_feet.value === 1
    });
  }
  
  if (result.eye_finelines) {
    const severity = result.eye_finelines_severity || 0;
    metrics.push({
      name: 'Líneas Finas Ojos',
      score: calculateScoreFromSeverity(severity),
      confidence: result.eye_finelines.confidence || 0.9,
      icon: '✨',
      category: 'wrinkles',
      severity: severity,
      hasWrinkles: result.eye_finelines.value === 1
    });
  }
  
  if (result.glabella_wrinkle) {
    const severity = result.glabella_wrinkle_severity || 0;
    metrics.push({
      name: 'Líneas Entrecejo',
      score: calculateScoreFromSeverity(severity),
      confidence: result.glabella_wrinkle.confidence || 0.9,
      icon: '😤',
      category: 'wrinkles',
      severity: severity,
      hasWrinkles: result.glabella_wrinkle.value === 1
    });
  }
  
  if (result.nasolabial_fold) {
    const severity = result.nasolabial_fold_severity || 0;
    metrics.push({
      name: 'Surcos Nasolabiales',
      score: calculateScoreFromSeverity(severity),
      confidence: result.nasolabial_fold.confidence || 0.9,
      icon: '😊',
      category: 'wrinkles',
      severity: severity,
      hasWrinkles: result.nasolabial_fold.value === 1
    });
  }
  
  // EYE PROBLEMS
  if (result.dark_circle) {
    const severity = result.dark_circle_severity || 0;
    metrics.push({
      name: 'Ojeras',
      score: calculateScoreFromSeverity(severity),
      confidence: result.dark_circle.confidence || 0.9,
      icon: '🌑',
      category: 'eyes',
      severity: severity,
      hasDarkCircles: result.dark_circle.value === 1
    });
  }
  
  if (result.eye_pouch) {
    const severity = result.eye_pouch_severity || 0;
    metrics.push({
      name: 'Bolsas en Ojos',
      score: calculateScoreFromSeverity(severity),
      confidence: result.eye_pouch.confidence || 0.9,
      icon: '👁️',
      category: 'eyes',
      severity: severity,
      hasEyeBags: result.eye_pouch.value === 1
    });
  }
  
  // PORES - PRO API gives detailed pore info
  if (result.pores || result.pores_forehead) {
    const poreScore = calculatePoreScore(result);
    metrics.push({
      name: 'Poros',
      score: poreScore,
      confidence: 0.85,
      icon: '⚫',
      category: 'texture',
      details: {
        forehead: result.pores_forehead?.value || 0,
        leftCheek: result.pores_left_cheek?.value || 0,
        rightCheek: result.pores_right_cheek?.value || 0,
        jaw: result.pores_jaw?.value || 0
      }
    });
  }
  
  // BLACKHEADS
  if (result.blackhead) {
    const severity = result.blackhead_severity || 0;
    metrics.push({
      name: 'Puntos Negros',
      score: calculateScoreFromSeverity(severity),
      confidence: result.blackhead.confidence || 0.9,
      icon: '⬛',
      category: 'texture',
      severity: severity,
      hasBlackheads: result.blackhead.value === 1
    });
  }
  
  // ACNE - PRO API has detailed acne classification
  if (result.acne) {
    const acneScore = calculateAcneScore(result);
    metrics.push({
      name: 'Acné',
      score: acneScore,
      confidence: result.acne.confidence || 0.9,
      icon: '🔴',
      category: 'spots',
      hasAcne: result.acne.value === 1,
      details: {
        papules: result.acne_papule?.count || 0,
        pustules: result.acne_pustule?.count || 0,
        nodules: result.acne_nodule?.count || 0
      }
    });
  }
  
  // SKIN SPOTS / PIGMENTATION
  if (result.skin_spot) {
    const severity = result.skin_spot_severity || 0;
    metrics.push({
      name: 'Manchas',
      score: calculateScoreFromSeverity(severity),
      confidence: result.skin_spot.confidence || 0.9,
      icon: '🎨',
      category: 'spots',
      severity: severity,
      hasSpots: result.skin_spot.value === 1
    });
  }
  
  // SKIN TYPE
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
      value: skinTypes[skinTypeIndex],
      type: skinTypeIndex
    });
  }
  
  // SENSITIVITY (PRO API feature)
  if (result.sensitivity !== undefined) {
    metrics.push({
      name: 'Sensibilidad',
      score: 100 - (result.sensitivity_level || 0),
      confidence: 0.85,
      icon: '🔴',
      category: 'sensitivity',
      level: result.sensitivity_level || 0,
      hasSensitivity: result.sensitivity === 1
    });
  }
  
  // MOISTURE (PRO API feature)
  if (result.water_area !== undefined || result.moisture_level !== undefined) {
    metrics.push({
      name: 'Hidratación',
      score: result.moisture_level || 70,
      confidence: 0.85,
      icon: '💧',
      category: 'hydration'
    });
  }
  
  // Calculate overall score
  const overallScore = metrics.length > 0
    ? Math.round(metrics.reduce((sum, m) => sum + m.score, 0) / metrics.length)
    : 68;
  
  // Determine ranking percentile
  const rankingPercentile = calculateRanking(overallScore);
  
  // Extract visualization maps if available
  const visualizations = {};
  if (apiResult.face_maps) {
    if (apiResult.face_maps.red_area) visualizations.redArea = apiResult.face_maps.red_area;
    if (apiResult.face_maps.brown_area) visualizations.brownArea = apiResult.face_maps.brown_area;
    if (apiResult.face_maps.texture_enhanced_pores) visualizations.pores = apiResult.face_maps.texture_enhanced_pores;
    if (apiResult.face_maps.texture_enhanced_lines) visualizations.lines = apiResult.face_maps.texture_enhanced_lines;
    if (apiResult.face_maps.water_area) visualizations.moisture = apiResult.face_maps.water_area;
  }
  
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
    visualizations: Object.keys(visualizations).length > 0 ? visualizations : null,
    rawResult: apiResult
  };
}

/**
 * Calculate score from severity level (0-10 scale to 0-100 score)
 * Lower severity = higher score (better skin)
 */
function calculateScoreFromSeverity(severity) {
  if (!severity || severity === 0) return 90; // No problem = excellent
  // Convert severity (0-10) to score (0-100)
  // severity 0 = score 90-100
  // severity 5 = score 50
  // severity 10 = score 10-20
  return Math.max(10, Math.round(100 - (severity * 9)));
}

/**
 * Calculate pore score from detailed pore data
 */
function calculatePoreScore(result) {
  let totalScore = 0;
  let count = 0;
  
  const poreRegions = ['pores_forehead', 'pores_left_cheek', 'pores_right_cheek', 'pores_jaw'];
  
  poreRegions.forEach(region => {
    if (result[region]) {
      // If has enlarged pores (value=1), lower score
      totalScore += result[region].value === 0 ? 85 : 35;
      count++;
    }
  });
  
  return count > 0 ? Math.round(totalScore / count) : 70;
}

/**
 * Calculate acne score from detailed acne classification
 */
function calculateAcneScore(result) {
  if (!result.acne || result.acne.value === 0) return 90;
  
  let severityPoints = 0;
  
  // Count different types of acne (more severe = more points)
  if (result.acne_papule?.count) severityPoints += result.acne_papule.count * 2;
  if (result.acne_pustule?.count) severityPoints += result.acne_pustule.count * 3;
  if (result.acne_nodule?.count) severityPoints += result.acne_nodule.count * 5;
  
  // Convert to score (0-10 severity to 10-90 score)
  const severity = Math.min(10, severityPoints);
  return Math.max(10, Math.round(100 - (severity * 9)));
}

/**
 * Calculate ranking percentile based on score
 */
function calculateRanking(score) {
  if (score >= 85) return Math.floor(Math.random() * 10) + 5;  // Top 5-15%
  if (score >= 75) return Math.floor(Math.random() * 15) + 15; // Top 15-30%
  if (score >= 65) return Math.floor(Math.random() * 20) + 30; // Top 30-50%
  if (score >= 55) return Math.floor(Math.random() * 20) + 50; // Top 50-70%
  return Math.floor(Math.random() * 20) + 70; // Top 70-90%
}
