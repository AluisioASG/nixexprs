{ stdenv, fetchFromGitHub, kernel, concurrentMode ? false }:

stdenv.mkDerivation rec {
  name = "rtl8723bu-${kernel.version}-${version}";
  version = "2020-01-26";

  src = fetchFromGitHub {
    owner = "lwfinger";
    repo = "rtl8723bu";
    rev = "2d939a37048e9ee9fa26e225461c59a34f72dcc5";
    sha256 = "0scc5hx083gmcp3igb00agwpv903r2h9pzz1zdmy2pm072m2ayji";
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
  ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "Driver for RTL8723BU";
    homepage = "https://github.com/lwfinger/rtl8723bu";
    license = licenses.unfreeRedistributableFirmware;
    platforms = platforms.linux;
    maintainers = [ maintainers.AluisioASG ];
  };
}
