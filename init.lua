vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.timeoutlen = 300

if vim.fn.has("nvim-0.9") == 0 then
    vim.api.nvim_err_writeln("Need Neovim 0.9+ for this config")
    vim.cmd([[quit]])
end

-- Check for required executables efficiently
local required_cmds = { "git", "rg" }
local fd_cmds = { "fd", "fdfind" }
local fd_found = false

for _, cmd in ipairs(required_cmds) do
    if vim.fn.executable(cmd) == 0 then
        vim.api.nvim_err_writeln(("Required command `%s` is not installed"):format(cmd))
        vim.cmd([[quit]])
    end
end

for _, c in ipairs(fd_cmds) do
    if vim.fn.executable(c) == 1 then
        fd_found = true
        break
    end
end
if not fd_found then
    vim.api.nvim_err_writeln("Required command `fd` or `fdfind` is not installed")
    vim.cmd([[quit]])
end

vim.opt.termguicolors = true

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Load configurations in correct order
-- options and mappings must load before plugins (leader key, etc.)
for _, mod in ipairs({ "options", "mappings", "autocmds", "plugins" }) do
    local ok, err = pcall(require, mod)
    if not ok then
        vim.api.nvim_err_writeln("Failed to load " .. mod .. "\n\n" .. tostring(err))
    end
end

-- Load custom configurations if they exist
local ok, custom = pcall(require, "custom")
if ok and type(custom) == "table" and type(custom.configs) == "function" then
    custom.configs()
end

local strudel = require("strudel")

vim.keymap.set("n", "<leader>sl", strudel.launch, { desc = "Launch Strudel" })
vim.keymap.set("n", "<leader>sq", strudel.quit, { desc = "Quit Strudel" })
vim.keymap.set("n", "<leader>st", strudel.toggle, { desc = "Strudel Toggle Play/Stop" })
vim.keymap.set("n", "<leader>su", strudel.update, { desc = "Strudel Update" })
vim.keymap.set("n", "<leader>ss", strudel.stop, { desc = "Strudel Stop Playback" })
vim.keymap.set("n", "<leader>sb", strudel.set_buffer, { desc = "Strudel set current buffer" })
vim.keymap.set("n", "<leader>sx", strudel.execute, { desc = "Strudel set current buffer and update" })
