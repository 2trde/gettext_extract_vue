# GettextExtractVue

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `gettext_extract_vue` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:gettext_extract_vue, "~> 0.1.0"}]
      {:gettext_extract_vue, "~> 0.1.0", only: :dev},
    end
    ```

  2. Add the extraction macro somewhere in your code, e.g. in your endpoint class

  ```elixir
  defmodule WebUI.Endpoint do
    use Phoenix.Endpoint, otp_app: :web_ui

    require GettextExtractVue
    GettextExtractVue.extract_vue_templates(WebUI.Gettext)

    ...

  end
  ```

  3. Extract vue tampltes

  Call
  ```
  mix gettext.extract
  ```

  Your translations will be put in ```priv/gettext/default.pot```

  4. Follow the gettext documentation to merge to your locales

  e.g.
  ```
  mix gettext.merge priv/gettext --locale=de
  ```

  5. Create the translation js file

  ```
  mix gettext_vue.extract
  ```
  This will create or update the web/static/js/translation.js
  file.



