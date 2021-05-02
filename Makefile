include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI support for ApFree WifiDog
LUCI_DEPENDS:=+apfree-wifidog
LUCI_PKGARCH:=all

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
