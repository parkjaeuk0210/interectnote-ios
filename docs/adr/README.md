# Architecture Decision Records

ADR은 되돌리기 어렵거나 여러 모듈에 영향을 미치는 기술·제품 결정을 기록한다.

## 상태

- Proposed: 토론 중
- Accepted: 구현 기준
- Superseded: 더 새로운 ADR로 대체
- Rejected: 채택하지 않음

## 목록

| ADR | 제목 | 상태 |
|---|---|---|
| [0001](0001-local-first-product-architecture.md) | Local-first product architecture | Proposed |
| [0002](0002-sqlite-grdb-as-primary-store.md) | SQLite/GRDB as the primary store | Proposed |
| [0003](0003-content-addressed-asset-store.md) | Content-addressed asset storage | Proposed |
| [0004](0004-command-based-document-mutations.md) | Command-based document mutations | Proposed |
| [0005](0005-hybrid-virtualized-canvas-renderer.md) | Hybrid virtualized canvas renderer | Proposed |
| [0006](0006-workspace-cloudkit-zone-mapping.md) | Workspace to CloudKit zone mapping | Proposed |
| [0007](0007-source-anchor-representation.md) | Source anchor representation | Proposed |
| [0008](0008-intelligence-provider-and-privacy-boundary.md) | Intelligence provider and privacy boundary | Proposed |

## 템플릿

```markdown
# ADR-NNNN: Title

- Status: Proposed
- Date: YYYY-MM-DD
- Owners: ...

## Context
## Decision
## Consequences
### Positive
### Negative
## Alternatives considered
## Guardrails
## Validation
## Rollback or supersession trigger
```
