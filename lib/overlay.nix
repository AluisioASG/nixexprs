final: prev: {
  lib = prev.lib // (import ./. prev.lib);
}
