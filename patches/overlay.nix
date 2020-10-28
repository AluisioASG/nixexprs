final: prev:

{

  haunt = import ./haunt { inherit (prev) haunt; };

  ipfs-cluster = import ./ipfs-cluster { inherit (prev) ipfs-cluster; };

}
