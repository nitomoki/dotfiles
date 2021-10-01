sudo pacman -S --needed base-devel
mkdir -p ~/pacman_aur
cd ~/pacman_aur
git clone https://aur.archlinux.org/aurman.git
makepkg -si
cd ~/

