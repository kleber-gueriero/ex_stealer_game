defmodule ExStealerGame.Match do
  alias ExStealerGame.{Match, Player}
  defstruct [:last_id, {:players, []}]

  @starting_score 10

  def start_link do
    Agent.start_link(fn -> %Match{last_id: 0} end, name: __MODULE__)
  end

  def register_player(player_name, client_pid) do
    new_player = %Player{id: next_id(), name: player_name, score: @starting_score, client_pid: client_pid}
    Agent.update(__MODULE__, fn(match) -> %{match | last_id: new_player.id, players: [new_player | match.players]} end)
    new_player
  end

  defp next_id do
    match().last_id + 1
  end

  defp match do
    Agent.get(__MODULE__, &(&1))
  end
end
