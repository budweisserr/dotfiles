local M, specs, loaded = {}, {}, {}

local function to_pack_spec(spec)
    return { src = spec[1]:match("^https?://") and spec[1] or ("https://github.com/" .. spec[1]), name = spec.name, version = spec.version }
end

local function load_plugin(spec, defer)
    if loaded[spec.name] then return end
    loaded[spec.name] = true
    for _, dep in ipairs(spec.dependencies or {}) do load_plugin(specs[dep], defer) end
    if spec.install == false then
        vim.pack.add({ to_pack_spec(spec) }, { confirm = false })
    else
        vim.cmd.packadd({ spec.name, bang = defer })
    end
    if spec.config then spec.config() end
end

local function stub_events(queue)
    local get_event_chain = function(event, buf, data)
        local chain = {}
        local event_triggers = { FileType = "BufReadPost", BufReadPost = "BufReadPre" }
        while event do
            local groups = {}
            if event ~= "FileType" then
                for _, autocmd in ipairs(vim.api.nvim_get_autocmds({ event = event })) do
                    if autocmd.group_name then groups[autocmd.group_name] = true end
                end
            end
            table.insert(chain, 1, { event = event, buffer = buf, exclude = groups, data = data })
            data = nil
            event = event_triggers[event]
        end
        return chain
    end

    for event, event_specs in pairs(queue) do
        local event_name, pattern = event:match("^(%S+)%s+(.+)$")
        vim.api.nvim_create_autocmd(event_name or event, {
            pattern = pattern,
            once = true,
            desc = "Pack lazy " .. event,
            callback = function(ev)
                local chain = (event_name or event) ~= "User" and get_event_chain(ev.event, ev.buf, ev.data) or {}
                for _, spec in ipairs(event_specs) do load_plugin(spec) end
                for _, opts in ipairs(chain) do
                    if next(opts.exclude) == nil then
                        vim.api.nvim_exec_autocmds(opts.event, { buffer = opts.buffer, modeline = false, data = opts.data })
                    else
                        local done = {}
                        for _, autocmd in ipairs(vim.api.nvim_get_autocmds({ event = opts.event })) do
                            local id = autocmd.event .. ":" .. (autocmd.group or "")
                            if autocmd.group and not done[id] and not opts.exclude[autocmd.group_name] then
                                done[id] = true
                                vim.api.nvim_exec_autocmds(opts.event, { buffer = opts.buffer, group = autocmd.group_name, modeline = false, data = opts.data })
                            end
                        end
                    end
                end
            end,
        })
    end
end

local function setup_lazy(spec, load_queue, event_queue)
    if spec.lazy == false then
        if spec.keys then for _, k in ipairs(spec.keys) do vim.keymap.set(unpack(k)) end end
        return table.insert(load_queue, spec)
    end
    if spec.event then
        for _, event in ipairs(spec.event) do
            if not event_queue[event] then event_queue[event] = {} end
            table.insert(event_queue[event], spec)
        end
    end
    if spec.keys then
        for _, mapping in ipairs(spec.keys) do
            vim.keymap.set(mapping[1], mapping[2], function()
                for _, k in ipairs(spec.keys) do if k[3] then vim.keymap.set(unpack(k)) else vim.keymap.del(k[1], k[2]) end end
                load_plugin(spec)
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(mapping[2], true, true, true), "i", false)
            end)
        end
    end
    if spec.cmd then
        for _, cmd in ipairs(spec.cmd) do
            vim.api.nvim_create_user_command(cmd, function(ev)
                for _, c in ipairs(spec.cmd) do pcall(vim.api.nvim_del_user_command, c) end
                load_plugin(spec)
                local command = { cmd = cmd, bang = ev.bang, mods = ev.smods, args = ev.fargs }
                if ev.range == 1 then
                    command.range = { ev.line1 }
                elseif ev.range == 2 then
                    command.range = { ev.line1, ev.line2 }
                elseif ev.count >= 0 then
                    command.count = ev.count
                end
                vim.cmd(command)
            end, {
                bang = true,
                nargs = "*",
                range = true,
                complete = function(_, line)
                    for _, c in ipairs(spec.cmd) do pcall(vim.api.nvim_del_user_command, c) end
                    load_plugin(spec)
                    return vim.fn.getcompletion(line, "cmdline")
                end,
            })
        end
    end
end

function M.setup()
    local installed, to_install, event_queue, load_queue, build_queue = {}, {}, {}, {}, {}

    for name in vim.fs.dir(vim.fn.stdpath("data") .. "/site/pack/core/opt/") do installed[name] = true end
    for name, type in vim.fs.dir(vim.fn.stdpath("config") .. "/lua/plugins") do
        if type == "file" and name:match("%.lua$") then
            for _, spec in ipairs(require("plugins." .. name:gsub("%.lua$", ""))) do
                spec.name = spec.name or spec[1]:match("[^/]+$")
                specs[spec.name] = spec
                if spec.install ~= false and not installed[spec.name] then
                    table.insert(to_install, to_pack_spec(spec))
                end
                setup_lazy(spec, load_queue, event_queue)
                if spec.init then spec.init() end
            end
        end
    end
    stub_events(event_queue)

    vim.api.nvim_create_autocmd("PackChanged", {
        callback = function(event)
            if event.data.kind ~= "install" and event.data.kind ~= "update" then return end
            local spec = specs[event.data.spec.name]
            if not spec or not spec.build then return end
            if build_queue then table.insert(build_queue, spec) else spec.build() end
        end,
    })

    if #to_install > 0 then vim.pack.add(to_install, { load = false, confirm = false }) end
    for _, spec in ipairs(build_queue) do spec.build() end
    for _, spec in ipairs(load_queue) do load_plugin(spec, true) end
    build_queue = nil
end

function M.load(names) for _, name in ipairs(names) do load_plugin(specs[name]) end end

return M