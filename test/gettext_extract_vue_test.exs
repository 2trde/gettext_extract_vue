defmodule GettextExtractVueTest do
  use ExUnit.Case
  doctest GettextExtractVue

  test "extract_vue_templates" do
    :meck.expect(Gettext.Extractor, :extract,
                 fn(%Macro.Env{file: "./test/test_templates/test.vue"},
                    :gettext_backend, "default", "Foo") -> end)

    backend = :gettext_backend
    GettextExtractVue.do_extract_vue_templates(backend, ".")
  end
end
