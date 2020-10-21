{ lib, aasgLib }:
let
  inherit (builtins) attrNames concatStringsSep intersectAttrs isAttrs;
in
rec {
  /*
   * Return a copy of the input attribute set with its (non-recursive)
   * attribute names capitalized.  Useful when mapping between Nixpkgs
   * and systemd.
   */
  capitalizeAttrNames = /*attrs:*/
    lib.mapAttrs' (name: value: lib.nameValuePair (aasgLib.capitalize name) value);


  /*
   * Like the update operator `//`, but throws if the right-hand
   * attrset contains an attribute that already exists in the
   * left-hand side.
   *
   * See `lib.attrsets.overrideExisting` for the opposite behavior.
   */
  updateNew = into: new:
    let
      commonAttributes = attrNames (intersectAttrs into new);
    in
    if commonAttributes == [ ]
    then into // new
    else throw "attrsets have the following attributes in common: ${concatStringsSep ", " commonAttributes}";

  /*
   * Recursive variant of updateNew.
   */
  updateNewRecursive = into: new:
    let
      commonAttributes = attrNames (intersectAttrs into new);
      commonNonAttrsets = builtins.filter (name: ! (isAttrs into.${name} && isAttrs new.${name})) commonAttributes;
      mergedCommonAttrsets = builtins.listToAttrs
        (map (name: lib.nameValuePair name (updateNewRecursive into.${name} new.${name})) commonAttributes);
    in
    if commonNonAttrsets == [ ]
    then into // new // mergedCommonAttrsets
    else
      throw "attrsets have the following attributes in common: ${concatStringsSep ", " commonNonAttrsets}";
}
