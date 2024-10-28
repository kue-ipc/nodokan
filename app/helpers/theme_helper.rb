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

  def theme_css
    navbar = Settings.theme["navbar"]
    return "" unless navbar

    light_css = []
    dark_css = []

    light_css << "--bs-navbar-bg: #{navbar};"
    light_css << "--bs-navbar-bg-rgb: #{to_rgb(navbar).map(&:to_s).join(", ")};"
    dark_css << "--bs-navbr-bg: \##{to_color(to_dark(navbar))};"
    dark_css << "--bs-navbar-bg-rgb: #{to_dark(navbar).map(&:to_s).join(", ")};"

    <<~CSS
      :root, [data-bs-theme=light] {
      #{light_css.join("\n")}
      }
      [data-bs-theme=dark] {
      #{dark_css.join("\n")}
      }
    CSS
  end

  def to_rgb(color)
    case color
    when /\A\s*\#(\h{2})(\h{2})(\h{2})\s*\z/
      [$1.to_i(16), $2.to_i(16), $3.to_i(16)]
    when /\A\s*rgb\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)\)\s*\z/
      [$1.to_i(16), $2.to_i(16), $3.to_i(16)]
    when /\A\s*rgba\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*\d+\s*\)\)\s*\z/
      [$1.to_i(16), $2.to_i(16), $3.to_i(16)]
    else
    raise "not a color: #{color}"
    end
  end

  def to_color(rgb)
    "\#%02x%02x%02x" % [rgb[0], rgb[1], rgb[2]]
  end

  def to_dark(color)
    color = to_rgb(color) if color.is_a?(String)
    color.map { |i| i / 4 }
  end
end
