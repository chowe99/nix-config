{ inputs, config, pkgs, lib, ... }:
let
pkgSource = if pkgs.system == "aarch64-linux" then inputs.nixpkgs-unstable else inputs.nixpkgs;
pkgSet = import pkgSource {
  system = pkgs.system;
  config = {
    allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "copilot.vim" ];
  };
};
in
{
  programs.nixvim = {
    enable = true;

# Core Settings
    extraPackages = with pkgSet; [
# LSP Servers (for mason fallback or manual use)
      nil
      lua-language-server
      typescript-language-server
      pyright
      tailwindcss-language-server
      yaml-language-server
      bash-language-server
      emmet-ls
      eslint
# Linters and Formatters for none-ls
      eslint_d
      pylint
      stylelint
      shellcheck
      prettierd
      black
      shfmt
# Utilities
      ripgrep
      fd
      nodePackages.graphql-language-service-cli
      nodejs # For DAP and Copilot
      libnotify # For notify plugin
# (pkgs.vimUtils.buildVimPlugin {
#   name = "mini-hipatterns-nvim";
#   src = pkgs.fetchFromGitHub {
#     owner = "echasnovski";
#     repo = "mini.hipatterns";
#     rev = "main";
#     sha256 = "sha256-WrFM7XdzruKWVPuhZiT0nvwYaKDTFsyqGMDEJWdbE74="; # Replace with the correct hash
#   };
# })
        ];
    clipboard = {
      register = "unnamedplus";
      providers.wl-copy.enable = true;
    };
    globals = {
      mapleader = " ";
      python3_host_prog = "~/.pyenv/shims/python";
    };
    opts = {
      undofile = true;
      undodir = "${config.home.homeDirectory}/.local/share/nvim/undo";
      encoding = "utf-8";
      fileencoding = "utf-8";
      number = true;
      relativenumber = true;
      title = true;
      autoindent = true;
      smartindent = true;
      hlsearch = true;
      backup = false;
      showcmd = true;
      cmdheight = 0;
      laststatus = 0;
      expandtab = true;
      scrolloff = 10;
      inccommand = "split";
      ignorecase = true;
      smarttab = true;
      breakindent = true;
      shiftwidth = 2;
      tabstop = 2;
      wrap = false;
      backspace = [ "start" "eol" "indent" ];
      path = [ "**" ];
      wildignore = [ "*/node_modules/*" ];
      splitbelow = true;
      splitright = true;
      splitkeep = "cursor";
      mouse = "";
      formatoptions = "r";
      foldmethod = "expr";
      foldexpr = "nvim_treesitter#foldexpr()";
      foldenable = false;
      foldlevel = 0;
      foldlevelstart = 0;
    };

# Plugins
    plugins = {
      render-markdown.enable = true;
      visual-multi.enable = true;
      spectre.enable = true;
      harpoon.enable = true;
      comment = {
        enable = true;
        settings = {
          toggler = { line = "<leader>/"; block = "<leader>cb"; };
          opleader = { line = "<leader>c"; block = "<leader>b"; };
        };
      };
      lsp = {
        enable = true;
        servers = {
          lua_ls = {
            enable = true;
            settings = {
              Lua = {
                runtime = { version = "LuaJIT"; };
                diagnostics = { globals = [ "vim" "nvim" ]; };
                workspace = {
                  library = { __raw = "vim.api.nvim_get_runtime_file('', true)"; };
                  maxPreload = 1000;
                  preloadFileSize = 1000;
                };
                telemetry = { enable = false; };
              };
            };
          };
          ts_ls = {
            enable = true;
            filetypes = [ "javascript" "javascriptreact" "typescript" "typescriptreact" ];
            extraOptions = {
              onAttach = ''
                function(client, bufnr)
                client.server_capabilities.documentFormattingProvider = false
                end
                '';
            };
          };
          pyright.enable = true;
          tailwindcss.enable = true;
          html.enable = true;
          cssls.enable = true;
          jsonls.enable = true;
          yamlls.enable = true;
          dockerls.enable = true;
          graphql = { enable = true; package = null; };
          bashls.enable = true;
          emmet_ls = {
            enable = true;
            filetypes = [ "html" "css" "javascript" "javascriptreact" "typescriptreact" ];
          };
          eslint.enable = true;
        };
      };
      none-ls = {
        enable = true;
        settings = {
          debounce = 250;
          diagnostics_format = "[#{c}] #{m} (#{s})";
          on_attach = ''
            function(client, bufnr)
            vim.api.nvim_buf_set_option(bufnr, "formatexpr", "v:lua.vim.lsp.formatexpr()")
            end
            '';
# sources = [
#   ''require("null-ls").builtins.formatting.black.with({ extra_args = { "--line-length=88" } })''
#     ''require("null-ls").builtins.formatting.prettierd.with({ filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "css", "scss", "json", "yaml" } })''
#     ''require("null-ls").builtins.formatting.shfmt.with({ extra_args = { "-i", "2" } })''
#     ''require("null-ls").builtins.diagnostics.eslint_d.with({ filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" } })''
#     ''require("null-ls").builtins.diagnostics.pylint.with({ filetypes = { "python" } })''
#     ''require("null-ls").builtins.diagnostics.stylelint.with({ filetypes = { "css", "scss" } })''
#     ''require("null-ls").builtins.diagnostics.shellcheck.with({ filetypes = { "sh" } })''
# ];
        };
      };
# rainbow_csv = {
#   enable = true;
#   settings = {
#     delimiters = [ ", " ";" "|" " " ];
#     highlight = true;
#     auto_align = true;
#     auto_preview = true;
#   };
# };
      notify = {
        enable = true;
        settings = { background_colour = "#000000"; };
      };
      web-devicons.enable = true;
      treesitter = {
        enable = true;
        settings = {
          highlight = { enable = true; };
          ensure_installed = [
            "javascript" "typescript" "tsx" "python" "html" "css" "json" "yaml"
              "gitignore" "graphql" "http" "scss" "sql" "vim" "lua"
          ];
        };
      };
      telescope = {
        enable = true;
        extensions = {
          file-browser.enable = true;
          fzy-native.enable = true;
          ui-select.enable = true;
          frecency = {
            enable = true;
            settings = { db_safe_mode = false; };
          };
        };

      };
      dap = {
        enable = true;
      };
      bufferline.enable = true;
      toggleterm = {
        enable = true;
        settings = {
          size = 20;
          open_mapping = "[[<c-\\>]]";
          shade_factor = 2;
          direction = "float";
          float_opts = { border = "curved"; };
        };
      };
      noice = {
        enable = true;
        settings.routes = [
        { filter = { event = "msg_show"; kind = "search_count"; }; opts = { skip = true; }; }
        ];
      };
      transparent.enable = true;
      lualine.enable = true;
      cmp = {
        enable = true;
        settings = {
          sources = [
          { name = "nvim_lsp"; }
          { name = "buffer"; }
          { name = "path"; }
          { name = "luasnip"; }
          ];
          mapping = {
            __raw = ''
            {
              ["<Up>"] = cmp.mapping.select_prev_item(),
              ["<Down>"] = cmp.mapping.select_next_item(),
              ["<CR>"] = cmp.mapping.confirm({ select = true }),
              ["<Tab>"] = cmp.mapping.select_next_item(),
              ["<S-Tab>"] = cmp.mapping.select_prev_item(),
            }
            '';
          };
        };
      };
      luasnip.enable = true;
      indent-blankline.enable = true;
      gitsigns.enable = true;
      alpha = {
        enable = true;
        theme = "dashboard";
      };
      nvim-autopairs.enable = true;
      nvim-surround.enable = true;
      neo-tree = {
        enable = true;
        enableDiagnostics = true;
        enableGitStatus = true;
        enableModifiedMarkers = true;
        enableRefreshOnWrite = true;
        closeIfLastWindow = true;
        popupBorderStyle = "rounded";
        buffers = {
          bindToCwd = false;
          followCurrentFile = { enabled = true; };
        };
        window = {
          position = "right";
          width = 25;
          autoExpandWidth = false;
          mappings = { "<space>" = "none"; };
        };
      };
      avante = {
        enable = true;
        settings = {
          provider = "copilot";
          behaviour = { use_absolute_path = true; };
# providers = {
#   gemini = {
#     model = "gemini-2.5-flash-preview-04-17";
#     temperature = 0;
#     timeout = 30000;
#   };
# };
          debug = true; # For troubleshooting
        };
      };
      which-key = {
        enable = true;
      };
      lz-n.enable = true;
    };

# Extra Plugins
    extraPlugins = with pkgs.vimPlugins; [
      mini-icons nui-nvim plenary-nvim nvim-dap undotree nvim-spectre
        vim-visual-multi nvim-ts-autotag hologram-nvim
        copilot-vim mason-nvim mason-lspconfig-nvim nvim-navic
        nvim-ts-context-commentstring bigfile-nvim friendly-snippets
        tokyonight-nvim dressing-nvim
        none-ls-nvim
        (pkgs.vimUtils.buildVimPlugin {
         name = "vscode-es7-javascript-react-snippets";
         src = pkgs.fetchFromGitHub {
         owner = "dsznajder";
         repo = "vscode-es7-javascript-react-snippets";
         rev = "master";
         sha256 = "sha256-VLRkj1rd53W3b9Ep2FAd+vs7B8CzKH2O3EE1Lw6vnTs=";
         };
         })
    (pkgs.vimUtils.buildVimPlugin {
     name = "tailwindcss-colorizer-cmp-nvim";
     src = pkgs.fetchFromGitHub {
     owner = "roobert";
     repo = "tailwindcss-colorizer-cmp.nvim";
     rev = "main";
     sha256 = "sha256-PIkfJzLt001TojAnE/rdRhgVEwSvCvUJm/vNPLSWjpY=";
     };
     })
    ];

# Keymaps
    keymaps = [
    { mode = "n"; key = "<leader>sf"; action = "<cmd>Telescope find_files<CR>"; }
    { mode = "n"; key = "<leader>sg"; action = "<cmd>Telescope live_grep<CR>"; }
    { mode = "n"; key = "<C-t>"; action = "<cmd>Neotree toggle<CR>"; }
    { mode = "n"; key = "x"; action = "\"_x"; }
    { mode = "v"; key = "d"; action = "\"_d"; }
    { mode = "n"; key = "<leader>ed"; action = "<cmd>Telescope diagnostics<CR>"; }
    { mode = "n"; key = "<leader>eh"; action = "<cmd>Noice all<CR>"; }
    { mode = "n"; key = "<leader>ee"; action = "<cmd>lua vim.diagnostic.open_float()<CR>"; }
    { mode = "n"; key = "<leader>u"; action = "<cmd>UndotreeToggle<CR><cmd>UndotreeFocus<CR>"; }

# ToggleTerm mappings
    { mode = "n"; key = "<leader>t1"; action = "<cmd>ToggleTerm 1<CR>"; desc = "Terminal 1"; }
    { mode = "n"; key = "<leader>t2"; action = "<cmd>ToggleTerm 2<CR>"; desc = "Terminal 2"; }
    { mode = "n"; key = "<leader>t3"; action = "<cmd>ToggleTerm 3<CR>"; desc = "Terminal 3"; }
    { mode = "n"; key = "<leader>t4"; action = "<cmd>ToggleTerm 4<CR>"; desc = "Terminal 4"; }
    { mode = "n"; key = "<leader>t5"; action = "<cmd>ToggleTerm 5<CR>"; desc = "Terminal 5"; }
    { mode = "n"; key = "<leader>t6"; action = "<cmd>ToggleTerm 6<CR>"; desc = "Terminal 6"; }
    { mode = "n"; key = "<leader>t7"; action = "<cmd>ToggleTerm 7<CR>"; desc = "Terminal 7"; }
    { mode = "n"; key = "<leader>t8"; action = "<cmd>ToggleTerm 8<CR>"; desc = "Terminal 8"; }
    { mode = "n"; key = "<leader>t9"; action = "<cmd>ToggleTerm 9<CR>"; desc = "Terminal 9"; }
    { mode = "n"; key = "<leader>t0"; action = "<cmd>ToggleTerm 10<CR>"; desc = "Terminal 10"; }

# vim-visual-multi mappings
    { mode = "n"; key = "<leader><C-a>"; action = "<Plug>(VM-Select-All)"; desc = "Select All"; }
    { mode = "n"; key = "<C-n>"; action = "<Plug>(VM-Find-Under)"; desc = "Find Under"; }
    { mode = "n"; key = "<C-M-Down>"; action = "<Plug>(VM-Add-Cursor-Down)"; desc = "Add Cursor Down"; }
    { mode = "n"; key = "<C-M-Up>"; action = "<Plug>(VM-Add-Cursor-Up)"; desc = "Add Cursor Up"; }

    ];

# Extra Lua Configuration
    extraConfigLua = ''
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
      require("nvim-autopairs").setup()

      -- Mason Setup
      require("mason").setup()
      require("mason-lspconfig").setup({
          ensure_installed = {
          "ts_ls", "pyright", "lua_ls", "tailwindcss", "html", "cssls",
          "jsonls", "yamlls", "dockerls", "graphql", "bashls", "emmet_ls", "eslint"
          },
          automatic_installation = true,
          })

    -- DAP Configuration
      local dap = require('dap')
      dap.adapters.node2 = {
        type = 'executable',
        command = '${pkgSet.nodejs}/bin/node',
        args = { vim.fn.expand("${pkgSet.vimPlugins.nvim-dap}/out/src/nodeDebug.js") },
      }
    dap.configurations.javascript = {
      {
        name = 'Launch',
        type = 'node2',
        request = 'launch',
        program = "$\{file}",
        cwd = vim.fn.getcwd(),
        sourceMaps = true,
        protocol = 'inspector',
        on_error = function(err)
          vim.notify("DAP Node2 adapter failed: " .. tostring(err), vim.log.levels.ERROR)
          end,
      },
    }

    -- Format on save
      vim.api.nvim_create_autocmd("BufWritePre", {
          callback = function()
          vim.lsp.buf.format()
          end,
          })

    -- Copilot setup
      vim.g.copilot_no_tab_map = true
      vim.api.nvim_set_keymap("i", "<Right>", 'copilot#Accept("<CR>")', { expr = true, silent = true })
      vim.api.nvim_set_keymap("i", "<Left>", 'copilot#Next()', { expr = true, silent = true })


      -- VSCode Snippets setup
      require('luasnip.loaders.from_vscode').lazy_load({ paths = { "./vscode-es7-javascript-react-snippets" } })

      -- Tailwind CSS Colorizer setup
      require("tailwindcss-colorizer-cmp").setup()
      '';
  };
}
