{pkgs, ...}:
{
  # replace with register is old...
  # I tried to yeet this, but it's muscle memory by now
  extraPlugins = [(pkgs.vimUtils.buildVimPlugin {
    name = "replaceWithRegister";
    src = pkgs.fetchFromGitHub {
        owner = "vim-scripts";
        repo = "ReplaceWithRegister";
        rev = "832efc23111d19591d495dc72286de2fb0b09345";
        sha256 = "sha256-D2FoV9G5u4MrOJhZmCdZtE+C5ya5pP/DSmUGWVDXYFU=";
    };
})];


}
