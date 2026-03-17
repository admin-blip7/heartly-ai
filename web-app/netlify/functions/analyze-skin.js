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
    
    // Request ALL visualization maps
    formData.append('return_maps', 'red_area,brown_area,texture_enhanced_pores,texture_enhanced_blackheads,texture_enhanced_oily_area,texture_enhanced_lines,water_area,rough_area,roi_outline_map,texture_enhanced_bw');
    
    // Request ALL detailed marks/coordinates
    formData.append('return_marks', 'wrinkle_mark,right_nasolabial_list,right_mouth_list,right_eye_wrinkle_list,right_crowsfeet_list,right_cheek_list,left_nasolabial_list,left_mouth_list,left_eye_wrinkle_list,left_crowsfeet_list,left_cheek_list,glabella_wrinkle_list,forehead_wrinkle_list,dark_circle_outline,sensitivity_mark,melanin_mark,cheekbone_mark');

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
 * Includes ALL features from Skin Analysis PRO
 */
function transformResults(apiResult) {
  const result = apiResult.result;
  const metrics = [];
  
  // ==================== SKIN AGE ANALYSIS ====================
  if (result.skin_age !== undefined) {
    metrics.push({
      name: 'Edad de la Piel',
      score: 100 - Math.abs(result.skin_age - 25) * 2, // Ideal age ~25
      value: result.skin_age,
      confidence: 0.9,
      icon: '👶',
      category: 'age',
      description: `Tu piel aparenta ${result.skin_age} años`
    });
  }
  
  // ==================== SKIN TYPE ====================
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
  
  // ==================== SKIN COLOR CLASSIFICATION ====================
  if (result.skin_color) {
    metrics.push({
      name: 'Color de Piel',
      score: 85,
      confidence: result.skin_color.confidence || 0.85,
      icon: '🎨',
      category: 'color',
      value: result.skin_color.classification || 'Normal',
      ita: result.skin_color.ita_value,
      undertone: result.skin_color.undertone
    });
  }
  
  // ==================== OIL/SHINE DETECTION ====================
  if (result.oily_area !== undefined || result.oil_level !== undefined) {
    const oilLevel = result.oil_level || 0;
    metrics.push({
      name: 'Nivel de Grasa',
      score: 100 - oilLevel,
      confidence: 0.85,
      icon: '✨',
      category: 'oil',
      level: oilLevel,
      area: result.oily_area_percentage || 0,
      description: oilLevel > 50 ? 'Piel muy grasa' : oilLevel > 30 ? 'Piel mixta' : 'Piel normal'
    });
  }
  
  // ==================== MOISTURE/HYDRATION ====================
  if (result.water_area !== undefined || result.moisture_level !== undefined) {
    const moistureLevel = result.moisture_level || 70;
    metrics.push({
      name: 'Hidratación',
      score: moistureLevel,
      confidence: 0.85,
      icon: '💧',
      category: 'hydration',
      level: moistureLevel,
      area: result.water_area_percentage || 0,
      description: moistureLevel < 50 ? 'Piel deshidratada' : moistureLevel < 70 ? 'Hidratación media' : 'Bien hidratada'
    });
  }
  
  // ==================== WRINKLES & LINES (8 types) ====================
  
  // Forehead Wrinkles
  if (result.forehead_wrinkle) {
    const severity = result.forehead_wrinkle_severity || 0;
    metrics.push({
      name: 'Arrugas Frente',
      score: calculateScoreFromSeverity(severity),
      confidence: result.forehead_wrinkle.confidence || 0.9,
      icon: '〰️',
      category: 'wrinkles',
      severity: severity,
      hasWrinkles: result.forehead_wrinkle.value === 1,
      count: result.forehead_wrinkle_count || 0,
      area: result.forehead_wrinkle_area || 0
    });
  }
  
  // Crow's Feet (Left & Right)
  if (result.crows_feet) {
    const severity = result.crows_feet_severity || 0;
    metrics.push({
      name: 'Patas de Gallo',
      score: calculateScoreFromSeverity(severity),
      confidence: result.crows_feet.confidence || 0.9,
      icon: '👁️',
      category: 'wrinkles',
      severity: severity,
      hasWrinkles: result.crows_feet.value === 1,
      left: result.left_crowsfeet_severity || 0,
      right: result.right_crowsfeet_severity || 0
    });
  }
  
  // Fine Lines Under Eyes (Left & Right)
  if (result.eye_finelines) {
    const severity = result.eye_finelines_severity || 0;
    metrics.push({
      name: 'Líneas Finas Ojos',
      score: calculateScoreFromSeverity(severity),
      confidence: result.eye_finelines.confidence || 0.9,
      icon: '✨',
      category: 'wrinkles',
      severity: severity,
      hasWrinkles: result.eye_finelines.value === 1,
      left: result.left_eye_finelines_severity || 0,
      right: result.right_eye_finelines_severity || 0
    });
  }
  
  // Glabellar Lines (Between Eyebrows)
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
  
  // Nasolabial Folds
  if (result.nasolabial_fold) {
    const severity = result.nasolabial_fold_severity || 0;
    metrics.push({
      name: 'Surcos Nasolabiales',
      score: calculateScoreFromSeverity(severity),
      confidence: result.nasolabial_fold.confidence || 0.9,
      icon: '😊',
      category: 'wrinkles',
      severity: severity,
      hasWrinkles: result.nasolabial_fold.value === 1,
      left: result.left_nasolabial_severity || 0,
      right: result.right_nasolabial_severity || 0
    });
  }
  
  // Mouth Corner Lines (Left & Right)
  if (result.mouth_corner_lines) {
    const severity = result.mouth_corner_severity || 0;
    metrics.push({
      name: 'Líneas Comisuras',
      score: calculateScoreFromSeverity(severity),
      confidence: 0.85,
      icon: '😐',
      category: 'wrinkles',
      severity: severity,
      left: result.left_mouth_severity || 0,
      right: result.right_mouth_severity || 0
    });
  }
  
  // Cheek Lines (Left & Right)
  if (result.cheek_lines) {
    const severity = result.cheek_lines_severity || 0;
    metrics.push({
      name: 'Líneas Mejillas',
      score: calculateScoreFromSeverity(severity),
      confidence: 0.85,
      icon: '😊',
      category: 'wrinkles',
      severity: severity,
      left: result.left_cheek_severity || 0,
      right: result.right_cheek_severity || 0
    });
  }
  
  // ==================== EYE PROBLEMS ====================
  
  // Dark Circles (with type classification)
  if (result.dark_circle) {
    const severity = result.dark_circle_severity || 0;
    const types = ['Pigmentadas', 'Vasculares', 'Estructurales', 'Mixtas'];
    metrics.push({
      name: 'Ojeras',
      score: calculateScoreFromSeverity(severity),
      confidence: result.dark_circle.confidence || 0.9,
      icon: '🌑',
      category: 'eyes',
      severity: severity,
      hasDarkCircles: result.dark_circle.value === 1,
      type: types[result.dark_circle_type || 0],
      left: result.left_dark_circle_severity || 0,
      right: result.right_dark_circle_severity || 0
    });
  }
  
  // Eye Bags
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
  
  // ==================== DOUBLE EYELID ====================
  if (result.double_eyelid) {
    const eyelidTypes = ['Monopárpado', 'Doble Párpado Paralelo', 'Doble Párpado Abanico'];
    metrics.push({
      name: 'Tipo de Párpado',
      score: 85,
      confidence: result.double_eyelid.confidence || 0.85,
      icon: '👀',
      category: 'eyes',
      left: eyelidTypes[result.left_eyelid_type || 0],
      right: eyelidTypes[result.right_eyelid_type || 0]
    });
  }
  
  // ==================== PORES (4 regions) ====================
  if (result.pores || result.pores_forehead) {
    const poreScore = calculateDetailedPoreScore(result);
    metrics.push({
      name: 'Poros',
      score: poreScore.overall,
      confidence: 0.85,
      icon: '⚫',
      category: 'texture',
      details: {
        forehead: {
          has: result.pores_forehead?.value || 0,
          severity: result.pores_forehead_severity || 0,
          count: result.pores_forehead_count || 0,
          size: result.pores_forehead_size || 0
        },
        leftCheek: {
          has: result.pores_left_cheek?.value || 0,
          severity: result.pores_left_cheek_severity || 0,
          count: result.pores_left_cheek_count || 0,
          size: result.pores_left_cheek_size || 0
        },
        rightCheek: {
          has: result.pores_right_cheek?.value || 0,
          severity: result.pores_right_cheek_severity || 0,
          count: result.pores_right_cheek_count || 0,
          size: result.pores_right_cheek_size || 0
        },
        chin: {
          has: result.pores_jaw?.value || 0,
          severity: result.pores_jaw_severity || 0,
          count: result.pores_jaw_count || 0,
          size: result.pores_jaw_size || 0
        }
      },
      totalCount: poreScore.totalCount,
      avgSize: poreScore.avgSize
    });
  }
  
  // ==================== BLACKHEADS ====================
  if (result.blackhead) {
    const severity = result.blackhead_severity || 0;
    metrics.push({
      name: 'Puntos Negros',
      score: calculateScoreFromSeverity(severity),
      confidence: result.blackhead.confidence || 0.9,
      icon: '⬛',
      category: 'texture',
      severity: severity,
      hasBlackheads: result.blackhead.value === 1,
      count: result.blackhead_count || 0,
      area: result.blackhead_area || 0
    });
  }
  
  // ==================== CLOSED COMEDONES ====================
  if (result.closed_comedone) {
    metrics.push({
      name: 'Comedones Cerrados',
      score: result.closed_comedone.value === 0 ? 90 : 40,
      confidence: result.closed_comedone.confidence || 0.85,
      icon: '⚪',
      category: 'texture',
      hasComedones: result.closed_comedone.value === 1,
      count: result.closed_comedone_count || 0
    });
  }
  
  // ==================== TEXTURE ====================
  if (result.texture || result.rough_area) {
    const roughness = result.roughness_level || 0;
    metrics.push({
      name: 'Textura',
      score: 100 - roughness,
      confidence: 0.85,
      icon: '📊',
      category: 'texture',
      roughness: roughness,
      area: result.rough_area_percentage || 0,
      description: roughness > 50 ? 'Textura rugosa' : roughness > 30 ? 'Textura media' : 'Textura suave'
    });
  }
  
  // ==================== ACNE (4 types) ====================
  if (result.acne || result.acne_papule || result.acne_pustule || result.acne_nodule) {
    const acneScore = calculateDetailedAcneScore(result);
    metrics.push({
      name: 'Acné',
      score: acneScore.overall,
      confidence: result.acne?.confidence || 0.9,
      icon: '🔴',
      category: 'spots',
      hasAcne: result.acne?.value === 1,
      details: {
        papules: {
          count: result.acne_papule?.count || 0,
          severity: result.acne_papule_severity || 0
        },
        pustules: {
          count: result.acne_pustule?.count || 0,
          severity: result.acne_pustule_severity || 0
        },
        nodules: {
          count: result.acne_nodule?.count || 0,
          severity: result.acne_nodule_severity || 0
        },
        marks: {
          count: result.acne_mark?.count || 0
        }
      },
      totalCount: acneScore.totalCount,
      description: acneScore.description
    });
  }
  
  // ==================== PIGMENTATION/SPOTS ====================
  if (result.skin_spot || result.pigmentation) {
    const severity = result.skin_spot_severity || result.pigmentation_severity || 0;
    metrics.push({
      name: 'Manchas/Pigmentación',
      score: calculateScoreFromSeverity(severity),
      confidence: result.skin_spot?.confidence || 0.9,
      icon: '🎨',
      category: 'spots',
      severity: severity,
      hasSpots: result.skin_spot?.value === 1,
      count: result.spot_count || 0,
      area: result.pigmentation_area_percentage || 0,
      description: severity > 5 ? 'Pigmentación notable' : severity > 2 ? 'Pigmentación leve' : 'Sin pigmentación'
    });
  }
  
  // ==================== MOLES ====================
  if (result.mole) {
    metrics.push({
      name: 'Lunares',
      score: 85,
      confidence: result.mole.confidence || 0.85,
      icon: '⚫',
      category: 'spots',
      hasMoles: result.mole.value === 1,
      count: result.mole_count || 0
    });
  }
  
  // ==================== SENSITIVITY ====================
  if (result.sensitivity !== undefined) {
    const level = result.sensitivity_level || 0;
    metrics.push({
      name: 'Sensibilidad',
      score: 100 - level,
      confidence: 0.85,
      icon: '🔴',
      category: 'sensitivity',
      level: level,
      hasSensitivity: result.sensitivity === 1,
      area: result.sensitivity_area_percentage || 0,
      description: level > 50 ? 'Piel muy sensible' : level > 30 ? 'Sensibilidad media' : 'Piel normal'
    });
  }
  
  // Calculate overall score
  const overallScore = metrics.length > 0
    ? Math.round(metrics.reduce((sum, m) => sum + m.score, 0) / metrics.length)
    : 68;
  
  // Determine ranking percentile
  const rankingPercentile = calculateRanking(overallScore);
  
  // Extract ALL visualization maps
  const visualizations = {};
  if (apiResult.face_maps) {
    if (apiResult.face_maps.red_area) visualizations.redArea = apiResult.face_maps.red_area;
    if (apiResult.face_maps.brown_area) visualizations.brownArea = apiResult.face_maps.brown_area;
    if (apiResult.face_maps.texture_enhanced_pores) visualizations.pores = apiResult.face_maps.texture_enhanced_pores;
    if (apiResult.face_maps.texture_enhanced_blackheads) visualizations.blackheads = apiResult.face_maps.texture_enhanced_blackheads;
    if (apiResult.face_maps.texture_enhanced_oily_area) visualizations.oilyArea = apiResult.face_maps.texture_enhanced_oily_area;
    if (apiResult.face_maps.texture_enhanced_lines) visualizations.lines = apiResult.face_maps.texture_enhanced_lines;
    if (apiResult.face_maps.water_area) visualizations.moisture = apiResult.face_maps.water_area;
    if (apiResult.face_maps.rough_area) visualizations.roughArea = apiResult.face_maps.rough_area;
    if (apiResult.face_maps.roi_outline_map) visualizations.roiOutline = apiResult.face_maps.roi_outline_map;
    if (apiResult.face_maps.texture_enhanced_bw) visualizations.enhancedBW = apiResult.face_maps.texture_enhanced_bw;
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
    skinAge: result.skin_age || null,
    rankingPercentile,
    warnings: apiResult.warning || [],
    visualizations: Object.keys(visualizations).length > 0 ? visualizations : null,
    timestamp: new Date().toISOString(),
    analysisId: generateAnalysisId(),
    rawResult: apiResult
  };
}

