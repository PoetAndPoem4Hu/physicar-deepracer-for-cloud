#!/bin/bash

### drfc
sudo apt-get update
sudo apt-get install -y jq awscli python3-boto3 docker-compose tmux ffmpeg
pip install boto3 python-dotenv pyyaml polib ipywidgets physicar

mkdir -p ~/.physicar-deepracer-for-cloud
cd ~/.physicar-deepracer-for-cloud
git clone --branch v5.3.3 --depth 1 --single-branch \
  https://github.com/aws-deepracer-community/deepracer-for-cloud.git
cd deepracer-for-cloud
bin/init.sh -c local -a cpu -s compose


### data copy & rm .devcontainer
cp -r ~/physicar-deepracer-for-cloud/.devcontainer/.physicar-deepracer-for-cloud/. ~/.physicar-deepracer-for-cloud/
rm -rf ~/physicar-deepracer-for-cloud/.devcontainer


### env setup
# sed -i 's/^DR_DOCKER_STYLE=.*$/DR_DOCKER_STYLE=compose/' ~/.physicar-deepracer-for-cloud/deepracer-for-cloud/system.env
sed -i 's/^DR_UPLOAD_S3_PROFILE=.*$/DR_UPLOAD_S3_PROFILE=minio/' ~/.physicar-deepracer-for-cloud/deepracer-for-cloud/system.env
sed -i 's/^DR_UPLOAD_S3_BUCKET=.*$/DR_UPLOAD_S3_BUCKET=bucket/' ~/.physicar-deepracer-for-cloud/deepracer-for-cloud/system.env
sed -i 's/^DR_LOCAL_S3_BUCKET=.*$/DR_LOCAL_S3_BUCKET=bucket/' ~/.physicar-deepracer-for-cloud/deepracer-for-cloud/system.env
sed -i 's/^DR_LOCAL_S3_PROFILE=.*$/DR_LOCAL_S3_PROFILE=minio/' ~/.physicar-deepracer-for-cloud/deepracer-for-cloud/system.env
sed -i 's/^DR_HOST_X=.*$/DR_HOST_X=True/' ~/.physicar-deepracer-for-cloud/deepracer-for-cloud/system.env
sed -i 's/^DR_GUI_ENABLE=.*$/DR_GUI_ENABLE=False/' ~/.physicar-deepracer-for-cloud/deepracer-for-cloud/system.env
sed -i '/^#[[:space:]]*DR_DISPLAY/ s/^#[[:space:]]*//' ~/.physicar-deepracer-for-cloud/deepracer-for-cloud/system.env
sed -i 's/^DR_DISPLAY=.*$/DR_DISPLAY=:99/' ~/.physicar-deepracer-for-cloud/deepracer-for-cloud/system.env
sed -i 's/^DR_UPLOAD_S3_PREFIX=.*$/DR_UPLOAD_S3_PREFIX=$DR_LOCAL_S3_MODEL_PREFIX/' ~/.physicar-deepracer-for-cloud/deepracer-for-cloud/run.env


######## bucket (minio)
cat <<EOF > ~/.aws/credentials
[minio]
aws_access_key_id = deepracer
aws_secret_access_key = deepracer
EOF
source ~/.physicar-deepracer-for-cloud/deepracer-for-cloud/bin/activate.sh --minio
python ~/.physicar-deepracer-for-cloud/setup_minio_anonymous.py

### mount
sudo apt-get update
sudo apt-get install -y s3fs
mkdir -p ~/.s3fs
echo "deepracer:deepracer" > ~/.s3fs/credentials
chmod 600 ~/.s3fs/credentials

### vnc
sudo apt-get update
sudo apt-get install -y xvfb x11vnc x11-xserver-utils fluxbox twm # for Xvfb
sudo apt-get install -y novnc websockify  # for noVNC
touch ~/.Xauthority

######## bashrc
cat << 'EOF' >> ~/.bashrc

export DISPLAY=:99
# source ~/.physicar-deepracer-for-cloud/deepracer-for-cloud/bin/activate.sh >/dev/null 2>&1 
# if [ "$CODESPACES" = "true" ]; then
#   (   
#     while true; do
#       sleep 240
#       echo "[Codespace keep-alive] $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
#     done
#   ) &
# fi

EOF