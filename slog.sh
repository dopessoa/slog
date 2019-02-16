#!/bin/sh

#
# name: slog
# function: A simple log writer lib for bash scripts.
# version: 1.1 (2019-02-16)
# created: Sep 09, 2014
#

usage(){
  echo "Usage : slog.sh [OPTIONS]
        Default log pattern: <category> | <YYYY-MM-DD HH:MM:SS,mss> | [<function>] | <file>.<line> | (pid:<pid>) | <message>
        -s, --separator <separator>                       set the separator for the default logfile.
        -d, --date-format <date format>                   set the format of the date string (refer to date command formatting options).
        -l, --log-level <DEBUG|INFO|WARN|ERROR>           set the log level.
        -p, --pattern \"<log pattern>\"                     set the log pattern.
              %c=Log Category
              %d=Date/Time
              %F=Filename of the logging request
              %L=Line number of the logging request
              %M=Function of the logging request
              %m=Log Message
              %t=Pid of the process requesting the log
        Example: Default log pattern in log pattern notation: \"%c | %d | %M | %F.%L | %t | %m\"
        -f, --file <logFile>                              set the log file for output, if no file is set, use the console as output.
        -t, --use-tee                                     print the output to the console too.
        -h, --help                                        print this help then exit.
        -v, --version                                     print the script version then exit."
}

version(){
  echo "slog.sh $(grep 'version' slog.sh | cut -d ' ' -f2-5)" | head -1
}

while [ "$1" != "" ]; do
    case $1 in
        -s | --separator )      shift
                                separator="$1"
                                ;;
        -d | --date-format )    shift
                                dateFormat="$1"
                                ;;
        -l | --log-level )      shift
                                logLevel="$1"
                                ;;
        -p | --pattern )        shift
                                logPattern="$1"
                                ;;
        -f | --file )           shift
                                logFile="$1"
                                ;;
        -h | --help )           usage
                                exit 0
                                ;;
        -v | --version)         version
                                exit 0
                                ;;
        -t | --use-tee)         useTee="TRUE"
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

if [ -z "$useTee" ]; then
  useTee="FALSE"
fi

if [ -n "$logFile" ]; then
  touch $logFile > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo "Could not write logfile." >&2
    echo "$(touch $logFile)" > /dev/null 2>&1
    exit 2
  fi
fi

# If no date formatting options passed, set it to default
if [ -z "$dateFormat" ]; then
  # Default iso-8601 format
  dateFormat="%F %T,%3N"
fi

# Not passing logLevel as parameter
if [ -z "$logLevel" ]; then
  # LogLevel configuration
  logLevel="DEBUG"
fi

if [ -z "$separator" ]; then
  separator="|"
fi

case $logLevel in
     DEBUG)      logLevelNum=4 
                 ;;
     INFO)       logLevelNum=3
                 ;;
     WARN)       logLevelNum=2
                 ;;
     ERROR)      logLevelNum=1
                 ;;
        * )      echo "LogLevel configuration is incorrect, please set one of DEBUG, INFO, WARN or ERROR."
                 exit 1
esac

if [ -z "$logPattern" ]; then
  logPattern='$logCategory ${separator} $(printDate) ${separator} [${FUNCNAME[ 1 ]}] ${separator} ${logOrigin}:${lineNo} ${separator} (pid:$$) ${separator} $1'
else
  logPattern=$(echo "${logPattern}" | sed s/%c/'$logCategory'/ | sed s/%d/'$(printDate)'/ | sed s/%F/'$logOrigin'/ | sed s/%L/'$lineNo'/ | sed s/%m/'$1'/ | sed s/%t/'$$'/)
fi

# Print the date in the given format
printDate() {
  date "+${dateFormat}"
}

logDebug() {
  if [ $logLevelNum -ge 4 ]; then
    logCategory="DEBUG"
    lineNo=$(caller | cut -d ' ' -f1)
    logOrigin=$(basename $(caller | cut -d ' ' -f2))
    writeLog $(eval "echo \"$logPattern\"")
  fi
}

logInfo() {
  if [ $logLevelNum -ge 3 ]; then
    logCategory="INFO"
    lineNo=$(caller | cut -d ' ' -f1)
    logOrigin=$(basename $(caller | cut -d ' ' -f2))
    writeLog $(eval "echo \"$logPattern\"")
  fi
}

logWarn() {
  if [ $logLevelNum -ge 2 ]; then
    logCategory="WARN"
    lineNo=$(caller | cut -d ' ' -f1)
    logOrigin=$(basename $(caller | cut -d ' ' -f2))
    writeLog $(eval "echo \"$logPattern\"")
  fi
}

logError() {
  if [ $logLevelNum -ge 1 ]; then
    logCategory="ERROR"
    lineNo=$(caller | cut -d ' ' -f1)
    logOrigin=$(basename $(caller | cut -d ' ' -f2))
    writeLog $(eval "echo \"$logPattern\"")
  fi
}

# Write the log
writeLog() {
  logString="$@"
  # Empty logFile configuration, print only to console
  if [ -z $logFile ]; then
    echo "$logString"
  else
    if [ $useTee = "TRUE" ]; then
      echo "$logString" >> $logFile
      echo "$logString"
    fi
  fi
}
