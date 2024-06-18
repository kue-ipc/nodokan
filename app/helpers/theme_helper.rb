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
end
