FROM elixir:1.16-otp-26-alpine AS build

RUN apk add --no-cache build-base npm git

WORKDIR /app

COPY mix.exs mix.lock ./
RUN mix local.hex --force && mix local.rebar --force
RUN mix deps.get --only prod

ENV MIX_ENV=prod

COPY config/config.exs config/prod.exs config/runtime.exs config/
COPY lib lib
COPY priv priv
COPY assets assets

RUN mix assets.deploy
RUN mix compile
RUN mix release

# ---- Runtime stage ----
FROM alpine:3.19 AS runtime

RUN apk add --no-cache libstdc++ openssl ncurses-libs

WORKDIR /app

COPY --from=build /app/_build/prod/rel/torch_room ./

ENV HOME=/app
EXPOSE 4000

CMD ["bin/torch_room", "start"]
