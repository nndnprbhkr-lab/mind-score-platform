# Micro-Interactions & Visual Feedback Patterns

## Option 1: Interactive Slider - Detailed Flow

### Mobile View (375px)
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Relationship Dynamics
  8 / 22 ████░░░░░░
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[HEADER ANIMATION]
Question slides in from top, fades in over 200ms

Question Text (fade in):
┌─────────────────────────────┐
│ I feel secure in my         │
│ relationships.              │
│                             │
│ Rate your agreement:        │
└─────────────────────────────┘

[SLIDER SECTION]
Emotions:        😢        😐        😊
Range labels:  Disagree  Neutral   Agree

Visual slider:
[😢] ─────●───────[😊]
     Strongly   Strongly
     Disagree    Agree

Color indicator (under track):
🔴 Red → 🟡 Yellow → 🟢 Green

[HAPTIC FEEDBACK]
- At each 5-step mark: light vibration (10ms)
- On drag: continuous haptic at 60fps
- On release: confirmation vibration (50ms)

[BUTTON STATE]
[← Back]  [Next →]
(Back appears only after Q2)
(Next button changes color: gray→blue when answered)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Micro-interactions:
- Slider thumb scales up 1.2x on touch (visual feedback)
- Emoji faces animate on drag (rotate/scale slightly)
- Progress bar fills 1/22 on answer
- Number appears above slider: "3 / 5" (user-friendly rating)
- Swipe up/down = next/previous (swiping feels natural)
```

### Desktop View (1280px)
```
┌──────────────────────────────────────────┐
│  ← Back | Relationship Dynamics | ⊗       │
├──────────────────────────────────────────┤
│                                          │
│         Question 8 of 22                 │
│         ████░░░░░░ 36%                   │
│                                          │
│   I feel secure in my relationships.     │
│                                          │
│   😢 ────────●────────── 😊              │
│  Disagree             Agree              │
│                                          │
│   [Your answer: 3/5 - Agree]             │
│                                          │
│                     [← Back] [Next →]    │
│                                          │
└──────────────────────────────────────────┘

Sidebar (optional on desktop):
- Summary of previous answers
- Dimension hints: "You're leaning toward Secure..."
- Time spent: "~3 min so far"
```

### Animation Timeline
```
Q1 → Q2 transition:
0ms:     Q1 answer recorded, button highlighted (green flash)
200ms:   Q1 slides out right, Q2 slides in from left
400ms:   Q2 question fades in, slider appears
600ms:   Progress bar animates from 4% to 9%
```

### Accessibility Considerations
```
Screen Reader:
- "Question 8 of 22. I feel secure in my relationships."
- "Slider, range from Strongly Disagree to Strongly Agree"
- "Current value: Agree"
- "Use arrow keys to adjust"

Keyboard Nav:
- Tab to slider
- Left/Right arrows: adjust by 1 step
- Shift+Left/Right: adjust by 5 steps
- Space: select current position

Color Blind:
- Don't rely on color alone
- Add pattern (stripes) under color bar
- Use numbers: "3/5" in addition to color
```

---

## Option 2: Card-Based Conversation - Detailed Flow

### Mobile Experience
```
┌───────────────────────────┐
│ SECTION INDICATOR         │
│ Attachment Security       │
│ ● ● ○ ○                   │  (4 dimensions, current is dot 1)
│ 2 / 6 ██░░░░               │
└───────────────────────────┘

[CARD ENTRANCE]
Card slides up from bottom, bounces slightly (bounce ease-out, 400ms)

┌───────────────────────────┐
│                           │
│  I feel secure in my      │
│  relationships.           │
│                           │
│  [Strongly Disagree]      │
│  [Disagree]               │
│  [Neutral]                │
│  [Agree]                  │
│  [Strongly Agree]         │
│                           │
└───────────────────────────┘

[BUTTON INTERACTIONS]
- On tap: Button grows 1.1x, fills with color (300ms spring animation)
- Other buttons fade out (opacity: 0.3)
- Selected button shows checkmark and stays highlighted
- Tap again: Deselect (revert to normal)

[NAVIGATION]
Below card:
[↑ Previous] [Next ↓]

