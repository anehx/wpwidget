---------------------------------------------------
-- Licensed under the GNU General Public License v2
-- * (c) 2015, Jonas M. <anehxdzn@gmail.com>
---------------------------------------------------

local awful    = require("awful")
local lfs      = require("lfs")
local gears    = require("gears")
local wpwidget = {}

local function startsWith(str, start)
   return string.sub(str, 1, string.len(start)) == start
end

local file_filter = function(e) return string.match(e, "%.png$") or string.match(e, "%.jpg$") end
local dir_filter = function(e) return not startsWith(e, '.') end

local function scanDir(path, filter)
    if not filter then
        filter = function(e) return true end
    end

    files = {}

    for filename in lfs.dir(path) do
        if filter(filename) then
            table.insert(files, filename)
        end
    end
    return files
end

local function makeMenuEntry(theme)
    entry = {
        theme,
        function() wpwidget.changeTheme(theme) end
    }
    return entry
end

function wpwidget.createWallpaperMenu()
    items = {}

    for i,theme in pairs(wpwidget.themes) do
        table.insert(items, makeMenuEntry(theme))
    end

    wpwidget.menu = awful.menu({
        items=items
    })
end

function wpwidget.updateTooltip()
    local strf = 'Current Wallpapers:'
    for i,wp in pairs(wpwidget.current_wps) do
        strf = string.format('%s\nScreen %s: %s', strf, wp.screen, wp.file)
    end
    wpwidget.tooltip:set_text(strf)
end

function wpwidget.setRandomWallpapers()
    wpwidget.current_wps = {}
    for s = 1, screen.count() do
        local wp = wpwidget.current_theme.files[math.random(#wpwidget.current_theme.files)]
        table.insert(wpwidget.current_wps, {screen=s,file=wp})
        gears.wallpaper.maximized(wpwidget.current_theme.path .. wp, s, false)
    end
    wpwidget.updateTooltip()
end

function wpwidget.setTimer()
    wpwidget.timer = timer { timeout = wpwidget.timeout }
    wpwidget.timer:connect_signal(
        "timeout",
        function()
            wpwidget.setRandomWallpapers()
            wpwidget.timer:stop()
            wpwidget.timer.timeout = wpwidget.timeout
            wpwidget.timer:start()
        end
    )
    wpwidget.timer:start()
end

function wpwidget.changeTheme(theme)
    wpwidget.setTheme(theme)
end

function wpwidget.setTheme(theme)
    wpwidget.current_theme = {
        name = theme,
        path = wpwidget.path .. theme .. "/"
    }
    wpwidget.current_theme.files = scanDir(wpwidget.current_theme.path, file_filter)

    -- update text
    wpwidget.textbox:set_markup(wpwidget.pattern:format(wpwidget.current_theme.name))

    -- set a random wallpaper of the given theme
    wpwidget.setRandomWallpapers()
end

function wpwidget.register(options)
    wpwidget.path    = options.path
    wpwidget.pattern = options.pattern
    wpwidget.themes  = scanDir(wpwidget.path, dir_filter)
    wpwidget.timeout = 600 -- 10 minutes
    wpwidget.textbox = options.textbox
    wpwidget.tooltip = awful.tooltip({objects={wpwidget.textbox}})

    wpwidget.setTheme(wpwidget.themes[math.random(#wpwidget.themes)])
    wpwidget.setTimer()
    wpwidget.createWallpaperMenu()
    wpwidget.updateTooltip()

    -- trigger buttons
    wpwidget.textbox:buttons(awful.util.table.join(awful.button({ }, 1, function () wpwidget.menu:toggle()  end)))

    if options.icon then
        options.icon:buttons(awful.util.table.join(awful.button({ }, 1, function () wpwidget.setRandomWallpapers() end)))
    end
end

return wpwidget
