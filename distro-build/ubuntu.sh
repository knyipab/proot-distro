dist_name="Ubuntu"
dist_version="jammy"


bootstrap_distribution() {
	sudo rm -f "${ROOTFS_DIR}"/ubuntu-*.tar.xz

	for arch in arm64 armhf amd64; do
		sudo rm -rf "${WORKDIR}/ubuntu-$(translate_arch "$arch")"
		sudo mmdebstrap \
			--architectures=${arch} \
			--variant=apt \
			--components="main,universe,multiverse" \
			--include="locales,passwd" \
			--format=directory \
			"${dist_version}" \
			"${WORKDIR}/ubuntu-$(translate_arch "$arch")"
		archive_rootfs "${ROOTFS_DIR}/ubuntu-$(translate_arch "$arch")-pd-${CURRENT_VERSION}.tar.xz" \
			"ubuntu-$(translate_arch "$arch")"
	done
	unset arch
}

write_plugin() {
	cat <<- EOF > "${PLUGIN_DIR}/ubuntu.sh"
	# This is a default distribution plug-in.
	# Do not modify this file as your changes will be overwritten on next update.
	# If you want customize installation, please make a copy.
	DISTRO_NAME="Ubuntu"
	DISTRO_COMMENT="Standard release (${dist_version}). Not available for x86 32-bit (i686) CPUs."

	TARBALL_URL['aarch64']="${GIT_RELEASE_URL}/ubuntu-aarch64-pd-${CURRENT_VERSION}.tar.xz"
	TARBALL_SHA256['aarch64']="$(sha256sum "${ROOTFS_DIR}/ubuntu-aarch64-pd-${CURRENT_VERSION}.tar.xz" | awk '{ print $1}')"
	TARBALL_URL['arm']="${GIT_RELEASE_URL}/ubuntu-arm-pd-${CURRENT_VERSION}.tar.xz"
	TARBALL_SHA256['arm']="$(sha256sum "${ROOTFS_DIR}/ubuntu-arm-pd-${CURRENT_VERSION}.tar.xz" | awk '{ print $1}')"
	TARBALL_URL['x86_64']="${GIT_RELEASE_URL}/ubuntu-x86_64-pd-${CURRENT_VERSION}.tar.xz"
	TARBALL_SHA256['x86_64']="$(sha256sum "${ROOTFS_DIR}/ubuntu-x86_64-pd-${CURRENT_VERSION}.tar.xz" | awk '{ print $1}')"

	distro_setup() {
	${TAB}# Configure en_US.UTF-8 locale.
	${TAB}sed -i -E 's/#[[:space:]]?(en_US.UTF-8[[:space:]]+UTF-8)/\1/g' ./etc/locale.gen
	${TAB}run_proot_cmd DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales
	}
	EOF
}
