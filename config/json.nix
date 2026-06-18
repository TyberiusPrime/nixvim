{ pkgs, ... }:
{
  # fixjson: a lenient JSON formatter. Tolerates JSON5-ish input
  # (comments, trailing commas, single quotes, unquoted keys) and
  # re-emits strict, pretty-printed JSON.
  extraPackages = [ pkgs.fixjson ];

  autoCmd = [
    {
      event = "FileType";
      pattern = [ "json" "jsonc" "json5" ];
      command = "noremap <buffer> <F12> :%!fixjson<cr>";
    }
  ];
}
