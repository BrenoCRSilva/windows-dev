local wezterm = require("wezterm")
local c = {}
if wezterm.config_builder then
    c = wezterm.config_builder()
end
c.default_domain = "WSL:Ubuntu-24.04"
c.window_decorations = "RESIZE"
c.window_background_opacity = 0.9
c.colors = {
    background = "#0c0b12",
    cursor_bg = "#808080",
    cursor_fg = "#0c0b12"
}
c.font = wezterm.font "Fira Code"
c.font_size = 17.0
c.hide_tab_bar_if_only_one_tab = true 
c.window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0
}
c.front_end = "OpenGL"
c.prefer_egl = true

return c 