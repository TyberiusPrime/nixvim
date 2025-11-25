{...}:
{
plugins.project-nvim = {
  enable = true;
  settings = {
    patterns = [ ".git" ".github" "code" ".hg" ];
    allow_different_owners = true;
  };
};
}
