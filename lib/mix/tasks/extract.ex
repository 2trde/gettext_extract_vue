defmodule Mix.Tasks.GettextVue.Extract do
  use Mix.Task
  @recursive true

  @shortdoc "Extracts translations from vue files and put result to web/static/js/translations.js"

  @default_po_file_path "priv/gettext"
  @default_target_json "web/static/js/translations.js"

  def run(args) do
    po_file_path = @default_po_file_path
    target_json = @default_target_json
    translations = scan_locales(po_file_path)
    {:ok, content} = Poison.encode(translations)
    File.write(target_json, "export default #{ content}")
  end

  @doc """
    scan locale directories in priv/gettext. There we expect dirs
    like en_US, en, de and so on
  """
  def scan_locales(path) when is_binary(path) do
    case File.ls(path) do
      {:ok, files} ->
        scan_locales(path, files)
      _ -> nil
    end
  end
  def scan_locales(path, files) when is_list(files) do
    Enum.reduce(files, %{}, fn(file, acc) ->
      fname = "#{path}/#{file}"
      if File.dir?(fname) do
        Map.put(acc, file, load_po_files(file, fname))
      else
        acc
      end
    end)
  end

  @doc """
    load all po files in a locale directory like /priv/gettext/en.
    It will look in all the files in LC_MESSAGES dir
  """
  def load_po_files(locale, path) do
    Enum.reduce(File.ls!("#{path}/LC_MESSAGES"), %{}, fn (file,acc) ->
      fname = "#{path}/LC_MESSAGES/#{file}"
      load_po(locale, file, fname)
      |> Map.merge(acc)
    end)
  end

  @doc """
    load a single po file and parse the content
  """
  def load_po(locale, file, fname) do
    state =
      File.stream!(fname)
      |> Enum.reduce(%{dict: %{}}, fn (line, state) ->
        parse_line(line, state)
      end)
    state.dict
  end

  @doc """
    parse a single line
  """
  def parse_line("msgid " <> param, state) do
    Map.put(state, :key, trim_no_quotes(param))
  end
  def parse_line("msgstr \"\"" <> _param, state) do
    dict = Map.put(state.dict, state.key, state.key)
    state
    |> Map.delete(:key)
    |> Map.put(:dict, dict)
  end
  def parse_line("msgstr " <> param, state) do
    dict = Map.put(state.dict, state.key, trim_no_quotes(param))
    state
    |> Map.delete(:key)
    |> Map.put(:dict, dict)
  end
  def parse_line(_whatever, state) do
    state
  end

  defp trim_no_quotes(str) do
    str
    |> String.trim
    |> String.slice(1..-2)
  end
end
