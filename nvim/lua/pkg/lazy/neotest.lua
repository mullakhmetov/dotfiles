return {
  'nvim-neotest/neotest', tag = 'v5.8.0',
  dependencies = {
      'nvim-neotest/nvim-nio',
      'nvim-lua/plenary.nvim',
      'antoinemadec/FixCursorHold.nvim',
      'nvim-treesitter/nvim-treesitter',
      'nvim-neotest/neotest-go',
  },
  config = function()
      require('neotest').setup({
        adapters = {
          require('neotest-go')({
            args = { '-coverprofile=coverage.out' },
          })
        },
      })
  end,
}
