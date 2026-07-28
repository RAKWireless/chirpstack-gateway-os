# Board identity helpers for the RAK7392.
#
# `eth0` is not a fixed concept on this board — the 2.5G WAN (r8125), both 1G
# LAN ports (r8169) and a hot-plugged mioty EdgeCard all compete for kernel
# names. Identity therefore anchors on the CM4-native GbE (bcmgenet), whose MAC
# comes from the module OTP: stable by construction, independent of PCIe
# enumeration and preserved across concentrator swaps.

# Space-separated list of netdevs bound to any of the drivers named in $@;
# empty if there are none.
rak_netdev_by_driver() {
	local dev drv want out=""

	for dev in /sys/class/net/*; do
		[ -L "$dev/device/driver" ] || continue
		drv=$(readlink "$dev/device/driver")
		for want in "$@"; do
			[ "${drv##*/}" = "$want" ] || continue
			out="${out:+$out }${dev##*/}"
			break
		done
	done

	echo "$out"
}

# MAC of the CM4-native GbE, lowercase colon-separated. Falls back to wlan0.
rak_identity_mac() {
	local dev

	dev=$(rak_netdev_by_driver bcmgenet)
	dev="${dev%% *}"

	if [ -n "$dev" ]; then
		cat "/sys/class/net/$dev/address"
		return 0
	fi

	logger -t rak-identity "warning: no bcmgenet netdev found, falling back to wlan0 MAC"
	cat /sys/class/net/wlan0/address 2>/dev/null
}

# Trailing 3 bytes of the identity MAC, lowercase hex, no separators.
rak_identity_gwid_end() {
	rak_identity_mac | awk -F\: '{print $4$5$6}'
}
