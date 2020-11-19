{ fetchpatch, bird-lg }:

bird-lg.overrideAttrs (oldAttrs: {
  patches = (oldAttrs.patches or [ ]) ++ [
    (fetchpatch {
      name = "bird-lg_dont_configure_log_file.patch";
      url = "https://github.com/AluisioASG/bird-lg/commit/e58112848e7160fb3cb71b5ca674ac3537e12b05.patch";
      sha256 = "0daqkql0a8slqap8pybngm4al96pcki69vai0807vck4gi4paw0z";
    })
  ];

  postPatch = ''
    # Replace the builtin config file with one given through an
    # environment variable.
    sed -i '/app\.config\.from_pyfile/c app.config.from_envvar("BIRD_LG_CONFIG")' lg.py lgproxy.py
  '';
})
