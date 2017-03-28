defmodule ExStealerGame.Client do
  @host 'server'
  @port String.to_integer(System.get_env("PORT"))

  def connect do
    {:ok, socket} = :gen_tcp.connect(@host, @port,
      [:binary, packet: :line, active: false, reuseaddr: true])

    IO.puts "Connected on server"

    main_loop(socket)
  end

  defp main_loop(socket) do
    read_server(socket)
    handle_user_input(socket)
    main_loop(socket)
  end

  def handle_user_input(socket) do
    IO.gets("Who're you gonna steal?(just write the number of the user you want to steal and press ENTER)")
    |> String.replace("\n","")
    |> send_to_server(socket)
  end

  defp read_server(socket) do
    {:ok, client_input} = :gen_tcp.recv(socket, 0)
    IO.puts client_input
  end

  defp send_to_server(message, socket) do
    IO.puts("SENDING TO SERVER:")
    IO.puts(message)
    :gen_tcp.send(socket, message)
    IO.puts("SENT TO SERVER")
  end
end
