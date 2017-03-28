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

  def get_players do
    Agent.get(__MODULE__, &(&1.players))
  end

  def get_player(player_client) do
    get_players()
    |> Enum.find(fn(player) -> player.client_pid == player_client end)
  end

  def execute_steal(stealer_id, target_id) when stealer_id == target_id do
  end

  def execute_steal(stealer_id, target_id) do
    Agent.update(__MODULE__, fn(match) ->
      players = match.players
      updated_players = Enum.map(players, fn(player) ->
        IO.inspect(player)
        case player do
          %Player{id: ^stealer_id} -> %{player | score: player.score + 1}
          %Player{id: ^target_id} -> %{player | score: player.score - 1}
          _ -> player
        end
      end)

      %{match | players: updated_players}
    end)
  end

  defp next_id do
    match().last_id + 1
  end

  defp match do
    Agent.get(__MODULE__, &(&1))
  end
end
