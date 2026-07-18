# ADR-0002: SQLite/GRDB as the primary store

- Status: Proposed
- Date: 2026-07-18
- Owners: Data, Architecture

## Context

The prototype serializes the full canvas, including binary data, into one UserDefaults value. The product roadmap requires partial updates, transactions, schema migration, full-text search, spatial queries, operation history and controlled sync metadata.

SwiftData provides an attractive Apple-native object model and versioned migrations, but Interect needs direct access to SQLite capabilities and predictable persistence behavior across complex workloads.

## Decision

Use SQLite through GRDB as the primary structured store.

- `DatabasePool` or `DatabaseQueue` is selected after benchmark; the repository API hides this choice.
- WAL is enabled for production databases where supported.
- Migrations are explicit and sequential.
- FTS5 stores searchable text.
- Spatial visibility uses SQLite R*Tree or an in-memory index rebuilt from DB records.
- The domain layer never imports GRDB.

## Consequences

### Positive

- Explicit transactions and schema
- Efficient partial updates
- Mature migration and recovery tooling
- FTS5 and spatial extension options
- Easy fixtures and inspection
- Clear ownership of sync metadata

### Negative

- Additional dependency and SQL knowledge
- More mapping code than direct SwiftData models
- Engineers must preserve actor/thread rules around database access

## Alternatives considered

### SwiftData

Retained as a fallback option if a time-boxed spike proves all required query, migration, performance and sync behaviors. Not selected as the default because several critical requirements need lower-level control.

### Core Data

Mature, but introduces object-context complexity without giving the same straightforward access to FTS and custom operation tables.

### JSON files

Rejected as the main store because partial updates, indexing and concurrent access would require rebuilding database behavior.

## Guardrails

- No feature writes SQL outside the Data module.
- Every migration has forward tests from all supported versions.
- Large binary content never enters normal entity rows.
- Database writes are not performed for hover, selection or drag preview.
- Schema changes require an ADR update when they alter domain boundaries.

## Validation

- Import, query and mutate the performance fixture.
- Crash during a transaction and verify consistency.
- Run migration tests from every released schema.
- Measure board-open and edit commit p95.

## Supersession trigger

Replace only if another store demonstrates equivalent control, portability and performance with lower operational cost through an accepted ADR.
