{ config, pkgs, lib, inputs, ... }:

let
  unstable = import inputs.nixpkgs-unstable {
    system = "aarch64-linux";
    config = {
      allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "copilot.vim"
      ];
    };
  };
in
{
  imports = [ inputs.nixvim.homeManagerModules.nixvim ];
  home.stateVersion = "24.11";
  home.username = "cod";
  home.homeDirectory = "/home/cod";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.package = pkgs.nix;

  home.packages = with unstable; [
    lsd
    neovim
    nix-prefetch-git
    wl-clipboard
    openssh
    oh-my-posh wofi waybar vim htop
    fastfetch btop
    tree home-manager
    hyprshot
    hyprpolkitagent
    papirus-icon-theme
    wget
    udiskie
    exfatprogs
    pywal
    hyprpaper
    swww
    ffmpeg-full
    yt-dlp
    superfile
    brightnessctl
    pamixer
    flatpak
    xdg-utils

    # Dependencies for NixVim
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

  home.sessionVariables = {
    XDG_DATA_DIRS = "${config.home.homeDirectory}/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:$XDG_DATA_DIRS";
    ELECTRON_DISABLE_GPU = "1";
    EDITOR = "nvim";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  # NixVim Configuration
  programs.nixvim = {
    enable = true;
    clipboard = {
      register = "unnamedplus";
      providers.wl-copy.enable = true;
    };
    globals = {
      mapleader = " ";
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
    plugins = {
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
          # Removed clangd due to installation issues
        };
      };
      neo-tree.enable = true;
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
      telescope.enable = true;
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
    };
    extraPlugins = with pkgs.vimPlugins; [
      mini-icons
      nui-nvim
      plenary-nvim
      nvim-dap
      undotree
      nvim-spectre
      vim-visual-multi
      nvim-autopairs
      avante-nvim
      nvim-ts-autotag
      hologram-nvim
      (pkgs.vimUtils.buildVimPlugin {
        name = "which-key-nvim";
        src = pkgs.fetchFromGitHub {
          owner = "folke";
          repo = "which-key.nvim";
          rev = "v2.1.0";
          hash = "sha256-gc/WJJ1s4s+hh8Mx8MTDg8pGGNOXxgKqBMwudJtpO4Y="; # Correct hash
        };
      })
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
      { mode = "n"; key = "<leader>sf"; action = "require('telescope.builtin').find_files"; }
      { mode = "n"; key = "<leader>sg"; action = "require('telescope.builtin').live_grep"; }
      { mode = "n"; key = "<C-t>"; action = ":Neotree toggle<CR>"; }
      { mode = "n"; key = "x"; action = "\"_x"; }
      { mode = "v"; key = "d"; action = "\"_d"; }
      { mode = "n"; key = "<leader>ee"; action = "vim.diagnostic.open_float"; }
      { mode = "n"; key = "<leader>ed"; action = "<cmd>Telescope diagnostics<CR>"; }
      { mode = "n"; key = "<leader>eh"; action = "<cmd>Noice all<CR>"; }
      { mode = "n"; key = "<leader>rn"; action = "vim.lsp.buf.rename"; }
      { mode = "n"; key = "<leader>u"; action = ":UndotreeToggle<CR>:UndotreeFocus<CR>"; }
    ];
    extraConfigLua = ''
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "ts_ls", "pyright", "lua_ls", "tailwindcss", "html", "cssls",
          "jsonls", "yamlls", "dockerls", "graphql", "bashls", "emmet_ls"
        },
        automatic_installation = true,
      })

      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
      require("which-key").setup({
        triggers = { "<leader>" },
        debug = true,
      })

      require("nvim-autopairs").setup()

      local wk = require("which-key")
      wk.register({
        { "<leader>e", group = "Diagnostics" },
        { "<leader>ed", "<cmd>Telescope diagnostics<CR>", desc = "Error Diagnostics" },
        { "<leader>ee", "<cmd>lua vim.diagnostic.open_float()<CR>", desc = "Open Error Float" },
        { "<leader>eh", "<cmd>Noice all<CR>", desc = "Noice All" },
      })

      wk.register({
        { "<leader>t", group = "Terminals" },
        { "<leader>t0", "<cmd>ToggleTerm 10<CR>", desc = "Terminal 10" },
        { "<leader>t1", "<cmd>ToggleTerm 1<CR>", desc = "Terminal 1" },
        { "<leader>t2", "<cmd>ToggleTerm 2<CR>", desc = "Terminal 2" },
        { "<leader>t3", "<cmd>ToggleTerm 3<CR>", desc = "Terminal 3" },
        { "<leader>t4", "<cmd>ToggleTerm 4<CR>", desc = "Terminal 4" },
        { "<leader>t5", "<cmd>ToggleTerm 5<CR>", desc = "Terminal 5" },
        { "<leader>t6", "<cmd>ToggleTerm 6<CR>", desc = "Terminal 6" },
        { "<leader>t7", "<cmd>ToggleTerm 7<CR>", desc = "Terminal 7" },
        { "<leader>t8", "<cmd>ToggleTerm 8<CR>", desc = "Terminal 8" },
        { "<leader>t9", "<cmd>ToggleTerm 9<CR>", desc = "Terminal 9" },
    })

      require("neo-tree").setup({
        close_if_last_window = true,
        filesystem = {
          hijack_netrw_behavior = "open_current",
          window = {
            position = "right",
            width = 25,
            mapping_options = {
              noremap = true,
              nowait = true,
            },
            mappings = {
              ["<leader>p"] = "image_preview"
            }
          },
          commands = {
            image_preview = function(state)
              local node = state.tree:get_node()
              if node.type == "file" then
                local hologram = require("hologram")
                hologram.setup {
                  auto_display = false,
                }
                local buf = vim.api.nvim_create_buf(false, true)
                local width = vim.o.columns * 0.5
                local height = vim.o.lines * 0.5
                vim.api.nvim_open_win(buf, true, {
                  relative = "editor",
                  width = math.floor(width),
                  height = math.floor(height),
                  row = math.floor((vim.o.lines - height) / 2),
                  col = math.floor((vim.o.columns - width) / 2),
                  style = "minimal",
                  border = "rounded",
                })
                require('hologram.image'):new(node.path):display(1, 1, buf, {})
              else
                vim.notify("Not a valid image file!", vim.log.levels.WARN)
              end
            end,
          },
        },
      })

      -- DAP Configuration
      local dap = require('dap')
      dap.adapters.node2 = {
        type = 'executable',
        command = 'node',
        args = { "${unstable.vimPlugins.nvim-dap}/out/src/nodeDebug.js" },
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

    '';
  };
  
  # Flatpak configuration
  services.flatpak = {
    enable = true;
    remotes = [
      {
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }
    ];
    packages = [
      "md.obsidian.Obsidian"
      "com.bitwarden.desktop"
      "app.zen_browser.zen"
      "com.github.tchx84.Flatseal"
    ];
    uninstallUnmanaged = true;
    update.auto = {
      enable = true;
      onCalendar = "weekly";
    };
  };

  xdg.desktopEntries = {
    "md.obsidian.Obsidian" = {
      name = "Obsidian";
      comment = "Knowledge base";
      exec = "flatpak run --no-sandbox --branch=stable --arch=aarch64 --command=obsidian.sh --file-forwarding md.obsidian.Obsidian --js-flags=\"--nodecommit_pooled_pages\" --disable-gpu @@u %U @@";
      icon = "md.obsidian.Obsidian";
      terminal = false;
      type = "Application";
      categories = [ "Office" ];
      mimeType = [ "x-scheme-handler/obsidian" ];
    };
    "superfile" = {
      name = "Superfile (TUI)";
      genericName = "TUI File Manager";
      comment = "Fast and modern TUI file manager";
      exec = "superfile";
      icon = "utilities-terminal";
      terminal = true;
      categories = [ "Utility" "FileTools" ];
      mimeType = [ "inode/directory" ];
    };
  };

  services.udiskie = {
    enable = true;
    automount = true;
    notify = true;
    tray = "never";
    settings = {
      program_options = {
        password_prompt = "kitty -e udiskie-unlock";
      };
      device_config = [
        {
          device = "UUID=BF75-E4C0";
          automount = true;
        }
        {
          device = "UUID=73535e6c-db20-4edb-9a7d-3fe4f869b924";
          luks = true;
          automount = true;
        }
      ];
    };
  };

  programs.ssh.enable = true;

  programs.rofi = {
    enable = true;
    package = unstable.rofi-wayland;
    extraConfig = {
      modi = "drun,run,window";
      show-icons = true;
      icon-theme = "Papirus";
    };
  };

  programs.git = {
    enable = true;
    userName = "chowe99";
    userEmail = "chowej99@gmail.com";
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      theme = "simple";
      plugins = [ "git" "common-aliases" "colored-man-pages" "z" "dnf" "docker" "npm" "fzf" ];
    };
    plugins = [
      {
        name = "fast-syntax-highlighting";
        src = unstable.zsh-fast-syntax-highlighting;
        file = "share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh";
      }
    ];
  };


  home.file.".zshrc" = {
    text = ''
      export EDITOR=nvim
      alias vim=nvim
      eval "$(oh-my-posh init zsh --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/1_shell.omp.json')"
      alias switch="home-manager switch --flake ~/nix-config#cod"
      alias c="clear && fastfetch"
      alias open="superfile"
      alias ls='lsd'
      alias l='ls -l'
      alias la='ls -a'
      alias lla='ls -la'
      alias lt='ls --tree'
      fastfetch
      export PATH="$HOME/Applications:$PATH"
    '';
    force = true;
  };

  home.file.".config/rofi" = {
    source = "${inputs.dotfiles}/rofi";
    recursive = true;
  };
  home.file.".config/waybar" = {
    source = "${inputs.dotfiles}/waybar";
    recursive = true;
  };
  home.file.".config/hypr" = {
    source = "${inputs.dotfiles}/hypr";
    recursive = true;
  };
  home.file.".config/kitty" = {
    source = "${inputs.dotfiles}/kitty";
    recursive = true;
  };
}
