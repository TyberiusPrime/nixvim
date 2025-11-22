{ ... }:

{
  extraConfigLua = ''
    -- a function that writes and closes the current buffer
    -- if it was the last buffer, quit vim
    function write_and_close()
        vim.cmd("w")
        if #vim.fn.getbufinfo({ buflisted = true }) == 1 then
            vim.cmd("q")
        else
            vim.cmd("bd")
        end
        end
  '';
  keymaps = [
    {
      action = ":lua write_and_close() <cr>";
      key = "<c-c><c-c>";
      mode = "n";
      options = {
        silent = true;
      };
    }
    {
      action = "<esc>:lua write_and_close() <cr>";
      key = "<c-c><c-c>";
      mode = "i";
      options = {
        silent = true;
      };
    }
    {
      # remove text, write to file and close
      action = "1GdG:lua write_and_close() <cr>";
      key = "<c-c><c-k>";
      mode = "n";
      options = {
        silent = true;
      };
    }
    {
      action = "<esc>1GdG:lua write_and_close() <cr>";
      key = "<c-c><c-k>";
      mode = "i";
      options = {
        silent = true;
      };
    }

    {
      # autoformat
      action = ":lua vim.lsp.buf.format() <cr>";
      key = "<F12>";
      mode = "n";
      options = {
        silent = true;
      };
    }
    {
      action = "<esc>:lua vim.lsp.buf.format() <cr>";
      key = "<F12>";
      mode = "i";
      options = {
        silent = true;
      };
    }
    {
      # quit without saving
      action = ":bd!<cr>:q<cr>";
      key = "<c-c><c-p>";
      mode = "n";
      options = {
        silent = true;
      };
    }
    {
      action = "<esc>:bd!<cr>:q<cr>";
      key = "<c-c><c-p>";
      mode = "i";
      options = {
        silent = true;
      };
    }
     # copy to clipboard
    {
      action = "\"+y";
      key = "<c-c>";
    }
    # paste from clipboard
  {
      action = "i<C-g>u<esc>\"+p";
      key = "<c-v>";
      mode = "n";
    }
  {
      action = "<C-g>u<esc>\"+p";
      key = "<c-v>";
      mode = "i";
    }


  ];
}
