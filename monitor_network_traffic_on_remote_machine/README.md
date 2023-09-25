## Credits

Credit for this guide goes to Rahul Panwar: https://linuxexplore.com/2010/05/30/remote-packet-capture-using-wireshark-tcpdump/

Credit for the the detailed explanations of the `ssh` and `wireshark` commands goes to ChatGPT.

## Guide

1. First step is to create a special FIFO file using mkfifo command, where you want to see the packet capture using WireShark. This file will use to read & write simultaneously using WireShark & tcpdump.

```
mkfifo /tmp/packet_capture
```

2. Second give the following ssh command on your terminal, to start the tcpdump on remote PC.

```
ssh hostname_or_ip_of_remote_pc "tcpdump -s 0 -U -n -w - -i eth0 not port 22" /tmp/packet_capture
```

```
1. ssh hostname_or_ip_of_remote_pc: This initiates an SSH connection to a remote PC using the specified hostname or IP address.

2. "tcpdump -s 0 -U -n -w - -i eth0 not port 22": This part of the command is enclosed in double quotes and is the command that will be executed on the remote PC after the SSH connection is established.

3. /tmp/packet_capture: This specifies the output file on the remote PC where the captured network traffic will be written. In this case, it will be saved in the /tmp directory with the filename packet_capture.
```

```
1. tcpdump: This is the command itself, indicating that you want to run the tcpdump tool.

2. -s 0: This option sets the snapshot length to 0, which means it captures the entire packet. By setting it to 0, you ensure that you capture the full packet contents.

3. -U: This option forces tcpdump to write packets to the output file immediately (unbuffered). This can be useful when you're piping the output to another command or application in real-time, such as Wireshark.

4. -n: This option tells tcpdump not to resolve hostnames and port numbers to their symbolic names. It displays IP addresses and port numbers in numeric form, which can improve capture performance.

5. -w -: This option specifies the output file or destination for the captured packets. In this case, it is set to -, which means the output is sent to standard output (stdout). This is typically used when you want to pipe the captured packets to another command or application, such as Wireshark.

6. -i eth0: This option specifies the network interface (eth0 in this case) from which you want to capture traffic. In this example, it captures traffic from the eth0 interface.

7. not port 22: This is a BPF (Berkeley Packet Filter) expression used to filter the captured packets. It instructs tcpdump to exclude packets with a destination or source port of 22. Port 22 is commonly used for SSH, so this filter effectively excludes SSH traffic from the capture.
```

3. Give the following command to start the WireShark on your PC, which will read packets from the special FIFO file ‘/tmp/packet_capture’ at runtime.

```
wireshark -k -i /tmp/packet_capture
```


a. `wireshark: This is the command to launch the Wireshark application.`

b. `-k: This option is used to start Wireshark in "live capture" mode. In this mode, Wireshark will read packets from the specified input file (/tmp/packet_capture) and display them in real-time as if they were being captured live.`

c. `-i /tmp/packet_capture: This option specifies the input file from which Wireshark should read the captured packets. In this case, it points to the /tmp/packet_capture file`

After giving the above command all the packets of remote pc’s eth0 will be visible on WireShark.
