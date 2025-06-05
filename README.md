# 🗣️ 말하기 피드백 시스템

이 프로젝트는 사용자가 웹에서 오디오 파일을 업로드하면, Whisper 모델을 통해 전사하고, GPT-4o를 통해 피드백을 반환하는 **웹 기반 말하기 평가 시스템**입니다.  
두 개의 Flask API 서비스(`whisper-service`, `feedback-service`)와 하나의 Flutter 웹 앱으로 구성되어 있으며, Docker Compose를 통해 전체 시스템을 실행할 수 있습니다.

---

## 📦 시스템 구성
Flutter Web
↓ (오디오 파일 업로드)
whisper-service (전사)
↓ (텍스트 전송)
feedback-service (GPT-4o 피드백)
↓
Flutter Web (결과 출력)


| 구성 요소         | 설명 |
|------------------|------|
| `whisper-service` | 오디오 전사 및 피드백 요청 중계 (Flask + Whisper) |
| `feedback-service` | GPT-4o API를 통한 말하기 피드백 생성 (Flask + OpenAI) |
| Flutter 웹 앱     | 오디오 파일 업로드 및 결과 시각화 (Flutter Web) |

---

## 🧱 기술 스택

- Python 3.10
- Flask
- Whisper (OpenAI)
- GPT-4o (OpenAI API)
- Flutter Web
- Docker, docker-compose

---

## 📜 라이선스 및 참고
Whisper: https://github.com/openai/whisper

OpenAI GPT-4o API: https://platform.openai.com/docs
