#!/bin/bash
# Function to handle Ctrl+C
cleanup() {
    echo "Exiting script..."
    exit 1
}
# Trap Ctrl+C and call cleanup function
trap cleanup INT
# Function to run commands with sudo without password prompt
run_with_sudo() {
    local command="$1"
    shift
    sudo -S <<< "$SUDO_PASSWORD" "$command" "$@"
}

# Ask for the user's password if not already set
if [ -z "$SUDO_PASSWORD" ]; then
    read -sp "Enter your password: " SUDO_PASSWORD
    echo  # Move to a new line after password input
fi
# Make directory where we will do our work
mkdir /home/$USER/mesa-minimal-git
cd /home/$USER/mesa-minimal-git
# Create "Packages" directory where at the end all compiled packages will be placed
mkdir Built-Packages
# Clone the Git repositories
git clone https://aur.archlinux.org/llvm-minimal-git.git
git clone https://aur.archlinux.org/lib32-llvm-minimal-git.git
git clone https://aur.archlinux.org/spirv-llvm-translator-minimal-git.git
git clone https://aur.archlinux.org/libclc-minimal-git.git
git clone https://aur.archlinux.org/mesa-minimal-git.git
git clone https://aur.archlinux.org/lib32-mesa-minimal-git.git
git clone https://aur.archlinux.org/lib32-spirv-llvm-translator-minimal-git.git
cd /home/$USER/mesa-minimal-git
arch-nspawn "$CHROOT/root" pacman -Syu --noconfirm
# Move compiled to spirv-llvm-translator-minimal-git
mv *.pkg.tar.zst "/home/$USER/mesa-minimal-git/spirv-llvm-translator-minimal-git/"
# Make llvm-minimal-git
cd /home/$USER/mesa-minimal-git/llvm-minimal-git
run_with_sudo makechrootpkg -c -r "$CHROOT" -- --nocheck
# Check the exit status of makechrootpkg command 1
if [ $? -ne 0 ]; then
    echo "makechrootpkg command 1 failed. Exiting script."
    exit 1
fi
# Move the generated packages to lib32-llvm-minimal-git
mv *.pkg.tar.zst "/home/$USER/mesa-minimal-git/lib32-llvm-minimal-git/"
# Build lib32-llvm-minimal in its folder
cd /home/$USER/mesa-minimal-git/lib32-llvm-minimal-git
# Edit PKGBUILD to disable the check function
run_with_sudo makechrootpkg -c -r "$CHROOT" -I llvm-minimal-git-*.pkg.tar.zst -I llvm-libs-minimal-git*.pkg.tar.zst -I clang-libs-minimal-git-*.pkg.tar.zst -I clang-minimal-git-*.pkg.tar.zst -I clang-opencl-headers-minimal-git-*.pkg.tar.zst -- --nocheck
# Check the exit status of makechrootpkg command 1
if [ $? -ne 0 ]; then
    echo "makechrootpkg command 1 failed. Exiting script."
    exit 1
fi
# Move compiled to spirv-llvm-translator-minimal-git
mv *.pkg.tar.zst "/home/$USER/mesa-minimal-git/spirv-llvm-translator-minimal-git/"
# Make spirv-llvm-translator-minimal-git
cd /home/$USER/mesa-minimal-git/spirv-llvm-translator-minimal-git
run_with_sudo makechrootpkg -c -r "$CHROOT" -I llvm-minimal-git-*.pkg.tar.zst -I llvm-libs-minimal-git*.pkg.tar.zst -I clang-libs-minimal-git-*.pkg.tar.zst -I clang-minimal-git-*.pkg.tar.zst -I clang-opencl-headers-minimal-git-*.pkg.tar.zst
# Check the exit status of makechrootpkg command 1
if [ $? -ne 0 ]; then
    echo "makechrootpkg command 1 failed. Exiting script."
    exit 1
fi
# Move compild to lib32-spirv-llvm-translator-minimal-git
mv *.pkg.tar.zst "/home/$USER/mesa-minimal-git/lib32-spirv-llvm-translator-minimal-git"
# Make lib32-spirv-llvm-translator-minimal-git
cd /home/$USER/mesa-minimal-git/lib32-spirv-llvm-translator-minimal-git
run_with_sudo makechrootpkg -c -r "$CHROOT" -I llvm-minimal-git-*.pkg.tar.zst -I llvm-libs-minimal-git*.pkg.tar.zst -I clang-libs-minimal-git-*.pkg.tar.zst -I clang-minimal-git-*.pkg.tar.zst -I clang-opencl-headers-minimal-git-*.pkg.tar.zst -I lib32-llvm-libs-minimal-git-*.pkg.tar.zst -I lib32-llvm-minimal-git-*.pkg.tar.zst -I lib32-clang-libs-minimal-git-*.pkg.tar.zst -I lib32-clang-minimal-git-*.pkg.tar.zst -I spirv-llvm-translator-minimal-git-*.pkg.tar.zst
# Check the exit status of makechrootpkg command 1
if [ $? -ne 0 ]; then
    echo "makechrootpkg command 1 failed. Exiting script."
    exit 1
fi
# Move compiled to libclc-minimal-git
mv *.pkg.tar.zst "/home/$USER/mesa-minimal-git/libclc-minimal-git/"
# Make libclc-minimal-git
cd /home/$USER/mesa-minimal-git/libclc-minimal-git
run_with_sudo makechrootpkg -c -r "$CHROOT" -I llvm-minimal-git-*.pkg.tar.zst -I llvm-libs-minimal-git*.pkg.tar.zst -I clang-libs-minimal-git-*.pkg.tar.zst -I clang-minimal-git-*.pkg.tar.zst -I clang-opencl-headers-minimal-git-*.pkg.tar.zst -I spirv-llvm-translator-minimal-git-*.pkg.tar.zst
# Check the exit status of makechrootpkg command 1
if [ $? -ne 0 ]; then
    echo "makechrootpkg command 1 failed. Exiting script."
    exit 1
fi
# Move compiled to mesa-minimal-git
mv *.pkg.tar.zst "/home/$USER/mesa-minimal-git/mesa-minimal-git/"
# Make mesa-minimal-git
cd /home/$USER/mesa-minimal-git/mesa-minimal-git
# Edit pkgbuild to compile only needed AMD components
sed -i 's/-D gallium-drivers=[^ ]* \\$/-D gallium-drivers=radeonsi \\/' PKGBUILD
sed -i 's/-D vulkan-drivers=[^ ]* \\$/-D vulkan-drivers=amd,swrast \\/' PKGBUILD
run_with_sudo makechrootpkg -c -r "$CHROOT" -I llvm-minimal-git-*.pkg.tar.zst -I llvm-libs-minimal-git*.pkg.tar.zst -I clang-libs-minimal-git-*.pkg.tar.zst -I clang-minimal-git-*.pkg.tar.zst -I clang-opencl-headers-minimal-git-*.pkg.tar.zst -I spirv-llvm-translator-minimal-git-*.pkg.tar.zst -I libclc-minimal-git-*.pkg.tar.zst
# Check the exit status of makechrootpkg command 1
if [ $? -ne 0 ]; then
    echo "makechrootpkg command 1 failed. Exiting script."
    exit 1
fi
# Move compiled to lib32-mesa-minimal-git
mv *.pkg.tar.zst "/home/$USER/mesa-minimal-git/lib32-mesa-minimal-git/"
# Make lib32-mesa-minimal-git
cd /home/$USER/mesa-minimal-git/lib32-mesa-minimal-git
# Edit pkgbuild to compile only needed AMD components
sed -i 's/-D gallium-drivers=[^ ]* \\$/-D gallium-drivers=radeonsi \\/' PKGBUILD
sed -i 's/-D vulkan-drivers=[^ ]* \\$/-D vulkan-drivers=amd,swrast \\/' PKGBUILD
run_with_sudo makechrootpkg -c -r "$CHROOT" -I llvm-minimal-git-*.pkg.tar.zst -I llvm-libs-minimal-git*.pkg.tar.zst -I clang-libs-minimal-git-*.pkg.tar.zst -I clang-minimal-git-*.pkg.tar.zst -I clang-opencl-headers-minimal-git-*.pkg.tar.zst -I lib32-llvm-libs-minimal-git-*.pkg.tar.zst -I lib32-llvm-minimal-git-*.pkg.tar.zst -I lib32-clang-libs-minimal-git-*.pkg.tar.zst -I lib32-clang-minimal-git-*.pkg.tar.zst -I lib32-clang-opencl-headers-minimal-git-*.pkg.tar.zst -I spirv-llvm-translator-minimal-git-*.pkg.tar.zst -I lib32-spirv-llvm-translator-minimal-git-*.pkg.tar.zst -I libclc-minimal-git-*.pkg.tar.zst -I mesa-minimal-git-*.pkg.tar.zst
# Check the exit status of makechrootpkg command 1
if [ $? -ne 0 ]; then
    echo "makechrootpkg command 1 failed. Exiting script."
    exit 1
fi
# Move compiled to Built-Packages
mv *.pkg.tar.zst /home/$USER/mesa-minimal-git/Built-Packages
# Install
cd /home/$USER/mesa-minimal-git/Built-Packages
# Step 1: Remove the existing folder
rm -rf /home/$USER/Documents/MAKE/repo-mesa-minimal-git
# Step 2: Recreate the folder
mkdir -p /home/$USER/Documents/MAKE/repo-mesa-minimal-git
# Step 3: Move *.pkg.tar.zst files to the repo folder
mv /home/$USER/mesa-minimal-git/Built-Packages/*.pkg.tar.zst /home/$USER/Documents/MAKE/repo-mesa-minimal-git/
# Make repo
repo-add -n /home/$USER/Documents/MAKE/repo-mesa-minimal-git/mesa-minimal-git.db.tar.gz /home/$USER/Documents/MAKE/repo-mesa-minimal-git/*.pkg.tar.zst
# Step 4: Create a folder with the current date
current_date=$(date +%Y-%m-%d)
target_folder="/home/$USER/Documents/MAKE/mesa-minimal-git-$current_date"
mkdir -p "$target_folder"
# Step 5: Copy *.pkg.tar.zst files to the created folder
cp /home/$USER/Documents/MAKE/repo-mesa-minimal-git/*.pkg.tar.zst "$target_folder"
echo "Packages copied to: $target_folder"
# Ask if the user wants to delete the mesa-minimal-git folder
read -p "Do you want to delete the mesa-minimal-git folder? (Y/n): " delete_folder
if [[ "$delete_folder" =~ ^[Yy]$ ]]; then
    rm -rf /home/$USER/mesa-minimal-git
    echo "mesa-minimal-git folder deleted."
fi
# Ask if the user wants to install
read -p "Do you want to install the packages now? (Y/n): " install_packages
if [[ "$install_packages" =~ ^[Yy]$ ]]; then
    sudo pacman -Syu
else
    echo "Installation skipped."
    exit 0
fi






