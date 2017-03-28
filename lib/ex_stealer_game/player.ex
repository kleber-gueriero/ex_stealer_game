defmodule ExStealerGame.Player do
  @derive {Poison.Encoder, only: [:id, :name, :score]}
  @enforce_keys [:id, :name, :score, :client_pid]
  defstruct [:id, :name, :score, :client_pid]
end
