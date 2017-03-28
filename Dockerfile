FROM elixir

RUN mkdir /ex_stealer_game
COPY . /ex_stealer_game
WORKDIR /ex_stealer_game

RUN mix local.hex --force
