using RootfsUtils: parse_build_args, upload_gha, test_sandbox
using RootfsUtils: debootstrap
using RootfsUtils: root_chroot

args         = parse_build_args(ARGS, @__FILE__)
arch         = args.arch
archive      = args.archive
image        = args.image

packages = [
    "automake",
    "bash",
    "bc",
    "build-essential",
    "bison",
    "cmake",
    "curl",
    "flex",
    "git",
    "less",
    "libglib2.0-dev",
    "libelf-dev",
    "libssl-dev",
    "libtool",
    "libudev-dev",
    "locales",
    "localepurge",
    "rsync",
    "python3",
    "vim",
]

artifact_hash, tarball_path, = debootstrap(arch, image; archive, packages, release="bullseye")

upload_gha(tarball_path)
test_sandbox(artifact_hash)
