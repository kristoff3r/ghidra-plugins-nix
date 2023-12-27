{ config, pkgs, lib, ... }:

let
    cfg = config.services.ghidra;
    stateDir = "/var/lib/ghidra";
in
{
  options.services.ghidra = {
   enable = lib.mkEnableOption "Host a Ghidra server";

   hostname = lib.mkOption {
     type = lib.types.str;
     description = "Which hostname is used for the server";
   };

   package = lib.mkOption {
    type = lib.types.package;
    default = pkgs.ghidra-bin;
   };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.ghidra = {
      enable = true;
      description = "Ghidra server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      path = [
        cfg.package
        pkgs.openjdk17
      ];
      serviceConfig = {
        Type = "forking";
        PreExecStart = ''
          mkdir ${stateDir}/server
          ln -s ${cfg.package}/lib/ghidra/server/ghidraSvr ${stateDir}/server
        '';
        ExecStart = ''${stateDir}/server/ghidraSvr console'';
        StateDirectory = "ghidra";
        WorkingDirectory = "${stateDir}";
        StateDirectoryMode = "0700";
        Environment=[
          "JAVA_HOME='${pkgs.jdk}'"
        ];
      };
    };
  };
}