module ThemeHelper
  THEMES = [
    {name: "light", icon: "sun-fill"},
    {name: "dark", icon: "moon-stars-fill"},
    {name: "auto", icon: "circle-half"},
  ].freeze

  THEME_NAMES = THEMES.pluck(:name).freeze

  THEME_ICONS =
    THEMES.to_h { |theme| [theme[:name].intern, theme[:icon]] }.freeze

  def themes
    THEME_NAMES
  end

  def theme_icon(name)
    THEME_ICONS[name.intern] || "palette-fill"
  end

  def theme_navbar_color
    @theme_navbar_color ||=
      Settings.theme.navbar&.then { |color| Color::RGB.by_css(color) }
  end

  def theme_css
    css = []

    navbar_color = theme_navbar_color
    if navbar_color
      css << "--theme-navbar-bg: #{navbar_color.html};"
      css << "--theme-navbar-bg-rgb: " \
        "#{navbar_color.to_a.map { |f| (f * 0xff).to_i }.join(", ")};"
    end

    if css.present?
      <<~CSS
        :root {
        #{css.join("\n")}
        }
      CSS
    else
      ""
    end
  end

  # TODO: 0.5でいいのかどうかはわからない
  def theme_navbar_theme
    case theme_navbar_color&.to_hsl&.l&.>=(0.5)
    in true
      :light
    in false
      :dark
    in nil
      nil
    end
  end
end
