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
  Filters the given JSON string with the given j(a)q code and loading `.jq` scripts
  in the given path.

  ## Examples

  ```
  iex> Jaqex.filter("[1, 2, 3]", "[ .[] | {v: .} ]")
  {:ok, [%{"v" => 1}, %{"v" => 2}, %{"v" => 3}]}
  ```

  Assuming `priv/` contains a jq script `t.jq`, the following demonstrates Jaqex loading that
  and availing it for use by your filter code:

  ```
  iex> Jaqex.filter("[\\"fooBar\\"]", "import \\"t\\" as t; [ .[] | t::snake_case(.) ]", "priv")
  {:ok, ["foo_bar"]}
  ```
  """
  @spec filter(String.t(), String.t(), Path.t()) :: {:ok, term} | {:error, term}
  def filter(json_doc, code, path \\ "") do
    {:ok, filter!(json_doc, code, path)}
  rescue
    e -> error(e)
  end

  @doc """
  Similar to `filter/3` but raises on errors.
  """
  @spec filter!(String.t(), String.t(), Path.t()) :: term
  def filter!(json_doc, code, path \\ "")

  def filter!(json_doc, code, path) when is_binary(json_doc) do
    result = nif_filter(json_doc, code, path)
    if(length(result) == 1, do: List.first(result), else: result)
  end

  def filter!(_, _, _), do: raise("Given json_doc is not a string/binary")

  @doc """
  Similar to `filter/3` but loads the json doc at the given path. Note that the
  file is opened in "Rust-land", thus bypassing any potential issues the BEAM may
  cause when processing large binaries.
  """
  @spec filter_file(Path.t(), String.t(), Path.t()) :: {:ok, term} | {:error, term}
  def filter_file(fname, code, path \\ "") do
    {:ok, filter_file!(fname, code, path)}
  rescue
    e -> error(e)
  end

  @doc """
  Similar to `filter_file/3` but raises on errors.
  """
  @spec filter_file!(Path.t(), String.t(), Path.t()) :: term
  def filter_file!(fname, code, path \\ "") do
    result = nif_filter_file(fname, code, path)
    if(length(result) == 1, do: List.first(result), else: result)
  end

  defp error(%ErlangError{original: err}), do: {:error, err}
  defp error(%ArgumentError{message: msg}), do: {:error, msg}

  defp nif_filter(_json_doc, _code, _path), do: :erlang.nif_error(:nif_not_loaded)

  defp nif_filter_file(_fname, _code, _path), do: :erlang.nif_error(:nif_not_loaded)
end
