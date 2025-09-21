# Tor on Fedora CoreOS (secureblue)

```
qemu-img create -f qcow2 tor-fedora.qcow2 100G

qemu-system-x86_64 -m 8096 -smp 2 -accel tcg,thread=multi -vga virtio -device qemu-xhci -device usb-kbd -device usb-tablet -nic user,model=virtio-net-pci -drive if=virtio,id=system,format=qcow2,file=.\tor-fedora.qcow2 -cdrom .\qemu\fedora-coreos-42.20250803.3.0-live-iso.x86_64.iso

sudo coreos-installer install /dev/vda \
    --ignition-url https://github.com/cozybear-dev/tor-fedora/releases/download/commit-fe2048fb53e1ce22962d408643f8edf1c6192312/template.ign

sudo curl -s https://pastebin.com/raw/ | sudo bash


Seperate container (core user pass hash);
docker run -ti --rm quay.io/coreos/mkpasswd --method=yescrypt

In container (grub pass hash);
grub-mkpasswd-pbkdf2

Butane config validation;
docker run --rm  -v ./template.butane:/template.butane -i quay.io/coreos/butane:latest /template.butane
```