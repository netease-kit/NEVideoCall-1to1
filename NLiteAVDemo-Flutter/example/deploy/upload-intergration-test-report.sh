# Copyright (c) 2022 NetEase, Inc. All rights reserved.
# Use of this source code is governed by a MIT license that can be
# found in the LICENSE file.

#!/usr/bin/env bash

## e.g. "sh upload-intergration-test-report.sh env root_directory_name"

PROJECT_PATH=$(pwd)
echo "PROJECT_PATH = $PROJECT_PATH"
env=$1
#nightly ,publish
root_directory_name=$2
platform=$3
version_name_code=$(cat pubspec.yaml | shyaml get-value version)
version_name=$(echo "${version_name_code}" | cut -d "+" -f 1)
rm -rf tools
git clone ssh://git@g.hz.netease.com:22222/yunxin-app/tools.git tools
logPath=v${version_name}/android/meeting_mobile_$(date +"%Y%m%d%H%M")_$(git rev-parse --short HEAD)_test_log
archive_root_path=${PROJECT_PATH}/outputs/${logPath}
mkdir -p  ${archive_root_path}
echo "archive_root_path = $archive_root_path"
mv /Users/yunxin/Desktop/integration_test/control/resultReport02.html  ${archive_root_path}/resultReport.html
pwd
ls
sh ./tools/backup/backup_10.242.141.186.sh  ${root_directory_name}
cd tools && ls
cd ../
url="http://10.242.141.186/meeting/${root_directory_name}/${logPath}"
echo "backup url=${url} "
sh ./tools/notification/feishu/notify.sh --platform "$platform" --env "${env}" --version "${version_name}" --downloadurl "${url}"
