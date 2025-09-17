---
title: VR + NixOS + Nvidia
modified: June 21, 2025
---

For the longest time, getting VR working nicely with Linux (and especially NixOS) was a monumental task.
Nowadays however, it is easier than ever: only requiring a handful of lines of Nix!

## Prerequisites

In this blog post, I will be focusing on getting VR working with Steam games, using an Oculus Quest 2 headset.
Ensure you have the proprietary Nvidia drivers installed, as this will most likely not work without them.
You will also need Home Manager setup, as we will be utilising that to get Steam games working.

```nix
# Generic drivers, good to have
hardware.graphics = {
  enable = true;
  enable32Bit = true;
};

# Nvidia specific
hardware.nvidia = {
  modesetting.enable = true;
  open = true;
};

services.xserver.videoDrivers = ["nvidia"];
```

## Installing WiVRn

As I am using a Quest 2, I am going to use an application called WiVRn, which will allow me to stream both wired _or_ wirelessly.
If you are using a tethered headset such as a HTC Vive or Valve Index, I can recommend you look into [Monado](https://gitlab.freedesktop.org/monado/monado).
WiVRn is actually based on Monado, so gertting it up and running should be fairly similar.
All we need to get WiVRn installed is put the following in our configuration!

```nix
/* configuration.nix */
services.wivrn = {
  enable = true;
  openFirewall = true; # Required for wireless streaming
  defaultRuntime = true;
};
```

Although we don't _necessarily_ need anything else now, installing some quality-of-life tools will definitely benefit us.

```nix
/* configuration.nix */
environment.systemPackages = with pkgs; [
  wlx-overlay-s # In-VR overlay
  android-tools # Allows for wired WiVRn
];
```

## Getting Steam games working

If all we want to do is play OpenXR games, we're set!
Most, if not all, steam games use OpenVR though, so we will need a compatibility layer: OpenComposite.
We can tell Steam to use OpenComposite and WiVRn for games by writing a few configuration files.
Because these files live in our home directory, we need to use Home Manager.
In home.nix, or wherever you have your home configuration:

```nix
/* home.nix */
xdg.configFile."openxr/1/active_runtime.json".source =
  "${osConfig.services.wivrn.package}/share/openxr/1/openxr_wivrn.json";

xdg.configFile."openvr/openvrpaths.vrpath".text = ''
   {
    "config" :
    [
      "${config.xdg.dataHome}/Steam/config"
    ],
    "external_drivers" : null,
    "jsonid" : "vrpathreg",
    "log" :
    [
      "${config.xdg.dataHome}/Steam/logs"
    ],
    "runtime" :
    [
      "${pkgs.opencomposite}/lib/opencomposite"
    ],
    "version" : 1
  }
'';
```

We are using `osConfig` in this case, as to use the same package we use when enabling WiVRn, meaning that if we changed `services.wivrn.package` in the future, it will use that package instead of the generic one from nixpkgs.

Going back to our main configuration, we now need to tell the game to actually use these settings.

We can do this by setting our game launch options to `PRESSURE_VESSEL_FILESYSTEMS_RW=$XDG_RUNTIME_DIR/wivrn/comp_ipc %command%`, however that isn't very "Nix", is it?
To do this for _every_ game, we can override our steam package to include this environment variable.

```nix
/* configuration.nix */
programs.steam.package = lib.mkDefault (
  pkgs.steam.override (prev: {
    extraEnv =
    {
      PRESSURE_VESSEL_FILESYSTEMS_RW = "$XDG_RUNTIME_DIR/wivrn/comp_ipc";
    }
    // (prev.extraEnv or {});
  })
);
```

Don't worry about your flatscreen games: they should just ignore this setting!

## Done!

We should now just be able to open the "WiVRn server" GUI application, and start gaming!
You can read the [official WiVRn documentation](https://github.com/WiVRn/WiVRn?tab=readme-ov-file#running-1) for platform independent help on getting it up and running now, as the Nix specific stuff has now been sorted.
