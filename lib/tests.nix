# To run the tests, do:
#
#     nix-instantiate --eval --strict ./tests.nix

with (import ../. { }).lib.extended;
let
  evalFailure = { success = false; value = false; };

  runTestsOrDieTrying = tests:
    let
      results = runTests tests;
    in
    assert (traceValSeq results) == [ ]; true;
in
runTestsOrDieTrying {

  ############
  # attrsets #
  ############

  testCapitalizeAttrNames1 = {
    expr = capitalizeAttrNames { };
    expected = { };
  };

  testCapitalizeAttrNames2 = {
    expr = capitalizeAttrNames { ExecStart = "/bin/false"; };
    expected = { ExecStart = "/bin/false"; };
  };

  testCapitalizeAttrNames3 = {
    expr = capitalizeAttrNames { execStart = "/bin/false"; };
    expected = { ExecStart = "/bin/false"; };
  };

  testCapitalizeAttrNames4 = {
    expr = capitalizeAttrNames { serviceConfig.execStart = "/bin/false"; };
    expected = { ServiceConfig = { execStart = "/bin/false"; }; };
  };

  testUpdateNew1 = {
    expr = updateNew { } { };
    expected = { };
  };

  testUpdateNew2 = {
    expr = updateNew { a = 1; } { };
    expected = { a = 1; };
  };

  testUpdateNew3 = {
    expr = updateNew { } { a = 1; };
    expected = { a = 1; };
  };

  testUpdateNew4 = {
    expr = builtins.tryEval (updateNew { a = 1; } { a = 2; });
    expected = evalFailure;
  };

  testUpdateNew5 = {
    expr = updateNew { a = 1; } { b = 2; };
    expected = { a = 1; b = 2; };
  };

  testUpdateNew6 = {
    expr = builtins.tryEval (updateNew { a = 1; b = { c = 2; }; } { d = 4; b = { d = 4; }; });
    expected = evalFailure;
  };

  testUpdateNewRecursive1 = {
    expr = updateNewRecursive { } { };
    expected = { };
  };

  testUpdateNewRecursive2 = {
    expr = updateNewRecursive { a = 1; } { };
    expected = { a = 1; };
  };

  testUpdateNewRecursive3 = {
    expr = updateNewRecursive { } { a = 1; };
    expected = { a = 1; };
  };

  testUpdateNewRecursive4 = {
    expr = builtins.tryEval (updateNewRecursive { a = 1; } { a = 2; });
    expected = evalFailure;
  };

  testUpdateNewRecursive5 = {
    expr = updateNewRecursive { a = 1; } { b = 2; };
    expected = { a = 1; b = 2; };
  };

  testUpdateNewRecursive6 = {
    expr = updateNewRecursive { a = 1; b = { c = 2; }; } { d = 4; b = { d = 4; }; };
    expected = { a = 1; b = { c = 2; d = 4; }; d = 4; };
  };

  #########
  # lists #
  #########

  testIndexOfFound = {
    expr = indexOf "c" [ "a" "b" "c" "d" "e" ];
    expected = 2;
  };

  testIndexOfNotFound = {
    expr = indexOf "g" [ "a" "b" "c" "d" "e" ];
    expected = -1;
  };

  testIndexOfWrongType = {
    expr = indexOf 3 [ "a" "b" "c" "d" "e" ];
    expected = -1;
  };

  testIndexOfEmpty = {
    expr = indexOf (throw "shouldn't be evaluated") [ ];
    expected = -1;
  };

  testIsSubsetOf1 = {
    expr = isSubsetOf [ 1 2 3 4 5 ] [ 1 3 5 ];
    expected = true;
  };

  testIsSubsetOf2 = {
    expr = isSubsetOf [ 1 2 3 4 5 ] [ ];
    expected = true;
  };

  testIsSubsetOf3 = {
    expr = isSubsetOf [ ] [ 1 3 5 ];
    expected = false;
  };

  testIsSubsetOf4 = {
    expr = isSubsetOf [ ] [ ];
    expected = true;
  };

  ###########
  # strings #
  ###########

  testCapitalize1 = {
    expr = capitalize "";
    expected = "";
  };

  # tryEval doesn't catch this, wait for github:NixOS/nix#1230.
  #testCapitalize2 = {
  #  expr = builtins.tryEval (capitalize strings);
  #  expected = evalFailure;
  #};

  testCapitalize3 = {
    expr = capitalize "05:14";
    expected = "05:14";
  };

  testCapitalize4 = {
    expr = capitalize "90-default.conf";
    expected = "90-default.conf";
  };

  testCapitalize5 = {
    expr = capitalize "testCapitalize5";
    expected = "TestCapitalize5";
  };

}
