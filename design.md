# Mudda Design System

> **Version:** 2.0 — Premium Civic Platform
> **Last updated:** April 2026
> **Theme file:** `lib/shared/theme/`

---

## Philosophy

Mudda's design language is built around one idea: **civic participation should feel empowering, not bureaucratic**. The interface uses a premium "dark-first" aesthetic, rich gradients, and purposeful micro-animations to make reporting issues and engaging with your community feel like something worth doing.

Three principles guide every decision:

1. **Clarity** — Information hierarchy is always obvious. Users should never have to hunt for an action.
2. **Trust** — The design feels reliable and credible. Status indicators, official response badges, and severity colours are consistent and honest.
3. **Energy** — Interactions feel alive. Buttons respond, cards animate in, votes bounce. The app shouldn't be static.

---

## Color Palette

All colours live in [`lib/shared/theme/app_colors.dart`](lib/shared/theme/app_colors.dart). **Never hardcode hex values** anywhere else in the codebase.

### Brand Colors

| Token | Light | Dark | Hex (Light) | Usage |
|---|---|---|---|---|
| `primary` | Civic Indigo | — | `#4F46E5` | Buttons, links, active states |
| `primaryDarkTheme` | — | Soft Indigo | `#818CF8` | Primary actions in dark mode |
| `primaryLight` | Indigo-200 | — | `#C7D2FE` | Tinted backgrounds, chips |
| `primaryDark` | Indigo-800 | — | `#3730A3` | Hover/pressed states |
| `accent` | Emerald-500 | — | `#10B981` | Success actions, FABs, resolution stats |
| `accentDark` | Emerald-400 | — | `#34D399` | Accent in dark mode |

### Backgrounds

| Token | Value | Notes |
|---|---|---|
| `scaffoldBackground` | `#F5F7FA` | Light mode page background — cool off-white |
| `scaffoldBackgroundDark` | `#0F172A` | **Midnight Navy** — the dark mode base |
| `surface` | `#FFFFFF` | Cards, sheets (light) |
| `surfaceDark` | `#1E293B` | Slate-800 — elevated dark surfaces |
| `surfaceElevatedDark` | `#334155` | Slate-700 — modals, bottom sheets |

> [!IMPORTANT]
> Dark mode is **Midnight Navy** (`#0F172A`), not generic dark grey. This is intentional — it's warmer and more premium-feeling than a flat black or `#212121`.

### Text Colors

| Token | Light | Dark |
|---|---|---|
| `textPrimary` | `#0F172A` Slate-900 | `#F1F5F9` Slate-100 |
| `textSecondary` | `#64748B` Slate-500 | `#94A3B8` Slate-400 |
| `textHint` | `#CBD5E1` Slate-300 | `#475569` Slate-600 |
| `textOnPrimary` | `#FFFFFF` | `#FFFFFF` |

### Status Colors

These are semantically meaningful and should only be used for their intended purpose.

| Token | Hex | Usage |
|---|---|---|
| `success` | `#10B981` | Resolved/Closed issues, positive stats |
| `warning` | `#F59E0B` | Open issues, pending states |
| `error` | `#EF4444` | Urgent issues, destructive actions |
| `info` | `#3B82F6` | Informational states, links |

### Issue Status Mapping

```dart
AppColors.getStatusColor(status) // always use this helper
```

| Status | Color |
|---|---|
| `OPEN` | `warning` (Amber) |
| `SOLVED` / `CLOSED` | `success` (Emerald) |
| `PENDING` | `info` (Sky Blue) |
| `URGENT` | `error` (Rose) |

### Severity Score Mapping (1–5)

```dart
AppColors.getSeverityColor(score) // 1 = low, 5 = critical
```

| Score | Color |
|---|---|
| 1 | Emerald |
| 2 | Lime |
| 3 | Amber |
| 4 | Orange |
| 5 | Rose |

---

## Gradients

Gradients give the UI energy and distinguish primary surfaces from neutral ones. They are defined as constants on `AppColors` — use them directly, don't redefine angles or colours inline.

| Token | Colors | Usage |
|---|---|---|
| `primaryGradient` | Indigo → Violet `#4F46E5 → #7C3AED` | Avatars, selected chips, vote pills, key CTAs |
| `ctaGradient` | Rose → Red `#EF4444 → #DC2626` | "Raise your voice" banner, destructive prompts |
| `successGradient` | Teal → Emerald `#059669 → #10B981` | Resolution rate, solved indicators |
| `infoGradient` | Blue `#2563EB → #3B82F6` | Avg response time card, neutral stats |
| `headerGradientDark` | Navy `#1E1B4B → #312E81` | Dashboard hero header in dark mode |

**Usage example:**
```dart
decoration: BoxDecoration(
  gradient: AppColors.primaryGradient,
  borderRadius: BorderRadius.circular(14),
)
```

---

## Typography

All type uses **Plus Jakarta Sans** (via `google_fonts`). Styles are defined in [`lib/shared/theme/app_typography.dart`](lib/shared/theme/app_typography.dart).

