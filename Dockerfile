FROM ghcr.io/gleam-lang/gleam:v1.17.0-erlang-alpine AS build

# lustre_ssg and smalto are git dependencies.
RUN apk add --no-cache git

WORKDIR /build

COPY gleam.toml manifest.toml ./
RUN gleam deps download

COPY src ./src
COPY content ./content
COPY public ./public
RUN gleam run

FROM caddy:2-alpine
COPY Caddyfile /etc/caddy/Caddyfile
COPY --from=build /build/dist /srv
