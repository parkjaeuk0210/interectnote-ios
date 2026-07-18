# ADR-0003: Content-addressed asset storage

- Status: Proposed
- Date: 2026-07-18
- Owners: Data, Import, Sync

## Context

Images and files are currently stored as `Data` inside canvas model values and are repeatedly encoded with the entire document. This increases memory, save latency, undo cost and corruption blast radius.

## Decision

Store original binaries in an AssetStore keyed by SHA-256 content hash. The database stores asset metadata and references.

```text
Assets/ab/cd/<sha256>
```

Import is staged:

1. copy to a temporary file
2. validate type and size
3. stream hash
4. atomically move to content path
5. insert or reuse metadata
6. generate thumbnail/OCR asynchronously

Original assets are immutable. Edits create a new asset version. Derived files are disposable caches.

## Consequences

### Positive

- Deduplication
- No full-document binary re-encoding
- Atomic import and easier recovery
- Independent thumbnail and OCR lifecycle
- Efficient CKAsset mapping

### Negative

- Requires reference counting or garbage collection
- Orphan files and missing files need diagnostics
- File access and protection policy must be managed carefully

## Alternatives considered

### BLOBs in SQLite

Possible for small assets, but large PDFs and images make backup, sync and streaming less convenient. Small thumbnails may still be stored as blobs if benchmarks justify it.

### Original external file references only

Rejected as default because security-scoped bookmarks can break and users expect imported work to remain available. External references may be an advanced option.

## Guardrails

- Hashing must stream; do not load large files fully into memory.
- An asset is deleted only after a grace period and reference scan.
- Import failures leave no committed DB reference.
- User-visible filenames are metadata, not filesystem identity.
- All derived cache entries are reproducible from the original.

## Validation

- Import the same file twice and verify one physical original.
- Interrupt import at each stage and verify cleanup.
- Remove a derived thumbnail and verify regeneration.
- Detect and report a missing original.

## Supersession trigger

A future encrypted object store may replace the filesystem layout while preserving immutable content identifiers and repository contracts.
