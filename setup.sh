#!/bin/bash

# By Ryuk Github | TG : [ anonymousx97 ]

red="\033[1;31m"
white="\033[1;37m"
green="\033[1;32m"
defaults=false

start(){
    clear
    local menu="${green}Main Menu:${white}"
    local options="
  1. Install packages
  2. Customize Termux
  3. Both (Uses Presets for customisation)
  4. Exit
"
    both(){
        defaults=true
        package_setup
        customize
    }
    declare -A start_options
    start_options[1]="package_setup"
    start_options[2]="customize"
    start_options[3]="both"
    start_options[4]="exit_"
    ask "${options}" "${menu}" "start_options"
}



customize(){
    clear
    local menu="${green}Customisation Menu:${white}"
    customize_all(){
        echo -e "${green}Customising All.${white}"
        setup_aria2
        setup_ytdlp
        setup_prettify
        setup_rxfetch
        change_cursor
        change_ui
        sleep 2
        clear
        rxfetch
    }
    if $defaults ; then
        customize_all
    else
        declare -A option_dict
        option_dict[1]="setup_aria2"
        option_dict[2]="setup_ytdlp"
        option_dict[3]="setup_prettify"
        option_dict[4]="setup_rxfetch"
        option_dict[5]="change_cursor"
        option_dict[6]="change_ui"
        option_dict[7]="customize_all"
        option_dict[8]="start"
        option_dict[9]="exit_"
        local options="
  1. Setup Aria2 Shortcut.
  2. Enable Downloading Audio or Video
     by sharing YT-DLP supported links to termux.
  3. Setup 'prettify' Bunch of py formatting tools.
  4. Setup Rxfetch.
  5. Change Cursor Style.
  6. Change Background and UI colour.
  7. All of the above.
  8. Go back to previous menu.
  9. Exit
"
        ask "${options}" "${menu}" "option_dict"
    fi
}



ask(){
    local header=" What do you want to do?"
    local option_text="$1"
    local menu="$2"
    local dict_name=$3
    echo -e "${menu}\n${header}${option_text}"
    while true;do
        read -p "> " choice
        if [ -z $choice ]; then
            clear
            echo -e "${menu}\n${header}${red}\n Choose an Option.${white}${option_text}"
        elif [[ -v ${dict_name}[$choice] ]]; then
            eval "\${${dict_name}[$choice]}"
            break 
        else
            clear
            echo -e "${menu}\n${header}${red}\n Invalid Input: ${white}${choice}${option_text}"
        fi
    done
}

package_setup(){
    # Update Termux Package Repository
    termux-change-repo
    yes|pkg upgrade
    apt update -y 
    apt upgrade -y

    # Install necessary packages
    apt install -y \
        python \
        python-pip \
        python-pillow \
        wget \
        curl \
        git \
        gh \
        openssh \
        sshpass \
        ffmpeg \
        aria2

    # Update pip packages
    pip install -U \
        wheel \
        setuptools \
        yt-dlp
}


setup_aria2(){
    echo -e "\n1. Setting up Aria2 shortcut"
    if ! [ -f $PATH/arc ] || $defaults ; then
        arc="#!$PATH/bash\ncd /sdcard/Download\nread -p 'Link or Magnet\n> ' x\naria2c $x"
        echo -e $arc > $PATH/arc
        chmod u+x $PATH/arc
        echo -e "${green}Done.${white}"
    else
        echo -e "${red}A script with the name arc exists in ${PATH}${white}"
    fi
}

setup_ytdlp(){
    echo -e "\n2. Downloading and Setting Up YT-DLP link share Trigger."
    mkdir -p $HOME/bin
    curl -s -O --output-dir $HOME/bin https://raw.githubusercontent.com/anonymousx97/termux-setup/main/termux-url-opener
    echo -e "${green}Done.${white}"
}

setup_prettify(){
    echo -e "\n3. Downloading and Setting up Prettify script." 
    curl -s -O --output-dir $PATH https://raw.githubusercontent.com/anonymousx97/termux-setup/main/prettify
    echo -e "${green}Done.${white}"
}

setup_rxfetch(){
    echo -e "\n4. Downloading and Setting up Rxfetch"
    curl -s -O --output-dir $PATH https://raw.githubusercontent.com/anonymousx97/termux-setup/main/rxfetch
    motd="#!$SHELL\nbash rxfetch"

    if [ -f ~/.termux/motd.sh ] && ! $defaults ; then
        echo -e "${red}A custom start script exists in the path ${HOME}/.termux/motd.sh${white}"
        echo -e "  Enter 1 to overwrite the current file.\n  Press Enter to skip."
        read -p "> " prompt_
        if ! [ $prompt_ ] ||  ! [ $prompt_ == 1 ] ; then
            echo -e "${green}Skipping motd modification.${white}"
        else
            echo -e "${red}Overwriting motd.${white}"
            echo -e $motd > ~/.termux/motd.sh
        fi
    else
        echo -e $motd > ~/.termux/motd.sh
    fi
    echo -e "${green}Done.${white}"
}


change_cursor(){
    echo -e "\n5. Changing Cursor"
    local menu="Cursor Menu:"
    local options="
  1. Change to ${green}|${white} (bar)
  2. Change to ${green}_${white} (underscore)
  3. Change to Default Block style.
  4. Exit
"
    block(){ printf '\e[1 q'; }
    bar(){ printf '\e[6 q'; }
    underscore(){ printf '\e[4 q'; }

    if ! $defaults ; then
        clear
        declare -A cursor_dict
        cursor_dict[1]="bar"
        cursor_dict[2]="underscore"
        cursor_dict[3]="block"
        cursor_dict[4]="exit_"
        ask "${options}" "${menu}" "cursor_dict"
    else
        underscore
    fi

    # Change Blink Rate
    sed -i "s/terminal-cursor-blink-rate.*/terminal-cursor-blink-rate = 600/" ~/.termux/termux.properties
    echo -e "${green}Done.${white}"
}


exit_(){
    echo -e "${green}Exiting...${white}"
    exit
}


change_ui(){
    echo -e "\n6. Changing UI and background colour."
    curl -s -O --output-dir $PATH ~/.termux https://raw.githubusercontent.com/anonymousx97/termux-setup/main/colors.properties
    echo -e "\n${green}Applying Changes.${white}"
    termux-reload-settings
    echo -e "${green}Done.${white}"
}

start
