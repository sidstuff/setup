return {
  {
    "mason-org/mason-lspconfig.nvim",
    lazy = false,
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "neovim/nvim-lspconfig",
    },
    opts = {},
  },

  {
    "dstein64/nvim-scrollview",
    lazy = false,
    event = { "BufReadPost", "BufAdd", "BufNewFile" },
    config = function()
      require "configs.scrollview"
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = { theme  = 'palenight' },
    },
  },
}
