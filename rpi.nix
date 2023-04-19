{ config, pkgs, lib, ... }:

{
  boot = {
    # If you have a Raspberry Pi 2 or 3, pick this:
    kernelPackages = pkgs.linuxPackages_latest;
    # A bunch of boot parameters needed for optimal runtime on RPi 3b+
    kernelParams = ["cma=256M"];
    loader = {
      raspberryPi = {
        enable = true;
        version = 3;
        uboot.enable = true;
        firmwareConfig = ''
          gpu_mem=256
        '';
      };
    };
  };

  # NixOS wants to enable GRUB by default
  boot.loader.grub.enable = false;

  environment.systemPackages = with pkgs; [
    libraspberrypi
  ];

  # File systems configuration for using the installer's partition layout
  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
  };

  # Preserve space by sacrificing documentation and history
  services.nixosManual.enable = false;
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 30d";
  };
  boot.cleanTmpDir = true;

  # Configure basic SSH access
  services.openssh = {
    enable = true;
    permitRootLogin = "yes";
  };

  # Use 1GB of additional swap memory in order to not run out of memory
  # when installing lots of things while running other things at the same time.
  swapDevices = [ { device = "/swapfile"; size = 1024; } ];
}
