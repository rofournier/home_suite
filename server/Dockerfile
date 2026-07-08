# Build : compile AOT → binaire unique.
FROM dart:stable AS build
WORKDIR /app
COPY pubspec.* ./
RUN dart pub get
COPY . .
RUN dart compile exe bin/server.dart -o /app/server

# Run : image slim, il ne faut que libsqlite3 en plus du binaire.
FROM debian:bookworm-slim
RUN apt-get update \
    && apt-get install -y --no-install-recommends libsqlite3-0 ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    # package:sqlite3 charge `libsqlite3.so` ; Debian ne fournit que le `.so.0`.
    && ln -s "$(ldconfig -p | sed -n 's/.*=> \(.*libsqlite3\.so\.0\)$/\1/p' | head -1)" /usr/lib/libsqlite3.so
COPY --from=build /app/server /server

# La DB vit dans /data (volume) pour survivre aux redéploiements.
ENV HSH_PORT=8080 \
    HSH_DB_PATH=/data/home_sweet_home.db \
    HSH_FILES_DIR=/data/files
VOLUME /data
EXPOSE 8080
CMD ["/server"]
