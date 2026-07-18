# ADR-0008: Intelligence provider and privacy boundary

- Status: Proposed
- Date: 2026-07-18
- Owners: Intelligence, Privacy, Product

## Context

Interect can benefit from summarization, clustering, retrieval and structured transformations. On-device model availability varies by OS, device, language and model version. Optional cloud models introduce data transfer, cost and policy concerns.

Directly coupling UI features to one model would make behavior brittle and privacy boundaries unclear.

## Decision

All AI capabilities use an `IntelligenceProvider` abstraction and return an `IntelligenceProposal` rather than mutating the document.

Providers:

- On-device Foundation Models provider when available
- Optional cloud provider with explicit user consent
- Disabled provider for unsupported or restricted environments

A request contains only an explicit scope. Retrieval tools return selected or relevant local items. The proposal contains citations, assumptions, warnings and typed commands that require confirmation.

## Consequences

### Positive

- Provider and model can change independently
- Offline AI can coexist with cloud AI
- Clear privacy UX
- Deterministic proposal application and Undo
- Easier model-version evaluation

### Negative

- Results may differ by provider and device
- Requires capability negotiation and fallback UI
- Citation validation and prompt evaluation add engineering work

## Alternatives considered

### One cloud model for all features

Rejected as the default because it makes private content transfer and network availability mandatory.

### On-device model only

Preferred for many tasks but cannot be the sole strategy because availability and capability vary.

### Model writes directly to the database

Rejected because it bypasses review, Undo and domain validation.

## Guardrails

- No model receives the entire library by default.
- Cloud requests show and log the selected scope without retaining note content in analytics.
- Every structural change is previewed and applied through commands.
- Unsupported devices retain all non-AI core workflows.
- Prompts are versioned and evaluated against a fixed dataset after OS/model updates.
- Generated claims distinguish quoted source content from inference.

## Validation

- Disable all AI providers and complete the core research workflow.
- Compare provider output against structured schemas and citation coverage.
- Verify a proposal can be partially accepted and fully undone.
- Confirm cloud payload contains only user-approved items.

## Supersession trigger

A future trusted local model may become the default, but provider boundaries and proposal-based mutation remain unless explicitly replaced.
