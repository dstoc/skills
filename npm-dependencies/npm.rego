package sandbox.npm

# Match only the npm executable supplied by the trusted Node image.
# Adjust this path if npm is installed elsewhere.
expected_path := "/usr/local/bin/npm"

# Gantry evaluates only caller-forwarded environment variables here.
# Reject missing, changed, or additional forwarded variables.
required_env := {
    "NPM_CONFIG_IGNORE_SCRIPTS": "true",
    "NPM_CONFIG_ALLOW_GIT": "none",
    "NPM_CONFIG_ALLOW_REMOTE": "none",
    "NPM_CONFIG_ALLOW_FILE": "none",
    "NPM_CONFIG_ALLOW_DIRECTORY": "none",
    "NPM_CONFIG_MIN_RELEASE_AGE": "7",
    "NPM_CONFIG_STRICT_NPMRC": "true",
}

default allow := false
default allow_env := false

allow_env if {
    input.env == required_env
}

allow if {
    input.command == "npm"
    input.path == expected_path
    allow_env
    allowed_args
}

# npm install
allowed_args if {
    input.args == ["install"]
}

# npm install -- <package-spec>
allowed_args if {
    count(input.args) == 3
    input.args[0] == "install"
    input.args[1] == "--"
    valid_package_spec(input.args[2])
}

# npm install --save-dev -- <package-spec>
allowed_args if {
    count(input.args) == 4
    input.args[0] == "install"
    input.args[1] == "--save-dev"
    input.args[2] == "--"
    valid_package_spec(input.args[3])
}

# npm install --save -- <package-spec>
allowed_args if {
    count(input.args) == 4
    input.args[0] == "install"
    input.args[1] == "--save"
    input.args[2] == "--"
    valid_package_spec(input.args[3])
}

# One nonempty positional operand, not an option.
# npm itself interprets the spec.
valid_package_spec(spec) if {
    count(spec) > 0
    not startswith(spec, "-")
}
