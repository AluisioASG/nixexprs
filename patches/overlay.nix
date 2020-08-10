self: super:

{

  haunt = import ./haunt { inherit (super) haunt; };

  ipfs-cluster = import ./ipfs-cluster { inherit (super) ipfs-cluster; };

}
