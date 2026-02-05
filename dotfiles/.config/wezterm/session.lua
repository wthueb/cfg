---@diagnostic disable-next-line: assign-type-mismatch
local wezterm = require("wezterm") ---@type Wezterm
local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")
local sessionizer = wezterm.plugin.require("https://github.com/mikkasendke/sessionizer.wezterm")

resurrect.state_manager.periodic_save({
    interval_seconds = 10,
    save_workspaces = true,
    save_windows = true,
    save_tabs = true,
})

wezterm.on("gui-startup", resurrect.state_manager.resurrect_on_gui_startup)

local function resurrect_callback(window, pane, id, label)
    if not id or not label then
        -- when you hit esc in the chooser
        return
    end

    label = label:gsub("󱂬 : ", "")

    --- save current workspace before switching
    local current_workspace = window:active_workspace()
    if current_workspace then
        local state = resurrect.workspace_state.get_workspace_state()
        resurrect.state_manager.save_state(state)
        resurrect.state_manager.write_current_state(current_workspace, "workspace")
    end

    window:perform_action(
        wezterm.action.SwitchToWorkspace({
            name = label,
            spawn = {
                cwd = id,
            },
        }),
        pane
    )

    local success, state = pcall(resurrect.state_manager.load_state, label, "workspace")
    if success and state then
        resurrect.workspace_state.restore_workspace(state, {
            window = window,
            relative = true,
            restore_text = true,
            resize_window = false,
            on_pane_restore = resurrect.tab_state.default_on_pane_restore,
        })
    end
end

---@alias Entry {label: string, id: string}

local function dirs_txt_generator()
    local file = io.open(wezterm.config_dir .. "/dirs.txt", "r")
    if not file then
        return {}
    end

    local schema = {}

    for spec_line in file:lines() do
        spec_line = spec_line:gsub("~", wezterm.home_dir)

        local method, path = spec_line:match("^(%w+)%s+(.-)$")

        if method == nil or path == nil or method == "raw" then
            local label = spec_line:gsub(wezterm.home_dir, "~")
            path = spec_line:gsub("~", wezterm.home_dir)
            table.insert(schema, { label = label, id = path })
        elseif method == "git" then
            table.insert(schema, function()
                ---@type Entry[]
                local entries = {}

                local _, stdout, _ = wezterm.run_child_process({
                    "fd",
                    "-Ha",
                    [[\.git$]],
                    path,
                })

                for line in stdout:gmatch("[^\n]*\n?") do
                    line = line:match("^%s*(.-)%s*$") -- trim whitepsace

                    local parent = line:match([[^(.+)[\/].git[\/]?$]])
                    local dir = string.basename(parent)

                    table.insert(entries, { label = dir, id = parent })
                end

                return entries
            end)
        elseif method == "dir" then
            table.insert(schema, function()
                ---@type Entry[]
                local entries = {}

                local _, stdout, _ = wezterm.run_child_process({
                    "fd",
                    "-t",
                    "d",
                    "-Ha",
                    "--max-depth=1",
                    ".",
                    path,
                })

                for line in stdout:gmatch("[^\n]*\n?") do
                    line = line:match("^%s*(.-)[\\/]?%s*$") -- trim whitepsace and trailing slash

                    local label = line:gsub(wezterm.home_dir, "~")

                    table.insert(entries, { label = label, id = line })
                end

                return entries
            end)
        end
    end

    file:close()
    return schema
end

local function active_workspaces_generator()
    ---@type Entry[]
    local entries = {}

    for _, ws in ipairs(wezterm.mux.get_workspace_names()) do
        local path = ws:gsub("~", wezterm.home_dir)
        table.insert(entries, { label = "󱂬 : " .. ws, id = path })
    end

    return entries
end

local schema = {
    options = {
        title = "Sessionizer",
        prompt = "Select workspace: ",
        always_fuzzy = true,
        callback = resurrect_callback,
    },

    active_workspaces_generator,
    sessionizer.DefaultWorkspace({ label_overwrite = "~", id_overwrite = wezterm.home_dir }),
    dirs_txt_generator,
    processing = function(entries)
        local seen = {}

        local i = 1
        while i <= #entries do
            if seen[entries[i].id] then
                table.remove(entries, i)
            else
                seen[entries[i].id] = true
                i = i + 1
            end
        end
    end,
}

return {
    schema = schema,
    show = function()
        return sessionizer.show(schema)
    end,
}
