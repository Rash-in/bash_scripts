#!/bin/bash

# ------------------------------ cli-wrapper.sh ------------------------------ #
# SCRIPT DEPENDANCY: bash >= 4. Use of array aliases is used requiring the use of declare -n
# Note Mac OS uses 3.x and will need to be upgraded prior to use.
# ---------------------------------------------------------------------------- #

#Fail script on non-zero status
set -e

################################################################################
# ----------------------------- Global Variables ----------------------------- #
################################################################################

# Determines current folder paths.
SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
REPO_PATH="$(dirname "${SCRIPTPATH}")"
CONFIG_PATH="$REPO_PATH/config"
CONFIG_TEMPLATE_NAME="config_template.txt"
CONFIG_FILE_NAME="config_envs"

# All config keys that need to be included in the config file
config_keys=("CLI" "INSTRUCTION" "CONFIG_ARRAY" "BINARY_CHOICE")
# All CLIs that the wrapper supports.
config_CLI=("kubectl" "hashi" "helm" "venafi")
# All Instructions that apply to the CLIs supported.
config_INSTRUCTION=("read" "create" "modify" "delete")
# All Accepted array elements
config_CONFIG_ARRAY_ALLOWED=("one" "five" "two" "ten")
# Binary choice
config_BINARY_CHOICE=("0" "1" "true" "false")
# --End of Global Variables-- #

################################################################################
# --------------------------- Function Definitions --------------------------- #
################################################################################

