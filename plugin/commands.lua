local job = require('nvim-midi-input.job')
local update = require('nvim-midi-input.update')

vim.api.nvim_create_user_command('MidiInputStart', function()
    job:start('out')
end, { desc = 'Start MIDI Input Listener' })

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
