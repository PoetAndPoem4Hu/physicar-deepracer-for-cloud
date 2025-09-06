# Physicar DeepRacer for Cloud


<div align="center">

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/physicar/physicar-deepracer-for-cloud?quickstart=1)

*Cloud-based PhysiCar DeepRacer training platform*

<br>

🚧 **Currently in Beta Version** 🚧

</div>

## 소개

본 레포지토리(Physicar DeepRacer for Cloud)는 [(주)AI CASTLE](https://aicastle.com)에서 만든 [**PhysiCar AI**](https://physicar.ai) 서비스중 하나인 DeepRacer의 클라우드 기반 훈련 플랫폼입니다.

### PhysiCar AI란

<div align="center">

🚀 **Official Launch Planned for End of 2025** 🚀

</div>

- [**PhysiCar AI**](https://physicar.ai)는 피지컬 AI를 쉽고 재미있게 배울수 있는 종합 플랫폼입니다.
    
- PhysiCar AI에서는 Agent (LLM 기반 로봇 비서), Follow (YOLO 기반 객체탐지), DeepRacer (강화학습 기반 자율주행) 등 여러 서비스를 제공합니다.
- 하나의 로봇 자율주행 키트 안에서 다양한 최신 AI 기술을 쉽고 재미있게 배울 수 있습니다.

## 주요 특징

- **GitHub Codespaces 지원**: Github 계정만 있으면 **즉시 체험 가능**
- **GUI 훈련 환경**: VSCode에서 **주피터 노트북 기반** ipywidgets으로 직관적인 인터페이스 제공
- **다중 시뮬레이션 훈련**: 오프라인 모델의 과적합 문제 해결
- **장애물 피하기**: **여러 종류의 장애물 유형** 지원
- **실시간 모니터링**: 훈련 진행 상황과 메트릭을 실시간으로 확인
- **비디오 재생**: 웹 호환 테스트 비디오 자동 변환
- **다국어 지원**: 여러 언어와 시간대 설정 지원


## 빠른 시작

### GitHub Codespaces에서 시작하기

1. 이 레포지토리에서 **Code** 버튼 클릭
2. **Codespaces** 탭 선택
3. **Create codespace** 클릭
4. 환경이 자동으로 설정될 때까지 대기

### setup.ipynb

[setup.ipynb](setup.ipynb)에서 언어 및 시간대 설정을 합니다.

### 01_start_training
[**01_start_training.ipynb**](01_start_training.ipynb)에서 모델 훈련을 시작합니다.
보상함수는 [reward_function.py](reward_function.py)에서 작성합니다.

### 02_your_models
[**02_your_models.ipynb**](02_your_models.ipynb) 에서 훈련중인 또는 훈련이 끝난 모델을 확인 합니다.

### 03_start_test
[**03_start_test.ipynb**](03_start_test.ipynb)에서 훈련된 모델의 랩타입을 테스트합니다. 테스트 기록은 [02_your_models.ipynb](02_your_models.ipynb)에서 확인 가능합니다.

### Tracks
[tracks.md](tracks.md)에서 지원되는 트랙 목록을 확인할 수 있습니다.



## 역사
### AWS DeepRacer
[AWS DeepRacer](https://aws.amazon.com/deepracer/)는 2018년 AWS에서 강화학습(RL)을 더 쉽게 접할 수 있게 만들기 위해 발표한 완전 자율주행 1/18 스케일 레이싱 카 플랫폼입니다.

### DeepRacer for Cloud
Physicar DeepRacer for Cloud는 AWS 커뮤니티에서 개발된 [DeepRacer for Cloud (DFfC)](https://github.com/aws-deepracer-community/deepracer-for-cloud) 프로젝트를 기반으로 수정 및 확장된 버전입니다. DRfC는 로컬 또는 클라우드(VM/EC2/Azure) 환경에서 DeepRacer 훈련을 신속하게 실행할 수 있도록 설계된 오픈 소스 플랫폼입니다.