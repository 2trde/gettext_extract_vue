defmodule GettextExtractVue do
  @moduledoc """
    Allow extraction of template-tags in vue templates. 
  """

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
    {:ok, cwd} = File.cwd
    do_extract_vue_templates(backend, cwd)
  end
  def do_extract_vue_templates(backend, cwd) do
    recursive(cwd <> "/web/static", %{backend: backend})
  end

  @doc """
    scan dir recursive
  """
  def recursive(dir \\ ".", ctx) do
    Enum.each(File.ls!(dir), fn file ->
      fname = "#{dir}/#{file}"
      if File.dir?(fname), do: recursive(fname, ctx)
      extract(fname, ctx)
    end)
  end

  @doc """
    extract file, if it is a vue template
  """
  def extract(file, ctx) do
    if String.ends_with?(file, ".vue") or String.ends_with?(file, ".js")do
      extract_vue(file, Map.put(ctx, :file, file))
    end
  end

  @doc """
    extract vue file
  """
  def extract_vue(file, ctx) do
    {:ok, content} = File.read(file)
    parse(content, ctx)
  end

  @doc """
    parse file until we hit a <translate> element
  """
  def parse(<< "<translate>" <> rem >>, ctx) do
    parse_translate(rem, "", ctx)
  end
  def parse(<< "<Translate>" <> rem >>, ctx) do
    parse_translate(rem, "", ctx)
  end
  def parse(<< "gettext(\"" <> rem >>, ctx) do
    parse_translate_js(rem, "", ctx)
  end
  def parse(<< "gettext('" <> rem >>, ctx) do
    parse_translate_js(rem, "", ctx)
  end
  def parse("", _ctx), do: nil
  def parse(<< c, rem :: binary >>, ctx) do
    parse(rem, ctx)
  end

  @doc """
    parse inside the template-element and buffer the content
  """
  def parse_translate("</translate>" <> rem, buffer, ctx) do
    Gettext.Extractor.extract(%Macro.Env{file: ctx.file, line: 1}, ctx.backend, "default", buffer)
    parse(rem, ctx)
  end
  def parse_translate("</Translate>" <> rem, buffer, ctx) do
    Gettext.Extractor.extract(%Macro.Env{file: ctx.file, line: 1}, ctx.backend, "default", buffer)
    parse(rem, ctx)
  end
  def parse_translate(<< c, rem :: binary >>, buffer, ctx) do
    parse_translate(rem, buffer <> << c >>, ctx)
  end
  def parse_translate("", buffer, ctx) do
    raise "can't find closing translate tag in #{ctx.file}"
  end

  def parse_translate_js("\")" <> rem, buffer, ctx) do
    Gettext.Extractor.extract(%Macro.Env{file: ctx.file, line: 1}, ctx.backend, "default", buffer)
    parse(rem, ctx)
  end
  def parse_translate_js("')" <> rem, buffer, ctx) do
    Gettext.Extractor.extract(%Macro.Env{file: ctx.file, line: 1}, ctx.backend, "default", buffer)
    parse(rem, ctx)
  end
  def parse_translate_js(<< c, rem :: binary >>, buffer, ctx) do
    parse_translate_js(rem, buffer <> << c >>, ctx)
  end
  def parse_translate_js("", buffer, ctx) do
    raise "can't find closing translate tag in #{ctx.file}"
  end
end
