local M = {}
local opts = require('nvim-midi-input.options')

local function checkExecutable()
    vim.health.start('External dependency')
    if vim.fn.executable('lilypond-midi-input') == 1 then
        vim.health.ok(
            string.format('External command `lilypond-midi-input` found in %s', vim.fn.exepath('lilypond-midi-input'))
        )
    else
        vim.health.error('External command `lilypond-midi-input` not found')
    end
end

local function checkDevice()
    vim.health.start('Default MIDI device')
    local device = opts.get().device
    if device then
        vim.health.ok(string.format('Default MIDI device is set to `%s`', device))
    else
        vim.health.warn('No default MIDI device specified', {
            'Get device names using the `lilypond-midi-input --list-devices` command',
            'A list of device names is presented by this plugin if no device is specified upon starting the job',
        })
    end
end

local function checkDebug()
    vim.health.start('Debugging')
    local debug = opts.get().debug
    local debug_values = {
        'input options',
        'key signature',
        'previous chord',
        'replace mode',
    }
    if not debug then
        vim.health.info('Debugging is disabled.')
        return
    end
    for _, debug_value in ipairs(debug_values) do
        if debug == debug_value then
            vim.health.warn(string.format('Debugging is enabled for: %s', debug), {
                'Setting the debug option will disable certain functionalities',
                'Note input will not be working anymore',
                'Instead of performing operations, information will be presented',
            })
            return
        end
    end
    vim.health.error(string.format('Invalid value for debugging: `%s`', debug))
end

local function checkOptions()
    vim.health.start('Plugin options')
    local no_fallback_messages = {
        'No default/fallback value exists',
        'Option cannot be reset if needed; the previously set value will keep being used',
    }
    local options = {
        {
            name = 'key',
            value = opts.get().key,
            warn_msg = { 'Default/Fallback value is `cM`' },
        },
        {
            name = 'accidentals',
            value = opts.get().accidentals,
        },
        {
            name = 'mode',
            value = opts.get().mode,
        },
        {
            name = 'alterations',
            value = opts.get().alterations,
        },
        {
            name = 'global_alterations',
            value = opts.get().global_alterations,
        },
        {
            name = 'replace_q',
            value = opts.get().replace_q,
            warn_msg = { 'Default/Fallback value is `true`' },
        },
        {
            name = 'replace_in_comment',
            value = opts.get().replace_in_comment,
            warn_msg = { 'Default/Fallback value is `false`' },
        },
    }
    print(vim.inspect(options))
    local final_warning = false
    for _, option in ipairs(options) do
        if option.value == nil and option.value ~= false then
            final_warning = true
            vim.health.warn(
                string.format([[Option '%s' has not been given a value.]], option.name),
                option.warn_msg or no_fallback_messages
            )
        else
            vim.health.ok(string.format([[Option '%s' was set to '%s']], option.name, option.value))
        end
    end
    if final_warning then
        vim.health.warn('Some options have not been given a value', {
            'Some minor things may not work as expected without default values',
            'Plugin will be unable to fallback to default options if required',
        })
    end
end

function M.check()
    checkExecutable()
    checkDevice()
    checkDebug()
    checkOptions()
end

return M
