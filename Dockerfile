FROM ghcr.io/gleam-lang/gleam:v1.17.0-erlang-alpine AS build

# lustre_ssg and smalto are git dependencies.
RUN apk add --no-cache git

WORKDIR /build

COPY gleam.toml manifest.toml ./
RUN gleam deps download

COPY src ./src
COPY content ./content
COPY public ./public
# The book club shelves come from the shop's API. ADD downloads it on every
# build, where a RUN fetch would be served from the layer cache and miss new
# picks. If the API is down the build fails and the current deploy stays up.
ADD https://api.dungeonbooks.com/v1/books content/shelves/book-club.json
RUN gleam run

FROM caddy:2-alpine
COPY Caddyfile /etc/caddy/Caddyfile
COPY --from=build /build/dist /srv
