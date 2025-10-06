# 빌드용 이미지
ARG NODE_VERSION=22.19.0
FROM node:${NODE_VERSION}-alpine AS builder

WORKDIR /usr/src/app

# package.json과 package-lock.json 복사
COPY package*.json ./

# publicConfig.example.json 복사
COPY publicConfig.example.json ./

# 의존성 설치 (devDependencies 제외)
RUN npm ci --omit=dev

# =============================
# 최종 실행용 이미지
FROM node:${NODE_VERSION}-alpine

ARG GIT_BRANCH=master
ARG GIT_COMMIT_ID=null
ARG GIT_COMMIT_DATE=0

ENV NODE_ENV production
ENV IS_DOCKER true
ENV GIT_COMMIT_ID ${GIT_COMMIT_ID}
ENV GIT_BRANCH ${GIT_BRANCH}
ENV GIT_COMMIT_DATE ${GIT_COMMIT_DATE}

WORKDIR /usr/src/app

# node_modules 복사
COPY --from=builder /usr/src/app/node_modules ./node_modules

# 소스 전체 복사
COPY . .

# config 폴더 생성 + publicConfig 복사
RUN mkdir -p config \
    && cp publicConfig.example.json config/publicConfig.json \
    || echo '{}' > config/publicConfig.json

EXPOSE 3000

CMD ["node", "main.js"]
