{ inputs, config, pkgs, lib, ... }:
let
  # Use unstable for aarch64-linux, stable for x86_64-linux
  pkgSource = if pkgs.system == "aarch64-linux" then inputs.nixpkgs-unstable else inputs.nixpkgs;
  pkgSet = import pkgSource {
    system = pkgs.system;
    config = {
      allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "copilot.vim"
      ];
    };
  };
in
{
  programs.nixvim = {
    enable = true;
    extraPackages = with pkgSet; [
      eslint_d
      pylint
      stylelint
      shellcheck
      prettierd
      black
      shfmt
      ripgrep
      fd
      gnumake
      gcc
      nodejs
      yarn
      cargo
      perl
      openssl
      libnotify
      nodePackages.graphql-language-service-cli  
      go
      php
      luarocks
      openjdk
      julia
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
      undodir = "~/.local/share/nvim/undo";
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
    plugins = {
      harpoon = {
        enable = true;
      };
      comment = {
        enable = true;
        settings = {
          toggler = {
            line = "<leader>/"; # Replace <gcc>
            block = "<leader>cb"; # Replace <gbc>
          };
          opleader = {
            line = "<leader>c"; # Replace <gc>
            block = "<leader>b"; # Replace <gb>
          };
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
          graphql = {
            enable = true;
            package = null;
          };
          bashls.enable = true;
          emmet_ls = {
            enable = true;
            filetypes = [ "html" "css" "javascript" "javascriptreact" "typescriptreact" ];
          };
          eslint.enable = true;
          # Removed clangd due to installation issues
        };
      };
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
      # telescope.enable = true;
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

      dap.enable = true;
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
          {
            filter = { event = "msg_show"; kind = "search_count"; };
            opts = { skip = true; };
          }
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
        };
      };
      luasnip.enable = true;
      indent-blankline.enable = true;
      gitsigns.enable = true;
      alpha = {
        enable = true;
        theme = "dashboard";
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
      nvim-autopairs.enable = true;
      nvim-surround.enable = true;
      # neo-tree = {
      #   enable = true;
      #   settings = {
      #     close_if_last_window = true;
      #     enableRefreshOnWrite = true;
      #     filesystem = {
      #       hijack_netrw_behavior = "open_current";
      #       window = {
      #         position = "right";
      #         width = 25;
      #         mapping_options = { noremap = true; nowait = true; };
      #       };
      #     };
      #   };
      # };
      neo-tree = {
        enable = true;
        enableDiagnostics = true;
        enableGitStatus = true;
        enableModifiedMarkers = true;
        enableRefreshOnWrite = true;
        closeIfLastWindow = true;
        popupBorderStyle = "rounded"; # Type: null or one of “NC”, “double”, “none”, “rounded”, “shadow”, “single”, “solid” or raw lua code
          buffers = {
            bindToCwd = false;
            followCurrentFile = {
              enabled = true;
            };
          };
        window = {
          position = "right";
          width = 25;
          autoExpandWidth = false;
          mappings = {
            "<space>" = "none";
          };
        };
      };

      avante = {
        enable = true;

        settings = {
          provider = "copilot";

          behaviour = {
            use_absolute_path = true;
          };

          providers = {
            # gemini = {
            #   api_key_name = [
            #     "op" "item" "get" "Gemini API Key" "--fields" "label=password" "--reveal"
            #   ];
            # };
            gemini = {
              model = "gemini-2.5-flash-preview-04-17";
              temperature = 0;
              timeout = 30000;
            };
          };
        };

        lazyLoad = {
          settings = {
            cmd = [
              "AvanteAsk"
                "AvanteBuild"
                "AvanteChat"
                "AvanteChatNew"
                "AvanteHistory"
                "AvanteClear"
                "AvanteEdit"
                "AvanteFocus"
                "AvanteRefresh"
                "AvanteStop"
                "AvanteSwitchProvider"
                "AvanteShowRepoMap"
                "AvanteToggle"
                "AvanteModels"
                "AvanteSwitchSelectorProvider"
            ];
          };
        };
      };
      which-key = {
        enable = true;
        settings = {
          debug = true;
        };
      };
      lz-n = {
        enable = true;
      };
    };
    extraPlugins = with pkgs.vimPlugins; [
      mini-icons
      nui-nvim
      plenary-nvim
      nvim-dap
      undotree
      nvim-spectre
      vim-visual-multi
      nvim-ts-autotag
      hologram-nvim

      # (pkgs.vimUtils.buildVimPlugin {
      #   name = "mini-hipatterns-nvim";
      #   src = pkgs.fetchFromGitHub {
      #     owner = "echasnovski";
      #     repo = "mini.hipatterns";
      #     rev = "main";
      #     sha256 = "sha256-WrFM7XdzruKWVPuhZiT0nvwYaKDTFsyqGMDEJWdbE74="; # Replace with the correct hash
      #   };
      # })
      (pkgs.vimUtils.buildVimPlugin {
        name = "vscode-es7-javascript-react-snippets";
        src = pkgs.fetchFromGitHub {
          owner = "dsznajder";
          repo = "vscode-es7-javascript-react-snippets";
          rev = "master";
          sha256 = "sha256-VLRkj1rd53W3b9Ep2FAd+vs7B8CzKH2O3EE1Lw6vnTs="; # Replace with the correct hash
        };
      })
      (pkgs.vimUtils.buildVimPlugin {
        name = "tailwindcss-colorizer-cmp-nvim";
        src = pkgs.fetchFromGitHub {
          owner = "roobert";
          repo = "tailwindcss-colorizer-cmp.nvim";
          rev = "main";
          sha256 = "sha256-PIkfJzLt001TojAnE/rdRhgVEwSvCvUJm/vNPLSWjpY="; # Replace with the correct hash
        };
      })
      copilot-vim
      # null-ls-nvim
      mason-nvim
      mason-lspconfig-nvim
      nvim-navic
      nvim-ts-context-commentstring
      bigfile-nvim
      friendly-snippets
      tokyonight-nvim
      render-markdown-nvim
      dressing-nvim
    ];
    keymaps = [
      { mode = "n"; key = "<leader>sf"; action = "<cmd>Telescope find_files<CR>"; }
      { mode = "n"; key = "<leader>sg"; action = "<cmd>Telescope live_grep<CR>"; }
      { mode = "n"; key = "<C-t>"; action = "<cmd>Neotree toggle<CR>"; }
      { mode = "n"; key = "x"; action = "\"_x"; }
      { mode = "v"; key = "d"; action = "\"_d"; }
      # { mode = "n"; key = "<leader>ee"; action = "vim.diagnostic.open_float"; }
      { mode = "n"; key = "<leader>ed"; action = "<cmd>Telescope diagnostics<CR>"; }
      { mode = "n"; key = "<leader>eh"; action = "<cmd>Noice all<CR>"; }
      # { mode = "n"; key = "<leader>rn"; action = "vim.lsp.buf.rename"; }
      { mode = "n"; key = "<leader>u"; action = "<cmd>UndotreeToggle<CR><cmd>UndotreeFocus<CR>"; }
      # { mode = "n"; key = "<leader>ha"; action = "require('harpoon'):list():add"; }
      # { mode = "n"; key = "<leader>hm"; action = "require('harpoon').ui:toggle_quick_menu(require('harpoon'):list())"; }
      # { mode = "n"; key = "<leader>h1"; action = "require('harpoon'):list():select(1)"; }
      # { mode = "n"; key = "<leader>h2"; action = "require('harpoon'):list():select(2)"; }
      # { mode = "n"; key = "<leader>h3"; action = "require('harpoon'):list():select(3)"; }
      # { mode = "n"; key = "<leader>h4"; action = "require('harpoon'):list():select(4)"; }
      # { mode = "n"; key = "<leader>hp"; action = "require('harpoon'):list():prev"; }
      # { mode = "n"; key = "<leader>hn"; action = "require('harpoon'):list():next"; }
    ];
    extraConfigLua = ''
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "ts_ls", "pyright", "lua_ls", "tailwindcss", "html", "cssls",
          "jsonls", "yamlls", "dockerls", "graphql", "bashls", "emmet_ls", "eslint"
        },
        automatic_installation = true,
      })

      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1

      require("nvim-autopairs").setup()


      -- DAP Configuration
      local dap = require('dap')
      dap.adapters.node2 = {
        type = 'executable',
        command = 'node',
        args = { "${pkgSet.vimPlugins.nvim-dap}/out/src/nodeDebug.js" },
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

      -- Mini Hipatterns setup
      -- require('mini.hipatterns').setup({})

      -- Null LS setup
      --local null_ls = require("null-ls")
      --null_ls.setup({
      --  sources = {
      --    null_ls.builtins.formatting.prettierd.with({
      --      filetypes = { "javascript", "typescript", "typescriptreact", "javascriptreact", "vue", "html", "css", "json", "yaml" },
      --    }),
      --    null_ls.builtins.formatting.black.with({ filetypes = { "python" } }),
      --    null_ls.builtins.diagnostics.eslint_d.with({ filetypes = { "javascript", "typescript", "typescriptreact", "javascriptreact", "vue" } }),
      --    null_ls.builtins.diagnostics.pylint.with({ filetypes = { "python" } }),
      --    null_ls.builtins.diagnostics.stylelint.with({ filetypes = { "css", "scss", "sass", "less" } }),
      --    null_ls.builtins.diagnostics.shellcheck.with({ filetypes = { "sh", "bash" } }),
      --  },
      --})

      -- VSCode Snippets setup
      require('luasnip.loaders.from_vscode').lazy_load({ paths = { "./vscode-es7-javascript-react-snippets" } })

      -- Tailwind CSS Colorizer setup
      require("tailwindcss-colorizer-cmp").setup()

      print("Lua package.path: " .. vim.inspect(package.path))
      print("Lua package.cpath: " .. vim.inspect(package.cpath))
    '';
  };
}
