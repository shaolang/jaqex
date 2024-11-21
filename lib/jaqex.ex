defmodule Jaqex do
  @moduledoc """
  Documentation for `Jaqex`.
  """
  use Rustler, otp_app: :jaqex, crate: :jaqex

  def add(_x, _y), do: :erlang.nif_error(:nif_not_loaded)
end
