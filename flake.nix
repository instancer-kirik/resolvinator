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
            # Elixir and Erlang
            beam.packages.erlangR26.elixir_1_15
            beam.packages.erlangR26.erlang

            # Development tools
            livebook
            inotify-tools # For file_system on Linux
            postgresql_15

            # Optional but useful
            git
            direnv
          ];

          # Environment variables
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