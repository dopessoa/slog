Slog
====

Slog is a simple logging library for shell scripts which is focused in being simple to use yet customizable.

Quickstart:
-----------

Just source slog.sh in your script with your parameters and start using the log printing functions.

	#!/bin/sh

	source lib/slog.sh

	logDebug "slog.sh sourced succesfully!"

	workFunction(){
	  logInfo "Starting work..."
	  logInfo "..."
	  logInfo "50% of work done..."
	  logWarn "Something strange is happening."
	}

	workFunction

	logError "Epic fail. :("


Example of output:
------------------

	[dopessoa@slogsys ~]# ./test_logging.sh
	DEBUG | 2014-10-10 01:31:30,626 | [main] | test_logging.sh:5 | (pid:16206) | slog.sh sourced succesfully!
	INFO | 2014-10-10 01:31:30,635 | [workFunction] | test_logging.sh:8 | (pid:16206) | Starting work...
	INFO | 2014-10-10 01:31:30,643 | [workFunction] | test_logging.sh:9 | (pid:16206) | ...
	INFO | 2014-10-10 01:31:30,651 | [workFunction] | test_logging.sh:10 | (pid:16206) | 50% of work done...
	WARN | 2014-10-10 01:31:30,660 | [workFunction] | test_logging.sh:11 | (pid:16206) | Something strange is happening.
	ERROR | 2014-10-10 01:31:30,668 | [main] | test_logging.sh:16 | (pid:16206) | Epic fail. :(

Help:
-----

Help can be obtained with the -h or --help parameter.

	[dopessoa@slogsys]# ./slog.sh -h
	Usage : slog.sh [OPTIONS]
	        Default log pattern: <category> | <YYYY-MM-DD HH:MM:SS,mss> | [<function>] | <file>.<line> | (pid:<pid>) | <message>
	        -s, --separator <separator>                       set the separator for the default logfile.
	        -d, --date-format <date format>                   set the format of the date string (refer to date command formatting options).
	        -l, --log-level <DEBUG|INFO|WARN|ERROR>           set the log level.
	        -p, --pattern "<log pattern>"                     set the log pattern.
	              %c=Log Category
	              %d=Date/Time
	              %F=Filename of the logging request
	              %L=Line number of the logging request
	              %M=Function of the logging request
	              %m=Log Message
	              %t=Pid of the process requesting the log
	        Example: Default log pattern in log pattern notation: "%c | %d | %M | %F.%L | %t | %m"
	        -f, --file <logFile>                              set the log file for output, if no file is set, use the console as output.
	        -t, --use-tee                                     print the output to the console too.
	        -h, --help                                        print this help then exit.
	        -v, --version                                     print the script version then exit.

