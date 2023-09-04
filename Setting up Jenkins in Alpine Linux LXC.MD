# Setting up Jenkins in Alpine Linux LXC

This guide was implemented in Alpine Linux v3.18.0 running in an LXC container.

### Step 1 - Install dependencies
```
apk update
apk add openssh-server jenkins vim iptables openjdk17-jre
```

```
rc-service sshd start
rc-status
rc-update add sshd
```

### Step 2 - Fix Broken initd script:
Access the file in question: `vim /etc/init.d/jenkins`

and comment out the following lines by prepending a `#` at the beginning of each line:
```
[ -n "$JENKINS_HANDLER_MAX" ] && PARAMS="$PARAMS --handlerCountMax=$JENKINS_HANDLER_MAX"
[ -n "$JENKINS_HANDLER_IDLE" ] && PARAMS="$PARAMS --handlerCountMaxIdle=$JENKINS_HANDLER_IDLE"
```

### Step 3 - Start Jenkins service
```
rc-service jenkins start
rc-status
rc-update add jenkins
```


### Step 4 - Network Setup:

Execute the following commands
```
iptables -I INPUT 1 -p tcp --dport 8443 -j ACCEPT
iptables -I INPUT 1 -p tcp --dport 8080 -j ACCEPT
iptables -I INPUT 1 -p tcp --dport 443 -j ACCEPT
iptables -I INPUT 1 -p tcp --dport 80 -j ACCEPT
```

To verify the changes were applied:
`iptables -L -n`

you should get the following output:
```
Chain INPUT (policy ACCEPT)
target     prot opt source               destination         
ACCEPT     6    --  0.0.0.0/0            0.0.0.0/0            tcp dpt:80
ACCEPT     6    --  0.0.0.0/0            0.0.0.0/0            tcp dpt:443
ACCEPT     6    --  0.0.0.0/0            0.0.0.0/0            tcp dpt:8080
ACCEPT     6    --  0.0.0.0/0            0.0.0.0/0            tcp dpt:8443

Chain FORWARD (policy ACCEPT)
target     prot opt source               destination         

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination
```

```
iptables -A PREROUTING -t nat -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 8080
iptables -A PREROUTING -t nat -i eth0 -p tcp --dport 443 -j REDIRECT --to-port 8443
```

To verify the changes were applied:
`iptables -L -t nat`

you should get the following output:

```
Chain PREROUTING (policy ACCEPT)
target     prot opt source               destination         
REDIRECT   tcp  --  anywhere             anywhere             tcp dpt:http redir ports 8080
REDIRECT   tcp  --  anywhere             anywhere             tcp dpt:https redir ports 8443

Chain INPUT (policy ACCEPT)
target     prot opt source               destination         

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination         

Chain POSTROUTING (policy ACCEPT)
target     prot opt source               destination
```

Running `iptables...` commands will only apply the changes temporarily. To make the changes permanent, run the following commands:

```
iptables-save > /etc/network/iptables.up.rules
touch /etc/local.d/iptables.start
chmod +x /etc/local.d/iptables.start
```

In the newly created file, `/etc/local.d/iptables.start`, add the following lines:
```
#!/bin/sh

echo "Applying iptables rules..."
iptables-restore /etc/network/iptables.up.rules
```

Boot up the local.d service:
```
rc-update add local
rc-service local start
```

To verify the script runs successfully:
```
rc-service local restart -v
```

The output should looks as follows:

```
 * Executing: /lib/rc/sh/openrc-run.sh /lib/rc/sh/openrc-run.sh /etc/init.d/local stop
 * Stopping local ...                                                                                              [ ok ]
 * Executing: /lib/rc/sh/openrc-run.sh /lib/rc/sh/openrc-run.sh /etc/init.d/local start
 * Starting local ...
 *   Executing "/etc/local.d/iptables.start" ...                                                                   [ ok ]
```
### Step 5 - Initial Jenkins Setup

The Jenkins service should now be running. Open up a browser, go to the configured host/IP address and follow the instructions for the first-time setup.

### Sources:

https://unix.stackexchange.com/questions/721400/network-is-unreachable-when-installing-jenkins-on-ubuntu-20-04

https://www.jenkins.io/doc/book/system-administration/reverse-proxy-configuration-with-jenkins/reverse-proxy-configuration-iptables/

https://stackoverflow.com/questions/42408703/why-does-jenkins-say-this-jenkins-instance-appears-to-be-offline

https://wiki.gentoo.org/wiki//etc/local.d

### Debugging Tips:
- If you're getting errors from Jenkins, check the runtimelog at: `/var/log/jenkins/jenkins.log`
