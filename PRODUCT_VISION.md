# Interect Product Vision

> **Think in space. Keep every source.**
>
> 자료의 출처를 잃지 않으면서, 생각을 공간적으로 배치하고 연결하고, 검증 가능한 결과물로 바꾸는 Apple-native 지식 작업 공간.

- 상태: Proposed
- 기준일: 2026-07-18
- 대상 저장소: `parkjaeuk0210/interectnote-ios`
- 제품 표시 이름 제안: **Interect**
- 문서 소유자: Product / Design / Engineering

## 1. 제품 재정의

현재 InterectNote는 스티키 노트, 이미지, PDF 미리보기와 기본 제스처를 제공하는 단일 무한 캔버스 프로토타입이다. 다음 단계의 목표는 범용 화이트보드 기능을 늘리는 것이 아니다.

Interect는 다음 작업을 하나의 연속된 흐름으로 연결한다.

```text
Capture → Trace → Connect → Synthesize → Deliver
```

1. **Capture** — PDF, 이미지, 웹 자료, 필기, 아이디어를 빠르게 수집한다.
2. **Trace** — 발췌, 주장, AI 결과가 원본의 정확한 위치로 돌아갈 수 있다.
3. **Connect** — 아이디어와 근거 사이의 관계를 공간적으로 표현한다.
4. **Synthesize** — 사용자가 선택한 근거를 바탕으로 비교, 군집화, 개요화한다.
5. **Deliver** — 보드를 보고서, 학습 세트, 발표 장면, 내보내기 파일로 변환한다.

## 2. 우리가 해결하는 문제

지식 작업자는 보통 여러 앱 사이에서 다음 단계를 반복한다.

- 자료를 모은다.
- 중요한 문장을 복사한다.
- 출처를 잊는다.
- 생각을 별도 노트에 다시 쓴다.
- 관계를 머릿속에서만 유지한다.
- 결과물을 만들 때 다시 원문을 찾는다.

이 과정의 핵심 손실은 **출처, 문맥, 관계, 공간적 사고, 결과물 사이의 단절**이다.

Interect는 하나의 보드에서 다음 질문에 답할 수 있어야 한다.

- 이 주장은 어떤 근거에서 나왔는가?
- 서로 충돌하는 자료는 무엇인가?
- 이 개념과 연결된 원문은 어디인가?
- 아직 근거가 없는 결론은 무엇인가?
- 이 보드를 발표나 과제 개요로 어떻게 바꿀 수 있는가?

## 3. 핵심 사용자

### 3.1 1차 사용자

#### 대학생·대학원생

- 강의 슬라이드와 교재를 함께 분석한다.
- 논문 여러 편의 공통점과 차이점을 비교한다.
- 시험 범위를 개념 지도와 학습 세트로 바꾼다.
- 과제와 발표를 출처가 남는 형태로 준비한다.

#### 연구자·리서치 중심 지식 노동자

- 논문, 인터뷰, 보고서, 웹 자료를 한 공간에 모은다.
- 주장과 근거, 반례와 의문을 연결한다.
- 원문을 잃지 않고 결론과 산출물을 만든다.

### 3.2 2차 사용자

- UX 리서처
- 제품 기획자
- 전략·시장 조사 담당자
- 작가와 콘텐츠 기획자
- 복잡한 자료를 시각적으로 구조화하는 개인

## 4. 핵심 사용자 과업

> 여러 자료를 읽고 중요한 부분을 꺼내, 내 생각과 연결하고, 나중에 근거를 다시 확인하며, 최종 결과물로 만들고 싶다.

초기 제품 범위는 이 과업에 직접 기여하는 기능만 포함한다.

## 5. 제품 원칙

### 5.1 Every result is traceable

발췌 카드, 사용자 주장, AI 요약, 내보낸 결과물은 가능한 한 원본 출처로 돌아갈 수 있어야 한다.

### 5.2 AI proposes; the user decides

AI는 사용자의 보드를 몰래 수정하지 않는다. 모든 구조 변경은 범위, 근거, 변경 전후, 부분 수락, 단일 Undo를 제공한다.

### 5.3 Local-first, cloud-optional

읽기, 편집, 검색, 기본 내보내기는 오프라인에서 동작한다. 동기화와 클라우드 AI는 명시적으로 분리한다.

### 5.4 Spatial arrangement carries meaning

카드 위치와 그룹은 사용자의 사고 구조다. 자동 정리는 원본 배치를 보존하고 제안으로 제공한다.

### 5.5 Every board can become an outcome

보드는 수집에서 끝나지 않는다. Outline, Study, Presentation, Export 중 하나로 이어질 수 있어야 한다.

### 5.6 Progressive complexity

처음에는 카드 작성과 자료 발췌만 보여주고, 관계 유형, 그래프, AI, 버전 기록은 필요할 때 드러낸다.

### 5.7 Apple-native by behavior, not decoration

Apple-native의 핵심은 유리 효과가 아니라 입력 지연, 키보드·Pencil·트랙패드의 일관성, 접근성, 파일과 공유 시스템 통합이다.

## 6. 핵심 제품 루프

### 대표 시나리오: 논문 세 편을 비교해 과제 개요 만들기

1. 사용자가 PDF 세 편을 가져온다.
2. PDF Reader에서 핵심 문장을 선택해 캔버스로 끌어온다.
3. Source Card가 페이지와 선택 영역을 기억한다.
4. 사용자가 자신의 주장 카드를 작성한다.
5. `supports`, `contradicts`, `question-about` 관계로 연결한다.
6. AI가 선택한 카드만 사용해 공통점, 차이점, 빈 근거를 제안한다.
7. Outline Mode에서 목차를 조정한다.
8. 출처가 포함된 Markdown/PDF로 내보낸다.

