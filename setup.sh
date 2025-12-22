#!/usr/bin/env bash

# By Ryuk Github | TG : [ anonymousx97 ]

red="\033[1;31m"
reset="\033[0m"
green="\033[1;32m"
defaults=0

download() {
	local dir="$1"
	local file="$2"
	local url="$3"

	mkdir -p "$dir"
	curl -sL -o "${dir%%/}/${file}" "$url"
}

print() {
	builtin echo -e "$@"
}

print_green() {
	print "${green}${*}${reset}"
}

graceful_exit() {
	print_green "Exiting..."
	exit
}

index_options_str() {
	local options_str=""

	idx=0
	for i in "$@"; do
		# Index with idx+1
		((idx++))
		options_str+="  ${idx}. ${i}"
		# add newline only if theres more  data
		((idx << $#)) && options_str+=$'\n'

	done

	printf '%s' "$options_str"
}

ask() {
	clear

	local header="What do you want to do?"
	local menu="$1"
	local option_text="$2"
	local -n arg_array="$3"

	local text_to_print="${green}${menu}:${reset}\n${header}\n${option_text}"

	print "$text_to_print"

	while true; do

		read -r -p "> " choice

		if [[ -z "${choice}" || ! "$choice" =~ ^[0-9]+$ || $choice -le 0 || ! -v arg_array[$((--choice))] ]]; then
			clear
			print "${text_to_print}${red}\n Invalid input.${reset}"
			continue

		fi

		"${arg_array[$choice]}" "$choice"
		break

	done
}

run_all() {
	export defaults=1
	package_setup
	customize_all
}

start() {
	# Setup Storage Permissions
	! [[ -w /sdcard && -r /sdcard ]] && termux-setup-storage

	local options=(
		"Install Essential packages."
		"Customize Termux."
		"Both 1 & 2 (Uses Presets for customisation)"
		"Setup Native GUI in Termux."
		"Exit"
	)

	export start_options_arr=(
		package_setup
		customize
		run_all
		setup_native_gui
		graceful_exit
	)

	ask "Main Menu" "$(index_options_str "${options[@]}")" "start_options_arr"
}

customize_all() {
	print_green "Customising All."
	export defaults=1
	setup_apm
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

customize() {

	export option_dict=(
		setup_apm
		setup_aria2
		setup_ytdlp
		setup_rxfetch
		change_cursor
		change_ui
		customize_all
		start
		graceful_exit
	)

	local options=(
		"Setup Android Package Manager by Ryuk."
		"Setup Aria2 Shortcut."
		"Enable Downloading Magnets or YT-DLP supported links by sharing to termux."
		"Setup Rxfetch."
		"Change Cursor Style."
		"Change Colour and Font."
		"All of the above. ( Uses Presets )"
		"Go back to previous menu."
		"Exit"
	)
	ask "Customisation Menu" "$(index_options_str "${options[@]}")" "option_dict"

}

package_setup() {
	# Update Termux Package Repository
	termux-change-repo

	yes | pkg upgrade
	apt update -y && apt upgrade -y

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
		tmux \
		tsu \
		wget \
		root-repo \
		x11-repo \
		tur-repo

	# Sets up Termux's PIP Index repo
	download "${HOME}/.config/pip/" "pip.conf" \
		"https://raw.githubusercontent.com/anonymousx97/termux-setup/main/configs/pip.conf"

	# Setup .bashrc
	cat <<-EOF >>"${HOME}/.bashrc"
		$(curl -fsSL https://raw.githubusercontent.com/anonymousx97/termux-setup/main/configs/.bashrc)
	EOF

	# Update and Install pip packages
	pip install -U \
		wheel \
		setuptools \
		yt-dlp
}

setup_debian() {
	apt update
	apt install -y
	apt install -y \
		proot \
		proot-distro \
		termux-x11-nightly \
		pulseaudio

	proot-distro install debian

	clear

	local options=("Install xfce4" "Install KDE" "Exit")

	wm=""
	wm_cmd=""

	export wm_dict=(
		"export wm=xfce4 wm_cmd=startxfce4"
		"export wm=kde-standard wm_cmd=startplasma-x11"
		"graceful_exit"
	)

	ask "Window Manager Menu" "$(index_options_str "${options[@]}")" "wm_dict"

	proot-distro login debian --termux-home --shared-tmp -- bash -c <<-EOF
		        apt update -y

		        apt install -y \
		            firefox-esr \
		            ${wm} \
		            xfce4-goodies \
		            locales \
		            fonts-noto-cjk

		        ln -sf /usr/share/zoneinfo/Asia/Calcutta /etc/localtime

		        echo en_US.UTF-8 UTF-8 >> /etc/locale.gen

		        locale-gen

		        echo 'LANG=en_US.UTF-8' > /etc/locale.conf
	EOF

	download "${HOME}" "debian.sh" \
		"https://raw.githubusercontent.com/anonymousx97/termux-setup/main/scripts/debian.sh"

	sed -i "s/wm_start_cmd/${wm_cmd}/" "${HOME}/debian.sh"

	cat <<-EOF >>"${HOME}/.bashrc"
		alias dcli="proot-distro login debian --termux-home --shared-tmp -- bash"
		alias dgui="bash debian.sh"

		[[ "$(whoami)" == "root" ]] && export HISTFILE=~/.debian_history

	EOF

	print_green "Done."

	print "You can now use '${green}dcli${reset}' for debian cli and '${green}dgui${reset}' for GUI (Termux x11 app required)."

}

setup_native_gui() {
	apt update -y && apt install -y i3 rofi feh alacritty proot termux-x11-nightly

	download "${HOME}.config/i3" "config" \
		"https://raw.githubusercontent.com/anonymousx97/termux-setup/main/configs/i3"

	download "${HOME}.config/alacritty" "alacritty.toml" \
		"https://raw.githubusercontent.com/anonymousx97/termux-setup/main/configs/alacritty.toml"

	download "$HOME" "gui.sh" \
		"https://raw.githubusercontent.com/anonymousx97/termux-setup/main/scripts/gui.sh"

	chmod +x "${HOME}/gui.sh"

	gui_alias="alias gui='~/gui.sh'"

	! grep -q "$gui_alias" ~/.bashrc && echo "$gui_alias" >> ~/.bashrc

}

setup_apm() {
	print "\n1. Downloading Android Package Manager By Ryuk."

	download "${PATH}" "apm" \
		"https://raw.githubusercontent.com/anonymousx97/termux-setup/main/bin/apm"

	chmod +x "${PATH}/apm"

	print "${green}Done.${reset} use 'apm' to call it."
}

setup_aria2() {
	print "\n2. Downloading Aria2 shortcut and config."

	download "${PATH}" "arc" \
		"https://raw.githubusercontent.com/anonymousx97/termux-setup/main/bin/arc"

	chmod +x "${PATH}/arc"

	download "${HOME}/.aria2/" "aria2.conf" \
		"https://raw.githubusercontent.com/anonymousx97/termux-setup/main/config/aria2.conf"

	print_green "Done."
}

setup_ytdlp() {
	print "\n3. Downloading files and Setting Up Magent & YT-DLP link share Trigger."

	download "${HOME}/bin" "termux-url-opener" \
		"https://raw.githubusercontent.com/anonymousx97/termux-setup/main/bin/termux-url-opener"

	print_green "Done."
}

setup_rxfetch() {
	print "\n5. Downloading and Setting up Rxfetch"

	download "${PATH}" "rxfetch" \
		"https://raw.githubusercontent.com/anonymousx97/termux-setup/main/bin/rxfetch"

	chmod +x "${PATH}/rxfetch"

	local motd="#!${SHELL}\nbash rxfetch"

	if [[ -f ~/.termux/motd.sh && $defaults -eq 0 ]]; then
		print "${red}A custom start script exists in the path ${HOME}/.termux/motd.sh${reset}"
		print "  Enter 1 to overwrite the current file.\n  Press Enter to skip."

		read -r -p "> " prompt

		if [[ ! "${prompt}" || ! "${prompt}" == 1 ]]; then
			print_green "Skipping motd modification."

		else
			print "${red}Overwriting motd.${reset}"
			print "${motd}" >~/.termux/motd.sh
		fi

	else
		print "${motd}" >~/.termux/motd.sh
	fi

	print_green "Done."
}

apply_cursor_change() {
	local choice="${1:-0}"
	local style
	local style_ansi

	case "$choice" in
	0)
		style="bar"
		style_ansi='\e[6 q'
		;;
	1)
		style="underline"
		style_ansi='\e[4 q'
		;;
	2)
		style="block"
		style_ansi='\e[1 q'
		;;
	esac

	printf "%b" "$style_ansi"

	# Set the style in termux properties
	sed -i "s/.*terminal-cursor-style.*/terminal-cursor-style = ${style}/" "${HOME}/.termux/termux.properties"

	# Change Blink Rate
	sed -i "s/.*terminal-cursor-blink-rate.*/terminal-cursor-blink-rate = 600/" "${HOME}/.termux/termux.properties"

	print_green "Done."
}

change_cursor() {
	print "\n6. Changing Cursor"

	[[ "$defaults" -ne 0 ]] && apply_cursor_change && return

	local options=(
		"Change to ${green}|${reset} (bar)"
		"Change to ${green}_${reset} (underscore)"
		"Change to Default Block style."
		"Exit"
	)

	export cursor_dict=(
		apply_cursor_change
		apply_cursor_change
		apply_cursor_change
		graceful_exit
	)

	ask "Cursor Menu" "$(index_options_str "${options[@]}")" "cursor_dict"

}

apply_ui_change() {
	local choice="${1:-0}"
	local url

	if [[ "$choice" -eq 0 ]]; then
		url="https://raw.githubusercontent.com/anonymousx97/termux-setup/main/.termux/colors.properties.dark_blue"

	else
		url="https://raw.githubusercontent.com/anonymousx97/termux-setup/main/.termux/colors.properties.light_blue"

	fi

	download "${HOME}/.termux" "colors.properties" url

	download "${HOME}/.termux/" "font.ttf" \
		"https://raw.githubusercontent.com/anonymousx97/termux-setup/main/.termux/MesloLGS_NF_Bold.ttf"

	print_green "\nApplying Changes."

	termux-reload-settings

	print_green "Done."
}

change_ui() {
	print "\n7. Changing Colour and Font."

	[[ "$defaults" -ne 0 ]] && apply_ui_change && return

	local options=("Set Dark Blue" "Set Light Blue")

	export ui_dict=(
		apply_ui_change
		apply_ui_change
	)
	ask "UI Menu" "$(index_options_str "${options[@]}")" "ui_dict"

}

save_setup_sh() {
	[[ -f "${PATH}/setup-termux" ]] && return 0

	print "\nSaving setup.sh for future use."

	cat <<-"EOF" >"${PATH}/setup-termux"
		#!/usr/bin/env bash
		bash -c "$(curl -fsSL https://raw.githubusercontent.com/anonymousx97/termux-setup/main/setup.sh)"
	EOF

	chmod +x "${PATH}/setup-termux"

	print "${green}Done\n${reset}You can now use ${green}'setup-termux'${reset} to get back to this menu."

}

trap 'print_green "\nCtrl+c received exiting..." && exit 1' SIGINT
start
save_setup_sh
