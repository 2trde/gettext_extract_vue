# GettextExtractVue

If you are using elixir with phoenix, vuejs for the frontend with .vue single files and
need i18n with gettext then this package might be helpful for you.

With [vue-gettext](https://github.com/Polyconseil/vue-gettext) you can use gettext with
vuejs. But it requires a json file and a couple of js packages to extract the translations.

With elixir/gettext there are already translations for backend stuff like validation messages
and so on. It might be good to combine that.

This package will scan your .vue files for <translation> elements and add these msgids to
gettext. They are then translated like the rest of the elixir-gettext messages. Later
you can create a translation.js file, that can be included in vue-gettext and the frontend
is translated as well.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

1. Add `gettext_extract_vue` to your list of dependencies in `mix.exs`:


    ```elixir
    def deps do
      [{:gettext_extract_vue, github: "2trde/gettext_extract_vue"]
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

Your translations will be put in `priv/gettext/default.pot`

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
