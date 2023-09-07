local uv = vim.loop

local J = {
    handle = nil,
    pid = nil,
    stdin = nil,
    stdout = nil,
    stderr = nil,
    callbacks = require('nvim-midi-input.callbacks'),
}

function J:clear()
    self.handle = nil
    self.pid = nil
    self.stdin = nil
    self.stdout = nil
    self.stderr = nil
end

function J:write(s)
    -- without the newline, Rust won't take the input
    local result = uv.write(self.stdin, string.format('%s\n', vim.trim(s)))
    print('>> Write:', vim.inspect(result))
end

function J:start(device)
    if not device then
        vim.api.nvim_err_writeln('No MIDI device was specified. Aborting.')
        return
    end
    self.stdin = uv.new_pipe()
    self.stdout = uv.new_pipe()
    self.stderr = uv.new_pipe()
    self.handle, self.pid = uv.spawn('lilypond-midi-input', {
        args = { device },
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

    print(
        string.format(
            'Started MIDI Input Listener (%s) (%s).',
            self.handle,
            self.pid
        )
    )
end

function J:stop()
    if self.handle then
        local result = uv.process_kill(self.handle, 1)
        print('MIDI CLOSED:', result)
        self:clear()
    end
end

return J
