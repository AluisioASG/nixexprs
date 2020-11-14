final: prev:

{

  bird-lg = final.callPackage ./bird-lg { inherit (prev) bird-lg; };

  haunt = final.callPackage ./haunt { inherit (prev) haunt; };

  ipfs-cluster = final.callPackage ./ipfs-cluster { inherit (prev) ipfs-cluster; };

}
