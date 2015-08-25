#! /bin/bash
buildpath=/anarchy/Suppdroid
javahome=/usr/lib/jvm/java-7-openjdk
androidhome=/home/$(whoami)/.android-sdk
echo Building Crimson $(cat build_version)

cd $buildpath

echo Downloading proprietary drivers...
wget https://dl.google.com/dl/android/aosp/broadcom-hammerhead-lmy48i-6922f559.tgz
wget https://dl.google.com/dl/android/aosp/lge-hammerhead-lmy48i-42aa57af.tgz
wget https://dl.google.com/dl/android/aosp/qcom-hammerhead-lmy48i-b7faab74.tgz
tar xf broadcom-hammerhead-lmy48i-6922f559.tgz
tar xf lge-hammerhead-lmy48i-42aa57af.tgz
tar xf qcom-hammerhead-lmy48i-b7faab74.tgz
rm broadcom-hammerhead-lmy48i-6922f559.tgz
rm lge-hammerhead-lmy48i-42aa57af.tgz
rm qcom-hammerhead-lmy48i-b7faab74.tgz
echo Please accept the following license agreements to extract the drivers:
./extract-broadcom-hammerhead.sh
./extract-qcom-hammerhead.sh
./extract-lge-hammerhead.sh

echo Setting build variables
export PATH=$buildpath/bin:$PATH
export JAVA_HOME=$javahome
export ANDROID_HOME=$androidhome

echo Getting initial repository
repo init -u https://android.googlesource.com/platform/manifest -b android-5.1.1_r9
echo Resyncing repository
repo sync

echo Entering virtual Python2.7 environment
virtualenv2 -p /usr/bin/python2.7 .
source bin/activate

echo Patching non-static AOSP content
cat Additional/Hammerhead/add_device.mk >> device/lge/hammerhead/device.mk

echo Setting build descriptor
sed -i "s/^build_desc.*/build_desc:=Crimson ReleaseCodename: Kate $(cat build_version) $(date) $(uname -snrm) $(whoami)/" build/core/Makefile
echo $(cat build_version | awk -F. -v OFS=. 'NF==1{print ++$NF}; NF>1{if(length($NF+1)>length($NF))$(NF-1)++; $NF=sprintf("%0*d", length($NF), ($NF+1)%(10^length($NF))); print}') > build_version

echo Entering AOSP build-environment
source build/envsetup.sh
export USE_CACHE=1
export CCACHE_DIR=$buildpath/ccache
prebuilts/misc/linux-x86/ccache/ccache -M 50G
echo Cleaning up
make clobber
echo Configuring for hammerhead
lunch aosp_hammerhead-userdebug
echo Starting make-process
make update-api
make -j10
echo Make exited. Exiting build-environment
deactivate
