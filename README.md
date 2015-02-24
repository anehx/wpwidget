# wpwidget
A wallpaper widget for Awesome WM written in lua

##Installation
`git clone https://github.com/anehx/wpwidget.git ~/.config/awesome/`

###Requirements
* [lua-filesystem](http://keplerproject.github.io/luafilesystem/)

Your wallpaper folder structure should be about this:
```
/path/to/wallpapers/
        theme1/
            wallpaper1.png
            wallpaper2.jpg
            wallpaper3.png
        theme2/
            wallpaper1.png
        ...
```

##Usage
In your rc.lua file:
* Require it: `local wpwidget = require("wpwidget/wpwidget")`
* Initialize it:
```
wpicon    = wibox.widget.imagebox() # initialize icon (optional)
wptextbox = wibox.widget.textbox()  # initialize textbox
icon:set_image(beautiful.random)  # set an image for the switcher button (optional)
wpwidget.register({
    path="/path/to/you/wallpapers/",
    textbox=wptextbox,
    icon=wpicon, # (optional)
    pattern="Current Theme: %s" # what to display (%s is the name of the current theme)
})
```
* add it to your wibox
