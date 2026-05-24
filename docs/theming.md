# Theming

`dist/json-tree.css` is self-contained and exposes every colour,
radius and font as a CSS custom property. Override on
`.json-tree-wrapper` (or any ancestor) to theme — the docs site you
are reading does exactly that, riding the Material light/dark palette
toggle in the header.

## The variable surface

| Variable | Purpose |
| --- | --- |
| `--jt-bg` | Wrapper background |
| `--jt-fg` | Body text colour |
| `--jt-key` | Object keys |
| `--jt-line` | Index bracket hairline + gutter rule |
| `--jt-marker` | Index labels + hover accents |
| `--jt-link` / `--jt-link-hover` | Resolved-link colour + hover |
| `--jt-null` | `null` leaf colour (italic) |
| `--jt-bool-num` | Boolean + number leaves |
| `--jt-str` | Plain string leaves |
| `--jt-copy-fg` | Copy chip text colour |
| `--jt-copy-border` | Copy chip border |
| `--jt-copy-hover-fg` / `--jt-copy-hover-bg` | Hover state |
| `--jt-copy-ok-fg` / `--jt-copy-ok-bg` | Success flash |
| `--jt-radius` | Wrapper border radius |
| `--jt-font-mono` | Monospace family for the tree |
| `--jt-font-size` | Base font size |

## Worked example — dark theme

```css
.json-tree-wrapper {
  --jt-bg: #161b22;
  --jt-fg: #e6edf3;
  --jt-key: #adbac7;
  --jt-line: #30363d;
  --jt-marker: #768390;
  --jt-link: #58a6ff;
  --jt-link-hover: #79c0ff;
  --jt-str: #e6edf3;
  --jt-copy-fg: #adbac7;
  --jt-copy-border: #30363d;
  --jt-copy-hover-fg: #e6edf3;
  --jt-copy-hover-bg: #21262d;
}
```

## Worked example — Material Design tie-in

The docs site uses this override to ride the Material theme toggle:

```css
.json-tree-wrapper {
  --jt-bg:        var(--md-code-bg-color);
  --jt-fg:        var(--md-typeset-color);
  --jt-key:       var(--md-default-fg-color--light);
  --jt-line:      var(--md-default-fg-color--lightest);
  --jt-marker:    var(--md-default-fg-color--light);
  --jt-link:      var(--md-primary-fg-color);
  --jt-link-hover: var(--md-accent-fg-color);
  --jt-str:       var(--md-typeset-color);
  --jt-copy-fg:        var(--md-default-fg-color--light);
  --jt-copy-border:    var(--md-default-fg-color--lightest);
  --jt-copy-hover-fg:  var(--md-typeset-color);
  --jt-copy-hover-bg:  var(--md-default-bg-color);
  --jt-copy-ok-fg:     var(--md-primary-bg-color);
  --jt-copy-ok-bg:     var(--md-primary-fg-color);
}
```

That single block is what you see ride the dark-mode toggle in the
[live demo](demo.md). The same trick works against any design system
that exposes its colours as custom properties (Tailwind themes,
Bootstrap 5+, Open Props, …).

## Class-level overrides

If you need to depart from a single colour ramp — say, a hot-pink
`v-policy` link to distinguish minting events at a glance — target
the class directly:

```css
.v-policy {
  color: #ff2d6f;
  text-decoration-color: #ff2d6f;
}
```

The default link classes (`.v-txid`, `.v-addr`, `.v-policy`, `.v-txin`)
all use `text-decoration: underline dotted` rather than
`border-bottom`, so a host stylesheet shipping
`border-bottom: 1px dotted` on `<a>` won't stack into a double
underline.
