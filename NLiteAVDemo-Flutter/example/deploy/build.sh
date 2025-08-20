# Copyright (c) 2022 NetEase, Inc. All rights reserved.
# Use of this source code is governed by a MIT license that can be
# found in the LICENSE file.

set -e
set +x

START=$(date +%s)

echo "Build start"
PLATFORM=$1
ENV=$2
IOS_DISTRIBUTE_PLATFORM=$3
if [ "$PLATFORM" == "Android" ]; then
  BACKUP_DIR=$3
else
  BACKUP_DIR=$4
fi

#echo 'Update submodule'
#git submodule update --init --force

PROJECT_PATH=$(pwd)

echo "$PROJECT_PATH"
cd "$PROJECT_PATH"

rm -rf "${PROJECT_PATH}/outputs"
mkdir -p "${PROJECT_PATH}/outputs"

now=$(date +"%Y%m%d%H%M")
current_day=$(date "+%Y%m%d")

VERSION_NAME_CODE=$(cat pubspec.yaml | shyaml get-value version)
VERSION_NAME=$(echo "${VERSION_NAME_CODE}" | cut -d "+" -f 1)

BUILD_EVN=$(cat ${PROJECT_PATH}/assets/config.properties | grep -w '^ENV' | head -1 | cut -d '=' -f 2 | tr '[A-Z]' '[a-z]')
BUILD_BRANCH=`git symbolic-ref HEAD 2>/dev/null | cut -d"/" -f 3`
BUILD_COMMIT_ID=`git rev-parse --short HEAD`
ARCHIVE_ROOT_PATH="${PROJECT_PATH}/outputs"
ARCHIVE_DIRECTOR_NAME="callkit_flutter_${now}_${BUILD_COMMIT_ID}_${BUILD_EVN}"
ARCHIVE_NAME="callkit_flutter_sample_${now}_${BUILD_COMMIT_ID}_${BUILD_EVN}"

echo "===================================== "
echo "PROJECT_PATH: ${PROJECT_PATH}"
echo "BUILD_EVN: ${BUILD_EVN}"
echo "GIT_BRANCH: ${GIT_BRANCH}"
echo "BUILD_BRANCH: ${BUILD_BRANCH}"
echo "BUILD_COMMIT_ID: ${BUILD_COMMIT_ID}"
echo "ARCHIVE_ROOT_PATH: ${ARCHIVE_ROOT_PATH}"
echo "ARCHIVE_DIRECTOR_NAME: ${ARCHIVE_DIRECTOR_NAME}"
echo "VERSION_NAME: ${VERSION_NAME}"
echo "ENV: ${ENV}"
echo "PLATFORM: ${PLATFORM}"
echo "IOS_DISTRIBUTE_PLATFORM: ${IOS_DISTRIBUTE_PLATFORM}"
echo "BACKUP_DIR: ${BACKUP_DIR}"
echo "===================================== "

if [ "$PLATFORM" == "Android" ]; then
  sh $PROJECT_PATH/deploy/build_android.sh ${PROJECT_PATH} ${ARCHIVE_ROOT_PATH} ${ARCHIVE_DIRECTOR_NAME} ${ARCHIVE_NAME}
elif [ "$PLATFORM" == "iOS" ]; then
echo "sh $PROJECT_PATH/deploy/build_ios.sh ${PROJECT_PATH} ${ARCHIVE_ROOT_PATH} ${ARCHIVE_DIRECTOR_NAME} ${ARCHIVE_NAME} ${IOS_DISTRIBUTE_PLATFORM}"
  sh $PROJECT_PATH/deploy/build_ios.sh ${PROJECT_PATH} ${ARCHIVE_ROOT_PATH} ${ARCHIVE_DIRECTOR_NAME} ${ARCHIVE_NAME} ${IOS_DISTRIBUTE_PLATFORM}
else
  sh $PROJECT_PATH/deploy/build_android.sh ${PROJECT_PATH} ${ARCHIVE_ROOT_PATH} ${ARCHIVE_DIRECTOR_NAME} ${ARCHIVE_NAME} ${IOS_DISTRIBUTE_PLATFORM}
  cd $PROJECT_PATH
  sh $PROJECT_PATH/deploy/build_ios.sh ${PROJECT_PATH} ${ARCHIVE_ROOT_PATH} ${ARCHIVE_DIRECTOR_NAME} ${ARCHIVE_NAME} ${IOS_DISTRIBUTE_PLATFORM}
fi

## begin to upload
if [ "$BACKUP_DIR" != "" ] && [ "$BACKUP_DIR" != "--" ]; then
    directory_name="${VERSION_NAME}"
    branch_name=${GIT_BRANCH-"$(git rev-parse --abbrev-ref HEAD)"}
    #if [[ "${branch_name}" =~ "feature/" ]] ; then
    suffix=$(echo "${branch_name}" | awk -F'/' '{print $NF}' | tr '-' '_')
    directory_name="${VERSION_NAME}_${suffix}"
    target_path="outputs/${BACKUP_DIR}/callkit_flutter/${VERSION_NAME}"
    mkdir -p "${target_path}"
    if [ "$PLATFORM" == "Android" ]; then
      mv "outputs/android" "${target_path}"
    else
      mv "outputs/ios" "${target_path}"
    fi
    #fi
    rm -rf build_tools
    git clone ssh://git@g.hz.netease.com:22222/yunxin-app/tools.git build_tools
    sh $PROJECT_PATH/build_tools/backup/upload-artifacts.sh outputs/. "${BACKUP_DIR}/callkit_flutter/${VERSION_NAME}"
    platform_lowercase=$(echo "$PLATFORM" | tr '[A-Z]' '[a-z]')
    sh $PROJECT_PATH/build_tools/notification/notify.sh --platform "$PLATFORM" --env "${ENV}" --version "${VERSION_NAME}" \
      --downloadurl "http://10.242.141.186/xkit/${BACKUP_DIR}/callkit_flutter/${VERSION_NAME}/$platform_lowercase"
    rm -rf build_tools
fi
## upload done

cd $PROJECT_PATH

echo "Build done"
pwd
echo "print overmind parameters to results.properties"
rm -rf results.properties
echo "buildVer=" >> results.properties
echo "appVer=${VERSION_NAME}" >> results.properties
echo "versionCode=${VERSION_NAME_CODE}" >> results.properties
echo "MD5=" >> results.properties
echo "git_author=${USER_NAME}" >> results.properties
git_cm_msg="$(git log HEAD^..HEAD --pretty='%s' | head -n 1)"
echo "git_cm_msg=${git_cm_msg}" >> results.properties
git_cm_hash=$(git rev-parse --short HEAD)
echo "git_cm_hash=${git_cm_hash}" >> results.properties
directory_name="${VERSION_NAME}"
platform_lowercase=$(echo "$PLATFORM" | tr '[A-Z]' '[a-z]')
download_url=http://10.242.141.186/xkit/$BACKUP_DIR/callkit_flutter/$VERSION_NAME/$platform_lowercase/$ARCHIVE_NAME
echo "download_url=${download_url}" >> results.properties
qr_url="https://api.pwmqr.com/qrcode/create/?url=${download_url}"
echo "qr_url=${qr_url}" >> results.properties
branch_name=${GIT_BRANCH-"$(git rev-parse --abbrev-ref HEAD)"}
echo "git_branch=${branch_name}" >> results.properties
cat results.properties
echo "results.properties  done"
##  build.properties  done

END=$(date +%s)
DURATION=$(($END-$START))
MINS=$(($DURATION/60))
SECS=$(($DURATION%60))
echo "Total time: $MINS mins $SECS secs"

set +e
