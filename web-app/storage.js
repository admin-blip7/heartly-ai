// Skin Analysis History Storage

/**
 * Save analysis to history
 */
function saveAnalysisToHistory(analysis) {
  const history = getAnalysisHistory();
  
  const analysisRecord = {
    analysisId: analysis.analysisId,
    timestamp: analysis.timestamp,
    overallScore: analysis.overallScore,
    skinAge: analysis.skinAge,
    metrics: analysis.metrics,
    skinType: analysis.skinType,
    rankingPercentile: analysis.rankingPercentile,
    visualizations: analysis.visualizations
  };
  
  history.push(analysisRecord);
  
  // Keep only last 50 analyses
  if (history.length > 50) {
    history.shift();
  }
  
  localStorage.setItem('heartly_analysis_history', JSON.stringify(history));
  
  return analysisRecord;
}

/**
 * Get analysis history
 */
function getAnalysisHistory() {
  const history = localStorage.getItem('heartly_analysis_history');
  return history ? JSON.parse(history) : [];
}

/**
 * Get latest analysis
 */
function getLatestAnalysis() {
  const history = getAnalysisHistory();
  return history.length > 0 ? history[history.length - 1] : null;
}

/**
 * Get analysis by ID
 */
function getAnalysisById(analysisId) {
  const history = getAnalysisHistory();
  return history.find(a => a.analysisId === analysisId) || null;
}

/**
 * Get previous analysis (before latest)
 */
function getPreviousAnalysis() {
  const history = getAnalysisHistory();
  return history.length > 1 ? history[history.length - 2] : null;
}

/**
 * Clear history
 */
function clearAnalysisHistory() {
  localStorage.removeItem('heartly_analysis_history');
}

/**
 * Get history statistics
 */
function getHistoryStats() {
  const history = getAnalysisHistory();
  
  if (history.length === 0) {
    return {
      totalAnalyses: 0,
      firstAnalysis: null,
      latestAnalysis: null,
      averageScore: null,
      bestScore: null,
      worstScore: null
    };
  }
  
  const scores = history.map(a => a.overallScore);
  
  return {
    totalAnalyses: history.length,
    firstAnalysis: history[0].timestamp,
    latestAnalysis: history[history.length - 1].timestamp,
    averageScore: Math.round(scores.reduce((a, b) => a + b, 0) / scores.length),
    bestScore: Math.max(...scores),
    worstScore: Math.min(...scores)
  };
}

/**
 * Get progress over time
 */
function getProgressOverTime() {
  const history = getAnalysisHistory();
  
  if (history.length < 2) {
    return null;
  }
  
  const progress = [];
  
  for (let i = 1; i < history.length; i++) {
    const current = history[i];
    const previous = history[i - 1];
    
    const scoreDiff = current.overallScore - previous.overallScore;
    const percentChange = Math.round((scoreDiff / previous.overallScore) * 100);
    
    progress.push({
      timestamp: current.timestamp,
      overallScore: current.overallScore,
      change: scoreDiff,
      percentChange: percentChange,
      skinAge: current.skinAge
    });
  }
  
  return progress;
}

/**
 * Export history as JSON
 */
function exportHistory() {
  const history = getAnalysisHistory();
  const blob = new Blob([JSON.stringify(history, null, 2)], { type: 'application/json' });
  const url = URL.createObjectURL(blob);
  
  const a = document.createElement('a');
  a.href = url;
  a.download = `heartly-analysis-history-${new Date().toISOString().split('T')[0]}.json`;
  a.click();
  
  URL.revokeObjectURL(url);
}
