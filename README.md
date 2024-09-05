
# mesa-minimal-git builder script / helper

Building [mesa-git](https://aur.archlinux.org/packages/mesa-git)/[mesa-minimal-git](https://aur.archlinux.org/packages/mesa-minimal-git) on Arch is suggested to be done manually rather than using an AUR helper. You should start by reading the pinned comments at the AUR page for mesa-git. You will get the idea why it is being done this way.

Here I will provide you with an automated script that fallows the AUR steps for compiling mesa-minimal-git,  but before you run it you will have to set a few things explained in the steps bellow.

A [clean chroot](https://wiki.archlinux.org/title/DeveloperWiki:Building_in_a_clean_chroot) has to be configured, and a [local repository for pacman](https://wiki.archlinux.org/title/Pacman/Tips_and_tricks#Custom_local_repository) should be made. 
Before running this script you will need (**only once!**) to set the **chroot** and the **local repo**. The first two steps here will explain doing just that.

I will be providing two scripts. One compiles mesa-minimal-git as is. The other will compile only the drivers for AMD-GPUs.



## Why mesa-minimal-git

Will paraphrase the AUR page for mesa-minimal-git - it's reason to exist is for the sake of performance and not compiling components that one wont normally need. 
The majority of mesa's components are of no use to me. Even better, the less components we compile, the lesser change for a build failure.


## Setting up chroot

The chroot is like a mini Arch install. We will be building the packages in it.
> Building in a clean chroot prevents missing dependencies in packages,
> whether due to unwanted linking or packages missing in the depends
> array in the PKGBUILD.

> The [devtools](https://archlinux.org/packages/?name=devtools) package
> provides tools for creating and building within clean chroots. Install
> it if not done already.

> To make a clean chroot, create a directory in which the chroot will
> reside. For example, `$HOME/chroot`.

Now here the Arch wiki has us creating the folder of the chroot in our home folder. We will call the folder **`.chroot`** instead of **`chroot`** to have it hidden.

 `mkdir ~/.chroot`

 Define the `CHROOT` variable:

 `$ CHROOT=$HOME/.chroot`
 Now create the chroot
`$ mkarchroot $CHROOT/root base-devel`

Define the `CHROOT` variable in `$HOME/.bashrc`. Put `export CHROOT=$HOME/.chroot` in it and reboot / log-out.

Adjust the mirrorlist in `$CHROOT/root/etc/pacman.d/mirrorlist` and enable the [multilib] repo.
 `$ nano $CHROOT/root/etc/pacman.conf`

 While we are here, lets edit makepkg to make sure it doesn't build us debug packages (judging by you reading this guide, you won't need them :P)
`$ sudo nano $CHROOT/root/etc/makepkg.conf`
Search for **!debug**

A bit below it you will see `OPTIONS=(strip docs !libtool !staticlibs emptydirs zipman purge debug lto)` , put an **!** before **debug** :

`OPTIONS=(strip docs !libtool !staticlibs emptydirs zipman purge !debug lto)`

While still here, search for `MAKEFLAGS` and make it `MAKEFLAGS="-j$(nproc)"`.
P.S. to searh in `nano` - `ctrl` + `W`


## Creating local repository

All you need to do is edit **/etc/pacman.conf**. Our repo will be named **repo-mesa-minimal-git**.
Edit ending of **pacman.conf** to resemble:

    # An example of a custom package repository. See the pacman manpage for
    # tips on creating your own repositories.
    [mesa-minimal-git]
    SigLevel = Optional TrustAll
    Server = file:///home/YOUR-USER-NAME/Documents/MAKE/repo-mesa-minimal-git/

Change `YOUR-USER-NAME` to your username.
Needs to be done only once.
## Why a local repository?
More packages could be compiled than needed to get installed. The local repo lets pacman install only what is needed.

## Now, what this script do?

 - It's a fairly simple script. It will make a directory under your home
   folder - **`mesa-minimal-git`**.

 - The script will pull from AUR what is needed for mesa-minimal-git to
   compile. It will start building in the correct build order.
 - Tests after compilation of llvm-minimal-git and lib32-llvm-minimal-git will get skipped to save time.

 - After all is build, it will ask to create some folders under
   `/home/$USER/Documents/MAKE/` .

    - There it will make a folder with the date in it's name with the current compiled packages after a successful compile.

      That is being done for archival purposes. The script doesn't delete old folders, you do when you want to.
   
    - Will also copy all the packages to `/home/$USER/Documents/MAKE/repo-mesa-minimal-git/`
      which you guessed it, is where the packages of our **local repo** are located.
   
    - In `repo-mesa-minimal-git/` the latest build packages will get stored and a few database files for the repo.
   
   
 - Script will update the local repo by calling:
   
   `repo-add -n /home/$USER/Documents/MAKE/repo-mesa-minimal-git/mesa-minimal-git.db.tar.gz /home/$USER/Documents/MAKE/repo-mesa-minimal-git/*.pkg.tar.zst`

   That updates the database files of the repo.

 - If you need to rollback, delete **only** the packages (`.pkg.tar.zst`) in the folder `repo-mesa-minimal-git`, run the above `repo-add` line and do a **pacman -Syyu**

 - After that it will call a `pacman -Syu`

  - **!** If you are running the script for the first time the **pacman -Syu** won't install mesa-minimal-git. You will have to  `pacman -S mesa-minimal-git lib32-mesa-minimal-git` **!**

# The AMD script
From all the compomemts we will be compiling `gallium-drivers=radeonsi,zink` and `vulkan-drivers=amd,swrast`. Now, `radeonsi` and `amd` are absolutely requiered! I keep `swrast` as a fallback. You are better off leaving `zink` in the mix too, although I skip compiling it at this time.

I really see no point in compiling Intel GPU drivers as I have only an AMD GPU in my system.
On the other hand for Intel you can only compile `iris`, `intel` and probably `swrast` only. If you don't plan to virtualize the installation, `virgl` is not needed.
## Running it

Make sure it's executable (from your file manager or **chmod +x filename.sh** ) and run it in a terminal. Should be automated. If it fails, well probably some new commit got made. I just share my script, if I fix it for myself, it will get fixed for you too.

## Disclaimer

I don't maintain the build scripts at AUR. The idea of this script is for me to automate the process as much as possible for myself. 
No responsibility will be taken! 
You should have a very good understanding why we are compiling these components and be able to troubleshoot by yourself. 
This is not an AUR helper where you just mash Enter and hope for the best!

If you experiance a built failure of some components, say `llvm-minimal-git` or be it `lib32-mesa-minimal-git`, you could copy the error code and report it to said AUR page.

Again, you should be able to troubleshoot the script youself.


You should be able to see in `PKGBUILDs`the required build packages, steps in the compilation and be able to do minor fixes on your own. 
After having a look at the `PKGBUILDs` you should have a nice understanding of wtich gets compiled, in what order, with what dependancies, what should get linked to it to compile.

Only Arch is supported, Arch derivatives are **NOT**!

