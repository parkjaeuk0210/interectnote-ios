# ADR-0005: Hybrid virtualized canvas renderer

- Status: Proposed
- Date: 2026-07-18
- Owners: Canvas, Performance, Design

## Context

The prototype creates a SwiftUI view for every item, sorts all items by `zIndex`, decodes original images in item views and embeds a live `PDFView` for each PDF object. Pan and zoom can therefore invalidate the entire tree.

Interect must support large mixed-media boards while preserving native text editing, controls and accessibility.

## Decision

Use a hybrid renderer with viewport virtualization and semantic level of detail.

- SwiftUI renders visible interactive cards.
- `Canvas`, Core Animation or Metal-backed layers render high-count edges, grid and ink.
- A spatial index returns visible items plus overscan.
- Only the active item uses the full editing hierarchy.
- Images and PDFs use thumbnails on the board.
- A single `CanvasTransform` owns every coordinate conversion.

## Consequences

### Positive

- Native controls where they matter
- High-count static content avoids excessive SwiftUI nodes
- Predictable performance budget
- LOD improves both orientation and speed

### Negative

- More complex hit testing and accessibility mapping
- Multiple render layers must stay synchronized
- Animation across layers requires explicit design

## Alternatives considered

### Pure SwiftUI for all items

Retained for prototypes and low-count screens, but rejected as the scaling architecture.

### Full custom Metal renderer

Could maximize throughput but would require rebuilding text editing, controls, accessibility and platform behavior. Reserved for specific bottlenecks.

### UIKit/AppKit only

Does not remove the need for virtualization and increases cross-platform duplication.

## Guardrails

- No feature may bypass `CanvasTransform` for persisted geometry.
- Visibility queries use an overscan margin to avoid pop-in.
- Render detail is a function of scale and interaction state.
- Accessibility exposes a linear Board Outline independent of visual culling.
- Performance fixtures are version-controlled.

## Validation

- 1,000 items and 5,000 edges fixture meets frame pacing target.
- Zoom around pointer/finger preserves anchor.
- Hit testing remains correct at min/max scale.
- Offscreen PDFs do not create `PDFView` instances.
- VoiceOver can reach every item through Outline Mode.

## Supersession trigger

Specific layers may move to Metal after profiling, while virtualization, transform ownership and accessibility contracts remain.
