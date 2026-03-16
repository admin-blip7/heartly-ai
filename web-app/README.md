# Heartly AI Web App

Functional web application for skin analysis with complete user flow.

---

## 🎯 What This Is

A **single-page web app** that works like a real product:
- User takes selfie or uploads photo
- App "analyzes" their skin (simulated for now)
- Shows results with 11 metrics, age comparison, future predictions
- User can share results or challenge friends

**Not a landing page. A real usable app.**

---

## 🚀 Quick Deploy

### Option 1: Netlify (Recommended)

```bash
# Install Netlify CLI
npm install -g netlify-cli

# Deploy from this folder
cd web-app
netlify deploy --prod

# Or drag & drop this folder to:
# https://app.netlify.com/drop
```

**Result:** Live URL like `https://heartly-ai-web.netlify.app`

---

### Option 2: Vercel

```bash
# Install Vercel CLI
npm install -g vercel

# Deploy
cd web-app
vercel --prod
```

---

### Option 3: GitHub Pages

1. Go to: https://github.com/admin-blip7/heartly-ai/settings/pages
2. Source: `main` branch → `/web-app` folder
3. Save
4. URL: `https://admin-blip7.github.io/heartly-ai`

---

### Option 4: Any Static Host

Upload `index.html` to any static hosting:
- AWS S3
- Google Cloud Storage
- Firebase Hosting
- Surge.sh
- etc.

---

## 📱 User Flow

### Screen 1: Welcome
- Value proposition
- Feature list
- Social proof ("2,847 people analyzed today")
- CTA: "Analyze My Skin"

### Screen 2: Camera
- Live camera preview
- Face guide overlay
- Capture button
- Upload fallback

### Screen 3: Loading
- Animated progress bar (0-100%)
- 4 steps with checkmarks:
  1. Detecting face
  2. Analyzing 11 metrics
  3. Calculating apparent age
  4. Generating predictions

### Screen 4: Results
- Overall score (0-100)
- Age comparison (actual vs apparent)
- 11 metric cards with progress bars
- Future comparison (today / worst case / best case)
- Social ranking (Top X%)
- Challenge & Share buttons

---

## 🧠 Psychological Triggers

### Built into the flow:

| Trigger | Implementation |
|---------|----------------|
| **Urgency** | "Your skin looks +2 years older" |
| **Hope** | "Can look -2 years if you take care" |
| **Loss Aversion** | Worst case image (look 10 years older) |
| **Social Comparison** | Ranking "Top 32%" |
| **Virality** | "Challenge a friend" button |
| **Social Proof** | "2,847 analyzed today" |
| **Curiosity** | "Your skin has an age" |

---

## 🔧 Customization

### Change User's Age

Edit line ~430:
```javascript
let userAge = 25; // Change this
```

### Connect Real API

Replace the `startAnalysis()` function with real API calls:

```javascript
async function startAnalysis() {
    // 1. Upload image to your API
    const response = await fetch('YOUR_API_ENDPOINT', {
        method: 'POST',
        body: imageBlob
    });
    
    // 2. Get real results
    const results = await response.json();
    
    // 3. Display real results
    showResults(results);
}
```

### Add Email Capture

Before showing results, add an email screen:

```html
<div id="email-screen" class="screen">
    <h2>¡Casi listo!</h2>
    <p>Dejanos tu email para ver tus resultados</p>
    <input type="email" placeholder="tu@email.com">
    <button onclick="submitEmail()">Ver Resultados</button>
</div>
```

---

## 📊 Metrics Simulated

Currently random but realistic values:

| Metric | Range | Good |
|--------|-------|------|
| Firmness | 0-100 | ≥70 |
| Wrinkles | 0-100 | ≥70 |
| Pores | 0-100 | ≥70 |
| Spots | 0-100 | ≥70 |
| Dark Circles | 0-100 | ≥70 |
| Hydration | 0-100 | ≥70 |
| Texture | 0-100 | ≥70 |
| Elasticity | 0-100 | ≥70 |
| Glow | 0-100 | ≥70 |
| Sun Damage | 0-100 | ≥70 |
| Expression Lines | 0-100 | ≥70 |

**Colors:**
- Green (≥70): Good
- Yellow (50-69): Medium
- Red (<50): Needs attention

---

## 🎨 Design System

### Colors:
```css
--primary: #00BFA5;      /* Teal - trust, health */
--primary-dark: #00897B;
--secondary: #FF8A80;    /* Coral - warmth, urgency */
--warning: #FF6B6B;      /* Red - attention */
--success: #00BFA5;
--text: #212121;
--text-light: #757575;
--bg: #FAFAFA;
```

### Typography:
- Font: Inter (Google Fonts)
- Weights: 400, 500, 600, 700, 800

### Spacing:
- Base: 20px
- Cards: 16px padding
- Buttons: 18px padding
- Border radius: 12px

---

## 📈 Next Steps

### Phase 1: Validation (Now)
1. Deploy to Netlify
2. Share with 10 friends
3. Get feedback
4. Iterate

### Phase 2: Email Capture
1. Add email screen before results
2. Connect to Mailchimp/ConvertKit
3. Run $50 ads test
4. Goal: 50 emails

### Phase 3: Real API
1. Get AILabTools API key
2. Replace simulation with real analysis
3. Show real metrics
4. Generate real future images

### Phase 4: Mobile App
1. Use existing Flutter code
2. Integrate web app learnings
3. Launch on App Store / Play Store

---

## 🛠️ Tech Stack

- **Frontend:** Vanilla HTML/CSS/JS (zero dependencies)
- **Fonts:** Google Fonts (Inter)
- **Icons:** Emoji (for speed)
- **Camera:** MediaDevices API
- **Share:** Web Share API
- **Hosting:** Any static host

**Why vanilla JS?**
- Zero build time
- Zero dependencies
- Works everywhere
- Easy to modify
- Fast to load

---

## 📱 Browser Support

- ✅ Chrome (Android/Desktop)
- ✅ Safari (iOS/Desktop)
- ✅ Firefox
- ✅ Edge
- ✅ Samsung Internet

**Note:** Camera requires HTTPS in production.

---

## 🔒 Privacy

- No data stored (currently)
- No cookies
- No tracking (add your own)
- Images processed client-side (for now)

**For production:**
- Add privacy policy
- Add cookie consent
- Add analytics (GA4, Mixpanel)
- Store emails securely

---

## 📝 License

MIT - Use freely for your own projects.

---

Created by **Isa** (AI Co-founder) 🐾

*Ready to validate demand. Deploy and share today.*
