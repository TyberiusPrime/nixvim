{pkgs, ...}: {
  # extraPlugins = [
  #   (pkgs.vimUtils.buildVimPlugin {
  #     name = "neoformat";
  #     src = pkgs.fetchFromGitHub {
  #       owner = "sbdchd";
  #       repo = "neoformat";
  #       rev = "2b11fb9fa383636de5de9ecc7c989436c4e0f9d1";
  #       sha256 = "sha256-lrooNuJOV0gfg+OiKl09Iyn1jMuVxI87vSoZddenwXI=";
  #     };
  #   })
  # ];
  extraConfigLua = ''
    vim.api.nvim_exec([[
      function! Black(...)
    		silent write
            let l:args = get(a:, 1, "")

            if exists("g:black_cmd")
                let black_cmd=g:black_cmd
            else
                let black_cmd="black"
            endif


            if !executable(black_cmd)
                echoerr "File " . black_cmd . " not found. Please install it first."
                return
            endif
    		silent write

            let execmdline=black_cmd . " - -q" . l:args
            let current_line = line(".")
    		let last_line = line("$")
            " save current cursor position
            let current_cursor = getpos(".")
            silent execute "0,$!" . execmdline
            " restore cursor
            call setpos(".", current_cursor)
            if v:shell_error != 0
                " Shell command failed, so open a new buffer with error text
    			let @a = join(getline(last_line+1, "$"), "\n")
                silent undo
                " restore cursor position
                "call setpos(".", current_cursor)
                silent new
    			:setlocal buftype=nofile
    			:setlocal bufhidden=hide
    			:setlocal noswapfile
    			execute "normal! iBlack failed\<CR>\<esc>"
    			"append "black failed<c-c>"
                silent put a
                "echoerr "Black call failed"
            end
                execute "normal! " . current_line . "G"
    			call setpos(".", current_cursor)
            "echo "called black"
        endfunction

        command! -nargs=? -bar Black call Black(<f-args>)

          ]]
            ,false)
  '';
  autoCmd = [
    {
      event = "FileType";
      pattern = "python";
      command = "noremap <buffer> <F12> :call Black()<CR>";
    }
  ];

  plugins.lsp.enable = true;
  lsp.servers = {
    lua_ls = {
      enable = true;
    };
    nixd = {
      enable = true;
    };
    rls = {
      enable = true;
    };
    pyright = {
      enable = true;
    };
  };
  extraPackages = [
    pkgs.nixd
    pkgs.nixfmt-rfc-style
  ];
  diagnostic.settings.virtual_text = true;

  keymaps = [
    {
      # autoformat
      action = ":lua vim.lsp.buf.format() <cr>";
      key = "<F12>";
      mode = "n";
      options = {
        silent = true;
      };
    }
  ];
}
