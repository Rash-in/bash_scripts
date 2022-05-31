#!/bin/bash
set -e;
# ------------------------------ cli-wrapper.sh ------------------------------ #
# SCRIPT DEPENDANCY: bash >= 4. Use of associative arrays are used requiring the use of declare -A
#   Note Mac OS uses 3.x and will need to be upgraded prior to use.
# ---------------------------------------------------------------------------- #

# Index: Search phrase to bring up the data. Data is read top of this file down.
# Sections:
    # Global Variables
        # Determines current file/folder paths.
        # Reference Arrays
        # Authoritative Values Data Arrays
    # Function Definitions
        # Determine if config file is present
        # Ensure that all key names in config are allowed
        # Ensure that config ENVS_DECLARED values are allowed
        # Ensure that config Non associative arr values are allowed
    # Main Program Functions
        # General Man Page for displaying help
        # Procedural function calls for Prompt
        # Procedureal function calls for Config
    # Main Program
        
#Fail script on non-zero status


################################################################################
# ----------------------------- Global Variables ----------------------------- #
################################################################################

# ------------------- Determines current file/folder paths. ------------------ #
SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )";
REPO_PATH="$(dirname "${SCRIPTPATH}")";
CONFIG_PATH="$REPO_PATH/config";
CONFIG_TEMPLATE_NAME="config_template.txt";
CONFIG_FILE_NAME="wrapper_envs";

# ----------------------------- Reference Arrays ----------------------------- #
config_env_combined_array=("ENVS_DECLARED");
config_env_seperate_arrays=("CONFIG_EVENS_ALLOWED" "CONFIG_ODDS_ALLOWED");
declare -A config_keys=( [CLI]="CLI" [INSTRUCTION]="INSTRUCTION" [BINARY_CHOICE]="BINARY_CHOICE");

# --------------------- Authoritative Values Data Arrays --------------------- #
config_CLI=("kubectl" "hashi" "helm" "venafi");
config_INSTRUCTION=("read" "create" "modify" "delete");
config_BINARY_CHOICE=("0" "1" "true" "false");
config_CONFIG_EVENS_ALLOWED=("two" "four");
config_CONFIG_ODDS_ALLOWED=("one" "three" "five");

# --End of Global Variables-- #

################################################################################
# --------------------------- Function Definitions --------------------------- #
################################################################################

# -------------------- Determine if config file is present ------------------- #
function config_read_for_envs_file(){
    echo "# -------------------- Checking for config file existence -------------------- #";
    if [ -f "${CONFIG_PATH}/${CONFIG_FILE_NAME}" ]; then
        CONFIG_FILE="${CONFIG_PATH}/${CONFIG_FILE_NAME}";
        echo "   Found file: ${CONFIG_PATH}/${CONFIG_FILE_NAME}";
        echo "     Progress: 1/1 - (PASS) Proceeding to check config";
        echo "# ---------------------------------------------------------------------------- #";
        echo;
    else
        echo "   Config file not found. Creating config file from template.";
        echo "     Template: $CONFIG_PATH/$CONFIG_TEMPLATE_NAME";
        echo "     New File: $CONFIG_PATH/$CONFIG_FILE_NAME";
        copy_execute=$(cat $CONFIG_PATH/$CONFIG_TEMPLATE_NAME > $CONFIG_PATH/$CONFIG_FILE_NAME);
        add_executable=$(chmod +x $CONFIG_PATH/$CONFIG_FILE_NAME);
        echo "   File creation executed. Re-running check.";
        if [ -f "${CONFIG_PATH}/${CONFIG_FILE_NAME}" ]; 
        then
            CONFIG_FILE="${CONFIG_PATH}/${CONFIG_FILE_NAME}";
            echo "   File creation successful. Exiting script. Please edit the config file and re-run script."; 
            echo "# ---------------------------------------------------------------------------- #"; exit 0;
        else
            echo "   File creation failed. Something is wrong with the script. Please reach out to dev."; 
            echo "# ---------------------------------------------------------------------------- #"; exit 1;
        fi;
    fi;
}

