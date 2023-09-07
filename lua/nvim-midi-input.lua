local job = require('nvim-midi-input.job')
local update = require('nvim-midi-input.update')

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--                                    Options
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

local options = {
    device = nil,
    key = 'cM',
    accidentals = 'sharps',
    mode = 'pedal',
    alterations = {},
    global_alterations = {},
}

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--                                 AutoCommands
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

local augroup_midideviceinput =
    vim.api.nvim_create_augroup('midideviceinput', {})

vim.api.nvim_create_autocmd({ 'ExitPre', 'QuitPre' }, {
    group = augroup_midideviceinput,
    pattern = { '*' },
    desc = 'Quit the MIDI Input Listener',
    callback = function()
        job:stop()
    end,
})

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--                                    Plugin
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local M = {}

function M.setup(opts)
    print('Hello MIDI input')
    options = vim.tbl_deep_extend('force', options, opts)
end

return M
-- vim: fdm=marker
