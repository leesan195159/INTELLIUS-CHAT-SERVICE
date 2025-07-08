# 1. 베이스 이미지 선택
FROM python:3.9-slim

# 2. 작업 디렉토리 설정
WORKDIR /app

# 3. 의존성 파일 복사 및 설치
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 4. 소스 코드 복사
COPY . .

# 5. 애플리케이션 실행
# uvicorn main:app --host 0.0.0.0 --port 8000
# --reload 옵션은 개발 중에만 사용하고, 프로덕션에서는 제거하는 것이 좋습니다.
# 여기서는 docker-compose로 실행할 것이므로 CMD 보다는 docker-compose에서 command를 지정하는 것이 더 유연할 수 있습니다.
# 하지만 기본 실행 명령을 정의해두는 것도 좋은 방법입니다.
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"] 