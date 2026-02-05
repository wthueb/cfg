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
    local workspaces = workspace_switcher.choices.get_workspace_elements({})

    -- put ~ workspace at the top
    for i, choice in ipairs(workspaces) do
        if choice.id == "~" then
            table.remove(workspaces, i)
            table.insert(workspaces, 1, choice)
            break
        end
    end

    local choices = table.shallow_copy(workspaces)

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

    ---@param choice Choice
    local function add_choice(choice)
        local exists = check_exists(choice)

        if not exists then
            table.insert(choices, choice)
        end
    end

    ---@param path string
    local function add_raw(path)
        local label = path:gsub(wezterm.home_dir, "~")
        add_choice({ label = label, id = path })
    end

    ---@param path string
    local function add_dir(path)
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

            add_choice({ label = label, id = line })
        end
    end

    ---@param path string
    local function add_git_dir(path)
        local _, stdout, stderr = wezterm.run_child_process({
            "fd",
            "-t",
            "d",
            "-Ha",
            [[\.git$]],
            path,
            "-x",
            "dirname",
        })

        print(stderr)

        for line in stdout:gmatch("[^\n]*\n?") do
            line = line:match("^%s*(.-)%s*$") -- trim whitepsace

            local dir = string.basename(line)

            add_choice({ label = dir, id = line })
        end
    end

    local file = io.open(wezterm.config_dir .. "/dirs.txt", "r")

    if file then
        for line in file:lines() do
            line = line:gsub("~", wezterm.home_dir)

            local method, path = line:match("^(%w+) (.-)$")

            if method == nil or path == nil or method == "raw" then
                add_raw(line)
            elseif method == "git" then
                add_git_dir(path)
            elseif method == "dir" then
                add_dir(path)
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
        table.insert(choices, 1, { label = "~", id = wezterm.home_dir })
    end

    return choices
end