# -------- Ensure that all key names in the combined array are allowed ------- #
function config_check_combined_env_keys(){
    echo "# ----------- Checking if allowed keys have values in declared envs ---------- #";echo;
    source "${CONFIG_FILE}";
    declare -A good_config=(" "); declare -A bad_config=(" "); declare -A good_allowed=(" "); declare -A bad_allowed=(" ")
    counter=0; bad_counter=0; counter_max=$((${#config_keys[@]}));
    echo "   Allowed Key Name List:"; echo "     ${!config_keys[@]}";
    echo "   Config Key Name List:"; echo "     ${!ENVS_DECLARED[@]}"; echo;
    for allowed_key in ${!config_keys[@]}; do counter=$((counter+1))
        env_value=${ENVS_DECLARED["$allowed_key"]};
        if [ -z "$env_value" ]; then bad_counter=$((bad_counter+1)); bad_config[$counter]+="[$allowed_key] ";
        else good_config[$counter]+="[$allowed_key] ";
        fi;
        for config_key in ${!ENVS_DECLARED[@]}; do
            allowed_value=${config_keys["$config_key"]};
            if [ -z "$allowed_value" ]; then bad_counter=$((bad_counter+1)); bad_allowed[$counter]+="[$config_key] ";
            else good_allowed[$counter]+="[$config_key] "; 
            fi
        done;
    done;
    echo;
    if [ "$bad_counter" != "0" ]; then
        echo "[RESULTS]: (FAIL) - Unable to match both config and authoritative list key names."; echo;
        echo "Successful key names in config: ${good_config[@]}";
        echo "Successful key names in authrorized list: ${good_allowed[$counter]}"
        echo
        echo "Please check config with details below and re-try:";
        echo "   Missing key names in config:  ${bad_config[@]}"
        echo "   Key names not authorized in config: ${bad_allowed[$counter]}"
        echo "# ---------------------------------------------------------------------------- #"; echo; exit 1;
    else
        echo "[RESULTS]: (PASS) - Able to match both config and authoritative list key names. Proceeding.";
        echo "# ---------------------------------------------------------------------------- #"; echo;
    fi;
}

# ------- Ensure that all key names in the separated arrays are allowed ------ #
function config_check_seperate_env_keys(){
    source "${CONFIG_FILE}";
    
}

#Ref Arr  config_env_combined_array=("ENVS_DECLARED");
#  Val Arr  config_CLI=("kubectl" "hashi" "helm" "venafi");
#  Val Arr  config_INSTRUCTION=("read" "create" "modify" "delete");
#  Val Arr  config_BINARY_CHOICE=("0" "1" "true" "false");
#     Env Arr  ENVS_DECLARED=( [CLI]="hashi" [INSTRUCTION]="create" [BINARY_CHOICE]=1)
# ------------ Ensure that config ENVS_DECLARED values are allowed ----------- #
function config_check_combined_env_values(){
    echo "# ----------- Checking config key values that match allowed lists ----------- #"; echo;

    
    
    
    counter=0; counter_max=$((${#config_keys[@]}));
    source "${CONFIG_FILE}";
    for allowed_key in ${config_keys[@]}; do
        env_key=$(echo ${allowed_key}); env_value=$(echo ${!allowed_key});
        if test "$allowed_key" = "CONFIG_ARRAY"; then
            counter=$((counter + 1));
            echo "   Checking values for $allowed_key against allowed values: ( skipped )";
            echo "     Progress: $counter/$counter_max - (ACCEPTED) env_value: ( Skipped )"; echo;
        elif test "$allowed_key" = "ALL_ENVS_DECLARED"; then
            counter=$((counter + 1));
            echo "   Checking values for $allowed_key against allowed values: ( skipped )";
            echo "     Progress: $counter/$counter_max - (ACCEPTED) env_value: ( Skipped )"; echo;
        else
            declare -n allowed_array=config_$allowed_key;
            echo "   Checking values for: $allowed_key against allowed values: ( ${allowed_array[@]} )";
            for allowed_value in ${allowed_array[@]}; do
                if test "$allowed_value" = "$env_value"; then counter=$((counter+1));
                    echo "     Progress: $counter/$counter_max - (ACCEPTED) env_value: ( $env_value ) allowed: ( $allowed_value )";
                fi;
            done;
            echo;
        fi;
    done;
    if [ "$counter_max" != "$counter" ]; then
        echo "   Progress: $counter/$counter_max - (ERROR) Recheck config and retry. Exiting Script.";echo; exit 1;
    else echo "   Progress: $counter/$counter_max - (PASS) Proceeding to check config arrays.";echo;
    fi
    echo "# ---------------------------------------------------------------------------- #";
    echo;
}

#Ref Arr  config_keys_not_associative=("EVENS" "ODDS")
# Val Arr  config_associative_CONFIG_EVENS_ALLOWED=("two" "four");
# Val Arr  config_associative_CONFIG_ODDS_ALLOWED=("one" "three" "five")
#    Env arr CONFIG_ODDS_ALLOWED=("one" "three" "five")
#    Env arr CONFIG_EVENS_ALLOWED=("two" "four" "six")

# --------- Ensure that config Non associative arr values are allowed -------- #
function config_check_seperate_env_values(){
    echo "---Checking CONFIG_ARRAY values that match the allowed array values---";
    echo;
    counter=0; counter_max=$((${#config_CONFIG_ARRAY_ALLOWED[@]})); 
    source "${CONFIG_FILE}";
    for allowed_value in ${config_CONFIG_ARRAY_ALLOWED[@]}; do
        echo "--Checking allowed_value: $allowed_value";
        for env_array_value in ${CONFIG_ARRAY[@]}; do
            if test "${env_array_value}" != "${allowed_value}"; then
                echo "     (REJECTED) env_array_value: $env_array_value allowed_value: $allowed_value";
            else counter=$((counter+1)); echo "(ACCEPTED) env_array_value: $env_array_value allowed_value: $allowed_value";
            fi;
        done;
    done;
    echo "Final Counter: $counter out of $counter_max";
}

# --End of Function Definitions-- #

################################################################################
# -------------------------- Main Program Functions -------------------------- #
################################################################################

# ------------------- General Man Page for displaying help ------------------- #
function man_cliwrapper(){
    echo "something";
    exit 1;
}
# ------------------- Procedural function calls for Prompt ------------------- #
function prompt_procedures(){
    clear;
    echo;
    echo "                             ######################";
    echo "                             # CLI-Wrapper Prompt #";
    echo "                             ######################";
    echo;
    exit 1;
}
# ------------------- Procedureal function calls for Config ------------------ #
function config_procedures(){
    clear;
    echo;
    echo "                             ######################";
    echo "                             # CLI-Wrapper Config #";
    echo "                             ######################";
    echo;
    config_read_for_envs_file;
    config_check_combined_env_keys;
    config_check_separate_env_keys;
    #config_check_combined_env_values;
    #config_check_seperate_env_values;
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