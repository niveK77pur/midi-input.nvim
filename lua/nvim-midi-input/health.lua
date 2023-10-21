local M = {}
local opts = require('nvim-midi-input.options')

function checkExecutable()
    vim.health.report_start('External dependency')
    if vim.fn.executable('lilypond-midi-input') == 1 then
        vim.health.report_ok(
            string.format(
                'External command `lilypond-midi-input` found in %s',
                vim.fn.exepath('lilypond-midi-input')
            )
        )
    else
        vim.health.report_error(
            'External command `lilypond-midi-input` not found'
        )
    end
end

function checkDevice()
    vim.health.report_start('Default MIDI device')
    if opts.get().device then
        vim.health.report_ok('Default MIDI device is set')
    else
        vim.health.report_warn('No default MIDI device specified', {
            'Get device names using the `lilypond-midi-input --list-devices` command',
            'A list of device names is presented by this plugin if no device is specified upon starting the job',
        })
    end
end

function checkOptions()
    vim.health.report_start('Plugin options')
    local options = {
        { 'device', opts.get().device },
        { 'key', opts.get().key },
        { 'accidentals', opts.get().accidentals },
        { 'mode', opts.get().mode },
        { 'alterations', opts.get().alterations },
        { 'global_alterations', opts.get().global_alterations },
        { 'replace_q', opts.get().replace_q },
        { 'replace_in_comment', opts.get().replace_in_comment },
        { 'debug', opts.get().debug },
    }
    local final_warning = false
    for _, option in ipairs(options) do
        key, value = option[1], option[2]
        if value == nil and value ~= false then
            final_warning = true
            vim.health.report_warn(
                string.format([[Option '%s' has not been given a value.]], key)
            )
        else
            vim.health.report_ok(
                string.format([[Option '%s' was set to '%s']], key, value)
            )
        end
    end
    if final_warning then
        vim.health.report_warn('Some options have not been given a value', {
            'Some minor things may not work as expected without default values',
            'Plugin will be unable to fallback to default options if required',
            'Setting the debug option will disable certain functionalities',
        })
    end
end

function M.check()
    checkExecutable()
    checkDevice()
    checkOptions()
end

return M
