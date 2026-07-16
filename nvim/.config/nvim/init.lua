vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true
vim.opt.clipboard = "unnamedplus"

if vim.env.SSH_TTY then
  local osc52 = require("vim.ui.clipboard.osc52")
  vim.g.clipboard = {
    name = "OSC 52",
    copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
    paste = { ["+"] = osc52.paste("+"), ["*"] = osc52.paste("*") },
  }
end
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.signcolumn = "yes"

local map = vim.keymap.set

-- Press Esc to also clear leftover search highlighting.
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Leader shortcuts for save / quit.
map("n", "<leader>w", "<cmd>write<CR>", { desc = "[W]rite (save) file" })
map("n", "<leader>q", "<cmd>quit<CR>", { desc = "[Q]uit window" })

-- Jump between split windows with Ctrl + hjkl.
map("n", "<C-h>", "<C-w>h", { desc = "Focus split left" })
map("n", "<C-j>", "<C-w>j", { desc = "Focus split below" })
map("n", "<C-k>", "<C-w>k", { desc = "Focus split above" })
map("n", "<C-l>", "<C-w>l", { desc = "Focus split right" })

-- In Visual mode, keep the selection from indenting so you can repeat < / >.
map("v", "<", "<gv", { desc = "Indent left, keep selection" })
map("v", ">", ">gv", { desc = "Indent right, keep selection" })

if vim.fn.has("mac") == 1 then
  map("n", "<leader>fr", ":!open -R %<CR>", { desc = "Reveal in Finder" })
end

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({ 
  {
    "rose-pine/neovim",
    name = "rose-pine",   -- repo is "neovim", too generic — rename the folder
    priority = 1000,
    config = function()
      require("rose-pine").setup({
        variant = "moon",                  -- match your WezTerm rose-pine-moon
        styles = { transparency = true },  -- keep your terminal background showing through
      })
      vim.cmd.colorscheme("rose-pine-moon")
    end,
  },
  {
    "karb94/neoscroll.nvim",
    config = function()
      require("neoscroll").setup({
        easing = "sine",
        duration_multiplier = 1.0
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").install({
        "lua", "vim", "vimdoc", "bash", "json", "yaml", "markdown", "markdown_inline",
        "javascript", "typescript", "tsx", "html", "css", "go",
      })

      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          file_ignore_patterns = { "node_modules", "%.git/" },
          preview = {
            treesitter = false,
          },
        },
        pickers = {
          buffers = {
            mappings = {
              n = { ["dd"] = require("telescope.actions").delete_buffer },
              i = { ["<C-d>"] = require("telescope.actions").delete_buffer },
            },
          },
        },
      })
      pcall(telescope.load_extension, "fzf")

      local builtin = require("telescope.builtin")
      local map = vim.keymap.set
      map("n", "<leader>ff", builtin.find_files, { desc = "[F]ind [F]iles" })
      map("n", "<leader>fg", builtin.live_grep,  { desc = "[F]ind by [G]rep (project text search)" })
      map("n", "<leader>fb", builtin.buffers,    { desc = "[F]ind open [B]uffers" })
      map("n", "<leader>fh", builtin.help_tags,  { desc = "[F]ind [H]elp" })
      map("n", "<leader>fr", builtin.oldfiles,   { desc = "[F]ind [R]ecent files" })
      map("n", "<leader>fa", function()
        builtin.find_files({ hidden = true, no_ignore = true })
      end, { desc = "[F]ind [A]ll files (incl. hidden + gitignored)" })
    end,
  },
  {
    "mason-org/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim"
    },
    config = function()
      vim.lsp.config("lua_ls", {
        settings = { Lua = { diagnostics = { globals = { "vim" } } } },
      })

      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "gopls", "ts_ls" },
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(event)
          local opts = { buffer = event.buf }
          local m = vim.keymap.set
          m("n", "gd",          vim.lsp.buf.definition,         opts)   -- Go to definition
          m("n", "gr",          vim.lsp.buf.references,         opts)   -- List references
          m("n", "K",           vim.lsp.buf.hover,              opts)   -- hover docs (Shift + K)
          m("n", "<leader>rn",  vim.lsp.buf.rename,             opts)   -- rename symbol
          m("n", "<leader>ca",  vim.lsp.buf.code_action,        opts)   -- code actions
          m("n", "]d",          function() vim.diagnostic.jump({ count = 1, float = true }) end, opts)  -- next diagnostic
          m("n", "[d",          function() vim.diagnostic.jump({ count = -1, float = true }) end, opts) -- prev diagnostic
        end,
      })
    end,
  },
  {
    "saghen/blink.cmp",
    version = "1.*",
    dependencies = { "rafamadriz/friendly-snippets" },
    opts = {
      keymap = { preset = "default" },
      appearance = { nerd_font_variant = "mono" },
      completion = { documentation = { auto_show = true } },
      sources = { default = { "lsp", "path", "snippets", "buffer" } },
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    ft = { "markdown" },
    opts = {},
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = { markdown = { "prettier" } },
    },
    keys = {
      { "<leader>cf", function() require("conform").format({ lsp_format = "fallback" }) end, desc = "[C]ode [F]ormat" },
    },
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      spec = {
        { "<leader>f", group = "Find" },
        { "<leader>c", group = "Code" },
      },
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    event = "VeryLazy",
    opts = {
      current_line_blame = true,
      current_line_blame_opts = {
        delay = 0,
        virt_text_pos = "right_align",
      },
      current_line_blame_formatter = "<author>, <author_time:%b %-d, %Y>",
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local function map(l, r, desc)
          vim.keymap.set("n", l, r, { buffer = bufnr, desc = desc })
        end
        map("<leader>hp", gs.preview_hunk,              "[H]unk [P]review (diff popup)")
        map("<leader>hi", gs.preview_hunk_inline,       "[H]unk preview [I]nline")
        map("<leader>hd", gs.diffthis,                  "[H]unk [D]iff whole file")
        map("]c", function() gs.nav_hunk("next") end, "Next change")
        map("[c", function() gs.nav_hunk("prev") end, "Prev change")
      end,
    },
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    cmd = "Neotree",
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<CR>", desc = "File [E]xplorer toggle" },
    },
    opts = {
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = false,
        },
      },
    },
  },
  {
    "nvim-flutter/flutter-tools.nvim",
    lazy = false,
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("flutter-tools").setup({})
    end,
  },
})

local function transparent_bg()
  for _, group in ipairs({ "Normal", "NormalNC", "SignColumn", "EndOfBuffer" }) do
    vim.api.nvim_set_hl(0, group, { bg = "none" })
  end
  vim.api.nvim_set_hl(0, "Visual", { bg = "#56526e" })
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#2a273f" })
  vim.api.nvim_set_hl(0, "FloatBorder", { bg = "#2a273f", fg = "#56526e" })
end
transparent_bg()
vim.api.nvim_create_autocmd("ColorScheme", { callback = transparent_bg })
