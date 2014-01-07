#!/bin/bash

cmd=$0
action="lock"
verbose=0
pid=""
wait=0
wait_timeout=180

while [ $# -gt 0 ]; do
	case "$1" in
		-l) action="lock" ; shift; pid="$1" ;;
		-u) action="unlock" ;;
		-v) verbose=1 ;;
		-w) wait=1 ;;
		-*) 
		    echo "Unknown option $1" >&2
		    echo "Usage: $cmd [-l pid|-u] [-w] [-v] <lockfile>" >&2
		    exit 1
		    ;;
		*)  break;;	# terminate while loop
	esac
	shift
done

lockfile="$1"

if [ "$action" == "lock" ]; then

	if [ -z "$lockfile" ]; then
		echo "No lock file provided" >&2
		echo "Usage: $cmd [-l|-u] [-v] <lockfile>" >&2
		exit 1
	fi

	if [ "$verbose" -gt 0 ]; then echo -n "Trying to acquire lock... "; fi

	if [ -e "$lockfile" ]; then
		if [ "$verbose" -gt 0 ]; then echo "Failed! Lock file already exists."; fi
		old_pid=$(cat "$lockfile")

		if [ "$verbose" -gt 0 ]; then echo -n "Verifying locking process status... "; fi
		is_running=$(ps -Ao pid | grep -w $old_pid | wc -l)
		if [ "$is_running" -eq 0 ]; then
			# Stale lock
			if [ "$verbose" -gt 0 ]; then echo "Not running anymore."; fi
			if [ "$verbose" -gt 0 ]; then echo -n "Removing lock... "; fi
			if ! rm -f "$lockfile" > /dev/null 2>&1; then
				if [ "$verbose" -gt 0 ]; then echo "Failed. Lock failed."; fi
				exit 1
			fi
			if [ "$verbose" -gt 0 ]; then echo "Done."; fi
			if [ "$verbose" -gt 0 ]; then echo -n "Acquiring lock... "; fi
		else
			if [ "$verbose" -gt 0 ]; then echo "Still running. Lock failed."; fi
			if [ "$wait" -eq 0 ]; then
				exit 1
			else
				lock_available=0
				if [ "$verbose" -gt 0 ]; then echo -n "Waiting $AUTODOWNLOAD_LOCK_WAIT seconds for lock to be available... "; fi
				for i in $(seq 0 5 300); do
					sleep 5
					if ! [ -e "$lockfile" ]; then
						lock_available=1
						break
					fi
				done
				if [ $lock_available -eq 0 ]; then
					if [ "$verbose" -gt 0 ]; then echo "Failed!"; fi
					exit 1
				fi
				if [ "$verbose" -gt 0 ]; then echo "Done."; fi
			fi
		fi
	fi

	echo -n "$pid" > "$lockfile"
	if [ -e "$lockfile" ]; then
		if [ "$verbose" -gt 0 ]; then echo "Done."; fi
		exit 0
	else
		if [ "$verbose" -gt 0 ]; then echo "Failed! Couldn't write to lockfile"; fi
		exit 1
	fi

else
	if [ "$verbose" -gt 0 ]; then echo -n "Removing lock... "; fi

	if ! [ -e "$lockfile" ]; then
		if [ "$verbose" -gt 0 ]; then echo "Lock file doesn't exist. Not doing anything."; fi
		exit 0
	else
		if ! rm -f "$lockfile" > /dev/null 2>&1; then
			if [ "$verbose" -gt 0 ]; then echo "Failed. Unock failed."; fi
			exit 1
		else
			if [ "$verbose" -gt 0 ]; then echo "Done."; fi
			exit 0
		fi
	fi
fi

