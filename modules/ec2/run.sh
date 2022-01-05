#!/bin/bash -x
yum -y update --security
sudo mkdir ${HOMEDIR}
cd ${HOMEDIR}
git clone https://github.com/Gigaspaces/xap-jenkins.git & echo "cloning done."
cd /home/jenkins/xap-jenkins/jenkins-docker
./build.sh 
sudo chmod -R xap-jenkins ubuntu:ubuntu
sudo chmod -R 777  xap-jenkins/jenkins_home
./xap-jenkins/jenkins-docker/run.sh