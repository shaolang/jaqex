defmodule Jaqex do
  @moduledoc """
  Documentation for `Jaqex`.
  """
  use Rustler, otp_app: :jaqex, crate: :jaqex

  def parse(json_doc, code, path \\ "") do
    result = _parse(json_doc, code, path)
    {:ok, if(length(result) == 1, do: List.first(result), else: result)}
  rescue
    e -> error(e)
  end

  defp error(%ErlangError{original: err}), do: {:error, err}

  defp _parse(_json_doc, _code, _path), do: :erlang.nif_error(:nif_not_loaded)
end
