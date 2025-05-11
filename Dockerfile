# 빌드 스테이지
FROM node:16-alpine as build-stage

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build

# 프로덕션 스테이지
FROM nginx:stable-alpine as production-stage

# Nginx 설정 파일 복사 (필요한 경우)
# COPY nginx.conf /etc/nginx/conf.d/default.conf

# 빌드된 파일을 Nginx 서빙 디렉토리로 복사
COPY --from=build-stage /app/dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]