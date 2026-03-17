/**
 * Netlify Function - Compare Skin Analysis History
 * Calculates improvement percentages between analyses
 */

export async function handler(event, context) {
  if (event.httpMethod !== 'POST') {
    return {
      statusCode: 405,
      body: JSON.stringify({ error: 'Method not allowed' })
    };
  }

  try {
    const { currentAnalysis, previousAnalysis } = JSON.parse(event.body);
    
    if (!currentAnalysis || !previousAnalysis) {
      return {
        statusCode: 400,
        body: JSON.stringify({ error: 'Missing analysis data' })
      };
    }

    // Calculate improvements
    const comparison = compareAnalyses(currentAnalysis, previousAnalysis);
    
    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(comparison)
    };

  } catch (error) {
    console.error('Comparison error:', error);
    return {
      statusCode: 500,
      body: JSON.stringify({ 
        error: 'Comparison failed',
        message: error.message 
      })
    };
  }
}

/**
 * Compare two analyses and calculate improvements
 */
function compareAnalyses(current, previous) {
  const improvements = [];
  const declined = [];
  const stable = [];
  
  // Create metric maps for easy lookup
  const currentMetrics = {};
  const previousMetrics = {};
  
  current.metrics.forEach(m => {
    currentMetrics[m.name] = m;
  });
  
  previous.metrics.forEach(m => {
    previousMetrics[m.name] = m;
  });
  
  // Compare each metric
  Object.keys(currentMetrics).forEach(metricName => {
    const currentMetric = currentMetrics[metricName];
    const previousMetric = previousMetrics[metricName];
    
    if (previousMetric) {
      const scoreDiff = currentMetric.score - previousMetric.score;
      const percentChange = Math.round((scoreDiff / previousMetric.score) * 100);
      
      const comparison = {
        name: metricName,
        icon: currentMetric.icon,
        category: currentMetric.category,
        currentScore: currentMetric.score,
        previousScore: previousMetric.score,
        scoreDiff: scoreDiff,
        percentChange: percentChange,
        currentSeverity: currentMetric.severity || 0,
        previousSeverity: previousMetric.severity || 0,
        severityDiff: (previousMetric.severity || 0) - (currentMetric.severity || 0),
        status: scoreDiff > 2 ? 'improved' : scoreDiff < -2 ? 'declined' : 'stable'
      };
      
      if (scoreDiff > 2) {
        improvements.push(comparison);
      } else if (scoreDiff < -2) {
        declined.push(comparison);
      } else {
        stable.push(comparison);
      }
    }
  });
  
  // Calculate overall improvement
  const overallScoreDiff = current.overallScore - previous.overallScore;
  const overallPercentChange = Math.round((overallScoreDiff / previous.overallScore) * 100);
  
  // Calculate skin age change
  const skinAgeDiff = current.skinAge && previous.skinAge 
    ? previous.skinAge - current.skinAge 
    : 0;
  
  // Determine overall status
  let overallStatus = 'stable';
  if (overallScoreDiff > 3) overallStatus = 'improved';
  else if (overallScoreDiff < -3) overallStatus = 'declined';
  
  // Generate recommendations based on declined metrics
  const recommendations = generateRecommendations(declined);
  
  return {
    success: true,
    comparison: {
      overall: {
        status: overallStatus,
        currentScore: current.overallScore,
        previousScore: previous.overallScore,
        scoreDiff: overallScoreDiff,
        percentChange: overallPercentChange
      },
      skinAge: {
        current: current.skinAge,
        previous: previous.skinAge,
        diff: skinAgeDiff,
        description: skinAgeDiff > 0 ? `Tu piel luce ${skinAgeDiff} años más joven 🎉` : 
                     skinAgeDiff < 0 ? `Tu piel luce ${Math.abs(skinAgeDiff)} años mayor` :
                     'Tu edad de piel se mantiene estable'
      },
      improvements: improvements.sort((a, b) => b.percentChange - a.percentChange),
      declined: declined.sort((a, b) => a.percentChange - b.percentChange),
      stable: stable,
      summary: {
        totalMetrics: Object.keys(currentMetrics).length,
        improved: improvements.length,
        declined: declined.length,
        stable: stable.length,
        improvementRate: Math.round((improvements.length / Object.keys(currentMetrics).length) * 100)
      },
      recommendations: recommendations,
      timeBetween: calculateTimeBetween(previous.timestamp, current.timestamp),
      currentAnalysisId: current.analysisId,
      previousAnalysisId: previous.analysisId
    }
  };
}

/**
 * Generate recommendations based on declined metrics
 */
function generateRecommendations(declined) {
  const recommendations = [];
  
  declined.forEach(metric => {
    switch(metric.category) {
      case 'wrinkles':
        recommendations.push({
          metric: metric.name,
          recommendation: 'Usar productos con retinol y aplicar protector solar diario',
          priority: metric.severityDiff > 2 ? 'high' : 'medium'
        });
        break;
      case 'eyes':
        recommendations.push({
          metric: metric.name,
          recommendation: 'Aplicar crema de ojos con cafeína y dormir 7-8 horas',
          priority: metric.severityDiff > 2 ? 'high' : 'medium'
        });
        break;
      case 'texture':
        recommendations.push({
          metric: metric.name,
          recommendation: 'Exfoliar 2-3 veces por semana y usar niacinamida',
          priority: metric.severityDiff > 2 ? 'high' : 'medium'
        });
        break;
      case 'hydration':
        recommendations.push({
          metric: metric.name,
          recommendation: 'Beber más agua y usar ácido hialurónico',
          priority: metric.severityDiff > 2 ? 'high' : 'medium'
        });
        break;
      case 'sensitivity':
        recommendations.push({
          metric: metric.name,
          recommendation: 'Evitar productos con fragancias y usar ingredientes calmantes',
          priority: metric.severityDiff > 2 ? 'high' : 'medium'
        });
        break;
      case 'spots':
        recommendations.push({
          metric: metric.name,
          recommendation: 'Usar vitamina C y protector solar SPF 50+',
          priority: metric.severityDiff > 2 ? 'high' : 'medium'
        });
        break;
      case 'oil':
        recommendations.push({
          metric: metric.name,
          recommendation: 'Usar productos oil-free y limpiar el rostro 2 veces al día',
          priority: metric.severityDiff > 2 ? 'high' : 'medium'
        });
        break;
    }
  });
  
  return recommendations;
}

/**
 * Calculate time between analyses
 */
function calculateTimeBetween(previousTimestamp, currentTimestamp) {
  const previous = new Date(previousTimestamp);
  const current = new Date(currentTimestamp);
  const diffMs = current - previous;
  
  const days = Math.floor(diffMs / (1000 * 60 * 60 * 24));
  const hours = Math.floor((diffMs % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
  
  if (days > 0) {
    return {
      days: days,
      hours: hours,
      description: `Hace ${days} ${days === 1 ? 'día' : 'días'}${hours > 0 ? ` y ${hours} ${hours === 1 ? 'hora' : 'horas'}` : ''}`
    };
  } else {
    return {
      days: 0,
      hours: hours,
      description: `Hace ${hours} ${hours === 1 ? 'hora' : 'horas'}`
    };
  }
}
