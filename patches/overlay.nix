self: super:

{
  haunt = import ./haunt { haunt = super.haunt; };
}
