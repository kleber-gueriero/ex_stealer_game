defmodule ExStealerGame.Client do
  alias ExStealerGame.{Player}
  @host 'server'
  @port String.to_integer(System.get_env("PORT"))

  def connect do
    {:ok, socket} = :gen_tcp.connect(@host, @port,
      [:binary, active: false, reuseaddr: true])

    IO.gets("What should I call you?\n")
    |> join_game(socket)

    Task.start_link(fn -> read_loop(socket) end)
    main_loop(socket)
  end

  defp join_game(player_name, socket) do
    player_name
    |> String.replace("\n","")
    |> send_to_server(:join_game, socket)
  end

  defp main_loop(socket) do
    handle_user_input(socket)
    main_loop(socket)
  end

  defp steal(player_id, socket) do
    send_to_server(player_id, :steal, socket)
  end

  defp handle_user_input(socket) do
    IO.gets("Who're you gonna steal?(just write the number of the user you want to steal and press ENTER)")
    |> String.replace("\n","")
    |> steal(socket)
  end

  defp read_loop(socket) do
    {:ok, client_input} = :gen_tcp.recv(socket, 0)

    String.split(client_input, "|") |> handle_client_input(socket)
    read_loop(socket)
  end

  defp handle_client_input(["update_score", players], socket) do
    Poison.decode!(players)
    |> print_ui()
  end

  defp print_ui(players) do
    score_string = Enum.reverse(players)
    |> Enum.map(fn(player) ->
         "##{player["id"]} - #{player["name"]} #{String.duplicate("# ", player["score"])}\n"
       end)

    IO.puts """
    #{IO.ANSI.clear}
    CURRENT SCORE:
    #{score_string}
    """
  end

  defp send_to_server(message, action, socket) do
    :gen_tcp.send(socket, "#{action}|#{message}")
  end
end
