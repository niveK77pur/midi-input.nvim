local job = require('nvim-midi-input.job')
local options = require('nvim-midi-input.options')
local update = require('nvim-midi-input.update')

---@private
---Check if the given device name is among the list of available devices.
---See `lilypond-midi-input --list-devices`.
---@param device string The MIDI input device name
---@return boolean # Whether or not the device exists
local function deviceExists(device)
    for _, device_name in ipairs(options.get_devices()) do
        if vim.trim(device) == vim.trim(device_name) then
            return true
        end
    end
    return false
end

vim.api.nvim_create_user_command('MidiInputStart', function(opts)
    if vim.fn.empty(opts.args) ~= 1 and deviceExists(opts.args) then
        job:start(opts.args)
    elseif options.get().device and deviceExists(options.get().device) then
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

vim.api.nvim_create_user_command('MidiInputUpdateOptions', update.updateMidiOptions, {
    desc = 'Update MIDI options',
})
