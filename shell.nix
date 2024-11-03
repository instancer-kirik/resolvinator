{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    beam.packages.erlangR26.elixir_1_15
    livebook
  ];
} 