## BGRT GRUB2 Theme

Theme based on [grub2-deadpool-theme](https://github.com/bishwassagar/grub2-deadpool-theme) with a background designed to look seamlesss with your motherboard boot logo.

### Screenshots

![BGRT GRUB Theme on a Framework Laptop](https://i.imgur.com/mYg5mI6.png)

### Installation/Update

#### Install GRUB theme

```sh
git clone https://github.com/logonoff/bgrt-grub-theme.git
cd bgrt-grub-theme
chmod 755 install.sh
sudo ./install.sh
cd ..
rm -r bgrt-grub-theme
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