| Style | Size | Weight | Usage |
|---|---|---|---|
| `displayLarge` | 32px | Bold | Hero splash text |
| `headlineLarge` | 24px | ExtraBold (w800) | Page titles |
| `headlineMedium` | 20px | Bold (w700) | Section headers |
| `headlineSmall` | 18px | SemiBold (w600) | Subsection labels |
| `titleLarge` | 18px | Bold (w700) | Card titles |
| `titleMedium` | 16px | SemiBold (w600) | List item titles |
| `titleSmall` | 14px | SemiBold (w600) | Small titles, sub-labels |
| `bodyLarge` | 16px | Regular | Main body, descriptions |
| `bodyMedium` | 15px | Regular | Standard body text |
| `bodySmall` | 13px | Regular | Secondary body, captions |
| `labelLarge` | 14px | SemiBold (w600) | Button labels |
| `labelMedium` | 12px | SemiBold (w600) | Tags, chips |
| `labelSmall` | 11px | Medium (w500) | Timestamps, meta text |

> [!TIP]
> Always use `Theme.of(context).textTheme.*` in shared widgets. Only drop to `GoogleFonts.plusJakartaSans(...)` directly when you need precise letter-spacing or weight that the theme style doesn't cover (e.g., hero numbers).

---

## Spacing & Shape

### Border Radii

| Context | Radius |
|---|---|
| Cards, containers | `20px` |
| Input fields, buttons | `14px` |
| Chips, badges, pills | `24px` (fully rounded) |
| Small icon containers | `10–12px` |
| Map containers | `24px` |
| Bottom sheets | `28px` (top corners) |

### Spacing Scale

Use multiples of **4px**. Common values:

| Token | Value | Usage |
|---|---|---|
| XS | `4px` | Icon gaps |
| S | `8px` | Inner component gaps |
| M | `12px` | Between related elements |
| L | `16px` | Section padding, list gaps |
| XL | `20–24px` | Card padding, section spacing |
| XXL | `32px` | Between major sections |

---

## Glassmorphism

The `GlassContainer` widget (`lib/shared/widgets/glass_container.dart`) applies a frosted-glass effect using Flutter's `BackdropFilter`.

```dart
GlassContainer(
  blur: 12,           // blur radius — 8 to 16 is ideal
  borderRadius: 20,
  padding: EdgeInsets.all(16),
  child: ...,
)
```

- Used on: **bottom navigation bar**, action sheets, floating cards over maps
- Light mode: fills with `AppColors.glassLight` — white at 91% opacity
- Dark mode: fills with `AppColors.glassDark` — Slate-800 at 80% opacity

> [!NOTE]
> `BackdropFilter` is GPU-intensive. Don't stack multiple glass layers or apply it inside frequently-rebuilding list items.

---

## Component Patterns

### Bottom Navigation Bar

The nav bar uses a `BackdropFilter` for a frosted-glass effect. Selected items animate with:
- **Background pill**: Indigo at 12% opacity, `12px` radius
- **Icon**: switches to filled variant
- **Label**: weight increases from `w500` → `w700`

All transitions use `AnimatedContainer` + `AnimatedDefaultTextStyle` with `250ms` `easeInOut`.

### Issue Card

Each card entry uses a **slide-up + fade-in** animation (`400ms`, `easeOut`). Key design decisions:

- **Avatar**: always shows a gradient (`primaryGradient`) circle with the user's first initial, falling back to their photo if available
- **Vote button**: a pill that switches from a neutral outlined state to a filled gradient on press, with a **bounce scale animation** (`1.0 → 1.35 → 1.0`, `180ms`) and `HapticFeedback.lightImpact()`
- **Status badge**: pill shape, color-tinted background + matching border, `6px` dot indicator

### Category Chips (Feed Screen)

Selected state uses `primaryGradient` fill with white text. Unselected state uses a subtle border on a tinted background. Transitions via `AnimatedContainer` at `220ms`.

### Offline Banner

Gradient amber strip (`#D97706 → #F59E0B`) with a rounded icon container and `w600` text. More premium than the flat `Colors.amber.shade800` it replaced.

---

## Elevation & Shadows

Rather than Material Design numeric elevation levels, shadows are defined contextually:

| Surface | Shadow |
|---|---|
| Issue cards | `Colors.black` at 5% opacity, `blurRadius: 20`, `offset: (0, 6)` |
| Dashboard stat cards | `Colors.black` at 4% opacity, `blurRadius: 16`, `offset: (0, 6)` |
| Gradient cards (info/cta) | Matching color at 20–30% opacity for a "glow" effect |
| Map container | `Colors.black` at 10–30% opacity (light/dark), `blurRadius: 20`, `offset: (0, 8)` |

---

## Dark Mode Checklist

When adding a new screen or widget, ensure:

- [ ] Read `final isDark = Theme.of(context).brightness == Brightness.dark;` at the top
- [ ] Use `AppColors.*Dark` token variants, not hardcoded hex
- [ ] `scaffoldBackgroundColor` comes from the theme, not a hardcoded value
- [ ] Shadows become more prominent in dark (higher opacity) — light shadows get lost
- [ ] Gradient cards use `AppColors.headerGradientDark` instead of `primaryGradient` where appropriate

---

## File Map

```
lib/
├── shared/
│   ├── theme/
│   │   ├── app_colors.dart       ← All color tokens & gradients
│   │   ├── app_theme.dart        ← Light & dark ThemeData
│   │   ├── app_typography.dart   ← TextStyle scale (Plus Jakarta Sans)
│   │   └── theme_controller.dart ← Riverpod ThemeMode notifier
│   └── widgets/
│       └── glass_container.dart  ← Reusable frosted-glass surface
└── core/
    └── navigation/
        └── bottom_nav_shell.dart ← App shell with glassmorphic nav bar
```
