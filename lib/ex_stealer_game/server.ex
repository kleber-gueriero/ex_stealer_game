defmodule ExStealerGame.Server do
  alias ExStealerGame.Match
  @port String.to_integer(System.get_env("PORT"))

  def start_server() do
    IO.puts "STARTING SERVER"
    {:ok, socket} = :gen_tcp.listen(@port,
      [:binary, active: false, reuseaddr: true])
    IO.puts "SERVER STARTED"

    accept_connection(socket)
  end

  defp accept_connection(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    IO.puts "NEW CLIENT CONNECTED"

    {:ok, pid} = Task.start(fn -> server_loop(client) end)
    :gen_tcp.controlling_process(client, pid)
    accept_connection(socket)
  end

  defp server_loop(client) do
    read_client(client)
    server_loop(client)
  end

  defp read_client(client) do
    {:ok, client_input} = :gen_tcp.recv(client, 0)
    IO.puts("RECEIVED FROM CLIENT:")
    IO.inspect(client_input)

    client_input
    |> String.split("|")
    |> handle_client_input(client)
  end

  defp send_to_client(message, action, client) do
    IO.puts("SENDING TO CLIENT:")
    IO.inspect(message)

    :gen_tcp.send(client, "#{action}|#{message}")
  end

  defp handle_client_input(["join_game", player_name], client) do
    IO.puts("PLAYER #{player_name} JOINED THE GAME")
    Match.register_player(player_name, client)

    send_score_to_clients
  end

  defp handle_client_input(["steal", target_id], client) do
    IO.puts("STEALING FROM #{target_id}")
    Match.get_player(client).id
    |> Match.execute_steal(String.to_integer(target_id))
    send_score_to_clients
  end

  defp send_score_to_clients do
    players = Match.get_players
    Enum.each(players, fn(player) ->
      players
      |> Poison.encode!()
      |> send_to_client("update_score", player.client_pid)
    end)
  end
end
