return {
    "lukas-reineke/indent-blankline.nvim",
    config = function()
        require("ibl").setup({
            enabled = false,
            indent = { char = "·" },
            whitespace = {
                remove_blankline_trail = false,
            },
            scope = { enabled = false },
        })

        vim.api.nvim_create_autocmd("FileType", {
            desc = "Enable indent guides",
            pattern = "yaml",
            group = vim.api.nvim_create_augroup("ibl", {clear = true}),
            callback = function()
                require("ibl").setup_buffer(0, {enabled = true})
            end,
        })
    end
}
