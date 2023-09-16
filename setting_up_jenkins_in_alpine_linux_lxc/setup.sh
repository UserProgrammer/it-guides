#!/bin/sh

# Install dependencies
apk update && apk add openssh-server jenkins vim iptables openjdk17-jre

# Start SSH server
rc-service sshd start
rc-status
rc-update add sshd

# Comment out lines that will break the Jenkins service bootup
sed -i '/[ -n "$JENKINS_HANDLER_MAX" ] && PARAMS="$PARAMS --handlerCountMax=$JENKINS_HANDLER_MAX"/ s/^/#/' /etc/init.d/jenkins
sed -i '/[ -n "$JENKINS_HANDLER_IDLE" ] && PARAMS="$PARAMS --handlerCountMaxIdle=$JENKINS_HANDLER_IDLE"/ s/^/#/' /etc/init.d/jenkins

# Start Jenkins service
rc-service jenkins start
rc-status
rc-update add jenkins

# Network setup
iptables -I INPUT 1 -p tcp --dport 8443 -j ACCEPT
iptables -I INPUT 1 -p tcp --dport 8080 -j ACCEPT
iptables -I INPUT 1 -p tcp --dport 443 -j ACCEPT
iptables -I INPUT 1 -p tcp --dport 80 -j ACCEPT

iptables -A PREROUTING -t nat -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 8080
iptables -A PREROUTING -t nat -i eth0 -p tcp --dport 443 -j REDIRECT --to-port 8443

iptables-save > /etc/network/iptables.up.rules
touch /etc/local.d/iptables.start
chmod +x /etc/local.d/iptables.start

rc-update add local
rc-service local start
