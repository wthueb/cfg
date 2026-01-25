---@diagnostic disable-next-line: assign-type-mismatch
local wezterm = require("wezterm") ---@type Wezterm
local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")
local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")

workspace_switcher.zoxide_path = ":"

resurrect.state_manager.periodic_save({
    interval_seconds = 10,
    save_workspaces = true,
    save_windows = true,
    save_tabs = true,
})

wezterm.on("gui-startup", resurrect.state_manager.resurrect_on_gui_startup)

---@diagnostic disable-next-line: unused-local
wezterm.on("smart_workspace_switcher.workspace_switcher.created", function(window, path, label)
    local success, state = pcall(resurrect.state_manager.load_state, label, "workspace")

    if not success then
        return
    end

    resurrect.workspace_state.restore_workspace(state, {
        window = window,
        relative = true,
        restore_text = true,

        resize_window = false,
        on_pane_restore = resurrect.tab_state.default_on_pane_restore,
    })
end)

---@diagnostic disable-next-line: unused-local
wezterm.on("smart_workspace_switcher.workspace_switcher.chosen", function(window, path, label) end)

---@diagnostic disable-next-line: unused-local
wezterm.on("smart_workspace_switcher.workspace_switcher.switched_to_prev", function(window, path, label) end)

---@diagnostic disable-next-line: unused-local
wezterm.on("smart_workspace_switcher.workspace_switcher.selected", function(window, path, label)
    local state = resurrect.workspace_state.get_workspace_state()
    resurrect.state_manager.save_state(state)
    resurrect.state_manager.write_current_state(label, "workspace")
end)

workspace_switcher.get_choices = function()
    ---@alias Choice {label: string, id: string}
    ---@type Choice[]
    local choices = workspace_switcher.choices.get_workspace_elements({})

    -- put ~ workspace at the top

    for i, choice in ipairs(choices) do
        if choice.id == "~" then
            table.remove(choices, i)
            table.insert(choices, 1, choice)
            break
        end
    end

    local workspaces = table.shallow_copy(choices)

    ---@param potential Choice
    local function check_exists(potential)
        local exists = false
        for _, choice in ipairs(choices) do
            if choice.id == potential.id then
                exists = true
                break
            end
        end
        for _, choice in ipairs(workspaces) do
            if choice.id == potential.label then
                exists = true
                break
            end
        end

        return exists
    end

    ---@param path string
    local function add_dirs(path)
        ---@type boolean, string, string
        local _, stdout, _ = wezterm.run_child_process({
            "fd",
            "-t",
            "d",
            "-Ha",
            ".",
            path,
            "--max-depth=1",
        })

        for line in stdout:gmatch("[^\n]*\n?") do
            ---@type string
            line = line:match("^%s*(.-)[\\/]?%s*$") -- trim whitepsace

            local label = line:gsub(wezterm.home_dir, "~")

            local potential = { label = label, id = line }

            local exists = check_exists(potential)

            if not exists then
                table.insert(choices, potential)
            end
        end
    end

    ---@param path string
    local function add_git_dirs(path)
        ---@type boolean, string, string
        local _, stdout, _ = wezterm.run_child_process({
            "fd",
            "-t",
            "d",
            "-Ha",
            "--min-depth",
            "1",
            "--max-depth",
            "5",
            "--no-ignore",
            "\\.git$",
            path,
            "-x",
            "dirname",
        })

        for line in stdout:gmatch("[^\n]*\n?") do
            ---@type string
            line = line:match("^%s*(.-)%s*$") -- trim whitepsace

            local dir = string.basename(line)

            local potential = { label = dir, id = line }

            local exists = check_exists(potential)

            if not exists then
                table.insert(choices, potential)
            end
        end
    end

    local file = io.open(wezterm.config_dir .. "/dirs.txt", "r")

    if file then
        for line in file:lines() do
            line = line
            local method, path = line:match("^(%w+) (.-)$")
            if method == nil or path == nil then
                local label = line:gsub(wezterm.home_dir, "~")
                table.insert(choices, { label = label, id = line })
            elseif method == "git" then
                add_git_dirs(path)
            elseif method == "dir" then
                add_dirs(path)
            elseif method == "raw" then
                local label = path:gsub(wezterm.home_dir, "~")
                table.insert(choices, { label = label, id = path })
            end
        end
        file:close()
    end

    local has_default = false

    for _, choice in ipairs(choices) do
        if choice.id == "~" then
            has_default = true
        end
    end

    if not has_default then
        table.insert(choices, 1, { id = wezterm.home_dir, label = "~" })
    end

    return choices
end
