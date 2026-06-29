{ ... }:
{
  plugins.project-nvim = {
    enable = true;
    settings = {
      patterns = [
        ".git"
        ".github"
        "code"
        ".hg"
      ];
      # allow_different_owners = true;
      plugins.project-nvim = {
        enable = true;
        settings = {
          allow_different_owners = true;
          different_owners = {
            allow = true;
            notify = false;
          };
          patterns = [
            ".git"
            ".github"
            "code"
            ".hg"
          ];
        };
      };
    };
  };
}
