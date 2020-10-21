{ lib, ... }:
let
  inherit (lib.strings) stringLength substring toUpper;
in
rec {
  /*
   * Return the given string with its first character made uppercase.
   */
  capitalize = str: "${toUpper (substring 0 1 str)}${substring 1 (stringLength str) str}";
}
