defmodule ExStealerGame.Server do
  alias ExStealerGame.Match
  @port String.to_integer(System.get_env("PORT"))

  def start_server() do
    IO.puts "STARTING SERVER"
    {:ok, socket} = :gen_tcp.listen(@port,
      [:binary, packet: :line, active: false, reuseaddr: true])
    IO.puts "SERVER STARTED"

    accept_connection(socket)
  end

  defp accept_connection(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    IO.puts "NEW CLIENT CONNECTED"

    Task.async(fn -> server_loop(client) end)
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

  defp send_to_client(message, client) do
    IO.puts("SENDING TO CLIENT:")
    IO.inspect(message)

    :gen_tcp.send(client, message)
  end

  defp handle_client_input(["join_game", player_name], client) do
    IO.puts("PLAYER #{player_name} JOINED THE GAME")
    Match.register_player(player_name, client)
    send_to_client("SERVER MESSAGE: YOU JOINED THE GAME", client)
  end
end
