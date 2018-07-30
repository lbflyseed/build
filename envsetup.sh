#!/bin/bash -e

parent_dir=`dirname ${BASH_SOURCE[0]}`
if [ x$parent_dir != "xbuild" ] ; then
	echo "Run \"source build/envsetup.sh\" at top directory of the SDK"
	return -1
fi

source build/setting.mk

unset _TARGET_CHIP
unset _TARGET_ARCH
unset _TARGET_PLATFORM
unset _TARGET_OS
unset _TARGET_BOARD

function select_platform()
{
	local cnt=0
	local choice
	local platform=""

	printf "All available platforms:\n"
	for platform in ${platforms[@]} ; do
		printf "%4d. %s\n" $cnt `echo $platform | awk -F':' '{ print $1 "(" $2 ")" }'`
		((cnt+=1))
	done

	while true ; do
		read -p "Choice: " choice
		if [ -z "${choice}" ] ; then
			continue
		fi

		if [ -z "${choice//[0-9]/}" ] ; then
			if [ $choice -ge 0 -a $choice -lt $cnt ] ; then
				_TARGET_CHIP=`echo ${platforms[$choice]} | awk -F':' '{ print $2 }' | awk -F',' '{ print $2 }'`
				_TARGET_ARCH=`echo ${platforms[$choice]} | awk -F':' '{ print $2 }' | awk -F',' '{ print $3 }'`
				_TARGET_PLATFORM=`echo ${platforms[$choice]} | awk -F':' '{ print $1 }'`
				break
			fi
		fi
		printf "Invalid input...\n"
	done
}

function select_os()
{
	local cnt=0
	local choice
	local os=""

	printf "All available OS:\n"
	for os in ${OSS[@]} ; do
		printf "%4d. %s\n" $cnt $os
		((cnt+=1))
	done

	while true ; do
		read -p "Choice: " choice
		if [ -z "${choice}" ] ; then
			continue
		fi

		if [ -z "${choice//[0-9]/}" ] ; then
			if [ $choice -ge 0 -a $choice -lt $cnt ] ; then
				_TARGET_OS="${OSS[$choice]}"
				break
			fi
		fi
		printf "Invalid input...\n"
	done
}

function select_board()
{
	local cnt=0
	local choice
	local boarddir
	local boards

	for boarddir in device/$_TARGET_PLATFORM/boards/* ; do
		boards[$cnt]=`basename $boarddir`
		[ -d $boarddir ] || continue
		printf "%4d. %s\n" $cnt ${boards[$cnt]}
		((cnt+=1))
	done

	while true ; do
		read -p "Choice: " choice
		if [ -z "${choice}" ] ; then
			continue
		fi

		if [ -z "${choice//[0-9]/}" ] ; then
			if [ $choice -ge 0 -a $choice -lt $cnt ] ; then
				_TARGET_BOARD="${boards[$choice]}"
				break
			fi
		fi
		printf "Invalid input...\n"
	done
}

select_platform
select_os
select_board

export _TARGET_CHIP
export _TARGET_ARCH
export _TARGET_PLATFORM
export _TARGET_OS
export _TARGET_BOARD