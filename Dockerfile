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
COPY rel rel

RUN mix compile
RUN mix assets.deploy
RUN mix release

# ---- Runtime stage ----
FROM elixir:1.16-otp-26-alpine AS runtime

WORKDIR /app

COPY --from=build /app/_build/prod/rel/torch_room ./

ENV HOME=/app
EXPOSE 4000

CMD ["bin/server"]
