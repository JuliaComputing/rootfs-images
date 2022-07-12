using RootfsUtils: parse_build_args, upload_gha, test_sandbox
using RootfsUtils: debootstrap
using RootfsUtils: root_chroot

args         = parse_build_args(ARGS, @__FILE__)
arch         = args.arch
archive      = args.archive
image        = args.image

packages = [
    "bash",
    "bc",
    "build-essential",
    "bison",
    "cmake",
    "curl",
    "flex",
    "git",
    "less",
    "libelf-dev",
    "libssl-dev",
    "locales",
    "localepurge",
    "rsync",
    "python",
    "python3",
    "vim",
]

artifact_hash, tarball_path, = debootstrap(arch, image; archive, packages)

upload_gha(tarball_path)
test_sandbox(artifact_hash)
