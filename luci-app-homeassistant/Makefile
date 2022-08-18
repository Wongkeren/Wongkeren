

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-homeassistant

LUCI_TITLE:=LuCI support for homeassistant
LUCI_PKGARCH:=all
LUCI_DEPENDS:=@(aarch64||arm||x86_64) +luci-app-dockerman +luci-lib-iform

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature


