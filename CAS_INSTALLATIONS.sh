#!/bin/bash

# ---- PRE-REQUISITE ------
yum update
yum install tree vim unzip git yum-utils curl -y
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum update

# ---- JAVA INSTALLATION -------

# https://adoptopenjdk.net/
# https://adoptopenjdk.net/installation.html?variant=openjdk11&jvmVariant=hotspot
# https://wiki.centos.org/HowTos/JavaRuntimeEnvironment

cat <<'EOF' > /etc/yum.repos.d/adoptopenjdk.repo
[AdoptOpenJDK]
name=AdoptOpenJDK
baseurl=http://adoptopenjdk.jfrog.io/adoptopenjdk/rpm/centos/$releasever/$basearch
enabled=1
gpgcheck=1
gpgkey=https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public
EOF


yum update
yum install yum install adoptopenjdk-11-hotspot adoptopenjdk-11-hotspot-jre -y
ln -s /usr/lib/jvm/adoptopenjdk-11-hotspot-jre /usr/lib/jvm/jre

alternatives --configure java

echo "JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")" | sudo tee -a /etc/profile
source /etc/profile
# -------- END JAVA INSTALL ----------

# ---- INSTALL TOMCAT ------
cd /usr/local/src

wget https://mirrors.gigenet.com/apache/tomcat/tomcat-9/v9.0.52/bin/apache-tomcat-9.0.52.zip
unzip apache-tomcat-9.0.52.zip
mv apache-tomcat-9.0.52.zip /opt/cas-server
useradd  -m -U -d /opt/cas-server -b /bin/false cas-server
chown -R cas-server: /opt/cas-server

# ------- END INSTALL TOMCAT ----------


# ---- BUILD & INSTALL CAS -------
cd /usr/local/src

git clone https://github.com/apereo/cas.git --recursive
cd cas
git checkout -b v6.3.6 v6.3.6
git submodule update --init --recursive


./gradlew build install --parallel -x test -x javadoc -x check --build-cache --configure-on-demand

cd build/
./release.sh

# ---- CAS config overlay ???? hold on this works and the build above doesn't work??
git clone https://github.com/apereo/cas-configserver-overlay.git
cd cas-configserver-overlay
./build.sh
./build.sh package
./gradlew createKeystore


# ---- TEST BUILD -----
java -jar libs/app.war -Djava.util.logging.config.file=/opt/cas-server/conf/logging.properties  -Djboss.http.port=8091


####### Access Test ######
# username = casuser
# password = _______
#
#

