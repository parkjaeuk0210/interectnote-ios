# InterectNote - Native iOS/macOS App

Apple Freeform에서 영감을 받은 네이티브 무한 캔버스 메모 애플리케이션입니다.

## 기능

- **무한 캔버스**: 제한 없는 작업 공간에서 자유롭게 메모
- **글래스모피즘 UI**: Apple 스타일의 세련된 반투명 디자인
- **스티키 노트**: 6가지 색상의 예쁜 메모 카드
- **이미지 지원**: 사진 추가 및 드래그 앤 드롭
- **PDF 지원**: PDF 파일 미리보기
- **다크 모드**: 시스템 설정에 따른 자동 테마 전환
- **제스처 지원**: 핀치 줌, 드래그 이동
- **Undo/Redo**: 실행 취소 및 다시 실행
- **자동 저장**: UserDefaults에 자동 저장

## 시스템 요구사항

- iOS 17.0+
- macOS 14.0+
- Xcode 15.0+

## 설치 및 실행

### Xcode로 열기
```bash
open InterectNote.xcodeproj
```

### 빌드
1. Xcode에서 프로젝트 열기
2. 타겟 디바이스 선택 (iPhone, iPad, Mac)
3. Cmd+R로 빌드 및 실행

## 프로젝트 구조

```
InterectNote/
├── InterectNoteApp.swift      # 앱 진입점
├── Models/
│   ├── Note.swift             # 노트 모델
│   ├── CanvasImage.swift      # 이미지 모델
│   ├── CanvasFile.swift       # 파일 모델
│   └── Viewport.swift         # 뷰포트 모델
├── Store/
│   └── CanvasStore.swift      # 상태 관리
├── Views/
│   ├── ContentView.swift      # 메인 뷰
│   ├── InfiniteCanvasView.swift  # 캔버스 뷰
│   ├── StickyNoteView.swift   # 노트 컴포넌트
│   ├── CanvasImageView.swift  # 이미지 컴포넌트
│   ├── CanvasFileView.swift   # 파일 컴포넌트
│   ├── SettingsView.swift     # 설정 뷰
│   └── Components/
│       ├── ToolbarView.swift      # 하단 툴바
│       ├── FloatingButtonView.swift  # + 버튼
│       └── TopBarView.swift       # 상단 바
└── Assets.xcassets/           # 에셋
```

## 사용 방법

### 노트 추가
- 캔버스 더블 탭
- 우측 하단 + 버튼 클릭

### 캔버스 이동
- 드래그하여 이동
- 핀치로 확대/축소

### 노트 편집
- 노트 더블 탭으로 편집 모드
- 드래그로 위치 이동
- 우측 하단 핸들로 크기 조절
- 색상 버튼으로 색상 변경

### 이미지/파일 추가
- + 버튼 → 사진 또는 파일 선택
- 드래그 앤 드롭 (macOS)

## 기술 스택

- **SwiftUI**: 선언적 UI
- **Combine**: 반응형 프로그래밍
- **PDFKit**: PDF 렌더링
- **PhotosUI**: 이미지 선택
- **UserDefaults**: 데이터 영속성

## 라이선스

MIT License
