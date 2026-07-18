# ADR-0007: Source anchor representation

- Status: Proposed
- Date: 2026-07-18
- Owners: Source Reader, Domain, Search

## Context

The product differentiator is the ability to return from a card, claim or AI result to the original source location. Storing only copied text or a page number is insufficient because identical text can occur multiple times and source files may be updated.

## Decision

Represent a source link as a typed `SourceAnchor` with stable asset identity, format-specific locator, selected content and re-anchoring context.

For PDFs, persist:

- Asset ID and content hash
- page index
- display box
- line-level page-space rectangles where available
- selected text
- optional character range
- context before and after

For images or scans, persist OCR text plus image-space polygons. Web and text formats add their own locator variants behind the same domain type.

## Consequences

### Positive

- Exact source navigation
- Citation generation
- Source change detection
- Shared behavior across PDF, OCR and future web clips
- AI can cite stable anchors instead of raw strings

### Negative

- Locator formats require versioning
- Re-anchoring can be ambiguous
- PDF coordinate conventions and rotation require careful normalization

## Alternatives considered

### Page number plus text

Too weak for precise highlighting and repeated text.

### Screenshot-only excerpt

Preserves appearance but loses searchable text, accessibility and adaptable citation.

### PDF annotation object as the source of truth

Ties Interect knowledge data to mutable PDF files and does not generalize to other source types.

## Guardrails

- Store coordinates in the source format's canonical space, not view pixels.
- Store a locator version.
- Never silently attach to a low-confidence new location.
- `needsReview` is a first-class state.
- Export includes human-readable citation even if navigation data is unavailable.

## Validation

- Rotate, zoom and resize Reader while preserving highlight.
- Reopen after app restart and navigate to the same selection.
- Replace a PDF with a modified revision and test automatic and manual re-anchor.
- Round-trip anchors across iOS and macOS.

## Supersession trigger

New source formats add locator variants without replacing the core anchor identity and re-anchoring contract.
