-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:
--
local utils = require("lua/utils")

hl.on("hyprland.start", function ()
  hl.exec_cmd(utils.uwsm("nm-applet"))
  hl.exec_cmd(utils.uwsm("qs -c noctalia-shell"))
  hl.exec_cmd(utils.uwsm("batsignal -b -e -w 30 -c 20 -d 10 -f 100"))
  hl.exec_cmd(utils.uwsm("blueman-applet"))
  hl.exec_cmd(utils.uwsm("udiskie --tray"))
  hl.exec_cmd(utils.uwsm("xwaylandvideobridge"))
end)
