# ADR-0004: Command-based document mutations

- Status: Proposed
- Date: 2026-07-18
- Owners: Domain, Canvas, Sync

## Context

The prototype mutates arrays directly from SwiftUI views. Undo stores complete canvas snapshots, and editing events can save the entire document repeatedly. This does not scale to large assets, sync, AI proposals or reliable version history.

## Decision

All persistent document changes are represented as typed commands and applied by a `CommandDispatcher`.

A command:

- validates preconditions
- executes in one repository transaction
- produces an inverse command when locally undoable
- appends a normalized operation for sync/history
- returns affected entity identifiers

Gesture preview remains in session state. One command is committed when the gesture ends.

## Consequences

### Positive

- Compact Undo/Redo
- Clear transaction boundaries
- Reusable changes from UI, AI, import and sync
- Deterministic tests
- Foundation for version history and collaboration

### Negative

- More types and ceremony
- Command coalescing requires careful behavior
- Schema changes may require operation migration or compaction

## Alternatives considered

### Full document snapshots

Rejected because memory and storage grow with every binary and object.

### Direct repository mutations from features

Rejected because Undo, sync and analytics would duplicate mutation semantics.

### Event sourcing as the only source of truth

Not selected for 1.0. A normalized operation log is retained, but current entity tables remain the fast materialized source of truth.

## Guardrails

- Views never write persistence directly.
- Remote operations are not added to the local Undo stack.
- Text edits are coalesced by editing session and debounce window.
- AI applies commands only after user confirmation.
- Operation compaction must preserve the latest materialized state and required history.

## Validation

- Property tests apply a command and inverse and compare state.
- A 10-second drag creates one committed command.
- Undo memory is independent of PDF/image byte size.
- Sync serialization round-trips every command-derived operation.

## Supersession trigger

If real-time collaboration requires CRDT-native operations, command contracts remain the UI boundary while operation internals may be superseded.
