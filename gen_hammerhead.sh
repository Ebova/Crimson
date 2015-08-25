#! /bin/bash
echo Building master
buildpath=/anarchy/Suppdroid

cd $buildpath
wget https://dl.google.com/dl/android/aosp/broadcom-hammerhead-lmy48i-6922f559.tgz
wget https://dl.google.com/dl/android/aosp/lge-hammerhead-lmy48i-42aa57af.tgz
wget https://dl.google.com/dl/android/aosp/qcom-hammerhead-lmy48i-b7faab74.tgz
tar xf broadcom-hammerhead-lmy48i-6922f559.tgz
tar xf lge-hammerhead-lmy48i-42aa57af.tgz
tar xf qcom-hammerhead-lmy48i-b7faab74.tgz
rm broadcom-hammerhead-lmy48i-6922f559.tgz
rm lge-hammerhead-lmy48i-42aa57af.tgz
rm qcom-hammerhead-lmy48i-b7faab74.tgz
./extract-broadcom-hammerhead.sh
./extract-qcom-hammerhead.sh
./extract-lge-hammerhead.sh

export PATH=$buildpath/bin:$PATH
export JAVA_HOME=/usr/lib/jvm/java-7-openjdk
export ANDROID_HOME=/home/androbuilder/.android-sdk

repo init -u https://android.googlesource.com/platform/manifest -b android-5.1.1_r9
repo sync

virtualenv2 -p /usr/bin/python2.7 .
source bin/activate

cat Additional/Hammerhead/add_device.mk >> device/lge/hammerhead/device.mk

sed -i "s/^build_desc.*/build_desc:=Crimson ReleaseCodename: Kate $(cat build_version) $(date) $(uname -snrm) $(whoami)/" build/core/Makefile
echo $(cat build_version | awk -F. -v OFS=. 'NF==1{print ++$NF}; NF>1{if(length($NF+1)>length($NF))$(NF-1)++; $NF=sprintf("%0*d", length($NF), ($NF+1)%(10^length($NF))); print}') > build_version

source build/envsetup.sh
export USE_CACHE=1
export CCACHE_DIR=$buildpath/ccache
prebuilts/misc/linux-x86/ccache/ccache -M 50G
make clobber
lunch aosp_hammerhead-userdebug
make update-api
make -j10
deactivate
