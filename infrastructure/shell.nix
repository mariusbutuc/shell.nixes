{ pkgs ? import <nixpkgs> {} }:

with pkgs;

let
  inputs = [
    awscli
    krane
    kubectl
    kubectx
    kubernetes-helm
    ruby
    terraform
  ];

in

mkShell {
  buildInputs = inputs;
}
