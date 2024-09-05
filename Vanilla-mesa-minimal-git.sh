#!/bin/bash
# Function to handle cleanup when script exits or is interrupted
cleanup() {
    echo "Cleaning up..."
    kill $SUDO_REFRESH_PID 2>/dev/null  # Terminate sudo refresh background process
    echo "Exiting script..."
    exit 1
}
# Trap Ctrl+C and call cleanup function
trap cleanup INT
# Ask for sudo password at the beginning of the script
sudo -v
# Start a background process to refresh sudo and prevent being asked for password twice
( while true; do sudo -v; sleep 270; done ) &  # Refresh every 4.5 minutes
SUDO_REFRESH_PID=$!  # Save the PID of the background process
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
sudo makechrootpkg -c -r "$CHROOT" -- --nocheck
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
sudo makechrootpkg -c -r "$CHROOT" -I llvm-minimal-git-*.pkg.tar.zst -I llvm-libs-minimal-git*.pkg.tar.zst -I clang-libs-minimal-git-*.pkg.tar.zst -I clang-minimal-git-*.pkg.tar.zst -I clang-opencl-headers-minimal-git-*.pkg.tar.zst -- --nocheck
# Check the exit status of makechrootpkg command 1
if [ $? -ne 0 ]; then
    echo "makechrootpkg command 1 failed. Exiting script."
    exit 1
fi
# Move compiled to spirv-llvm-translator-minimal-git
mv *.pkg.tar.zst "/home/$USER/mesa-minimal-git/spirv-llvm-translator-minimal-git/"
# Make spirv-llvm-translator-minimal-git
cd /home/$USER/mesa-minimal-git/spirv-llvm-translator-minimal-git
sudo makechrootpkg -c -r "$CHROOT" -I llvm-minimal-git-*.pkg.tar.zst -I llvm-libs-minimal-git*.pkg.tar.zst -I clang-libs-minimal-git-*.pkg.tar.zst -I clang-minimal-git-*.pkg.tar.zst -I clang-opencl-headers-minimal-git-*.pkg.tar.zst
# Check the exit status of makechrootpkg command 1
if [ $? -ne 0 ]; then
    echo "makechrootpkg command 1 failed. Exiting script."
    exit 1
fi
# Move compild to lib32-spirv-llvm-translator-minimal-git
mv *.pkg.tar.zst "/home/$USER/mesa-minimal-git/lib32-spirv-llvm-translator-minimal-git"
# Make lib32-spirv-llvm-translator-minimal-git
cd /home/$USER/mesa-minimal-git/lib32-spirv-llvm-translator-minimal-git
sudo makechrootpkg -c -r "$CHROOT" -I llvm-minimal-git-*.pkg.tar.zst -I llvm-libs-minimal-git*.pkg.tar.zst -I clang-libs-minimal-git-*.pkg.tar.zst -I clang-minimal-git-*.pkg.tar.zst -I clang-opencl-headers-minimal-git-*.pkg.tar.zst -I lib32-llvm-libs-minimal-git-*.pkg.tar.zst -I lib32-llvm-minimal-git-*.pkg.tar.zst -I lib32-clang-libs-minimal-git-*.pkg.tar.zst -I lib32-clang-minimal-git-*.pkg.tar.zst -I spirv-llvm-translator-minimal-git-*.pkg.tar.zst
# Check the exit status of makechrootpkg command 1
if [ $? -ne 0 ]; then
    echo "makechrootpkg command 1 failed. Exiting script."
    exit 1
fi
# Move compiled to libclc-minimal-git
mv *.pkg.tar.zst "/home/$USER/mesa-minimal-git/libclc-minimal-git/"
# Make libclc-minimal-git
cd /home/$USER/mesa-minimal-git/libclc-minimal-git
sudo makechrootpkg -c -r "$CHROOT" -I llvm-minimal-git-*.pkg.tar.zst -I llvm-libs-minimal-git*.pkg.tar.zst -I clang-libs-minimal-git-*.pkg.tar.zst -I clang-minimal-git-*.pkg.tar.zst -I clang-opencl-headers-minimal-git-*.pkg.tar.zst -I spirv-llvm-translator-minimal-git-*.pkg.tar.zst
# Check the exit status of makechrootpkg command 1
if [ $? -ne 0 ]; then
    echo "makechrootpkg command 1 failed. Exiting script."
    exit 1
fi
# Move compiled to mesa-minimal-git
mv *.pkg.tar.zst "/home/$USER/mesa-minimal-git/mesa-minimal-git/"
# Make mesa-minimal-git
cd /home/$USER/mesa-minimal-git/mesa-minimal-git
sudo makechrootpkg -c -r "$CHROOT" -I llvm-minimal-git-*.pkg.tar.zst -I llvm-libs-minimal-git*.pkg.tar.zst -I clang-libs-minimal-git-*.pkg.tar.zst -I clang-minimal-git-*.pkg.tar.zst -I clang-opencl-headers-minimal-git-*.pkg.tar.zst -I spirv-llvm-translator-minimal-git-*.pkg.tar.zst -I libclc-minimal-git-*.pkg.tar.zst
# Check the exit status of makechrootpkg command 1
if [ $? -ne 0 ]; then
    echo "makechrootpkg command 1 failed. Exiting script."
    exit 1
fi
# Move compiled to lib32-mesa-minimal-git
mv *.pkg.tar.zst "/home/$USER/mesa-minimal-git/lib32-mesa-minimal-git/"
# Make lib32-mesa-minimal-git
cd /home/$USER/mesa-minimal-git/lib32-mesa-minimal-git
sudo makechrootpkg -c -r "$CHROOT" -I llvm-minimal-git-*.pkg.tar.zst -I llvm-libs-minimal-git*.pkg.tar.zst -I clang-libs-minimal-git-*.pkg.tar.zst -I clang-minimal-git-*.pkg.tar.zst -I clang-opencl-headers-minimal-git-*.pkg.tar.zst -I lib32-llvm-libs-minimal-git-*.pkg.tar.zst -I lib32-llvm-minimal-git-*.pkg.tar.zst -I lib32-clang-libs-minimal-git-*.pkg.tar.zst -I lib32-clang-minimal-git-*.pkg.tar.zst -I lib32-clang-opencl-headers-minimal-git-*.pkg.tar.zst -I spirv-llvm-translator-minimal-git-*.pkg.tar.zst -I lib32-spirv-llvm-translator-minimal-git-*.pkg.tar.zst -I libclc-minimal-git-*.pkg.tar.zst -I mesa-minimal-git-*.pkg.tar.zst
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
# Ask if the user wants to install the packages now
read -p "Do you want to install the packages now? (Y/n): " install_packages
if [[ "$install_packages" =~ ^[Yy]$ ]]; then
    sudo pacman -Syu  # Use sudo for the installation command
else
    echo "Installation skipped."
fi
# Cleanup: Kill the sudo refresher process
kill $SUDO_REFRESH_PID 2>/dev/null  # Ensure the refresher is terminated
# Final message
echo "Script finished. Exiting."
exit 0






