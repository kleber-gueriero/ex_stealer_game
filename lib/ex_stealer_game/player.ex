defmodule ExStealerGame.Player do
  @enforce_keys [:id, :name, :score, :client_pid]
  defstruct [:id, :name, :score, :client_pid]
end
