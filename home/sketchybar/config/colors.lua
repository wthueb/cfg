local M = {}

-- catppuccin mocha theme
local CTP_BASE = 0xff1e1e2e
local CTP_TEXT = 0xffcdd6f4
local CTP_OVERLAY0 = 0xff6c7086
local CTP_SURFACE0 = 0xff313244
local CTP_BLUE = 0xff89b4fa
local CTP_YELLOW = 0xfff9e2af
local CTP_RED = 0xfff38ba8

M.transparent = 0x00000000
M.bg = CTP_BASE
M.modal_bg = CTP_SURFACE0
M.modal_border = CTP_OVERLAY0
M.text = CTP_TEXT
M.icon = CTP_TEXT
M.primary = CTP_BLUE
M.warn = CTP_YELLOW
M.danger = CTP_RED

return M
