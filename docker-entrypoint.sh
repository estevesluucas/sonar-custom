#!/bin/bash
set -e

echo "##"
echo "# Preparing to starting SonarQube"
echo "# - removing all bundled plugins"
rm -rf /opt/sonarqube/lib/bundled-plugins/sonar-*.jar

echo "# - copy downloaded plugins to: ${SONARQUBE_HOME}/extensions/plugins/"
cp -a $PLUGIN_DOWNLOAD_LOCATION/. $SONARQUBE_HOME/extensions/plugins/

echo "# - list installed plugins"
ls -la ${SONARQUBE_HOME}/extensions/plugins/

echo "# - starting SonarQube"
echo "##"
$SONARQUBE_HOME/bin/run.sh &
echo "Após script de run"
function curlAdmin {
    curl -v -u admin:admin $@
}

echo "BASE_URL"
BASE_URL=http://127.0.0.1:9000
echo "$BASE_URL"
function isUp {
    echo "Is up?"
    curl -s -u admin:admin -f "$BASE_URL/api/system/info"
}

# Wait for server to be up


echo 'Waiting sonarqube start ...' &&
    count=1 &&
until $(curl --output /dev/null --silent --head --fail -s -u admin:admin -f "$BASE_URL/api/system/info"); do
        printf 'Waiting ...\n'
        sleep 5
        if [ $count -gt 60 ]
        then
            echo 'Application is not up, abortion operation....'
            exit 1
        fi
        let "count+=1"
done

# Restore qualityprofile

    curl -v POST -u admin:admin "http://127.0.0.1:9000/api/qualityprofiles/restore" --form backup=@/qualityprofile/java-custom.xml
    curl -s -u admin:admin -X POST "http://127.0.0.1:9000/api/qualityprofiles/set_default?language=java&profileName=Sonar+java+custom"
    #Creating quality profile
    curl -u admin:admin -X POST "http://localhost:9000/api/qualitygates/create?name=custom"
    curl -u admin:admin -X POST "http://localhost:9000/api/qualitygates/set_as_default?id=2"
    curl -u admin:admin -X POST "http://localhost:9000/api/qualitygates/create_condition?gateId=2&metric=new_security_rating&op=GT&error=1&period=1"
    curl -u admin:admin -X POST "http://localhost:9000/api/qualitygates/create_condition?gateId=2&metric=new_reliability_rating&op=GT&error=1&period=1"
    curl -u admin:admin -X POST "http://localhost:9000/api/qualitygates/create_condition?gateId=2&metric=new_maintainability_rating&op=GT&error=1&period=1"
    curl -u admin:admin -X POST "http://localhost:9000/api/qualitygates/create_condition?gateId=2&metric=new_coverage&op=LT&error=100&warning=100"
    curl -u admin:admin -X POST "http://localhost:9000/api/qualitygates/create_condition?gateId=2&metric=new_bugs&op=GT&error=0&period=1"
    curl -u admin:admin -X POST "http://localhost:9000/api/qualitygates/create_condition?gateId=2&metric=new_code_smells&op=GT&error=0&period=1"
    curl -u admin:admin -X POST "http://localhost:9000/api/qualitygates/create_condition?gateId=2&metric=coverage&op=LT&error=100&warning=100"
    curl -u admin:admin -X POST "http://localhost:9000/api/qualitygates/create_condition?gateId=2&metric=bugs&op=GT&error=0"
    curl -u admin:admin -X POST "http://localhost:9000/api/qualitygates/create_condition?gateId=2&metric=code_smells&op=GT&error=0"
    curl -u admin:admin -X POST "http://localhost:9000/api/qualitygates/create_condition?gateId=2&metric=security_rating&op=GT&error=1"

wait
