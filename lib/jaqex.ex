defmodule Jaqex do
  @moduledoc """
  Documentation for `Jaqex`.
  """
  source_url = Mix.Project.config()[:source_url]
  version = Mix.Project.config()[:version]

  use RustlerPrecompiled,
    base_url: "#{source_url}/releases/download/v#{version}",
    crate: :jaqex,
    force_build: String.downcase(System.get_env("FORCE_JAQEX_BUILD", "0")) in ["1", "true"],
    nif_versions: ["2.15", "2.16", "2.17"],
    otp_app: :jaqex,
    version: version

  @doc """
  Filter the given JSON string with the given j(a)q code.
  """
  @spec filter(String.t(), String.t(), Path.t()) :: {:ok, term} | {:error, term}
  def filter(json_doc, code, path \\ "") do
    filter!(json_doc, code, path)
  rescue
    e -> error(e)
  end

  @doc """
  Filter the given JSON string with the given j(a)q code, raising on errors.
  """
  @spec filter!(String.t(), String.t(), Path.t()) :: term
  def filter!(json_doc, code, path \\ "") do
    result = nif_filter(json_doc, code, path)
    {:ok, if(length(result) == 1, do: List.first(result), else: result)}
  end

  @doc """
  Filter the JSON in the given file with the given j(a)q code.
  """
  @spec filter_file(Path.t(), String.t(), Path.t()) :: {:ok, term} | {:error, term}
  def filter_file(fname, code, path \\ "") do
    filter_file!(fname, code, path)
  rescue
    e -> error(e)
  end

  @doc """
  Filter the JSON in the given file with the given j(a)q code, raising on errors.
  """
  @spec filter_file!(Path.t(), String.t(), Path.t()) :: term
  def filter_file!(fname, code, path \\ "") do
    result = nif_filter_file(fname, code, path)
    {:ok, if(length(result) == 1, do: List.first(result), else: result)}
  end

  defp error(%ErlangError{original: err}), do: {:error, err}

  defp nif_filter(_json_doc, _code, _path), do: :erlang.nif_error(:nif_not_loaded)

  defp nif_filter_file(_fname, _code, _path), do: :erlang.nif_error(:nif_not_loaded)
end
