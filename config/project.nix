{ ... }:
{
  plugins.project-nvim = {
    enable = true;
    settings = {
      patterns = [
        "florg_data.folder"
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
