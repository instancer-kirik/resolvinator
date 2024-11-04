{
  description = "Resolvinator Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Updated to Erlang 27
            beam.packages.erlang_27.elixir
            beam.packages.erlang_27.erlang
            livebook
            inotify-tools
            postgresql_15
            git
            direnv
          ];

          shellHook = ''
            export LANG=C.UTF-8
            export MIX_HOME=$HOME/.mix
            export HEX_HOME=$HOME/.hex
            export PATH=$MIX_HOME/escripts:$PATH

            # Initialize mix if needed
            if [ ! -f $MIX_HOME/rebar3 ]; then
              mix local.rebar --force
              mix local.hex --force
            fi

            echo "Elixir Development Environment Ready!"
          '';
        };
      }
    );
} 