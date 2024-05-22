#!/usr/bin/env bash

# Docker 네트워크 생성 (이미 존재하는 경우 에러 무시)
docker network create ec_mall_network || true

# MariaDB 컨테이너를 사용자 정의 네트워크에 연결하여 실행
docker run --name mariadb-container --network ec_mall_network -e MYSQL_ROOT_PASSWORD=1234 -d mariadb:latest

# 새 버전을 가져온다.
docker pull wlsdud0/ec_mall-boot:latest

# 포트 설정을 진행한다.
# 다음에 실행할 포트를 나타내는 변수를 만들고
next_run=8081
# 이전에 실행한 포트 정보를 파일에서 회수한다.
if [ -f "$HOME/last_run" ]; then
  last_run=$(cat "$HOME/last_run")
else
  last_run=-1
fi

# 이전 실행 정보를 바탕으로 다음 실행 포트 결정
case "$last_run" in
  8081)
    echo "Before Run: 8081"
    next_run=8082
    ;;
  8082)
    echo "Before Run: 8082"
    next_run=8081
    ;;
  *)
    echo "First Run or Unknown last run"
    ;;
esac

# next_run 포트 정보 기록
echo "$next_run" > "$HOME/last_run"

# next_run 포트에 새 버전을 실행한다.
docker run --rm -d \
  --network ec_mall_network \
  -p "$next_run:8080" \
  --name "ec_mall-app-$next_run" \
  -e DB_HOST=mariadb-container \
  -e DB_PORT=3306 \
  -e DB_USER=sa \
  -e DB_PASSWORD=1234 \
  wlsdud0/ec_mall-boot:latest

# 이전 nginx 설정이 있는 경우 제거
if [ $last_run -ne -1 ]; then
  sudo rm -f "/etc/nginx/sites-enabled/app_$last_run"
fi

# 새 nginx 설정 적용
sudo ln -sf "/etc/nginx/sites-available/app_$next_run" "/etc/nginx/sites-enabled/app_$next_run"
sudo systemctl restart nginx

# 이전 애플리케이션 인스턴스 종료
if [ $last_run -ne -1 ]; then
  docker stop "ec_mall-app-$last_run"
fi
