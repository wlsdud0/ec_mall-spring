#!/usr/bin/env bash

# 실행중인 컨테이너 확인
running=$(docker ps -a --format "{{.ID}}" --filter "name=ec_mall-cd" | wc -l)
# 실행중인 컨테이너가 있을 경우,
if [ $running -ge 1 ]; then
  # 중단하고
  docker stop ec_mall-cd
  # 삭제한다.
  docker rm ec_mall-cd
fi

# 새 이미지를 가져오고
docker pull wlsdud0/ec_mall-boot:latest
# 실행한다.
docker run -d --name ec_mall-cd -p 8080:8080 wlsdud0/ec_mall-boot:latest