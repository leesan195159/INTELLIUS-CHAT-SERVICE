# IntelliU 상담 챗봇 서비스 API

FastAPI와 MariaDB를 기반으로 구축된 AI 상담 챗봇 서비스의 백엔드 API입니다. 대규모 동시 접속 환경을 가정하여 비동기 처리와 확장성을 고려하여 설계되었습니다.

## ✨ 주요 기능 (Features)

-   **채팅 API**: 채팅방 생성, 사용자별 채팅방 목록 조회, 채팅 메시지 전송 및 조회
-   **비동기 AI 응답**: `BackgroundTasks`를 활용하여 AI 응답(1~3초 딜레이 시뮬레이션)을 비동기적으로 처리하여 API 응답성 확보
-   **논리적 삭제 (Soft Delete)**: 데이터의 보존 및 복구를 위해 채팅방과 메시지를 물리적으로 삭제하지 않고 `is_deleted` 플래그로 관리
-   **페이지네이션 (Pagination)**: `skip`과 `limit`을 이용한 페이지네이션으로 대용량 데이터 조회 시 성능 저하 방지

## 🛠️ 기술 스택 (Tech Stack)

-   **Framework**: FastAPI
-   **Database**: MariaDB
-   **Containerization**: Docker, Docker Compose
-   **Language**: Python 3.9+
-   **Key Libraries**:
    -   `SQLAlchemy`: Python ORM
    -   `Uvicorn`: ASGI Server
    -   `Pydantic`: Data validation

## 📂 프로젝트 구조 (Project Structure)

```
.
├── app/                  # FastAPI 애플리케이션 소스 코드
│   ├── crud.py           # 데이터베이스 CRUD(Create, Read, Update, Delete) 로직
│   ├── database.py       # 데이터베이스 연결 및 세션 관리
│   ├── main.py           # FastAPI 앱 초기화 및 라우터 설정
│   ├── models.py         # SQLAlchemy 데이터베이스 모델 정의
│   ├── routers/          # API 엔드포인트(라우터) 정의
│   │   └── chat.py
│   └── schemas.py        # Pydantic 데이터 유효성 검사 스키마
├── docker-compose.yml    # Docker 다중 컨테이너 실행 설정
├── Dockerfile            # FastAPI 애플리케이션 Docker 이미지 빌드 설정
├── init-db/
│   └── init.sql          # 초기 데이터베이스 스키마 및 목 데이터
└── requirements.txt      # Python 의존성 라이브러리 목록
```

## 🚀 실행 방법 (Getting Started)

### 사전 요구사항 (Prerequisites)

-   [Docker](https://www.docker.com/get-started)
-   [Docker Compose](https://docs.docker.com/compose/install/)

### 설치 및 실행

1.  **Docker 컨테이너 실행**

    프로젝트 루트 디렉토리에서 아래 명령어를 실행하여 Docker 컨테이너를 빌드하고 실행합니다. `docker-compose.yml` 파일에 필요한 환경 변수가 이미 설정되어 있습니다.

    ```bash
    docker-compose up -d --build
    ```

    `chat-app`과 `chat-db` 두 개의 컨테이너가 성공적으로 실행됩니다.

2.  **서비스 확인**

    웹 브라우저에서 `http://localhost:8000`으로 접속하여 아래와 같은 메시지가 나오는지 확인합니다.

    ```json
    {
      "message": "Welcome to the IntelliU Chat Service"
    }
    ```

## 📚 API 문서 (API Documentation)

서버가 실행 중일 때, 아래 URL에서 자동으로 생성된 API 문서를 확인할 수 있습니다. 각 엔드포인트에 대한 상세한 설명과 직접 테스트해볼 수 있는 기능을 제공합니다.

-   **Swagger UI**: `http://localhost:8000/docs`
-   **ReDoc**: `http://localhost:8000/redoc` 