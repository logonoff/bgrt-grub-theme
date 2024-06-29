## GRUB2 Theme for Framework 13 (2.2k screen)

Theme based on [grub2-deadpool-theme](https://github.com/bishwassagar/grub2-deadpool-theme) with a background designed to look seamlesss with the boot logo of the Framework Laptop 13 (original or matte display)

### Screenshots

![Framework GRUB Theme](https://i.imgur.com/mYg5mI6.png)

### Installation/Update

#### Install GRUB theme

```sh
git clone https://github.com/logonoff/framework-13-grub-theme.git
cd framework-13-grub-theme
chmod 755 install.sh
sudo ./install.sh
cd ..
rm -r framework-13-grub-theme
```

#### (Optional) enable custom EFI firmware icon
Tested on Fedora 40. Apply the following diff to `/etc/grub.d/30_uefi-firmware`:

```diff
<   menuentry '$LABEL' \$menuentry_id_option 'uefi-firmware' {
---
>   menuentry '$LABEL' --class efi \$menuentry_id_option 'uefi-firmware' {
```
Then update GRUB:

```sh
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```

#### Done!!!
