#!/usr/bin/bash

echo "This script was created to simplify the setup process for Surface devices running Arch Linux."
echo 

cache_folder=.cache_setup
patches_repository=git://github.com/jakeday/linux-surface.git
patches_src_folder=linux-surface
firmware_src_folder="$cache_folder/$patches_src_folder/firmware"

############################### CACHE CREATION ############################### 

# This cache is purely temporary (fixes issues with superuser permissions)
echo "Creating temporary cache ..."
mkdir -p $cache_folder
cd $cache_folder

# Only the patches repository needs to be tracked
if [ -d $patches_src_folder ]; then
  cd $patches_src_folder && git pull && cd ..
else
  git clone $patches_repository $patches_src_folder
fi

# Exit the cache folder 
cd ..

############################### INSTALLATION ############################### 

# Prompt for installation of root files
echo
read -r -p "Copy config files from jakeday's kernel to root? [y/N] "
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "Unpacking files to / ..."
  cp -r $cache_folder/$patches_src_folder/root/etc/* /etc
  mkdir -p /lib/systemd/system-sleep
  cp $cache_folder/$patches_src_folder/root/lib/systemd/system-sleep/sleep /lib/systemd/system-sleep

  echo "Making /lib/systemd/system-sleep/sleep executable ..."
  chmod a+x /lib/systemd/system-sleep/sleep
  
  echo "Done copying config files."
fi

# Prompt for replacement of suspend with hibernate
echo
read -r -p "Replace suspend with hibernate? [y/N] "

# User selected 'yes' option
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "Symlinking suspend target/service to hibernate target/service ..."
  ln -sf /lib/systemd/system/hibernate.target /etc/systemd/system/suspend.target
  ln -sf /lib/systemd/system/systemd-hibernate.service /etc/systemd/system/systemd-suspend.service
  echo "Done replacing suspend with hibernate."
fi

# Prompt for installation of WiFi firmware
echo
read -r -p "Install WiFi firmware (marvel, mwlwifi)? [y/N] "

# User selected 'yes' option 
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "Unpacking files to /lib/firmware/mrvl ..."
  mkdir -p /lib/firmware/mrvl/
  unzip -o $firmware_src_folder/mrvl_firmware.zip -d /lib/firmware/mrvl
  echo "Done installing marvel firmware."

  echo "Unpacking files to /lib/firmware/mwlwifi ..."
  mkdir -p /lib/firmware/mwlwifi/
  unzip -o $firmware_src_folder/mwlwifi_firmware.zip -d /lib/firmware/mwlwifi
  echo "Done installing mwlwifi firmware."
fi

# Prompt for installation for model-based firmware
echo
read -r -p "Install device-specific firmware (touchscreen, wireless, GPU)? [y/N] "

# User selected 'yes' option 
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "What Surface model is your device? Enter the number corresponding to your selection."
  select SURFACE_MODEL in "Surface Pro 3" "Surface Pro 4" "Surface Pro 2017" "Surface Pro 6" "Surface Laptop" "Surface Book" "Surface Book 2 13\"" "Surface Book 2 15\"" "Surface Go"; do
    break;
  done

  echo "$SURFACE_MODEL selected. Installing firmware ..."

  i915_folder=/lib/firmware/i915/
  intel_ipts_folder=/lib/firmware/intel/ipts/
  nvidia_folder=/lib/firmware/nvidia/gp108/
  ath10k_folder=/lib/firmware/ath10k

  case $SURFACE_MODEL in
    "Surface Pro 3")
      echo "Unpacking files to $i915_folder ..."
      mkdir -p $i915_folder 
      unzip -o $firmware_src_folder/i915_firmware_bxt.zip -d $i915_folder 
      ;;
    "Surface Pro 4")
      echo "Unpacking files to $intel_ipts_folder ..."
      mkdir -p $intel_ipts_folder 
      unzip -o $firmware_src_folder/ipts_firmware_v78.zip -d $intel_ipts_folder 

      echo "Unpacking files to $i915_folder ..."
      mkdir -p $i915_folder 
      unzip -o $firmware_src_folder/i915_firmware_skl.zip -d $i915_folder 
      ;;
    "Surface Pro 2017")
      echo "Unpacking files to $intel_ipts_folder ..."
      mkdir -p $intel_ipts_folder 
      unzip -o $firmware_src_folder/ipts_firmware_v102.zip -d $intel_ipts_folder 

      echo "Unpacking files to $i915_folder ..."
      mkdir -p $i915_folder 
      unzip -o $firmware_src_folder/i915_firmware_kbl.zip -d $i915_folder 
      ;;
    "Surface Pro 6")
      echo "Unpacking files to $intel_ipts_folder ..."
      mkdir -p $intel_ipts_folder 
      unzip -o $firmware_src_folder/ipts_firmware_v102.zip -d $intel_ipts_folder 

      echo "Unpacking files to $i915_folder ..."
      mkdir -p $i915_folder 
      unzip -o $firmware_src_folder/i915_firmware_kbl.zip -d $i915_folder 
      ;;
    "Surface Laptop")
      echo "Unpacking files to $intel_ipts_folder ..."
      mkdir -p $intel_ipts_folder 
      unzip -o $firmware_src_folder/ipts_firmware_v79.zip -d $intel_ipts_folder 

      echo "Unpacking files to $i915_folder ..."
      mkdir -p $i915_folder 
      unzip -o $firmware_src_folder/i915_firmware_skl.zip -d $i915_folder 
      ;;
    "Surface Book")
      echo "Unpacking files to $intel_ipts_folder ..."
      mkdir -p $intel_ipts_folder 
      unzip -o $firmware_src_folder/ipts_firmware_v76.zip -d $intel_ipts_folder 

      echo "Unpacking files to $i915_folder ..."
      mkdir -p $i915_folder 
      unzip -o $firmware_src_folder/i915_firmware_skl.zip -d $i915_folder 
      ;;
    "Surface Book 2 13\"")
      echo "Unpacking files to $intel_ipts_folder ..."
      mkdir -p $intel_ipts_folder 
      unzip -o $firmware_src_folder/ipts_firmware_v137.zip -d $intel_ipts_folder 

      echo "Unpacking files to $i915_folder ..."
      mkdir -p $i915_folder 
      unzip -o $firmware_src_folder/i915_firmware_kbl.zip -d $i915_folder 

      echo "Unpacking files to $nvidia_folder ..."
      mkdir -p $nvidia_folder
      unzip -o $firmware_src_folder/nvidia_firmware_gp108.zip -d $nvidia_folder
      ;;
    "Surface Book 2 15\"")
      echo "Unpacking files to $intel_ipts_folder ..."
      mkdir -p $intel_ipts_folder 
      unzip -o $firmware_src_folder/ipts_firmware_v101.zip -d $intel_ipts_folder 

      echo "Unpacking files to $i915_folder ..."
      mkdir -p $i915_folder 
      unzip -o $firmware_src_folder/i915_firmware_kbl.zip -d $i915_folder 

      echo "Unpacking files to $nvidia_folder ..."
      mkdir -p $nvidia_folder
      unzip -o $firmware_src_folder/nvidia_firmware_gp108.zip -d $nvidia_folder
      ;;
    "Surface Go")
      echo "Unpacking files to $ath10k_folder ..."
      mkdir -p $ath10k_folder
      unzip -o $firmware_src_folder/ath10k_firmware.zip -d $ath10k_folder
      ;;
    *)
      echo "Invalid selection. Moving on."
      ;;
  esac
fi

############################### CACHE REMOVAL ###############################

# Remove the cache folder to handle permission issues
echo ""
echo "Removing temporary cache ..."
rm -rf $cache_folder

# Yay! All done.
echo 
echo "Setup process finished!"
echo "Install your patched kernel and then reboot."
