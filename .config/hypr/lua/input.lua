---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "altgr-intl",
        kb_model   = "",
        kb_options = "altwin:swap_lalt_lwin,ctrl:nocaps,shift:both_capslock",
        -- kb_options description (ordered): 
        -- swap left alt and meta keys
        -- set caps lock to ctrl
        -- press both shifts to enab

        kb_rules   = "",

        follow_mouse = 1,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.
        accel_profile = "flat",

        touchpad = {
            natural_scroll = true,
        },

    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})

-- Example per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
hl.device({
    name        = "tpps/2-elan-trackpoint",
    sensitivity = 0,
})

