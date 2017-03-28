defmodule ExStealerGame.Client do
  alias ExStealerGame.{Player}
  @host 'server'
  @port String.to_integer(System.get_env("PORT"))

  def connect do
    {:ok, socket} = :gen_tcp.connect(@host, @port,
      [:binary, active: false, reuseaddr: true])

    IO.gets("What should I call you?\n")
    |> join_game(socket)

    main_loop(socket)
  end

  defp join_game(player_name, socket) do
    player_name
    |> String.replace("\n","")
    |> send_to_server(:join_game, socket)
  end

  defp main_loop(socket) do
    read_server(socket)
    handle_user_input(socket)
    main_loop(socket)
  end

  def handle_user_input(socket) do
    IO.gets("Who're you gonna steal?(just write the number of the user you want to steal and press ENTER)")
    |> String.replace("\n","")
    |> IO.puts()
  end

  defp read_server(socket) do
    {:ok, client_input} = :gen_tcp.recv(socket, 0)

    String.split(client_input, "|") |> handle_client_input(socket)
    # read_server(socket)
  end

  defp handle_client_input(["update_score", players], socket) do
    Poison.decode!(players)
    |> print_ui()
  end

  defp print_ui(players) do
    IO.write IO.ANSI.clear
    IO.puts "CURRENT SCORE:"

    Enum.reverse(players)
    |> Enum.each(fn(player) ->
         IO.puts("##{player["id"]} - #{player["name"]} #{String.duplicate("# ", player["score"])}\n")
       end)
  end

  defp send_to_server(message, action, socket) do
    IO.puts("SENDING TO SERVER:")
    IO.puts(message)

    :gen_tcp.send(socket, "#{action}|#{message}")
    IO.puts("SENT TO SERVER:")
  end
end
