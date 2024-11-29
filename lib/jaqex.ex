defmodule Jaqex do
  @moduledoc """
  Documentation for `Jaqex`.
  """
  source_url = Mix.Project.config()[:source_url]
  version = Mix.Project.config()[:version]

  use RustlerPrecompiled,
    base_url: "#{source_url}/releases/download/v#{version}",
    crate: :jaqex,
    otp_app: :jaqex,
    version: version

  def parse(json_doc, code, path \\ "") do
    result = nif_parse(json_doc, code, path)
    {:ok, if(length(result) == 1, do: List.first(result), else: result)}
  rescue
    e -> error(e)
  end

  def parse_file(fname, code, path \\ "") do
    result = nif_parse_file(fname, code, path)
    {:ok, if(length(result) == 1, do: List.first(result), else: result)}
  rescue
    e -> error(e)
  end

  defp error(%ErlangError{original: err}), do: {:error, err}

  defp nif_parse(_json_doc, _code, _path), do: :erlang.nif_error(:nif_not_loaded)

  defp nif_parse_file(_fname, _code, _path), do: :erlang.nif_error(:nif_not_loaded)
end
