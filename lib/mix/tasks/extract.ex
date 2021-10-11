defmodule Mix.Tasks.GettextVue.Extract do
  use Mix.Task
  @recursive true

  @shortdoc "Extracts translations from vue files and put result to web/static/js/translations.js"

  @default_po_file_path "priv/gettext"
  @default_target_json_dir "src/"

  def run(args) do
    %{paths: paths, seperate_language_files: seperate_language_files, output_dir: output_dir} =
      parse_args(args)

    translations = scan_locales(paths)
    File.mkdir_p!(output_dir)

    case seperate_language_files do
      true ->
        Enum.map(translations, fn {language, values} ->
          {:ok, content} = Poison.encode(values, pretty: true)

          File.write(
            Path.join(output_dir, "#{language}.json"),
            "#{content}"
          )
        end)

      false ->
        {:ok, content} = Poison.encode(translations, pretty: true)

        File.write(
          Path.join(output_dir, "translations.js"),
          "export default #{content}"
        )
    end
  end

  def parse_args(args) do
    {flags, values} =
      OptionParser.parse!(args, strict: [seperate_language_files: :boolean, output_dir: :string])

    %{
      paths: po_file_path(values),
      seperate_language_files: Keyword.get(flags, :seperate_language_files, false),
      output_dir: Keyword.get(flags, :output_dir, @default_target_json_dir)
    }
  end

  def po_file_path([]), do: [@default_po_file_path]
  def po_file_path(paths), do: paths

  @doc """
    scan locale directories in priv/gettext. There we expect dirs
    like en_US, en, de and so on
  """
  def scan_locales(path_list) when is_list(path_list) do
    path_list
    |> Enum.reduce(%{}, fn x, acc ->
      x = scan_locales(x)

      languages =
        (Map.keys(x) ++ Map.keys(acc))
        |> Enum.uniq()

      languages
      |> Enum.map(fn lang ->
        {lang, Map.merge(Map.get(acc, lang, %{}), Map.get(x, lang, %{}))}
      end)
      |> Enum.into(%{})
    end)
  end

  def scan_locales(path) do
    case File.ls(path) do
      {:ok, files} ->
        Enum.reduce(files, %{}, fn file, acc ->
          fname = "#{path}/#{file}"

          if File.dir?(fname) do
            Map.put(acc, file, load_po_files(file, fname))
          else
            acc
          end
        end)

      _ ->
        nil
    end
  end

  @doc """
    load all po files in a locale directory like /priv/gettext/en.
    It will look in all the files in LC_MESSAGES dir
  """
  def load_po_files(locale, path) do
    Enum.reduce(File.ls!("#{path}/LC_MESSAGES"), %{}, fn file, acc ->
      fname = "#{path}/LC_MESSAGES/#{file}"

      load_po(locale, file, fname)
      |> Map.merge(acc)
    end)
  end

  @doc """
    load a single po file and parse the content
  """
  def load_po(_locale, _file, fname) do
    state =
      File.stream!(fname)
      |> Enum.reduce(%{dict: %{}}, fn line, state ->
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
    |> String.trim()
    |> String.slice(1..-2)
  end
end
