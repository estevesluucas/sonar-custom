FROM sonarqube:7.4-community


# create plugin download location; so we can copy them later when SonarQube is started
ENV PLUGIN_DOWNLOAD_LOCATION /opt/sonarqube/plugins-download
RUN mkdir -p $PLUGIN_DOWNLOAD_LOCATION
WORKDIR ${PLUGIN_DOWNLOAD_LOCATION}

# download plugins from:
RUN rm /opt/sonarqube/extensions/plugins/sonar-java-plugin*
RUN wget https://binaries.sonarsource.com/Distribution/sonar-java-plugin/sonar-java-plugin-5.10.1.16922.jar
RUN wget https://binaries.sonarsource.com/Distribution/sonar-javascript-plugin/sonar-javascript-plugin-5.0.0.6962.jar
RUN wget https://github.com/spotbugs/sonar-findbugs/releases/download/3.9.1/sonar-findbugs-plugin-3.9.1.jar

VOLUME /qualityprofile
COPY /qualityprofile/java-custom.xml /qualityprofile/java-custom.xml

COPY docker-entrypoint.sh /opt/sonarqube/docker-entrypoint-chmod.sh
RUN cat /opt/sonarqube/docker-entrypoint-chmod.sh > /opt/sonarqube/docker-entrypoint.sh
RUN chmod +x /opt/sonarqube/docker-entrypoint.sh

WORKDIR ${SONARQUBE_HOME}
ENTRYPOINT ["/opt/sonarqube/docker-entrypoint.sh"]
