defmodule GettextExtractVue do
  @moduledoc """
    Allow extraction of template-tags in vue templates.
  """
  alias GettextExtractVue.JSParserInterface

  @doc """
    Use this macro somewhere in you code, e.g. in the endpoint. It will be
    active when ```mix gettext.extract``` is called and extract all <translation>
    tags in your vue files.
  """
  defmacro extract_vue_templates(backend) do
    {backend_mod, _} = Code.eval_quoted(backend)
    do_extract_vue_templates(backend_mod)
  end

  def do_extract_vue_templates(backend) do
    {:ok, cwd} = File.cwd()
    do_extract_vue_templates(backend, cwd)
  end

  def do_extract_vue_templates(backend, cwd) do
    files = Path.wildcard("#{cwd}/src/**/*.{vue,js,ts,tsx,ex}")
    chunk_count = floor(Enum.count(files) / 10)

    Task.await_many(
      Enum.chunk_every(files, chunk_count)
      |> Enum.map(fn files ->
        Task.async(fn ->
          Enum.map(files, fn file -> extract_vue(file, %{backend: backend}) end)
        end)
      end),
      60 * 1000 * 5
    )

    IO.puts("Processed #{Enum.count(files)} frontend files")
  end

  @doc """
    extract vue file
  """
  def extract_vue(file, ctx) do
    case JSParserInterface.extract_gettext(file) do
      {:ok, values} ->
        Enum.map(values, fn val ->
          Gettext.Extractor.extract(
            %Macro.Env{file: file, line: 1},
            ctx.backend,
            "default",
            val,
            []
          )
        end)

      {:error, error} ->
        IO.puts("Failed to parse #{file} via js: #{error}")
        System.halt(1)
    end
  end
end
