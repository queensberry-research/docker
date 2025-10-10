set dotenv-load := true
set positional-arguments := true

@build:
  docker buildx build .
