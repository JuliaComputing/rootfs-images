using RootfsUtils: parse_build_args, upload_gha, test_sandbox
using RootfsUtils: debootstrap
using RootfsUtils: root_chroot

args         = parse_build_args(ARGS, @__FILE__)
arch         = args.arch
archive      = args.archive
image        = args.image

packages = [
    "bash",
    "build-essential",
    "cmake",
    "curl",
    "git",
    "less",
    "libtinfo5",
    "libx11-6",
    "locales",
    "localepurge",
    "ninja-build",
    "python3",
    "python3-pip",
    "python3-setuptools",
    "vim",
]

vivado_path = expanduser("~/vivado")

artifact_hash, tarball_path, = debootstrap(arch, image; archive, packages) do rootfs, chroot_ENV
    my_chroot(args...) = root_chroot(rootfs, "bash", "-eu", "-o", "pipefail", "-c", args...; ENV=chroot_ENV)

    my_chroot("""
    curl -L https://raw.githubusercontent.com/enjoy-digital/litex/master/litex_setup.py -o /usr/bin/litex_setup
    chmod +x /usr/bin/litex_setup

    # litex requires meson
    pip3 install meson

    # Install litex tools and RISC-V toolchain
    mkdir -p /usr/local/litex
    cd /usr/local/litex/
    litex_setup --tag=2022.04 --init --install --gcc=riscv 

    # Cleanup tarballs
    rm -f *.tar.gz

    # Symlink gcc tools into `/usr/local/bin`
    for f in riscv*/bin/*; do
      ln -vs "\$(realpath "\${f}")" "/usr/local/bin/\$(basename "\${f}")"
    done

    # chmod /usr/local so that we can write in the vivado tools
    chmod 777 /usr/local
    """)

    # Next, install vivado, then revert the permissions of /usr/local
    cp(vivado_path, joinpath(rootfs, "usr", "local", "vivado"))
    my_chroot("""
    chmod 755 /usr/local

    # Symlink vivado tools into `/usr/local/bin`
    for tool in vivado; do
      TOOL_PATH="\$(realpath /usr/local/vivado/Vivado/*/bin/\${tool})"
      ln -vs "\${TOOL_PATH}" "/usr/local/bin/\${tool}"
    done
    """)
end

upload_gha(tarball_path)
test_sandbox(artifact_hash)
