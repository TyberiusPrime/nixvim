{
  description = "A nixvim configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixvim.url = "github:nix-community/nixvim";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = {
    nixvim,
    flake-parts,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      perSystem = {system, ...}: let
        nixvimLib = nixvim.lib.${system};
        nixvim' = nixvim.legacyPackages.${system};
        nixvimModule = {
          inherit system; # or alternatively, set `pkgs`
          module = import ./config; # import the module directly
          # You can use `extraSpecialArgs` to pass additional arguments to your module files
          extraSpecialArgs = {
            # inherit (inputs) foo;
          };
        };
        nvim = nixvim'.makeNixvimWithModule nixvimModule;
      in {
        checks = {
          # Run `nix flake check .` to verify that your config is not broken
          default = (
            nixvimLib.check.mkTestDerivationFromNixvimModule nixvimModule
          );
        };

        packages = let
          pkgs = import nixvim.inputs.nixpkgs {inherit system;};
          ag = pkgs.writeShellScriptBin "ag" ''
            ag_dir=""
            for d in "$HOME/upstream/agents" /ff-m5/agents; do
              if [ -d "$d" ]; then
                ag_dir="$d"
                break
              fi
            done
            if [ -z "$ag_dir" ]; then
              echo "ag: no agents directory found (tried /ff-m5/agents, $HOME/upstream/agents, $HOME/agents)" >&2
              exit 1
            fi
            case "$1" in
              claude)
                shift
                CLAUDE_CODE_MAX_OUTPUT_TOKENS=64000 exec "$ag_dir/claude/result/bin/safe-claude" "$@"
                ;;
              opencode)
                shift
                exec "$ag_dir/opencode-nix/result/bin/safe-opencode" "$@"
                ;;
              dirge)
                shift
                exec "$ag_dir/dirge/result/bin/safe-dirge" "$@"
                ;;
              pi)
                shift
                exec "$ag_dir/pi/result/bin/safe-pi" "$@"
                ;;
              *)
                echo "Usage: ag {claude|opencode|dirge} [args...]" >&2
                exit 1
                ;;
            esac
          '';
        in {
          # Lets you run `nix run .` to start nixvim
          default = pkgs.symlinkJoin {
            name = "nvim-wrapped";
            paths = [nvim ag];
            buildInputs = [pkgs.makeWrapper];
            postBuild = ''
              wrapProgram $out/bin/nvim \
                --set NVIM_APPNAME "nixnvim"
            '';
          };
        };
      };
    };
}