이 흐름을 10분 안에 처음부터 끝까지 경험하는 것이 Activation 목표다.

## 7. 차별화 기능

### 7.1 Trace Card

PDF·이미지·웹 자료의 발췌가 원문 위치와 연결된 카드다.

필수 정보:

- Asset ID
- 페이지 또는 문서 위치
- 페이지 좌표 또는 영역
- 선택 텍스트
- 앞뒤 문맥
- 원본 content hash
- 재연결 상태

카드를 열면 원문 Reader가 정확한 위치를 표시한다.

### 7.2 Typed Connections

연결선은 단순 선이 아니라 의미를 가진다.

초기 관계 유형:

- supports
- contradicts
- explains
- causes
- example-of
- depends-on
- question-about
- derived-from
- related

이를 통해 근거 없는 주장, 상충하는 자료, 파생 경로를 찾을 수 있다.

### 7.3 Portal and Nested Board

보드 안에서 다른 보드 또는 특정 Frame을 참조한다. 복제 없이 여러 문맥에서 같은 지식을 재사용한다.

### 7.4 Semantic Zoom

확대율에 따라 정보 밀도를 바꾼다.

- 멀리서: Frame, 클러스터, 장면, 관계 밀도
- 중간: 카드 제목, 태그, 출처 종류, 연결선
- 가까이: 본문, 주석, 인용, 편집 도구

### 7.5 Focus Lens

선택한 카드의 직접 관계, 원본, 상위·하위 개념, 파생 결과만 강조한다.

### 7.6 Spatial Copilot

채팅창이 아니라 선택 기반 보드 도구로 동작한다.

- 요약
- 군집화
- 클러스터 제목 생성
- 주장·근거 분류
- 중복·모순 탐색
- 누락 관점 제안
- 개념 지도·타임라인·표 변환
- 개요·발표·학습 세트 생성

모든 답변은 사용한 카드와 원문 근거를 표시한다.

### 7.7 Multiple representations

동일한 문서 모델을 여러 방식으로 보여준다.

- Board Mode
- Outline Mode
- Study Mode
- Presentation Mode

## 8. 플랫폼 전략

| 플랫폼 | 주 역할 |
|---|---|
| iPad | 주력 제작, Pencil, PDF 분석, 공간 편집 |
| Mac | 대형 보드, 키보드 중심 리서치, 다중 창, 내보내기 |
| iPhone | Inbox, 빠른 수집, 검색, 복습, 간단 편집 |

모든 플랫폼에 동일한 UI를 복제하지 않는다. 데이터 모델과 핵심 행동은 공유하되 각 기기의 강점을 우선한다.

## 9. 정보 구조

```text
Library
├── Inbox
├── Recent
├── Favorites
├── Workspaces
│   ├── Boards
│   └── Collections
├── Shared
├── Templates
└── Trash
```

보드 화면의 기본 구조:

- 왼쪽: 도구와 Library
- 위: breadcrumb, 제목, Undo/Redo, 검색, 공유, 내보내기
- 오른쪽: 선택 객체 Inspector
- 아래: 확대율, 미니맵, Fit, Scene, 동기화 상태

## 10. 비목표

Interect 1.0은 다음을 목표로 하지 않는다.

- Freeform 또는 Miro의 모든 도형 기능 복제
- Google Docs 수준의 실시간 공동 편집
- 범용 팀 프로젝트 관리
- 독점 포맷에 사용자를 가두는 생태계
- 클라우드 AI를 핵심 편집 경로의 필수 조건으로 만들기
- iPhone을 iPad와 동일한 완전 편집기로 만들기

## 11. 성공 지표

### North Star

**주간 완료 지식 루프 수**

완료 지식 루프는 다음 중 하나다.

- 출처 자료를 발췌하고 자신의 생각과 연결
- 여러 자료를 비교하여 개요 생성
- 보드를 학습 세트로 변환
- 보드를 발표 또는 문서로 내보냄

### Activation

첫 24시간 안에:

- Board 1개 생성
- 객체 5개 이상
- SourceAnchor 1개 이상
- 관계 2개 이상
- Outline, Study, Export 중 하나 완료

### 품질 지표

- crash-free sessions
- hang-free sessions
- 저장 실패율
- sync 성공률
- 보드 open p50/p95
- pan/zoom frame pacing
- AI 결과 수락률과 Undo율
- SourceAnchor 재연결 실패율

## 12. 1.0 정의

Interect 1.0은 다음 조건을 만족해야 한다.

- 여러 Workspace와 Board
- 문서급 로컬 영속성과 안전한 마이그레이션
- 대형 보드에서 안정적인 캔버스
- PDF Reader와 원문 연결 발췌
- 의미 있는 연결선과 Outline
- 출처 포함 내보내기
- 선택 기반 AI 제안과 인용
- 개인 iCloud 동기화
- 접근 가능한 Outline 탐색
- 복구, 진단, 테스트, 개인정보 설명

## 13. 제품 문장

### 한 문장

**Interect는 자료의 출처를 보존하며 생각을 공간적으로 연결하고 결과물로 바꾸는 Apple-native 지식 작업 공간이다.**

### App Store 서브타이틀 후보

- Source-linked thinking canvas
- Spatial knowledge workspace
- 자료에서 생각까지, 근거가 남는 공간

### 핵심 메시지

**Think in space. Keep every source.**
