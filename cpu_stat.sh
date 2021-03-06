#!/bin/sh
while getopts i:p:g OPT
do
	case $OPT in
		"i" ) FLG_INTERVAL="TRUE" ; VAL_INTERVAL="$OPTARG" ;;
		"p" ) FLG_PLOT="TRUE" ; VAL_PLOT="$OPTARG" ;;
		"g" ) FLG_DEBUG="TRUE" ;;
	esac
done
if [ "${FLG_INTERVAL}" = "TRUE" ]; then
	INTERVAL=${VAL_INTERVAL};
else
	INTERVAL=5;
fi
if [ "${FLG_PLOT}" = "TRUE" ]; then
	PLOT=${VAL_PLOT};
else
	PLOT=30;
fi
PERL_CPU_STAT=`dirname $0`/cpu_stat.pl;
PERL_CPU_STAT_FORM_ROW=`dirname $0`/cpu_stat_form_row.pl;
PROC_STAT0_FILE=proc_stat0.tmp
PROC_STAT1_FILE=proc_stat1.tmp
CPU_STAT_FILE=cpu_stat.tmp
PLOT_DATA_FILE=cpu_stat.plot
ERROR_FILE=error.tmp
PLOT_DATA_NO=0
if [ -e ${PLOT_DATA_FILE} ]; then
	echo "remove old plot data."
	rm ${PLOT_DATA_FILE}
fi
trap 'rm -f ${PROC_STAT0_FILE};
      rm -f ${PROC_STAT1_FILE};
      rm -f ${CPU_STAT_FILE};
      rm -f ${ERROR_FILE};' EXIT
