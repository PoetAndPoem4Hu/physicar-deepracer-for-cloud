#!/usr/bin/env python3

import boto3
import json
import time
from botocore.client import Config
from botocore.exceptions import ClientError

def setup_minio_anonymous_access():
    """
    MinIO bucket에 익명 읽기 권한을 설정하여 URL로 직접 다운로드 가능하게 함
    """
    # MinIO 설정
    MINIO_ENDPOINT = 'http://localhost:9000'
    ACCESS_KEY = 'deepracer'
    SECRET_KEY = 'deepracer'
    BUCKET_NAME = 'bucket'
    
    max_retries = 30  # 최대 30번 시도 (5분)
    retry_interval = 10  # 10초마다 재시도
    
    for attempt in range(max_retries):
        try:
            print(f"[{attempt+1}/{max_retries}] Trying to connect to MinIO...")
            
            # MinIO 클라이언트 생성
            s3_client = boto3.client(
                's3',
                endpoint_url=MINIO_ENDPOINT,
                aws_access_key_id=ACCESS_KEY,
                aws_secret_access_key=SECRET_KEY,
                config=Config(signature_version='s3v4'),
                region_name='us-east-1'
            )
            
            # MinIO 서버가 준비되었는지 확인
            s3_client.list_buckets()
            print("[OK] Connected to MinIO server!")

            # 익명 읽기 권한을 허용하는 정책
            bucket_policy = {
                "Version": "2012-10-17",
                "Statement": [
                    {
                        "Effect": "Allow",
                        "Principal": "*",
                        "Action": ["s3:GetObject"],
                        "Resource": [f"arn:aws:s3:::{BUCKET_NAME}/*"]
                    }
                ]
            }
            
            # 정책 적용
            s3_client.put_bucket_policy(
                Bucket=BUCKET_NAME,
                Policy=json.dumps(bucket_policy)
            )

            print(f"[OK] URL: http://localhost:9000/{BUCKET_NAME}/path/to/file")
            return True
            
        except ClientError as e:
            error_code = e.response.get('Error', {}).get('Code', 'Unknown')
            if error_code == 'NoSuchBucket':
                print(f"[Failed] {BUCKET_NAME} is not found. Retrying...")
            else:
                print(f"[Failed] {e}")
        except Exception as e:
            print(f"[Failed] {e}")
            
        if attempt < max_retries - 1:
            print(f"Retrying in {retry_interval} seconds...")
            time.sleep(retry_interval)
    
    print("[Error] Initial setup failed after multiple attempts.")
    return False

if __name__ == "__main__":
    setup_minio_anonymous_access()