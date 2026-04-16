# UI State Matrix

This matrix defines the canonical interactive states for core UI components.
All implementations should map to these tokenized states from `lib/theme/app_theme.dart` and `lib/theme/design_tokens.dart`.

## Buttons

### ElevatedButton
- Enabled: brand background, white foreground, elevation 3
- Hovered: brand background, elevation 5
- Pressed: darker brand (`#7C3AED`), elevation 1
- Focused: brand background + default focus ring from Material
- Disabled: neutral surface (`#E2E8F0` light / `#334155` dark), reduced contrast foreground

### OutlinedButton
- Enabled: transparent background, semantic border (`#94A3B8` light / `#64748B` dark)
- Hovered: subtle overlay (`#12000000`)
- Pressed: subtle overlay (`#12000000`)
- Focused: border switches to brand with 2px stroke
- Disabled: weak border (`#CBD5E1` light / `#475569` dark), muted foreground

### IconButton (side actions)
- Enabled: semantic background (action dependent), strong foreground contrast
- Hovered/Pressed: ripple from Material overlay
- Focused: visible focus highlight via Ink/Material
- Disabled: inherited Material disabled state

## Forms

### TextField/InputDecoration
- Enabled: subtle filled surface + neutral border
- Focused: brand border 1.6px
- Error: danger border 1.4px
- Disabled: low-contrast border and container
- Hint: secondary text color for each theme

### ChoiceChip
- Enabled: theme surface
- Selected: brand background + white foreground
- Disabled: inherited Material disabled style
- Pressed/Hovered: Material overlay

## Cards

### CardTheme / GlassCard
- Resting: rounded large radius, low elevation, neutral border
- Hovered/Pressed: overlay through InkWell
- Focused: Ink focus highlight visible
- Disabled (if applicable): consumer controls opacity

## Navigation

### Bottom Navigation Item
- Enabled: semantic button + InkWell ripple
- Selected: brand pill icon + stronger label weight
- Unselected: secondary text color
- Dynamic Text: scale clamped to preserve layout

## Accessibility Requirements
- Minimum tap target: 48x48
- Text contrast: target WCAG AA
- Semantic labels for icon-only actions
- Tooltips for icon buttons
- Timer and progress use explicit semantics labels
- Dynamic text should not overflow critical controls