Or swipe:
- Swipe up = next question
- Swipe down = previous question
- Swiping reveals partial next card (hint at what's coming)
```

### Desktop Experience
```
┌─────────────────────────────────────────┐
│         Attachment Security             │
│    Question 2 of 6 in this section      │
│    ██░░░░░░░░░░░░░░░░░░ 33%            │
└─────────────────────────────────────────┘

Center card (600px wide):
┌─────────────────────────────────────────┐
│                                         │
│   I feel secure in my relationships.   │
│                                         │
│                                         │
│            [Strongly Disagree]          │
│            [Disagree]                   │
│            [Neutral]                    │
│            [Agree]                      │
│            [Strongly Agree]             │
│                                         │
│                                         │
│           [← Back]  [Next →]           │
│                                         │
└─────────────────────────────────────────┘

Right sidebar:
Progress overview
- Attachment Security: ██░ (2/6)
- Conflict Engagement: ░░░░░░ (0/6)
- Emotional Expression: ░░░░░░ (0/6)
- Love Language: ░░░░ (0/4)
```

### Button Interaction States
```
Default:
┌──────────────────┐
│ Strongly Disagree│  (40px tall, rounded)
│ (Light gray bg)  │
└──────────────────┘

Hover (desktop):
┌──────────────────┐  (shadow appears, bg lightens)
│ Strongly Disagree│
└──────────────────┘

Pressed:
┌──────────────────┐  (bg fills with brand color, white text)
│ Strongly Disagree│  (✓ checkmark appears)
│ (Brand color)    │
└──────────────────┘

Unselected (others):
┌──────────────────┐  (opacity: 0.4, text gray)
│ Disagree         │
└──────────────────┘
```

### Animation Sequence
```
Card entrance: 0-400ms
- Y position: +100px → 0px (easeOutCubic)
- Opacity: 0 → 1
- Scale: 0.95 → 1.0
- Bounce effect at end

Button selection: 0-300ms
- Scale: 1 → 1.05 → 1 (click animation)
- Color transition: gray → brand color
- Checkmark fades in (200ms delay, 150ms duration)

Card exit: 0-300ms (on next)
- Y position: 0 → -100px (easeInCubic)
- Opacity: 1 → 0
- Next card slides in from below simultaneously
```

---

## Option 4: Emotion Wheel - Interaction Pattern

### Visual Layout
```
┌─────────────────────────────────────┐
│ Question 5 of 22                    │
│                                     │
│ I feel anxious when apart from my   │
│ partner.                            │
│                                     │
│         Strongly Disagree           │
│              ↓                      │
│        😢   😟   😐   🙂   😊       │
│         ◀─────●─────▶               │
│         Emotion Scale               │
│              ↑                      │
│        Strongly Agree               │
│                                     │
│ Selected: Neutral (😐)              │
│ Confidence: Moderate                │
│                                     │
│          [Next Question]            │
└─────────────────────────────────────┘

Interaction:
1. User taps on emoji (e.g., 🙂)
2. Emoji scales up 1.3x (200ms spring)
3. Checkmark appears below emoji
4. Color ring grows around emoji (300ms)
5. Text updates: "Selected: Agree (Emotional)"
6. Next button highlights, ready to proceed
7. Can tap different emoji to change answer
```

### Color Rings (for intensity/confidence)
```
Ring 1 (Slight): Thin, light color
Ring 2 (Moderate): Medium thickness
Ring 3 (Clear): Thicker, saturated
Ring 4 (Strong): Extra thick, bold

Example for "Agree" (🙂):
    ◯◯◯◯    ← Strong agreement (all rings)
    ◯◯◯     ← Clear agreement (3 rings)
    ◯◯      ← Moderate agreement (2 rings)
    ◯       ← Slight agreement (1 ring)
```

### Desktop vs Mobile Adaptation
```
Mobile (375px):
Emoji horizontal: 😢 😟 😐 🙂 😊
Tap to select

Desktop (1280px):
Emoji circular wheel (360° radial):
        😢
    😟      😊
    😐      🙂
          ↓
Radial buttons with better spacing
Click center to confirm
```

---

## Option 5: Progressive Disclosure - Section Navigation

### Tab Navigation
```
┌────────┬────────┬────────┬────────┐
│ ✓      │ 2/6    │ ○      │ ○      │
│ Attach │Conflict│Express │ Love   │
└────────┴────────┴────────┴────────┘
   ↑ Current
  
Current section slides open:

┌─────────────────────────────┐
│ Attachment Security         │
│ Question 2 of 6             │
│ ██░░░░░░░░ 33%              │
│                             │
│ 💡 "Secure attachment means │
│    feeling safe & trusting" │
│ [Learn more ▼]              │
│                             │
│ I feel secure in my         │
│ relationships.              │
│                             │
│ ⊙ Strongly Disagree         │
│ ○ Disagree                  │
│ ○ Neutral                   │
│ ○ Agree                     │
│ ○ Strongly Agree            │
│                             │
│    [Skip] [Next →]          │
└─────────────────────────────┘

On "Learn more" tap:
Definition panel slides in from right:
┌──────────────────────────────┐
│ Secure Attachment            │
│ ════════════════════════════ │
│                              │
│ Being secure means:          │
│ • Feeling trust in partner   │
│ • Managing conflict calmly   │
│ • Seeking connection         │
│ • Recovery after conflict    │
│                              │
│ vs. Anxious Attachment:      │
│ • Fear of abandonment        │
│ • Need constant reassurance  │
│ • High emotional reactivity  │
│                              │
│ [← Back to Question]         │
└──────────────────────────────┘
```

### Smart Branching (Skip Logic)
```
User's responses to Q1-Q3 show strong "Secure" pattern
  ↓
System detects high confidence
  ↓
Offers: "You seem confident about Attachment.
         Skip remaining 3 questions? [Yes] [No]"
  ↓
If Yes: Jump to Conflict Engagement section
If No: Continue with Q4, Q5, Q6
```

---

## Option 6: Forced Choice (A/B Pairwise)

### Card Layout
```
┌──────────────────────────────────────┐
│ Which statement feels MORE true?     │
│ Progress: 18/55 comparisons          │
├──────────┬──────────┬──────────┐
│          │   VS     │          │
│ I feel   │    ⚔️    │ I worry  │
│ secure   │          │ about    │
│ in my    │  [Skip]  │ being    │
│relationship        │ abandoned│
│          │          │          │
│ [Select] │          │[Select]  │
└──────────┴──────────┴──────────┘

Animation on selection:
1. Tap left card
2. Card grows 1.2x and highlights (blue)
3. Right card fades (opacity 0.3)
4. Checkmark appears
5. "Selected!" indicator
6. Auto-advance after 1 second OR
7. Manual [Next] button appears
```

### Undo Feature
```
After selection:
┌──────────────────────────┐
│ You selected: "I feel    │
│ secure..."               │
│                          │
│ ✓ Recorded (0.5s delay) │
│ [← Undo] [Next →]       │
└──────────────────────────┘

If undo tapped within 2 seconds:
- Cards return to neutral
- Can select different option
- After 2 seconds, Undo button disappears
```

---

## Visual Design Tokens (for all options)

### Color Palette
```
Disagreement (negative): #E74C3C (red)
Neutral: #F39C12 (orange/gold)
Agreement (positive): #27AE60 (green)

Secure/Confident: #3498DB (blue)
Anxious/Insecure: #E67E22 (orange-red)
Avoidant: #95A5A6 (gray)
Engaged: #2ECC71 (green)

Text: #2C3E50 (dark gray)
Disabled/Hint: #95A5A6 (light gray)
Background: #FFFFFF (white)
Subtle bg: #ECF0F1 (very light gray)
```

### Typography
```
Heading (Question): 20px / 1.4 line-height
Body (Options): 16px / 1.6 line-height
Hint/Caption: 12px / 1.5 line-height
Button: 16px / 1.5 line-height, medium weight
```

### Spacing (8px grid)
```
Card padding: 24px (3 × 8)
Button height: 48px (6 × 8)
Between buttons: 16px (2 × 8)
Section spacing: 32px (4 × 8)
```

### Animations
```
Standard easing: cubic-bezier(0.4, 0.0, 0.2, 1)
Spring easing: cubic-bezier(0.34, 1.56, 0.64, 1)
Duration: 200-400ms for micro-interactions
```

---

## Recommendation: Hybrid Implementation

**Primary:** Option 2 (Card-based) + Option 5 (Progressive Disclosure)  
**Secondary:** Option 1 (Slider) for rapid follow-ups

### Phase 8 Implementation Tasks
```
✅ Create design tokens (colors, spacing, typography)
✅ Build custom slider widget (Option 1)
✅ Build card screen (Option 2)
✅ Implement swipe navigation
✅ Add progress indicators
✅ Implement section tabs (Option 5)
✅ Add accessibility (ARIA labels, keyboard nav)
✅ Haptic feedback on mobile
✅ A/B testing framework
```

**Estimated effort:** 2-3 sprints (80 hours)
