#!/bin/bash

###### jupyterlab
tmux new-session -d -s jupyterlab bash -lc '
cd ~/physicar-deepracer-for-cloud
while true; do
  INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
  uv run jupyter lab --ip=0.0.0.0 --port=8888 --NotebookApp.token="$INSTANCE_ID" --no-browser
  echo "💥  jupyter crashed. Fix code & save to auto-restart."
  sleep 5
done
'

###### upgrade physicar (current major version only)
tmux new-session -d -s upgrade bash -lc '
cd ~/physicar-deepracer-for-cloud
while true; do
  current_version=$(uv pip show physicar 2>/dev/null | grep "Version:" | cut -d" " -f2 || echo "0.0.0")
  major_version=$(echo $current_version | cut -d"." -f1)
  uv pip install --upgrade "physicar~=${major_version}.0"
  sleep 5
done
'

####### system - physicar
tmux new-session -d -s system bash -lc '
cd ~/physicar-deepracer-for-cloud
while true; do
  uv run -m physicar.deepracer.cloud.system
  echo "💥  app crashed. Fix code & save to auto-restart."
  sleep 2
done
'

####### vnc
tmux new-session -d -s vnc bash -lc '
while true; do
  # Xserver  
  if ! pgrep -x Xvfb >/dev/null; then
    sudo rm /tmp/.X99-lock
    Xvfb :99 -screen 0 1280x720x24 &
  fi
  sleep 2
  # window manager (fluxbox)
  if ! pgrep -x fluxbox >/dev/null; then
    DISPLAY=:99 fluxbox  & 
  fi
  sleep 2
  # VNC
  if ! pgrep -x x11vnc >/dev/null; then
    INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
    x11vnc -display :99 -forever -passwd "$INSTANCE_ID" -rfbport 5901  &
  fi
  sleep 2
  # noVNC
  if ! pgrep -f "websockify.*6080" >/dev/null; then
    websockify --web /usr/share/novnc/ 6080 localhost:5901  &
  fi
  sleep 2
done
'

####### mount
mkdir -p ~/.physicar-deepracer-for-cloud/bucket
tmux new-session -d -s mount bash -lc '
while true
do
  if ! mountpoint -q ~/.physicar-deepracer-for-cloud/bucket; then
    if s3fs bucket ~/.physicar-deepracer-for-cloud/bucket \
      -o passwd_file=~/.s3fs/credentials \
      -o url=http://localhost:9000 \
      -o use_path_request_style \
      -o uid=1000 -o gid=1000 -o umask=077
    then
      mkdir -p ~/.physicar-deepracer-for-cloud/bucket/models
    fi
  else
    mkdir -p ~/.physicar-deepracer-for-cloud/bucket/models
  fi
  sleep 5
done
'

####### minio anonymous access setup
tmux new-session -d -s minio-setup bash -lc '
echo "⏱️  MinIO 익명 접근 설정을 위해 대기 중..."
sleep 30  # MinIO가 완전히 시작될 때까지 대기
cd ~/physicar-deepracer-for-cloud
if [ -f setup_minio_anonymous.py ]; then
  uv run ~/.physicar-deepracer-for-cloud/setup_minio_anonymous.py
else
  echo "❌ setup_minio_anonymous.py 파일을 찾을 수 없습니다."
fi
'

