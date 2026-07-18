# ADR-0001: Local-first product architecture

- Status: Proposed
- Date: 2026-07-18
- Owners: Product, Architecture, Data

## Context

Interect handles personal notes, research files, annotations and source-linked knowledge. Users expect immediate editing, offline access and control over whether content leaves the device. Treating a remote service as the source of truth would make core editing dependent on network and complicate recovery.

## Decision

The local database and AssetStore are the source of truth. CloudKit and optional AI services are adapters over local state.

Core editing, search, source navigation and export must work offline. A command commits locally before it becomes eligible for sync. Remote changes are merged into the same local repository and never rendered directly from CloudKit records.

## Consequences

### Positive

- Immediate and reliable editing
- Full offline capability
- Easier deterministic tests and recovery
- Cloud provider can change without rewriting the domain
- Explicit privacy boundary

### Negative

- Requires a sync queue, conflict policy and local storage management
- Multiple devices can diverge temporarily
- Shared collaboration requires more work than server-authoritative state

## Alternatives considered

### Cloud-first document service

Rejected for 1.0 because it makes the network part of every critical path and requires operating a backend before product-market fit.

### File-document-only architecture

Useful for export and user portability, but insufficient as the internal store for indexing, cross-board links and incremental sync.

## Guardrails

- No core feature may require a successful network request.
- Sync state must be visible but must not block local commits.
- Cloud records are projections of local entities and operations.
- User data export must not require an active subscription.

## Validation

- Create, edit, search and export while offline.
- Reconnect after a large local operation backlog without data loss.
- Delete CloudKit data and reconstruct it from local state in a test environment.

## Supersession trigger

A future collaboration architecture may add a server-authoritative shared session, but personal local documents remain local-first.