PLOTTING=0
DEVICES=`adb devices`
CPU_PRESENT=`adb shell cat /sys/devices/system/cpu/present 2>/dev/null`
adb shell cat /proc/stat 1> ${PROC_STAT0_FILE} 2>/dev/null
sleep ${INTERVAL}
while :
do
	DATE=`date +'%m-%d %H:%M:%S'`
	CPU_ONLINE=`adb shell cat /sys/devices/system/cpu/online 2>/dev/null`
	CPU0_FREQ_MAX=`adb shell cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq 2>/dev/null`
	CPU0_FREQ_MIN=`adb shell cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq 2>/dev/null`
	CPU1_FREQ_MAX=`adb shell cat /sys/devices/system/cpu/cpu1/cpufreq/cpuinfo_max_freq 2>/dev/null`
	CPU1_FREQ_MIN=`adb shell cat /sys/devices/system/cpu/cpu1/cpufreq/cpuinfo_min_freq 2>/dev/null`
	CPU2_FREQ_MAX=`adb shell cat /sys/devices/system/cpu/cpu2/cpufreq/cpuinfo_max_freq 2>/dev/null`
	CPU2_FREQ_MIN=`adb shell cat /sys/devices/system/cpu/cpu2/cpufreq/cpuinfo_min_freq 2>/dev/null`
	CPU3_FREQ_MAX=`adb shell cat /sys/devices/system/cpu/cpu3/cpufreq/cpuinfo_max_freq 2>/dev/null`
	CPU3_FREQ_MIN=`adb shell cat /sys/devices/system/cpu/cpu3/cpufreq/cpuinfo_min_freq 2>/dev/null`
	CPU0_FREQ=`adb shell cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq 2>/dev/null`
	CPU1_FREQ=`adb shell cat /sys/devices/system/cpu/cpu1/cpufreq/scaling_cur_freq 2>/dev/null`
	CPU2_FREQ=`adb shell cat /sys/devices/system/cpu/cpu2/cpufreq/scaling_cur_freq 2>/dev/null`
	CPU3_FREQ=`adb shell cat /sys/devices/system/cpu/cpu3/cpufreq/scaling_cur_freq 2>/dev/null`
	adb shell cat /proc/stat 1> ${PROC_STAT1_FILE} 2>/dev/null

	echo "\n[CPU STAT]" | tee ${CPU_STAT_FILE}
	echo "no            : ${PLOT_DATA_NO}" | tee -a ${CPU_STAT_FILE}
	echo "date          : ${DATE}" | tee -a ${CPU_STAT_FILE}
	echo "cpu_present   : ${CPU_PRESENT}" | tee -a ${CPU_STAT_FILE}
	echo "cpu_online    : ${CPU_ONLINE}" | tee -a ${CPU_STAT_FILE}
	if expr "${CPU0_FREQ_MAX}" : "^[0-9]*" > /dev/null; then
		echo "cpu0_max_freq : ${CPU0_FREQ_MAX}" | tee -a ${CPU_STAT_FILE}
	fi
	if expr "${CPU1_FREQ_MAX}" : "^[0-9]*" > /dev/null; then
		echo "cpu1_max_freq : ${CPU1_FREQ_MAX}" | tee -a ${CPU_STAT_FILE}
	fi
	if expr "${CPU2_FREQ_MAX}" : "^[0-9]*" > /dev/null; then
		echo "cpu2_max_freq : ${CPU2_FREQ_MAX}" | tee -a ${CPU_STAT_FILE}
	fi
	if expr "${CPU3_FREQ_MAX}" : "^[0-9]*" > /dev/null; then
		echo "cpu3_max_freq : ${CPU3_FREQ_MAX}" | tee -a ${CPU_STAT_FILE}
	fi
	if expr "${CPU0_FREQ_MIN}" : "^[0-9]*" > /dev/null; then
		echo "cpu0_min_freq : ${CPU0_FREQ_MIN}" | tee -a ${CPU_STAT_FILE}
	fi
	if expr "${CPU1_FREQ_MIN}" : "^[0-9]*" > /dev/null; then
		echo "cpu1_min_freq : ${CPU1_FREQ_MIN}" | tee -a ${CPU_STAT_FILE}
	fi
	if expr "${CPU2_FREQ_MIN}" : "^[0-9]*" > /dev/null; then
		echo "cpu2_min_freq : ${CPU2_FREQ_MIN}" | tee -a ${CPU_STAT_FILE}
	fi
	if expr "${CPU3_FREQ_MIN}" : "^[0-9]*" > /dev/null; then
		echo "cpu3_min_freq : ${CPU3_FREQ_MIN}" | tee -a ${CPU_STAT_FILE}
	fi
	if expr "${CPU0_FREQ}" : "^[0-9]*" > /dev/null; then
		echo "cpu0_freq     : ${CPU0_FREQ}" | tee -a ${CPU_STAT_FILE}
	fi
	if expr "${CPU1_FREQ}" : "^[0-9]*" > /dev/null; then
		echo "cpu1_freq     : ${CPU1_FREQ}" | tee -a ${CPU_STAT_FILE}
	fi
	if expr "${CPU2_FREQ}" : "^[0-9]*" > /dev/null; then
		echo "cpu2_freq     : ${CPU2_FREQ}" | tee -a ${CPU_STAT_FILE}
	fi
	if expr "${CPU3_FREQ}" : "^[0-9]*" > /dev/null; then
		echo "cpu3_freq     : ${CPU3_FREQ}" | tee -a ${CPU_STAT_FILE}
	fi
	if [ "${FLG_DEBUG}" = "TRUE" ]; then
		echo "--- /proc/stat ---"
		echo "previous      :\n`cat ${PROC_STAT0_FILE}`"
		echo "current       :\n`cat ${PROC_STAT1_FILE}`"
	fi
	CPU_STAT=`perl ${PERL_CPU_STAT} ${PROC_STAT0_FILE} ${PROC_STAT1_FILE} 2>${ERROR_FILE}`
	RESULT=$?
	cp ${PROC_STAT1_FILE} ${PROC_STAT0_FILE}
	echo "--- cpu usage ---" | tee -a ${CPU_STAT_FILE}
	if [ "${RESULT}" != "0" ]; then
		echo "An error occurred!\n`cat ${ERROR_FILE}`"
	else
		cat ${ERROR_FILE}
		echo "${CPU_STAT}" | tee -a ${CPU_STAT_FILE}
	fi
	PLOT_DATA=`perl ${PERL_CPU_STAT_FORM_ROW} ${CPU_STAT_FILE} 2>${ERROR_FILE}`
	RESULT=$?
	echo "--- plot data ---"
	if [ "${RESULT}" != "0" ]; then
		echo "An error occurred!\n`cat ${ERROR_FILE}`"
	else
		cat ${ERROR_FILE}
		echo ${PLOT_DATA} | tee -a ${PLOT_DATA_FILE}
		if [ "${PLOTTING}" = "0" ]; then
			cpu_stat_plot.sh -i 5 -s "< tail -${PLOT} ${PLOT_DATA_FILE}" &
			PLOTTING=1;
		fi
	fi

	PLOT_DATA_NO=`expr $PLOT_DATA_NO + 1`

	sleep ${INTERVAL}
done