# -------------------- Determine if config file is present ------------------- #
function config_read_for_envs_file(){
    echo "---Checking for config file---"
    if [ -f "${CONFIG_PATH}/${CONFIG_FILE_NAME}" ]; then
        CONFIG_FILE="${CONFIG_PATH}/${CONFIG_FILE_NAME}";
        echo "Found file: ${CONFIG_PATH}/${CONFIG_FILE_NAME}";
        echo "Proceeding to validation";
        echo;
    else
        echo "Config file not found. Creating config file from template.";
        echo "Template: $CONFIG_PATH/$CONFIG_TEMPLATE_NAME";
        echo "New File: $CONFIG_PATH/$CONFIG_FILE_NAME"
        copy_execute=$(cat $CONFIG_PATH/$CONFIG_TEMPLATE_NAME > $CONFIG_PATH/$CONFIG_FILE_NAME)
        add_executable=$(chmod +x $CONFIG_PATH/$CONFIG_FILE_NAME)
        echo "File creation executed. Re-running check."
        if [ -f "${CONFIG_PATH}/${CONFIG_FILE_NAME}" ]; 
        then
            CONFIG_FILE="${CONFIG_PATH}/${CONFIG_FILE_NAME}";
            echo "File creation successful. Exiting script. Please edit the config file and re-run script."; echo; exit 0;
        else echo "File creation failed. Something is wrong with the script. Please reach out to dev."; echo; exit 1;
        fi
    fi
}
# -------------- Ensure that all key names in config are allowed ------------- #
function config_check_env_keys(){
    echo "---Checking config key names that match allowed list---";
    counter=0; counter_max=$((${#config_keys[@]}));
    source "${CONFIG_FILE}"
    echo "All Allowed Keys: ${config_keys[@]}";echo;
    for allowed_key in ${config_keys[@]}; do
        env_key=$(echo ${allowed_key}); env_value=$(echo ${!allowed_key});
        if [ -z "$env_value" ]; then echo "NO_MATCH: allowed key: $allowed_key empty or missing in config.";
        elif test "$allowed_key" = "$env_key"; then echo "MATCH: config key: ${env_key}"; counter=$((counter+1));
        else echo "NO_MATCH: config key: ${env_key}";
        fi
    done
    echo 
    echo "Final Counter: $counter out of $counter_max"
    if [ "$counter" = "$counter_max" ]; then echo "All config key names accounted for. Proceeding to check values."; echo;
    else echo "Recheck config and retry. Exiting Script.";echo; exit 1;
    fi
}
# ------------- Ensure that all key values in config are allowed ------------- #
function config_check_env_values(){
    echo "---Checking config key values that match allowed list---";
    echo
    counter=0; counter_max=$((${#config_keys[@]})); 
    source "${CONFIG_FILE}"
    for allowed_key in ${config_keys[@]}; do
        env_key=$(echo ${allowed_key}); env_value=$(echo ${!allowed_key});
        #read ${config_keys[$allowed_key]} env_other;
        echo "Test: ${config_keys[$allowed_key]}"
        if test "$allowed_key" = "CONFIG_ARRAY"; then 
            counter=$((counter -1)); 
            echo "Checking values for $allowed_key against allowed values ( skipped )"
            echo "   ($allowed_key) env_value: ( Skipped ) Checked next"; echo;
        else
            counter=$((counter+1));
            declare -n allowed_array=config_$allowed_key
            echo "Checking values for: $allowed_key against allowed values: ( ${allowed_array[@]} )"
            for allowed_value in ${allowed_array[@]}; do
                if test "$allowed_value" = "$env_value"; then
                    counter=$((counter+1)); echo "   (ACCEPTED) env_value: ( $env_value ) allowed: ( $allowed_value )";
                else echo "     (REJECTED) env_value: ( $env_value ) allowed: ( $allowed_value )";
                fi
            done
            echo;
        fi
    done
    echo "Final Counter: $counter out of $counter_max"
    if [ "$counter_max" != "$counter" ]; then
        echo "Recheck config and retry. Exiting Script.";echo; exit 1;
    else echo "All key pair values accounted for. Proceeding to check config arrays.";echo;
    fi
}

# ------------------------- Testing double for loops ------------------------- #
function config_check_CONFIG_ARRAY(){
    echo "---Checking CONFIG_ARRAY values that match the allowed array values---"
    echo
    counter=0; counter_max=$((${#config_CONFIG_ARRAY_ALLOWED[@]})); 
    source "${CONFIG_FILE}"
    for allowed_value in ${config_CONFIG_ARRAY_ALLOWED[@]}; do
        echo "--Checking allowed_value: $allowed_value"
        for env_array_value in ${CONFIG_ARRAY[@]}; do
            if test "${env_array_value}" != "${allowed_value}"; then
                echo "     (REJECTED) env_array_value: $env_array_value allowed_value: $allowed_value"
            else counter=$((counter+1)); echo "(ACCEPTED) env_array_value: $env_array_value allowed_value: $allowed_value"
            fi
        done
    done
    echo "Final Counter: $counter out of $counter_max"
}

# --End of Function Definitions-- #

################################################################################
# -------------------------- Main Program Functions -------------------------- #
################################################################################

# ------------------- General Man Page for displaying help ------------------- #
function man_cliwrapper(){
    echo "something"
    exit 1;
}
# ------------------- Procedural function calls for Prompt ------------------- #
function prompt_procedures(){
    clear;
    echo;
    echo "######################";
    echo "# CLI-Wrapper Prompt #";
    echo "######################";
    echo;
    exit 1;
}
# ------------------- Procedureal function calls for Config ------------------ #
function config_procedures(){
    clear;
    echo;
    echo "######################";
    echo "# CLI-Wrapper Config #";
    echo "######################";
    echo;
    config_read_for_envs_file;
    config_check_env_keys;
    config_check_env_values;
    config_check_CONFIG_ARRAY;
    #test_loop;
    exit 1;
}
# ------------------------ Display all CLIs supported ------------------------ #
#function display_clis(){

#}
# --End of Main Program Functions -- #

################################################################################
# ------------------------------- Main Program ------------------------------- #
################################################################################
# If no args or more args than allowed, display man page, else loop flags
while true; do
    if [ "$#" -eq 0 ]; then
        man_cliwrapper;
    elif [ "$#" -gt 1 ]; then
        man_cliwrapper;
    else
        for i in "$@"; do
            case $i in
                -p | -P | -prompt | --prompt)   prompt_procedures; exit 0;;
                -c | -C | -config | --config)   config_procedures; exit 0;;
                --cli)  display_clis; exit 0;;
                *)  echo "Flag not recognized: $1. Exiting."; exit 0;;
            esac
        done
    fi
done
# --End of Main Program -- #

#EOF