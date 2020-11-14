{ bird-lg }:

bird-lg.overrideAttrs (oldAttrs: {
  postPatch = ''
    # Don't configure a log file; let systemd handle it.
    sed -i '/file_handler/d' lg.py lgproxy.py

    # Replace the builtin config file with one given through an
    # environment variable.
    sed -i '/app\.config\.from_pyfile/c app.config.from_envvar("BIRD_LG_CONFIG")' lg.py lgproxy.py
  '';
})
