# Nifty-router rootfs generator

Generates a root filesystem for a linux router running on a Kerio NG300.

## Building

```
git clone --recurse-submodules https://github.com/niftyprojects/ng300_router.git
cd ng300_router
make nifty_ng300_defconfig
make all
```

See [Building a router for home](https://niftyprojects.net/2021/building-a-router-for-home.html) for implementation and deployment details.

