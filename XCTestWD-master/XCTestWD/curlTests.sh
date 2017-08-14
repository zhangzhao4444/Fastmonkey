
export JSON_HEADER='-H "Content-Type:application/json"'
export DEVICE_URL='http://127.0.0.1:8001'

TagHead() {
echo "\n#### $1 ####"
}

#Session: create session

TagHead "Create Session"

curl -X POST $JSON_HEADER \
-d "{\"desiredCapabilities\":{\"deviceName\":\"iPhone 6\",\"platformName\":\"iOS\", \"bundleId\":\"xudafeng.ios-app-bootstrap\",\"autoAcceptAlerts\":false}}" \
$DEVICE_URL/wd/hub/session \

### Read session as input for next stage testing

echo "\n\ninput the sessionID generated:\n"
read sessionID

#Session: query sessions

TagHead "Query Session"

curl -X GET $JSON_HEADER \
$DEVICE_URL/wd/hub/sessions \

#Session: checkon source

curl -X POST $JSON_HEADER \
-d "{\"using\":\"xpath\",\"value\":\"//XCUIElementTypeTextField[1]\"}" \
$DEVICE_URL/wd/hub/session/$sessionID/elements \

echo "\n\ninput the elementID generated:\n"
read elementID

curl -X POST $JSON_HEADER \
$DEVICE_URL/wd/hub/session/$sessionID/tap/$elementID \

TagHead "Check Source"

curl -X GET $JSON_HEADER \
$DEVICE_URL/wd/hub/source \

#TagHead "Press Home"
#
#curl -X POST $JSON_HEADER \
#$DEVICE_URL/wd/hub/session/$sessionID/homeScreen \

TagHead "Title"

curl -X GET $JSON_HEADER \
$DEVICE_URL/wd/hub/session/$sessionID/title \

##Session: delete session by ID

#TagHead "Delete Session By ID"
#
#curl -X DELETE $JSON_HEADER \
#$DEVICE_URL/wd/hub/session/$sessionID \
