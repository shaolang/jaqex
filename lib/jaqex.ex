defmodule Jaqex do
  @moduledoc """
  Documentation for `Jaqex`.
  """
  use Rustler, otp_app: :jaqex, crate: :jaqex

  def parse(json_doc, code, path \\ "") do
    result = _parse(json_doc, code, path)

    if is_list(result) and length(result) == 1 do
      List.first(result)
    else
      result
    end
  end

  @doc false
  def _parse(_json_doc, _code, _path), do: :erlang.nif_error(:nif_not_loaded)
end
