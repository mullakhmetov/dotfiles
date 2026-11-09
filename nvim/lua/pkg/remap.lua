vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- reload vimrc
vim.keymap.set("n", "<leader>sv", function()
    dofile(vim.fn.stdpath("config") .. "/init.lua")
end)

-- move highlighted with up & down with J & K
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- takes line below and appends it to current line with space
vim.keymap.set("n", "J", "mzJ`z")

-- keeps cursor in the middle while half-page jumping
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- keeps cursor in the middle while searching
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- pastes over highlighed word preserving clipboard
vim.keymap.set("x", "<leader>p", [["_dP]])

-- yank (replace prev) to vim & system clipboard
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
-- don't know what happens here
vim.keymap.set("v", "<leader>Y", [["+Y]])

-- delete without storing in clipboard
vim.keymap.set({"n", "v"}, "<leader>d", [["_d]])

-- C-c as Escape
vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "Q", "<nop>")

-- quickfix navigation
vim.keymap.set("n", "<C-j>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-k>", "<cmd>cprev<CR>zz")

-- locationlist navigation
vim.keymap.set("n", "<leader>j", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lprev<CR>zz")

-- switch between buffers
vim.keymap.set("n", "<leader>[", "<cmd>bprev<CR>")
vim.keymap.set("n", "<leader>]", "<cmd>bnext<CR>")
