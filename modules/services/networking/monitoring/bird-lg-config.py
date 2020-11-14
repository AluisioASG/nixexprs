# Put everything inside a function to avoid polluting the script's
# global namespace.
def _config_loader_main():
    import json
    import os
    for filename in os.environ.get("BIRD_LG_CONFIG_FILES", "").split(os.pathsep):
        with open(filename, "r") as file:
            config = json.load(file)
            globals().update(config)
_config_loader_main()
