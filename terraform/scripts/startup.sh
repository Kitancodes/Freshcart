#!/bin/bash
set -euo pipefail

dnf update -y
dnf install -y docker

systemctl enable --now docker

docker network create freshcart-network 2>/dev/null || true
docker volume create freshcart-postgres-data

docker rm -f freshcart-db checkout-api 2>/dev/null || true

docker run -d \
  --name freshcart-db \
  --restart unless-stopped \
  --network freshcart-network \
  -e POSTGRES_DB=freshcart \
  -e POSTGRES_USER=freshcart \
  -e POSTGRES_PASSWORD=freshcart \
  -v freshcart-postgres-data:/var/lib/postgresql/data \
  postgres:16

until docker exec freshcart-db pg_isready -U freshcart -d freshcart; do
  sleep 2
done

docker pull "${container_image}"

docker run -d \
  --name checkout-api \
  --restart unless-stopped \
  --network freshcart-network \
  -e DATABASE_URL="postgres://freshcart:freshcart@freshcart-db:5432/freshcart" \
  -e PORT="${container_port}" \
  -p "${container_port}:${container_port}" \
  "${container_image}"