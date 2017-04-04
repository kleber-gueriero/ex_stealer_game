defmodule ExStealerGame.Server do
  alias ExStealerGame.Match
  @port String.to_integer(System.get_env("PORT"))
  @score_line_size 25

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

    handle_player_join(client)
    {:ok, pid} = Task.start(fn -> match_loop(client) end)
    :gen_tcp.controlling_process(client, pid)
    accept_connection(socket)
  end

  defp match_loop(client) do
    client
    |> read_client()
    |> handle_match_message(client)

    match_loop(client)
  end

  defp read_client(client) do
    {:ok, client_input} = :gen_tcp.recv(client, 0)
    IO.puts("RECEIVED FROM CLIENT:")
    IO.inspect(client_input)

    client_input
    |> String.replace("\r\n", "")
    |> String.replace("\n","")
  end

  defp send_to_client(message, client) do
    IO.puts("SENDING TO CLIENT:")
    IO.inspect(message)

    :gen_tcp.send(client, message)
  end

  defp handle_client_input(["join_game", player_name], client) do
    IO.puts("PLAYER #{player_name} JOINED THE GAME")
    Match.register_player(player_name, client)

    send_score_to_clients
  end

  defp handle_match_message(message, client) do
    case Integer.parse(message) do
      {target_id, _} -> 
        IO.puts("STEALING FROM #{target_id}")
        Match.get_player(client).id
        |> Match.execute_steal(target_id)
        send_score_to_clients()
      :error -> send_score_to_clients()
    end
  end

  defp send_score_to_clients do
    players = Match.get_players
    Enum.each(players, fn(player) ->
      players
      |> print_ui()
      |> send_to_client(player.client_pid)
    end)
  end

  defp print_ui(players) do
    """
    #{IO.ANSI.clear}
    COMMANDS: <player_id> - steals from the player | quit - quit the game

    CURRENT SCORE:
    #{build_score_lines(players)}
    Who're you gonna steal?\n
    """
  end

  defp build_score_lines(players) do
    Enum.reverse(players)
    |> Enum.map(fn(player) ->
      player_line = "##{player.id} - #{player.name}"
      space_available = @score_line_size - String.length(player_line)
      "#{player_line}#{String.duplicate(" ", space_available)}#{String.duplicate("# ", player.score)}\n"
    end)
  end

  defp handle_player_join(client) do
    send_to_client("What should I call you?\n", client)

    player_name = read_client(client)

    IO.puts("PLAYER #{player_name} JOINED THE GAME")
    String.slice(player_name, 0, @score_line_size)
    |> Match.register_player(client)

    send_score_to_clients()
  end
end
