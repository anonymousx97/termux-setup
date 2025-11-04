#include <stdio.h>
#include <stdlib.h>
#include "../include/ask_input.h"
#include "../include/colors.h"
#include "../include/curl.h"
#include "../include/file_io.h"
#include "../include/read_int.h"
#include "../include/sigint.h"
#include "../include/tasks.h"

#define HOME "/data/data/com.termux/files/home"
#define BIN "/data/data/com.termux/files/usr/bin"
#define TMPDIR "/data/data/com.termux/files/usr/tmp"
#define SHELL "/data/data/com.termux/files/usr/bin/bash"

static int DEFAULTS = 0;

static void __exit(int _) {
    run_tasks(EXIT_TASK);
    printf(GREEN "Exiting...\n" RESET);
}

void packages_setup(int _) {
    system("termux-change-repo; yes | pkg upgrade ; apt update");

    system(
        "apt install -y "
        " aria2"
        " curl"
        " ffmpeg"
        " git"
        " gh"
        " openssh"
        " python"
        " python-pip"
        " tmux"
        " tsu"
        " wget"
        " root-repo"
        " x11-repo"
        " tur-repo");

    // Save Termux pip iindex url
    download_file(
        "https://raw.githubusercontent.com/anonymousx97/"
        "termux-setup/main/configs/pip.conf",
        "pip.conf", HOME "/.config/pip/", "a+");

    system(
        "pip install -U "
        " wheel"
        " setuptools"
        " yt-dlp");

    download_file(
        "https://raw.githubusercontent.com/anonymousx97/"
        "termux-setup/main/configs/.bashrc",
        ".bashrc", HOME, "a+");
}

void setup_native_gui(int _) {
    system(
        "apt update -y && apt install -y i3 rofi feh alacritty "
        "proot");
    exit_if_sigint();
    //  Save i3 WM config
    download_file(
        "https://raw.githubusercontent.com/anonymousx97/"
        "termux-setup/main/configs/i3",
        "config", HOME "/.config/i3", "w+");
    // save gui start sscript
    download_file(
        "https://raw.githubusercontent.com/anonymousx97/"
        "termux-setup/main/scripts/gui.sh",
        "gui.sh", HOME, "w+");
    // create executable
    system("chmod +x " HOME "/gui.sh");
    // setup alias
    write_to_file(HOME "/.bashrc", "\nalias gui=~/gui.sh", "a+");

    printf(GREEN "\nDone.\n" RESET "\nRestart Termux and type:" RED "gui\n" RESET);
}

void setup_apm(int choice) {
    printf("\n%d. Downloading Android Package Manager By Ryuk.\n", choice);

    download_file(
        "https://raw.githubusercontent.com/anonymousx97/"
        "termux-setup/main/bin/apm",
        "apm", BIN, "w+");

    system("chmod +x " BIN "/apm");

    printf(GREEN "Done\n." RESET "use 'apm' to call it.");
}

void setup_aria2(int choice) {
    printf("\n%d. Downloading Aria2 shortcut and config.\n", choice);

    download_file(
        "https://raw.githubusercontent.com/anonymousx97/"
        "termux-setup/main/bin/arc",
        "arc", BIN, "w+");

    system("chmod +x " BIN "/arc");

    download_file(
        "https://raw.githubusercontent.com/anonymousx97/"
        "termux-setup/main/config/aria2.conf",
        "aria2.conf", HOME ".aria2/", "w+");

    printf(GREEN "Done.\n" RESET "Usage: " RED "arc\n" RESET);
}

void setup_ytdlp(int choice) {
    printf(
        "\n%d. Downloading files and Setting Up Magent & YT-DLP "
        "link share Trigger.\n",
        choice);

    download_file(
        "https://raw.githubusercontent.com/anonymousx97/"
        "termux-setup/main/bin/"
        "termux-url-opener",
        "termux-url-opner", HOME "/bin", "w+");

    printf(GREEN "Done\n." RESET);
}

void setup_rxfetch(int choice) {
    printf("\n%d. Downloading and Setting up Rxfetch\n", choice);

    download_file(
        "https://raw.githubusercontent.com/anonymousx97/"
        "termux-setup/main/bin/rxfetch",
        "rxfetch", BIN, "w+");

    printf(GREEN "Downloaded...\n" RESET);

    system("chmod +x " BIN "/rxfetch");

    const char motd[] = "#!" SHELL "\nbash rxfetch";

    if (is_file(HOME "/.termux/motd,sh") && DEFAULTS == 0) {
        printf(RED "A custom start script exists in the path " HOME "/.termux/motd.sh\n" RESET
                   "  Enter 1 to overwrite the current file\n  Press "
                   "any other key to skip.\n>");

        ReadResult result = read_int();

        if (result.num == 1) {
            printf(RED "Overwriting motd." RESET);
        } else {
            printf(GREEN "Skipping motd modification.\n" RESET);
            return;
        }
    }

    write_to_file(HOME "/.termux/motd.sh", motd, "w+");
    printf(GREEN "Done\n." RESET);
}

