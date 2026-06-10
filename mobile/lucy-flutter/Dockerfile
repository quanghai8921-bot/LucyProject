FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app

COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . ./

ARG LUCY_AUTH_API_URL
ARG LUCY_PAYMENT_API_URL
ARG LUCY_LMS_API_URL
ARG LUCY_REALTIME_URL

RUN flutter build web --release \
  --dart-define=LUCY_AUTH_API_URL="${LUCY_AUTH_API_URL}" \
  --dart-define=LUCY_PAYMENT_API_URL="${LUCY_PAYMENT_API_URL}" \
  --dart-define=LUCY_LMS_API_URL="${LUCY_LMS_API_URL}" \
  --dart-define=LUCY_REALTIME_URL="${LUCY_REALTIME_URL}"

FROM node:20-alpine AS final
WORKDIR /app

RUN npm install -g serve
COPY --from=build /app/build/web ./build/web

CMD ["sh", "-c", "serve -s build/web -l tcp://0.0.0.0:${PORT:-8080}"]
