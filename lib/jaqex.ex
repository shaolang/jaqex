defmodule Jaqex do
  @moduledoc """
  Documentation for `Jaqex`.
  """
  use Rustler, otp_app: :jaqex, crate: :jaqex

  def parse(_json_doc, _code, _path \\ ""), do: :erlang.nif_error(:nif_not_loaded)
end
