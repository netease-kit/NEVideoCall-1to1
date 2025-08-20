# Copyright (c) 2022 NetEase, Inc. All rights reserved.
# Use of this source code is governed by a MIT license that can be
# found in the LICENSE file.

set -e
set +x

echo "Pack meeting evn start"
ENV=$1
echo "ENV: ${ENV}"

PROJECT_PATH=$(pwd)
echo "$PROJECT_PATH"
cd "$PROJECT_PATH"

SERVER_CONFIG="$PROJECT_PATH/../yunxin_meeting/lib/src/meeting_service/config/server_config.dart"
echo "${SERVER_CONFIG}"

SERVER_FIELD_NAME=" static final String _serverUrl = ";
SERVER_ONLINE="https://yiyong-xedu-v2.netease.im/scene/meeting";
SERVER_TEST="https://yiyong-xedu-v2-test.netease.im/scene/meeting";
SERVER_QA="https://yiyong-xedu-v2-qa.netease.im/scene/meeting";

CONFIG_PROPERTIES="${PROJECT_PATH}/assets/config.properties"
echo "${CONFIG_PROPERTIES}"

packOnline(){
  echo "Config sdk online address";
  sed -i "" "s#^ENV=.*#ENV=ONLINE#g" "$CONFIG_PROPERTIES"
  sed -i "" "s#${SERVER_FIELD_NAME}.*#${SERVER_FIELD_NAME}\'${SERVER_ONLINE}\';#g" "$SERVER_CONFIG"
}

packTest(){
  echo "Config sdk test address";
  sed -i "" "s#^ENV=.*#ENV=TEST#g" "$CONFIG_PROPERTIES"
  sed -i "" "s#${SERVER_FIELD_NAME}.*#${SERVER_FIELD_NAME}\'${SERVER_TEST}\';#g" "$SERVER_CONFIG"
  echo "Config sdk test address done";
}

packQa(){
  echo "Config sdk qa address";
  sed -i "" "s#^ENV=.*#ENV=QA#g" "$CONFIG_PROPERTIES"
  sed -i "" "s#${SERVER_FIELD_NAME}.*#${SERVER_FIELD_NAME}\'${SERVER_QA}\';#g" "$SERVER_CONFIG"
  echo "Config sdk qa address done";
}

showUsage(){
  echo "must input build params:"
  echo "online  pack online evn"
  echo "test    pack test evn"
  exit 1;
}

updateBuildTime(){
  current_time=$(date "+%Y-%m-%d %H:%M:%S")
  echo "$current_time"
  sed -i "" '$d' "$CONFIG_PROPERTIES"
  echo "time=$current_time" >>"$CONFIG_PROPERTIES"
}

if [ "$ENV" == "online" ]; then
  packOnline
elif [ "$ENV" == "test" ]; then
  packTest
elif [ "$ENV" == "qa" ]; then
  packQa
else
  packTest
fi

updateBuildTime
