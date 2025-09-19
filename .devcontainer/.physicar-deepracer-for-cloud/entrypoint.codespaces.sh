#!/bin/bash

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
    x11vnc -display :99 -forever -nopw -rfbport 5901  &
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

###### ports public <-> private (Only Codespaces)
if [[ -n "${CODESPACES:-}" ]]; then
  tmux new-session -d -s ports bash -lc "while true; do
    echo \"Check ports at \$(date)\"
    gh codespace ports --json sourcePort,visibility -c \"${CODESPACE_NAME}\" > /tmp/cs_ports.json || { echo \"cannot list ports\"; sleep 2; continue; }

    TO_PUBLIC=()
    TO_PRIVATE=()

    for P in 8080 8081 8082 8083 8084 8085 8086 8087 8088 8089 9000; do
      VIS=\$(jq -r --arg p \"\$P\" \".[] | select(.sourcePort==(\\\$p|tonumber)) | .visibility\" /tmp/cs_ports.json)

      if [[ -z \"\$VIS\" || \"\$VIS\" == \"null\" ]]; then
        echo \"skip \$P (not forwarded)\"
        continue
      fi

      if ss -lnt \"( sport = :\$P )\" | grep -q \":\$P\"; then
        if [[ \"\$VIS\" != \"public\" ]]; then
          TO_PUBLIC+=(\"\$P:public\")
        else
          echo \"OK \$P already public\"
        fi
      else
        if [[ \"\$VIS\" != \"private\" ]]; then
          TO_PRIVATE+=(\"\$P:private\")
        else
          echo \"OK \$P already private\"
        fi
      fi
    done

    if (( \${#TO_PUBLIC[@]} )); then
      echo \"setting → public: \${TO_PUBLIC[*]}\"
      gh codespace ports visibility \"\${TO_PUBLIC[@]}\" -c \"${CODESPACE_NAME}\" || echo \"error: public change failed\"
    fi

    if (( \${#TO_PRIVATE[@]} )); then
      echo \"setting → private: \${TO_PRIVATE[*]}\"
      gh codespace ports visibility \"\${TO_PRIVATE[@]}\" -c \"${CODESPACE_NAME}\" || echo \"error: private change failed\"
    fi

    if (( ! \${#TO_PUBLIC[@]} && ! \${#TO_PRIVATE[@]} )); then
      echo \"all good (no changes)\"
    fi

    sleep 30
  done"
fi

####### swap memory (Only Codespaces)
if [[ -n "${CODESPACES:-}" ]]; then
  tmux new-session -d -s swap bash -lc "
set -Eeuo pipefail

SWAPFILE=\"/tmp/swapfile\"

# 실메모리(GB) 계산 (/proc/meminfo 의 kB 값을 GiB로 변환)
mem_kb=\$(awk '/^MemTotal:/ {print \$2}' /proc/meminfo)
mem_gib=\$(( mem_kb / (1024*1024) ))

# 64GiB 초과면 스왑 생성 안 함
if (( mem_gib > 64 )); then
  echo \"[swap] Mem=\${mem_gib}GiB > 64GiB -> do nothing\"
  exit 0
fi

# 목표 총 메모리: min(4 * mem_gib, 64)
target_total_gib=\$(( mem_gib * 4 ))
if (( target_total_gib > 64 )); then
  target_total_gib=64
fi

# 필요한 스왑: target_total - mem (하한 0, 상한 32)
desired_swap_gib=\$(( target_total_gib - mem_gib ))
if (( desired_swap_gib < 0 )); then desired_swap_gib=0; fi
if (( desired_swap_gib > 32 )); then desired_swap_gib=32; fi
desired_swap_bytes=\$(( desired_swap_gib * 1024 * 1024 * 1024 ))

# 현재 /tmp/swapfile가 올라가 있으면 사이즈 확인 (헤더 제거)
current_swap_bytes=0
if swapon --show=NAME --noheadings | grep -qx \"\${SWAPFILE}\"; then
  current_swap_bytes=\$(swapon --show=NAME,SIZE --bytes --noheadings \
    | awk -v f=\"\${SWAPFILE}\" '\$1==f {print \$2}')
fi

echo \"[swap] Mem=\${mem_gib}GiB, target_total=\${target_total_gib}GiB, desired_swap=\${desired_swap_gib}GiB\"

# 스왑 0이 목표면 내리고 끝
if (( desired_swap_gib == 0 )); then
  if [[ -f \"\${SWAPFILE}\" ]]; then
    sudo swapoff \"\${SWAPFILE}\" || true
    sudo rm -f \"\${SWAPFILE}\" || true
  fi
  exit 0
fi

# 사이즈가 다르면 재생성
recreate=true
if (( current_swap_bytes == desired_swap_bytes )) && [[ -f \"\${SWAPFILE}\" ]]; then
  recreate=false
fi

if \$recreate; then
  # 기존 것 비활성/삭제
  if [[ -f \"\${SWAPFILE}\" ]]; then
    sudo swapoff \"\${SWAPFILE}\" || true
    sudo rm -f \"\${SWAPFILE}\" || true
  fi

  # /tmp 용량 확인(안전 여유 1GiB)
  avail_bytes=\$(df --output=avail -B1 /tmp | tail -n1)
  needed_bytes=\$(( desired_swap_bytes + 1024*1024*1024 ))
  if (( avail_bytes < needed_bytes )); then
    if command -v numfmt >/dev/null 2>&1; then
      echo \"[swap] Not enough space on /tmp (avail=\$(numfmt --to=iec \${avail_bytes}), need>=(\$(numfmt --to=iec \${needed_bytes})))\"
    else
      echo \"[swap] Not enough space on /tmp (avail=\${avail_bytes}B, need>=\${needed_bytes}B)\"
    fi
    exit 1
  fi

  # 생성 → 권한 → mkswap
  sudo dd if=/dev/zero of=\"\${SWAPFILE}\" bs=1M count=\$(( desired_swap_gib * 1024 )) status=none
  sudo chmod 600 \"\${SWAPFILE}\"
  sudo mkswap \"\${SWAPFILE}\" >/dev/null
fi

# 활성화(이미 활성화돼 있으면 건너뜀)
if ! swapon --show=NAME --noheadings | grep -qx \"\${SWAPFILE}\"; then
  sudo swapon \"\${SWAPFILE}\"
fi
"
fi
