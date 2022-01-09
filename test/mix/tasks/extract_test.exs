defmodule Mix.Tasks.ExtractTest do
  use ExUnit.Case
  doctest GettextExtractVue

  alias Mix.Tasks.GettextVue.Extract

  test "scan_locales" do
    assert Extract.scan_locales("test/gettext_sample") == %{
             "de" => %{"" => "", "Price" => "Preis", "can't be blank" => "bitte ausfüllen"},
             "en" => %{"" => "", "Price" => "The Price", "can't be blank" => "please put something here"}
           }
  end
end
