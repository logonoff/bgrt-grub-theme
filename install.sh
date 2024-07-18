#! /usr/bin/env bash

THEME='bgrt-grub-theme'

# Pre-authorise sudo
sudo echo

# Detect existence of BGRT
if [[ ! -r /sys/firmware/acpi/bgrt/image ]]; then
	echo "Sorry, I can't read /sys/firmware/acpi/bgrt/image"
	echo "Exiting..."
	exit 1
fi

if [[ ! -r /sys/firmware/acpi/bgrt/xoffset ]]; then
	echo "Sorry, I can't read /sys/firmware/acpi/bgrt/xoffset"
	echo "Exiting..."
	exit 1
fi

if [[ ! -r /sys/firmware/acpi/bgrt/image ]]; then
	echo "Sorry, I can't read /sys/firmware/acpi/bgrt/yoffset"
	echo "Exiting..."
	exit 1
fi

# detect an instance of imagemagick to convert the BMP to GRUB-readable PNG
MAGICK='magick'

# Check if magick is installed
if ! command -v magick &> /dev/null
then
	if ! command -v convert &> /dev/null
	then
		echo "Could not find either magick or convert from ImageMagick. Please install it before running this script."
		exit 1
	else
		MAGICK='convert'
	fi
fi

# Detect distro and set GRUB location and update method
GRUB_DIR='grub'
UPDATE_GRUB=''

if [ -e /etc/os-release ]; then

	source /etc/os-release

	if [[ "$ID" =~ (debian|ubuntu|solus) || \
		  "$ID_LIKE" =~ (debian|ubuntu) ]]; then

		UPDATE_GRUB='update-grub'

	elif [[ "$ID" =~ (arch|manjaro|gentoo) || \
			"$ID_LIKE" =~ (archlinux|manjaro|gentoo) ]]; then

		UPDATE_GRUB='grub-mkconfig -o /boot/grub/grub.cfg'

	elif [[ "$ID" =~ (centos|fedora|opensuse) || \
			"$ID_LIKE" =~ (fedora|rhel|suse) ]]; then

		GRUB_CFG_PATH='/boot/grub2/grub.cfg'

		if [ -d /boot/efi/EFI/${ID} ]
		then
			GRUB_CFG_PATH="/boot/efi/EFI/${ID}/grub.cfg"
		fi

		# BLS etries have 'kernel' class, copy corresponding icon
		if [[ -d /boot/loader/entries && -e icons/${ID}.png ]]
		then
			cp icons/${ID}.png icons/kernel.png
		fi

		GRUB_DIR='grub2'
		UPDATE_GRUB="grub2-mkconfig -o ${GRUB_CFG_PATH}"
	fi
fi

echo 'Loading BGRT image'
sudo "$MAGICK" /sys/firmware/acpi/bgrt/image PNG24:./theme/bgrt.png

cp ./theme.txt ./theme/theme.txt
echo '' >> ./theme/theme.txt
echo '+ image {' >> ./theme/theme.txt
echo "    left = $(</sys/firmware/acpi/bgrt/xoffset)" >> ./theme/theme.txt
echo "    top  = $(</sys/firmware/acpi/bgrt/yoffset)" >> ./theme/theme.txt
echo '    file = "bgrt.png"' >> ./theme/theme.txt
echo '}' >> ./theme/theme.txt

echo 'Creating GRUB themes directory'
sudo mkdir -p /boot/${GRUB_DIR}/themes/${THEME}

echo 'Copying theme to GRUB themes directory'
sudo cp -r ./theme/* /boot/${GRUB_DIR}/themes/${THEME}

echo 'Removing other themes from GRUB config'
sudo sed -i '/^GRUB_THEME=/d' /etc/default/grub

echo 'Making sure GRUB uses graphical output'
sudo sed -i 's/^\(GRUB_TERMINAL\w*=.*\)/#\1/' /etc/default/grub

echo 'Removing empty lines at the end of GRUB config' # optional
sudo sed -i -e :a -e '/^\n*$/{$d;N;};/\n$/ba' /etc/default/grub

echo 'Adding new line to GRUB config just in case' # optional
echo | sudo tee -a /etc/default/grub

echo 'Adding theme to GRUB config'
echo "GRUB_THEME=/boot/${GRUB_DIR}/themes/${THEME}/theme.txt" | sudo tee -a /etc/default/grub

echo 'Updating GRUB'
if [[ $UPDATE_GRUB ]]; then
	eval sudo "$UPDATE_GRUB"
else
	echo   --------------------------------------------------------------------------------
	echo    Cannot detect your distro, you will need to run \`grub-mkconfig\` as root manually.
	echo
	echo    Common ways:
	echo    "- Debian, Ubuntu, Solus and derivatives: \`update-grub\` or \`grub-mkconfig -o /boot/grub/grub.cfg\`"
	echo    "- RHEL, CentOS, Fedora, SUSE and derivatives: \`grub2-mkconfig -o /boot/grub2/grub.cfg\`"
	echo    "- Arch, Gentoo and derivatives: \`grub-mkconfig -o /boot/grub/grub.cfg\`"
	echo    --------------------------------------------------------------------------------
fi

echo 'Cleaning up temporary files...'
sudo rm ./theme/theme.txt
sudo rm ./theme/bgrt.png
