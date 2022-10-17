# https://hexdocs.pm/phoenix/installation.html
# https://nixos.org/manual/nixpkgs/stable/#elixir---phoenix-project

{ pkgs ? import <nixpkgs> {} }:

with pkgs;

let
  basePackages = [
    beam.packages.erlangR25.elixir_1_14
    git
  ];

  inputs = basePackages
    ++ lib.optionals stdenv.isLinux [
      # https://hexdocs.pm/phoenix/installation.html#inotify-tools-for-linux-users
      inotify-tools
    ]
    ++ lib.optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [
      CoreFoundation
      CoreServices
    ]);

  hooks = ''
    export HEX_HOME=$PWD/.nix-hex
    export MIX_HOME=$PWD/.nix-mix
    export PHX_VERSION="1.6.13"

    mkdir -p $MIX_HOME $HEX_HOME

    # leverage hex from Nixpkgs
    export MIX_PATH="${beam.packages.erlang.hex}/lib/erlang/lib/hex/ebin"

    export PATH=$MIX_HOME/bin:$HEX_HOME/bin:$PATH
    export LANG=C.UTF-8

    if ! mix phx.new --version; then
      mix archive.install hex phx_new $PHX_VERSION --force
    fi

    # persist iex shell history
    export ERL_AFLAGS="-kernel shell_history enabled -kernel shell_history_file_bytes 1024000"
  '';
in

mkShell {
  buildInputs = inputs;
  shellHook = hooks;
}
