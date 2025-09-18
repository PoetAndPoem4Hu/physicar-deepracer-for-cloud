# Physicar DeepRacer for Cloud

<div align="center">

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/physicar/physicar-deepracer-for-cloud?quickstart=1)

*Cloud-based PhysiCar DeepRacer training platform*

<br>

🚧 **Currently in Beta Version** 🚧

</div>

## Introduction

This repository (Physicar DeepRacer for Cloud) is a cloud-based training platform for DeepRacer, one of the services under [**PhysiCar AI**](https://physicar.ai) developed by [(AI CASTLE Inc.)](https://aicastle.com).

### What is PhysiCar AI?

<div align="center">

🚀 **Official Launch Planned for End of 2025** 🚀

</div>

- [**PhysiCar AI**](https://physicar.ai) is a comprehensive platform that makes learning Physical AI easy and fun.  
- PhysiCar AI provides multiple services such as Agent (LLM-based robotic assistant), Follow (YOLO-based object detection), and DeepRacer (reinforcement learning-based autonomous driving).  
- With a single robotic self-driving kit, you can explore various cutting-edge AI technologies in an easy and engaging way.  

## Key Features

- **GitHub Codespaces Support**: Experience instantly with just a GitHub account  
- **GUI Training Environment**: Intuitive interface with Jupyter Notebook ipywidgets inside VSCode  
- **Multi-Simulation Training**: Mitigates overfitting issues in offline models  
- **Obstacle Avoidance**: Supports **multiple types of obstacle categories**  
- **Real-Time Monitoring**: Track training progress and metrics live  
- **Video Playback**: Automatically converts test videos into web-compatible format  
- **Multilingual Support**: Supports multiple languages and timezone settings  

## Quick Start

### Start with GitHub Codespaces

1. Click the **Code** button in this repository  
2. Select the **Codespaces** tab  
3. Click **Create codespace**  
4. Wait until the environment is automatically set up  

### setup.ipynb

Configure language and timezone settings in [setup.ipynb](setup.ipynb).

> When launching Jupyter Notebook, if prompted to select a kernel, choose `physicar-deepracer-for-cloud (Python 3.12.1)`. This applies in the same way to all of the instructions below.

### 01_start_training

Start training your model in [**01_start_training.ipynb**](01_start_training.ipynb).  
Define your reward function in [reward_function.py](reward_function.py).

### 02_your_models

Check ongoing or completed models in [**02_your_models.ipynb**](02_your_models.ipynb).

### 03_start_test

Test lap types of your trained model in [**03_start_test.ipynb**](03_start_test.ipynb).  
Test results can also be reviewed in [02_your_models.ipynb](02_your_models.ipynb).

### Tracks

See the list of supported tracks in [tracks.md](tracks.md).

## History

### AWS DeepRacer

[AWS DeepRacer](https://aws.amazon.com/deepracer/) was introduced in 2018 by AWS as a fully autonomous 1/18 scale racing car platform to make reinforcement learning (RL) more accessible.

### DeepRacer for Cloud

Physicar DeepRacer for Cloud is a modified and extended version of the community-developed [DeepRacer for Cloud (DFfC)](https://github.com/aws-deepracer-community/deepracer-for-cloud) project.  
DRfC is an open-source platform designed to quickly run DeepRacer training in local or cloud environments (VM/EC2/Azure).
