#!/bin/bash

# UTILITIES ###################################################################

display_help() {
    echo "Usage: casys [OPTION]"
    echo "Launch Carla and configure audio routing for Casys."
    echo "Options:"
    echo "  gui     Launches Carla with GUI."
    echo "  stop    (or quit or exit or kill) Stops Carla and reset audio routing."
    echo "  restart Restarts Carla and audio routing."
    echo "  help    (or -h) Display this help message."
}

check_if_already_running() {
    local will_quit carlamsg sinkmsg

    sink_exists=$(pactl list sinks short | grep "$SINK_NAME")
    carla_is_running=$(ps -p "$(cat $CARLA_PID_TMP_FILENAME)" | grep "carla")

    # Check Carla status
    if [ -f $CARLA_PID_TMP_FILENAME ] && [ -n "$carla_is_running" ]; then
        carlamsg="\e[31mCarla is already running and a pid file is already set.\e[0m"
        will_quit=1
    elif [ -n "$carla_is_running" ]; then
        carlamsg="\e[31mCarla is already running, but no pid file was found.\e[0m"
        will_quit=1
    elif [ -f $CARLA_PID_TMP_FILENAME ]; then
        carlamsg="\e[31mCarla is not running, but a pid file exists.\e[0m"
        will_quit=1
    fi

    # Check sink status
    if [ -f $SINK_ID_TMP_FILENAME ] && [ -n "$sink_exists" ]; then
        sinkmsg="\e[31mSink $SINK_NAME is already set and an id file is already set.\e[0m"
        will_quit=1
    elif [ -n "$sink_exists" ]; then
        sinkmsg="\e[31mSink $SINK_NAME is already set, but no id file was found.\e[0m"
        will_quit=1
    elif [ -f $SINK_ID_TMP_FILENAME ]; then
        sinkmsg="\e[31mSink $SINK_NAME is not set, but an id file exists.\e[0m"
        will_quit=1
    fi

    if [ "$will_quit" -eq 1 ]; then
        echo -e "\e[31mSomething went wrong:\e[0m"
        [ -n "$carlamsg" ] && echo -e "$carlamsg"
        [ -n "$sinkmsg" ] && echo -e "$sinkmsg"
        echo
        echo "Please run 'casys stop' or 'casys restart'."
        exit 1
    fi
}

# FUNCTIONS ###################################################################

create_audio_sink() {
    # This command creates a virtual sink and outputs its ID to stdout
    local sink_cmd="pactl load-module module-null-sink sink_name=$SINK_NAME"
    # Run the cmd and save the ID to a temp file to unload it with "casys stop"
    $sink_cmd > $SINK_ID_TMP_FILENAME
    echo "Sink created with module ID $(cat $SINK_ID_TMP_FILENAME)."
}

launch_carla() {
    local filepath="$CASYS_DIR/carla-session.carxp"
    # build cmd to launch carla. Runs with gui if arg is present
    carla_cmd=$([ -n "$1" ] && echo "carla $filepath" || echo "carla --no-gui $filepath")
    # Runs Carla in the background
    $carla_cmd &
    # Writes the PID to a temp file to kill it with "casys stop"
    echo $! > $CARLA_PID_TMP_FILENAME
    echo "Carla running with PID $(cat $CARLA_PID_TMP_FILENAME)."
}

link_audio_ports() {
    pw-link "$SINK_NAME":monitor_FL Carla:audio-in1
    pw-link "$SINK_NAME":monitor_FR Carla:audio-in2
    pw-link Carla:audio-out1 "$OUTPUT_DEVICE:playback_FL"
    pw-link Carla:audio-out2 "$OUTPUT_DEVICE:playback_FR"
}


# MAIN ########################################################################

run() {
    check_if_already_running
    launch_carla "$1"
    create_audio_sink
    pactl set-default-sink "$SINK_NAME"
    echo "System audio out is now $SINK_NAME."
    link_audio_ports
}

quit() {
    # TODO: refactor this
    # check if the module exists
    output=$(pactl list sinks short | grep "$SINK_NAME")
    [ -n "$output" ] && pactl unload-module module-null-sink
    [ -f $CARLA_PID_TMP_FILENAME ] && carla_pid=$(cat $CARLA_PID_TMP_FILENAME)
    [ -n "$carla_pid" ] && kill "$carla_pid"
    # remove temp files
    rm $CARLA_PID_TMP_FILENAME $SINK_ID_TMP_FILENAME
}

# ENTRY POINT #################################################################

# casys cmd should have only 1 argument
if [ -n "$2" ]; then
    echo -e "\e[31mInvalid argument: $2\e[0m"
    display_help
    exit 1
fi

SINK_NAME="Casys"
CARLA_PID_TMP_FILENAME="carla_pid"
SINK_ID_TMP_FILENAME="sink_id"
OUTPUT_DEVICE=$(pactl get-default-sink)
CASYS_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

case $1 in
    "" | gui)                   run $1;;
    stop | quit | exit | kill)  quit;;
    restart)                    quit; run;;
    "-h" | help)                display_help;;
    *)
        echo -e "\e[31mInvalid argument: $1\e[0m"
        display_help
        exit 1;;
esac
