FROM openjdk:8
# Install needed tools, including CLI
RUN apt-get update && apt-get install -y curl unzip

RUN apt-get update -yq \
    && apt-get install curl gnupg -yq \
    && curl -sL https://deb.nodesource.com/setup_10.x | bash \
    && apt-get install nodejs -yq

RUN curl -OL https://bintray.com/artifact/download/groovy/maven/apache-groovy-binary-2.4.14.zip
RUN unzip apache-groovy-binary-2.4.14.zip && ln -s /groovy-2.4.14/bin/groovy /usr/local/bin/groovy
ADD npmbuild.tar.gz /root/
# Actual generator
ADD Runner.groovy /Runner.groovy
# Helpers
ADD HelperTools.groovy /HelperTools.groovy
ADD Generator.groovy /Generator.groovy
ADD config.properties.defaults /config.properties.defaults
RUN chmod +x /Runner.groovy /root/npmSetup.sh
RUN groovy /Runner.groovy --import-grapes
ENTRYPOINT /Runner.groovy