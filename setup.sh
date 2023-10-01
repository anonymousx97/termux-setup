#!/bin/bash

# By Ryuk Github | TG : [ anonymousx97 ]

red="\033[1;31m"
white="\033[0m"
green="\033[1;32m"
defaults=false

start(){
    clear
    local menu="${green}Main Menu:${white}"
    local options="
  1. Install Essential packages.
  2. Customize Termux
  3. Setup Debian in Termux.
  4. All (Uses Presets for customisation)
  5. Exit
"
    all(){
        defaults=true
        package_setup
        customize
        setup_debian
    }
    declare -A start_options
    start_options[1]="package_setup"
    start_options[2]="customize"
    start_options[3]="setup_debian"
    start_options[4]="all"
    start_options[5]="exit_"
    ask "${options}" "${menu}" "start_options"
    if ! [ "$( ls /sdcard/ 2> /dev/null )" ]; then
        termux-setup-storage
    fi
}



customize(){
    clear
    local menu="${green}Customisation Menu:${white}"
    customize_all(){
        echo -e "${green}Customising All.${white}"
        defaults=true
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
  6. Change Colour and Font.
  7. All of the above. ( Uses Presets )
  8. Go back to previous menu.
  9. Exit
"
        ask "${options}" "${menu}" "option_dict"
    fi
}



ask(){
    local header="What do you want to do?"
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
        aria2 \
        curl \
        ffmpeg \
        git \
        gh \
        openssh \
        python \
        python-pip \
        python-pillow \
        sshpass \
        tmux \
        tsu \
        wget \

    # Update and Install pip packages
    pip install -U \
        wheel \
        setuptools \
        yt-dlp \
        black \
        isort \
        autopep8 \
        autoflake
}


setup_aria2(){
    echo -e "\n1. Downloading Aria2 shortcut"
    if ! [ -f $PATH/arc ] || $defaults ; then
        curl -s -O --output-dir $PATH https://raw.githubusercontent.com/anonymousx97/termux-setup/main/bin/arc
        chmod u+x $PATH/arc
        echo -e "${green}Done.${white}"
    else
        echo -e "${red}A script with the name 'arc' exists in ${PATH}${white}"
    fi
}

setup_debian(){
    apt update
    apt install -y root-repo x11-repo
    apt install -y \
    proot \
    proot-distro \
    termux-x11-nightly \
    pulseaudio 

    proot-distro install debian
    clear
    local options="
1. Install xfce4
2. Install KDE
3. Exit
"
    declare -A wm_dict
    wm_dict[1]="export wm=xfce4 wm2=xfce4-goodies wm_cmd=startxfce4"
    wm_dict[2]="export wm=kde-standard wm_cmd=startplasma-x11"
    wm_dict[3]="exit_"

    ask "${options}" "Window Manager Menu:" "wm_dict"

    proot-distro login debian  --termux-home --shared-tmp -- bash -c "
    apt update && \
    apt install -y --no-install-recommends \
    firefox-esr \
    ${wm} \
    ${wm2} \
    locales \
    fonts-noto-cjk && \
    echo en_US.UTF-8 UTF-8 >> /etc/locale.gen && \
    locale-gen && \
    echo 'LANG=en_US.UTF-8' > /etc/locale.conf "

    curl -s -O --output-dir $HOME https://raw.githubusercontent.com/anonymousx97/termux-setup/main/scripts/debian.sh
    sed -i "s/wm_start_cmd/${wm_cmd}/" $HOME/debian.sh
    echo -e '\nalias dcli="proot-distro login debian --termux-home --shared-tmp -- bash" \nalias dgui="bash debian.sh"\n' >> $HOME/.bashrc
    echo '
check_distro(){
    if [[ "$(whoami)" == "root" ]]; then
        export HISTFILE="~/.debian_history"
    fi
}
check_distro
' >> $HOME/.bashrc
    echo "Done."
    echo -e "You can now use '${green}dcli${white}' for debian cli and '${green}dgui${white}' for GUI (Termux x11 app required)."
}


setup_ytdlp(){
    echo -e "\n2. Downloading files and Setting Up YT-DLP link share Trigger."
    mkdir -p $HOME/bin
    curl -s -O --output-dir $HOME/bin https://raw.githubusercontent.com/anonymousx97/termux-setup/main/bin/termux-url-opener
    echo -e "${green}Done.${white}"
}

setup_prettify(){
    echo -e "\n3. Downloading and Setting up Prettify script." 
    curl -s -O --output-dir $PATH https://raw.githubusercontent.com/anonymousx97/termux-setup/main/bin/prettify
    chmod u+x $PATH/prettify
    echo -e "${green}Done.${white}"
}

setup_rxfetch(){
    echo -e "\n4. Downloading and Setting up Rxfetch"
    curl -s -O --output-dir $PATH https://raw.githubusercontent.com/anonymousx97/termux-setup/main/bin/rxfetch
    chmod u+x $PATH/rxfetch
    local motd="#!$SHELL\nbash rxfetch"

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
    if ! $defaults ; then
        clear
        declare -A cursor_dict
        cursor_dict[1]="eval printf '\e[6 q' && export style=bar"
        cursor_dict[2]="eval printf '\e[4 q' && export style=underline"
        cursor_dict[3]="eval printf '\e[1 q' && export style=block"
        cursor_dict[4]="exit_"
        ask "${options}" "${menu}" "cursor_dict"
    else
        printf '\e[6 q'
        style=bar
    fi
    # Set the style in termux properties 
    sed -i "s/.*terminal-cursor-style.*/terminal-cursor-style = ${style}/" $HOME/.termux/termux.properties
    # Change Blink Rate
    sed -i "s/.*terminal-cursor-blink-rate.*/terminal-cursor-blink-rate = 600/" $HOME/.termux/termux.properties
   echo -e "${green}Done.${white}"
}


change_ui(){
    local colors="colors.properties.dark_blue"
    if ! $defaults; then 
        echo -e "\n6. Changing Colour and Font."
        local ui_options="\n1. Set Dark Blue\n2. Set Light Blue"
        declare -A ui_dict
        ui_dict[1]="export colors=colors.properties.dark_blue"
        ui_dict[2]="export colors=colors.properties.light_blue"
        clear
        ask "${ui_options}" "${green}UI Menu${white}" "ui_dict"
    fi
    curl -s -o $HOME/.termux/colors.properties https://raw.githubusercontent.com/anonymousx97/termux-setup/main/.termux/"${colors}"
    wget -q -O $HOME/.termux/font.ttf https://raw.githubusercontent.com/anonymousx97/termux-setup/main/.termux/MesloLGS_NF_Bold.ttf
    echo -e "\n${green}Applying Changes.${white}"
    termux-reload-settings
    echo -e "${green}Done.${white}"
}


exit_(){
    echo -e "${green}Exiting...${white}"
    exit
}

save_setup_sh(){
    if ! [ -f $PATH/setup-termux ]; then
        echo -e "\nSaving setup.sh for future use."
        echo -e '#!/bin/bash\nbash -c "$(curl -fsSL https://raw.githubusercontent.com/anonymousx97/termux-setup/main/setup.sh)"' > $PATH/setup-termux
        chmod u+x $PATH/setup-termux
        echo -e "${green}Done\n${white}You can now use ${green}'setup-termux'${white} to get back to this menu."
    fi
}

start
save_setup_sh
