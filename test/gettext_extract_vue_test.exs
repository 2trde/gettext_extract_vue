defmodule GettextExtractVueTest do
  use ExUnit.Case
  doctest GettextExtractVue

  test "extract_vue_templates" do
    :meck.expect(Gettext.Extractor, :extract,
                 fn(%Macro.Env{file: "./test/test_templates/test.vue"},
                    :gettext_backend, "default", key, []) ->
                   send self(), {:translate, key}
                 end)

    backend = :gettext_backend
    GettextExtractVue.recursive(".", %{backend: backend})
    assert_receive {:translate, "Foo"}
    assert_receive {:translate, "Bar"}
  end
end
