local job = require('nvim-midi-input.job')
local update = require('nvim-midi-input.update')
local options = require('nvim-midi-input.options')

vim.api.nvim_create_user_command('MidiInputStart', function(opts)
    if not vim.fn.empty(opts.args) then
        job:start(opts.args)
    elseif options.get().device then
        job:start(options.get().device)
    else
        options.query_devices(function(device)
            job:start(device)
        end)
    end
end, { nargs = '?', desc = 'Start MIDI Input Listener' })

vim.api.nvim_create_user_command('MidiInputStop', function()
    job:stop()
end, { desc = 'Stop MIDI Input Listener' })

vim.api.nvim_create_user_command(
    'MidiInputUpdateOptions',
    update.updateMidiOptions,
    {
        desc = 'Update MIDI options',
    }
)
