------------------
---- MONITORS ----
------------------
-- See https://wiki.hypr.land/Configuring/Basics/Monitors/

hl.monitor({
    output   = "desc:ASUSTek COMPUTER INC XG27AQWMG W2LMTF013105",
    mode     = "2560x1440@280",
    position = "0x0",
    scale    = "auto",
    bitdepth = 10,
})

hl.monitor({
    output   = "desc:HP Inc. HP 24w CNC8261SFL",
    mode     = "1920x1080@60",
    position = "2560x0",
    scale    = "auto",
})

-- Thinkpad x1 carbon monitor
hl.monitor({
    output   = "desc:BOE 0x094C",
    mode     = "1920x1200@60",
    position = "auto",
    scale    = "1.00",
})