static void apply_cursor(int choice) {
    char* style;
    char* style_ansi;

    switch (choice - 1) {
        case 0:
            style = "bar";
            style_ansi = "\e[6 q";
            break;
        case 1:
            style = "underline";
            style_ansi = "\e[4 q";
            break;
        case 2:
            style = "block";
            style_ansi = "\e[1 q";
            break;
    }
    printf("%s", style_ansi);  // apply in current term

    char sed_str[500];
    snprintf(sed_str, sizeof(sed_str),
             "sed -i "
             "\"s/.*terminal-cursor-style.*/terminal-cursor-style = "
             "%s/\" "
             "%s/.termux/termux.properties",
             style, HOME);

    // change  in config gile
    system(sed_str);

    // change blinkrate
    system(
        "sed -i "
        "\"s/.*terminal-cursor-blink-rate.*/"
        "terminal-cursor-blink-rate = 600/\" \"" HOME "/.termux/termux.properties\"");
}

void change_cursor(int choice) {
    printf("\n%d. Changing Cursor\n", choice);
    if (DEFAULTS != 0) {
        apply_cursor(1);
    }
    AskArray array = {.capacity = 3, .values = {apply_cursor, apply_cursor, apply_cursor}};
    char options[] = "  1. Change to " GREEN "|" RESET
                     " (bar)\n"
                     "  2. Change to " GREEN "_" RESET
                     " (underscore)\n"
                     "  3. Change to Default Block style.\n";
    ask_and_run(&array, "Cursor Menu", options);
    printf(GREEN "Done\n." RESET);
}

static void apply_ui_change(int choice) {
    char* url;

    if ((choice - 1) == 0) {
        url =
            "https://raw.githubusercontent.com/anonymousx97/"
            "termux-setup/main/.termux/"
            "colors.properties.dark_blue";
    } else {
        url =
            "https://raw.githubusercontent.com/anonymousx97/"
            "termux-setup/main/.termux/"
            "colors.properties.light_blue";
    }

    download_file(url, "colors.properties", HOME "/.termux", "w+");
    download_file(
        "https://raw.githubusercontent.com/anonymousx97/"
        "termux-setup/main/.termux/"
        "MesloLGS_NF_Bold.ttf",
        "font.ttf", HOME "/.termux", "w+");
}

void change_ui(int choice) {
    printf("%d. Changing Colour and Font.\n", choice);
    if (DEFAULTS != 0) {
        apply_ui_change(1);
    } else {
        AskArray array = {.capacity = 2, .values = {apply_ui_change, apply_ui_change}};
        ask_and_run(&array, "UI Menu", "  1. Set Dark Blue\n  2. Set Light Blue");
    }

    printf(GREEN "Applying Changes.\n" RESET);

    system("termux-reload-settings");

    printf(GREEN "Done\n." RESET);
}

void save_setup_sh(void) {
    if (is_file(BIN "/setup-termux") == 0) {
        return;
    }

    printf("\nSaving setup.sh for future use.\n");

    write_to_file(BIN "/setup-termux",
                  "#!/usr/bin/env bash"
                  "\nexecutable=" TMPDIR
                  "/setup"
                  "\ncurl -fsSL "
                  "https://raw.githubusercontent.com/anonymousx97/"
                  "termux-setup/main/setup_src/"
                  "setup > $executable"
                  "\n$executable",
                  "w+");

    system("chmod +x " BIN "/setup-termux");

    printf(GREEN "\nDone\n" RESET "You can now use " GREEN "'setup-termux'" RESET " to get back to this menu.\n");
}

void customize_all(int choice) {
    MenuCallable array[] = {
        setup_apm, setup_aria2, setup_ytdlp, setup_rxfetch, change_cursor, change_ui,
    };

    int size = sizeof(array) / sizeof(array[0]);

    for (int i = 0; i < size; i++) {
        array[i](choice);
    }
}

void start(int _);
void customize(int _);

void run_all(int choice) {
    DEFAULTS++;
    packages_setup(choice);
    customize_all(choice);
}

void start(int _) {
    AskArray menu_array = {.capacity = 5, .values = {packages_setup, customize, run_all, setup_native_gui, __exit}};

    char options[] =
        "  1. Install Essential Packages.\n"
        "  2. Customize Termux.\n"
        "  3. Both 1 & 2 (Uses Presets)\n"
        "  4. Setup Native i3 Gui in termux (needs termux-x11 "
        "app)\n"
        "  5. Exit";

    ask_and_run(&menu_array, "Main Menu", options);
}

void customize(int _) {
    AskArray array = {.capacity = 10,
                      .values = {
                          setup_apm,
                          setup_aria2,
                          setup_ytdlp,
                          setup_rxfetch,
                          change_cursor,
                          change_ui,
                          customize_all,
                          start,
                          __exit,
                      }};
    char options[] =
        "  1. Setup Android Package Manager by Ryuk."
        "\n  2. Setup Aria2 Shortcut."
        "\n  3. Enable Downloading Magnets or YT-DLP supported "
        "links by sharing to termux."
        "\n  4. Setup Rxfetch."
        "\n  5. Change Cursor Style. "
        "\n  6. Change Colour and Font."
        "\n  7. All of the above. ( Uses Presets )"
        "\n  8. Go back to previous menu."
        "\n  9. Exit";

    ask_and_run(&array, "Customisation Menu", options);
}

int main(void) {
    // check if termux has storage perm.
    if (check_write_access("/sdcard") != 0) {
        system("termux-setup-storage");
    }
    run_tasks(INIT_TASK);
    start(0);
    run_tasks(EXIT_TASK);
    save_setup_sh();
}
