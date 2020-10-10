{ stdenv, fetchFromGitHub, kernel, concurrentMode ? false }:

stdenv.mkDerivation rec {
  name = "rtl8723bu-${kernel.version}";

  src = fetchFromGitHub {
    owner = "lwfinger";
    repo = "rtl8723bu";
    rev = "5100a8b347bad28655cabc975786e701b5e1fa1f";
    sha256 = "18x3x9jx6mc22cgc8rf2fsa0crwq55iapry9ymdn1rw4dclyahjk";
  };

  postPatch = stdenv.lib.optionalString (!concurrentMode) ''
    sed -i '/-DCONFIG_CONCURRENT_MODE/d' Makefile
  '';

  hardeningDisable = [
    "fortify"
    "pic"
    "stackprotector"
  ];

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = [
    "ARCH=${stdenv.hostPlatform.platform.kernelArch}"
    "KSRC=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "KVER=${kernel.version}"
    "DEPMOD=true"
    "INSTALL_MOD_PATH=$(out)"
    # Fix build for Linux 5.8(+?) on Nixpkgs 20.09.
    # https://wiki.gentoo.org/wiki/Binutils_2.32_upgrade_notes/elfutils_0.175:_unable_to_initialize_decompress_status_for_section_.debug_info
    "USER_EXTRA_CFLAGS=-gz=none"
  ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "Driver for RTL8723BU";
    longDescription = ''
      Kernel driver for Realtek RTL8723BU Wireless Adapter with hardware ID 0bda:b720.
    '';
    homepage = "https://github.com/lwfinger/rtl8723bu";
    license = licenses.unfreeRedistributableFirmware;
    platforms = platforms.linux;
    maintainers = with maintainers; [ AluisioASG ];
  };
}
