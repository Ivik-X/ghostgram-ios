
config_setting(
	name = "ios_sim_arm64",
	values = {"cpu": "ios_sim_arm64"},
)

config_setting(
    name = "linux_arm64",
    constraint_values = [
        "@platforms//os:linux",
        "@platforms//cpu:aarch64",
    ],
)

config_setting(
    name = "linux_x86_64",
    constraint_values = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
)

exports_files([
    "GenerateStrings/GenerateStrings.py",
])

xcode_version(
    name = "xcode_version",
    version = "26.2",
    default_ios_sdk_version = "18.0",
    default_macos_sdk_version = "14.5",
    default_tvos_sdk_version = "18.0",
    default_watchos_sdk_version = "11.0",
)

xcode_config(
    name = "host_xcodes",
    versions = [":xcode_version"],
    default = ":xcode_version",
)

