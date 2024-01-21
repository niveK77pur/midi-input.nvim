local uv = vim.loop
local options = require('nvim-midi-input.options')

local J = {
    handle = nil,
    pid = nil,
    stdin = nil,
    stdout = nil,
    stderr = nil,
    callbacks = require('nvim-midi-input.callbacks'),
}

---Check if another job is already running
---@param show_message boolean? Whether or not to display message in case the job is not running. Default: `true`
---@return boolean
---@nodiscard
function J:is_running(show_message)
    local show_message = show_message or true
    local running = (self.pid and self.handle) ~= nil
    if not running and show_message then
        vim.notify(
            'MIDI input is not running.',
            vim.log.levels.ERROR,
            require('nvim-midi-input').notify_table
        )
    end
    return running
end

---Clear the job variables after it was stopped
function J:clear()
    self.handle = nil
    self.pid = nil
    self.stdin = nil
    self.stdout = nil
    self.stderr = nil
end

---Write data into the job's stream/stdin
---@param s string Data to be sent
function J:write(s)
    -- without the newline, Rust won't take the input
    uv.write(self.stdin, string.format('%s\n', vim.trim(s)))
end

---Start a new job (if not already running)
---@param device string The MIDI input device's name
function J:start(device)
    if self:is_running(false) then
        vim.notify(
            'MIDI input is already running.',
            vim.log.levels.WARN,
            require('nvim-midi-input').notify_table
        )
        return
    end
    if not device then
        vim.notify(
            'No MIDI device was specified. Aborting.',
            vim.log.levels.ERROR,
            require('nvim-midi-input').notify_table
        )
        return
    end

    self.stdin = uv.new_pipe()
    self.stdout = uv.new_pipe()
    self.stderr = uv.new_pipe()

    local args = { device }
    if options.get().key then
        table.insert(args, '--key')
        table.insert(args, options.get().key)
    end
    if options.get().accidentals then
        table.insert(args, '--accidentals')
        table.insert(args, options.get().accidentals)
    end
    if options.get().mode then
        table.insert(args, '--mode')
        table.insert(args, options.get().mode)
    end
    if options.get().alterations then
        table.insert(args, '--alterations')
        table.insert(args, options.parse_alterations(options.get().alterations))
    end
    if options.get().global_alterations then
        table.insert(args, '--global-alterations')
        table.insert(
            args,
            options.parse_alterations(options.get().global_alterations)
        )
    end

    self.handle, self.pid = uv.spawn('lilypond-midi-input', {
        args = args,
        stdio = { self.stdin, self.stdout, self.stderr },
    }, self.callbacks.exit)

    uv.read_start(self.stdout, function(err, data)
        assert(not err, err)
        if data then
            vim.schedule(function()
                -- when input is arriving very fast, it can happen that
                -- multiple lines in stdin will be merged into a single `data`
                for _, line in ipairs(vim.fn.split(data, [[\n]])) do
                    self.callbacks.stdout(line)
                end
            end)
        end
    end)

    uv.read_start(self.stderr, function(err, data)
        assert(not err, err)
        if data then
            vim.schedule(function()
                self.callbacks.stderr(data)
            end)
        end
    end)

    vim.notify(
        string.format(
            'Started MIDI Input Listener (%s) (%s).',
            self.handle,
            self.pid
        ),
        vim.log.levels.INFO,
        require('nvim-midi-input').notify_table
    )
end

---Stop the currently running job. Silently exit if not running.
function J:stop()
    if self:is_running() then
        uv.process_kill(self.handle, 1)
        self:clear()
    end
end

return J