/**
 * Generate unique analysis ID
 */
function generateAnalysisId() {
  return `analysis_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
}

/**
 * Calculate score from severity level (0-10 scale to 0-100 score)
 * Lower severity = higher score (better skin)
 */
function calculateScoreFromSeverity(severity) {
  if (!severity || severity === 0) return 90;
  return Math.max(10, Math.round(100 - (severity * 9)));
}

/**
 * Calculate detailed pore score from PRO API data
 */
function calculateDetailedPoreScore(result) {
  let totalScore = 0;
  let totalCount = 0;
  let totalSize = 0;
  let count = 0;
  
  const poreRegions = ['forehead', 'left_cheek', 'right_cheek', 'jaw'];
  
  poreRegions.forEach(region => {
    const poreData = result[`pores_${region}`];
    const severity = result[`pores_${region}_severity`] || 0;
    const regionCount = result[`pores_${region}_count`] || 0;
    const regionSize = result[`pores_${region}_size`] || 0;
    
    if (poreData) {
      totalScore += poreData.value === 0 ? 85 : 35 - (severity * 5);
      totalCount += regionCount;
      totalSize += regionSize;
      count++;
    }
  });
  
  return {
    overall: count > 0 ? Math.round(totalScore / count) : 70,
    totalCount: totalCount,
    avgSize: count > 0 ? Math.round(totalSize / count) : 0
  };
}

/**
 * Calculate detailed acne score from PRO API classification
 */
function calculateDetailedAcneScore(result) {
  let severityPoints = 0;
  let totalCount = 0;
  
  // Count different types of acne (more severe = more points)
  if (result.acne_papule?.count) {
    severityPoints += result.acne_papule.count * 2;
    totalCount += result.acne_papule.count;
  }
  if (result.acne_pustule?.count) {
    severityPoints += result.acne_pustule.count * 3;
    totalCount += result.acne_pustule.count;
  }
  if (result.acne_nodule?.count) {
    severityPoints += result.acne_nodule.count * 5;
    totalCount += result.acne_nodule.count;
  }
  if (result.acne_mark?.count) {
    severityPoints += result.acne_mark.count * 1;
    totalCount += result.acne_mark.count;
  }
  
  const severity = Math.min(10, severityPoints);
  const score = Math.max(10, Math.round(100 - (severity * 9)));
  
  let description = 'Sin acné';
  if (totalCount > 0) {
    if (severityPoints > 20) {
      description = 'Acné severo';
    } else if (severityPoints > 10) {
      description = 'Acné moderado';
    } else {
      description = 'Acné leve';
    }
  }
  
  return {
    overall: score,
    totalCount: totalCount,
    description: description
  };
}

/**
 * Calculate ranking percentile based on score
 */
function calculateRanking(score) {
  if (score >= 85) return Math.floor(Math.random() * 10) + 5;
  if (score >= 75) return Math.floor(Math.random() * 15) + 15;
  if (score >= 65) return Math.floor(Math.random() * 20) + 30;
  if (score >= 55) return Math.floor(Math.random() * 20) + 50;
  return Math.floor(Math.random() * 20) + 70;
}
