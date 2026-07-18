# ADR-0006: Workspace to CloudKit zone mapping

- Status: Proposed
- Date: 2026-07-18
- Owners: Sync, Data, Product

## Context

Interect needs reliable personal sync first and project sharing later. CloudKit custom zones provide atomic changes, change tokens and zone-wide sharing. Cross-zone references are restricted, so the domain boundary must match the sync boundary.

## Decision

Map one Workspace to one CloudKit custom record zone.

- Workspace records, Boards, Items, Edges and Asset metadata live in the same zone.
- Original binaries are uploaded as `CKAsset` records referenced by content hash.
- Cross-workspace links use UUID locators, not `CKRecord.Reference`.
- `CKSyncEngine` manages incremental fetch/send state.
- Sharing a Workspace uses zone-wide sharing as the default model.

## Consequences

### Positive

- Workspace is a clear sync and sharing unit
- Atomic-by-zone operations are available
- Deleting or sharing a project has a natural boundary
- Cross-device state is easier to diagnose

### Negative

- Very large Workspaces can create large zones
- Moving a Board between Workspaces requires record migration
- Cross-workspace references need application-level resolution

## Alternatives considered

### One zone per Board

Improves small sync units but complicates Workspace sharing, cross-board assets and atomic moves.

### One zone for the entire account

Simpler initially but creates a large failure and sharing boundary.

### Custom backend

Deferred until collaboration or platform requirements exceed CloudKit.

## Guardrails

- Local IDs are UUIDs independent of CloudKit record names.
- Sync never uses CloudKit references for cross-zone relationships.
- Every remote deletion becomes a local tombstone before compaction.
- Sync errors are classified as retryable, conflict or user action required.
- Workspace move is an explicit long-running operation with rollback.

## Validation

- Offline changes on two devices converge deterministically.
- A Workspace can be shared without exposing other Workspaces.
- A Board move between Workspaces preserves assets and links or reports unresolved links.
- Full CloudKit rebuild from local state succeeds in a test container.

## Supersession trigger

A custom collaboration backend may replace transport, but Workspace remains the primary share and permission boundary unless a new ADR changes it.
