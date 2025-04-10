#!/usr/bin/env bash

# function to clean up files and make executables
remake () {
    # echo -e "\ old files and making executables"
    make -s clean
    make -s >/dev/null 2>&1
}


echo -e "To remove colour from tests, set COLOUR to 1 in sh file\n"
COLOUR=0
if [[ COLOUR -eq 0 ]]; then
    ORANGE='\033[0;33m'
    GREEN='\033[0;32m'
    RED='\033[0;31m'
    NC='\033[0m'
else
    ORANGE='\033[0m'
    GREEN='\033[0m'
    RED='\033[0m'
    NC='\033[0m'
fi

SCORE=0

echo -e "\nStart testing"
remake
echo -e "\nTesting :: Compilation\n"
echo -e "  ${GREEN}Test #1 Passed${NC}"
SCORE=$(($SCORE+10))



remake
echo -e "\nTesting :: Correct ls -l when exiting normally - ./main -n 0\n"
echo -e "n\nr\n"|gdb --args ./main -n 0 > test_normal_log.txt
sleep 6 #in case no valid wait() call in main.cpp
child_pid=`grep -Pzo "(?<=child process )[0-9]+" test_normal_log.txt`
parent_pid=`grep -Pzo "(?<=\(process )[0-9]+" test_normal_log.txt`
RES=$(. ./test-files/test_normal.txt)
echo "$RES" > test_normal_reference.txt
EXIT_MSG=$(echo "$RES"|tail -1)
if  [ $(grep -o "`ls -l`" test_normal_log.txt|wc -l) -ge 1 ]; then
    echo -e "  ${GREEN}Test #2 Passed${NC}"
    SCORE=$(($SCORE+9))
else
    echo -e "  ${RED}Failed${NC}"
fi
echo -e "\nTesting :: Correct exit message when exiting normally - ./main -n 0\n"
if  [ $(grep -o "${EXIT_MSG}" test_normal_log.txt|wc -l) -ge 1 ]; then
    echo -e "  ${GREEN}Test #3 Passed${NC}"
else
    echo -e "  ${RED}Failed${NC}"
fi
echo -e "\nTesting :: Correct parent PID when exiting normally - ./main -n 0\n"
if  [ $(grep -o "$parent_pid" test_normal_log.txt|wc -l) -ge 2 ]; then
    echo -e "  ${GREEN}Test #4 Passed${NC}"
    SCORE=$(($SCORE+4))
else
    echo -e "  ${RED}Failed${NC}"
fi
echo -e "\nTesting :: Correct child PID when exiting normally - ./main -n 0\n"
if  [ $(grep -o "$child_pid" test_normal_log.txt|wc -l) -ge 2 ]; then
    echo -e "  ${GREEN}Test #5 Passed${NC}"
    SCORE=$(($SCORE+4))
else
    echo -e "  ${RED}Failed${NC}"
fi




remake
echo -e "\nTesting :: Correct wait or waitpid\n"
echo -e "n\nr\n"|gdb --args ./main -n 1 > test_kill_log.txt
child_pid=`grep -Pzo "(?<=child process )[0-9]+" test_kill_log.txt`
parent_pid=`grep -Pzo "(?<=\(process )[0-9]+" test_kill_log.txt`
RES=$(. ./test-files/test_kill.txt)
echo "$RES" > test_kill_reference.txt
EXIT_MSG=$(echo "$RES"|tail -1)
if  [ $(grep -Pzo 'wait\((?!\s*NULL\s*)\s*\&*[a-zA-Z]+\s*\);' main.cpp|wc -w) -ge 1 ] ||
    [ $(grep -Pzo 'waitpid\(.*,(?!\s*NULL\s*)\s*\&*[a-zA-Z]+\s*,.*\);' main.cpp|wc -w) -ge 1 ]; then
    echo -e "  ${GREEN}Test #6 Passed${NC}"
    SCORE=$(($SCORE+9))
else
    echo -e "  ${RED}Failed${NC}"
fi
echo -e "\nTesting :: Correct exit message when exiting with kill - ./main -n 1\n"
if  [ $(grep -o "${EXIT_MSG}" test_kill_log.txt|wc -l) -ge 1 ]; then
    echo -e "  ${GREEN}Test #7 Passed${NC}"
else
    echo -e "  ${RED}Failed${NC}"
fi
echo -e "\nTesting :: Correct parent PID when exiting with kill - ./main -n 1\n"
if  [ $(grep -o "$parent_pid" test_kill_log.txt|wc -l) -ge 2 ]; then
    echo -e "  ${GREEN}Test #8 Passed${NC}"
    SCORE=$(($SCORE+4))
else
    echo -e "  ${RED}Failed${NC}"
fi
echo -e "\nTesting :: Correct child PID when exiting with kill - ./main -n 1\n"
if  [ $(grep -o "$child_pid" test_kill_log.txt|wc -l) -ge 2 ]; then
    echo -e "  ${GREEN}Test #9 Passed${NC}"
    SCORE=$(($SCORE+4))
else
    echo -e "  ${RED}Failed${NC}"
fi




echo -e "\nTesting :: Correct sleep\n"
if  [ $(grep -Pzo "sleep\s*\(.*6.*\)" main.cpp|wc -w) -ge 1 ]; then
    echo -e "  ${GREEN}Test #10 Passed${NC}"
    SCORE=$(($SCORE+2))
else
    echo -e "  ${RED}Failed${NC}"
fi
echo -e "\nTesting :: Correct WIFSIGNALED\n"
if  [ $(grep -Pzo "WIFSIGNALED\s*\(.+\)" main.cpp|wc -w) -ge 1 ]; then
    echo -e "  ${GREEN}Test #11 Passed${NC}"
    SCORE=$(($SCORE+2))
else
    echo -e "  ${RED}Failed${NC}"
fi

echo -e "\nTesting :: Correct WIFEXITED\n"
if  [ $(grep -Pzo "WIFEXITED\s*\(.+\)" main.cpp|wc -w) -ge 1 ]; then
    echo -e "  ${GREEN}Test #12 Passed${NC}"
    SCORE=$(($SCORE+2))
else
    echo -e "  ${RED}Failed${NC}"
fi

# print score and delete executable
echo -e "\nSCORE: ${SCORE}/50\n"
make -s clean

exit 0
