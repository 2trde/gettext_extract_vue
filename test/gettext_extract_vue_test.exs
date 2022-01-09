defmodule GettextExtractVueTest do
  use ExUnit.Case
  doctest GettextExtractVue

  test "extract_vue_templates" do
    :meck.expect(Gettext.Extractor, :extract, fn %Macro.Env{file: _}, :gettext_backend, "default", _, key, [] ->
      send(self(), {:translate, key})
    end)

    GettextExtractVue.extract_vue_templates(:gettext_backend)
    assert_receive {:translate, "Foo"}
    assert_receive {:translate, "Bar"}
  end
end
