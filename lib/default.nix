{ lib }:

{
  indexOf = x: xs:
    let indexOfRec = i: xs:
      if xs == [ ] then -1
      else if (builtins.head xs) == x then i
      else indexOfRec (i + 1) (builtins.tail xs);
    in indexOfRec 0 xs;
}
