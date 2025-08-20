# Copyright (c) 2022 NetEase, Inc. All rights reserved.
# Use of this source code is governed by a MIT license that can be
# found in the LICENSE file.

set -e
set +x

echo "integration start"
deviceId1=$1
isStartUp=$2
customHost=$3
port=8896
host="10.219.25.29"
a=$(lsof -i:$port | wc -l)
server=/Users/$(whoami)/Desktop/integration_test/control/server.py
echo "deviceId1: ${deviceId1}"


PROJECT_PATH=$(pwd)

MOCK_CONFIG="$PROJECT_PATH/test_driver/mock/integrated_mock.dart"
MEETING_FLUTTER_TEST="$PROJECT_PATH/test_driver/meeting_flutter_test.dart"
FIELD_NAME="const nickname = ";
FIELD_MOBILE="const mobile = ";

FIELD_MOBILE1="${FIELD_MOBILE}'15712893500';";
FIELD_NAME1="${FIELD_NAME}'赵冲';";
FIELD_MOBILE2="${FIELD_MOBILE}'18588897464';";
FIELD_NAME2="${FIELD_NAME}'赵冲01';";

startUp(){
  if [ "$a" -gt "0" ];then
    echo "端口已存在0"
  else
    echo "端口已死亡1"
    echo "1.integration test git clone TC Case Repo or Request socket post $server"
#    chmod u+x "${server}"
    python3 "$server" --host  $host  --port $port   --min-client 1 &
  fi
}


integrationTest(){
  echo "integration test is start :$PROJECT_PATH"
  echo "integration test customHost :${customHost}"
  flutter clean
  if [[ ! -z ${customHost} ]]; then
    sed -i "" "s#localhost#${customHost}#g" "$MEETING_FLUTTER_TEST"
    echo "customHost 修改为 ${customHost} 的IP地址"
  else
    sed -i "" "s#localhost#${host}#g" "$MEETING_FLUTTER_TEST"
    echo "default host $host 的IP地址"
  fi

  if [ "$isStartUp" == "true" ];then
    echo "flutter drive $deviceId1 "
    startUp
  else
    sed -i "" "s#${FIELD_MOBILE1}#${FIELD_MOBILE2}#g" "$MOCK_CONFIG"
    sed -i "" "s#${FIELD_NAME1}#${FIELD_NAME2}#g" "$MOCK_CONFIG"
    sleep 60
    echo "just run check device"
  fi
  echo " flutter pub upgrade"
  flutter pub get
  flutter drive --target=test_driver/meeting_flutter.dart
#  -d "$deviceId1"
#  git clone ssh://git@g.hz.netease.com:22222/meeting/integration_test.git
  echo "2.integration test run TC Case"
  echo "3.integration test is all pass"
  echo "integration test is done"
}

updateBuildTime(){
  current_time=$(date "+%Y-%m-%d %H:%M:%S")
  echo "$current_time"
}



integrationTest
updateBuildTime

