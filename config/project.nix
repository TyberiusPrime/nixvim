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
      different_owners = {
        allow = true;
        notify = false;
      };
    };
  };
}
