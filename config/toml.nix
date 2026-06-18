{ pkgs, ... }:
{
  # tombi: a TOML 1.1 formatter / linter / LSP.
  # Chosen over taplo (TOML 1.0 only) for TOML 1.1 support.
  # `tombi format -` reads from stdin, so it works as a `:%!` filter.
  extraPackages = [ pkgs.tombi ];

  autoCmd = [
    {
      event = "FileType";
      pattern = [ "toml" ];
      command = "noremap <buffer> <F12> :%!tombi format -<cr>";
    }
  ];
}
