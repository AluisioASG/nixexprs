self: super:

{
  haunt = import ./haunt { haunt = super.haunt; };
  zoxide = import ./zoxide { inherit (super) fetchFromGitHub lib zoxide; };
}
