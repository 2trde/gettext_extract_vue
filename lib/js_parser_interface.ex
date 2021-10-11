defmodule GettextExtractVue.JSParserInterface do
  def extract_gettext(file) do
    parser = Path.join([__DIR__, "..", "dist/parser.js"])

    case System.cmd("node", [parser, file]) do
      {result, 0} ->
        Poison.decode(result)

      {err, exit_code} ->
        {:error, "#{err} #{exit_code}"}
    end
  end
end
