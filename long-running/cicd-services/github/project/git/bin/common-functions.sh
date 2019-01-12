#!/bin/bash

##
#/**
#* This has functions that can be used for local operation such as moving file ,changing permissions etc.
#*/
##

###############################################################################
#                               Documentation                                 #
###############################################################################
#                                                                             #
# Description                                                                 #
#     : This script consists of all the common utility functions.             #
#                                                                             #
# Note                                                                        #
#     : 1) If function argument ends with * then its required argument.       #
#       2) If function argument ends with ? then its optional argument.       #
#                                                                             #
###############################################################################
#                             Function Definitions                            #
###############################################################################

#/**
#* Assert if given variable is set.
#* If variable is,
#*    Set - Do nothing
#*    Empty - Exit with failure message
#*@param variable_name name of the variable
#*@param variable_value value of the variable
#*/
function fn_assert_variable_is_set(){

  variable_name=$1

  variable_value=$2

  if [ "${variable_value}" == "" ]
  then

    exit_code=${EXIT_CODE_VARIABLE_NOT_SET}

    failure_messages="${variable_name} variable is not set"

    fn_exit_with_failure_message "${exit_code}" "${failure_messages}"

  fi

}

#/**
#* Log given failure message and exit the script with given exit code
#*@param exit_code exit code to be used to exit with
#*@param failure_message failure message to be logged
#*/
function fn_exit_with_failure_message(){

  exit_code=$1

  failure_message=$2

  fn_log_error "${failure_message}"

  exit ${exit_code}

}

#/**
#* Check the exit code.
#* If exit code is,
#*    Success - Log the success message and return
#*    Failure - Log the failure message and exit with the same exit code based on flag
#*@param exit_code exit code to be checked
#*@param success_message message to be logged if the exit code is zero
#*@param failure_message message to be logged if the exit code is non zero
#*@param fail_on_error flag to handle the exit code
#*/
function fn_handle_exit_code(){

  exit_code=$1

  success_message=$2

  failure_message=$3

  fail_on_error=$4

  if [ "${exit_code}" != "$EXIT_CODE_SUCCESS" ]
  then

    fn_log_error "${failure_message}"

    if [ "${fail_on_error}" != "$EXIT_CODE_SUCCESS" ]
    then

      exit ${exit_code}

    fi

  else

    fn_log_info "${success_message}"

  fi

}

#/**
#* Check if the executable/command exists or not
#*@param executable path to the executable file
#*@param fail_on_error flag to handle the exit code
#*/

function fn_assert_executable_exists() {

  executable=$1

  fail_on_error=$2

  if ! type "${executable}" > /dev/null; then

    fn_log_error "Executable ${executable} does not exists"

    if [ "${fail_on_error}" == "${BOOLEAN_TRUE}" ];
    then

        exit ${EXIT_CODE_EXECUTABLE_NOT_PRESENT}

    fi
  fi

}

#/**
#* Check if file exists or not.
#*@param some_file path to the file
#*@param fail_on_error flag to handle the exit code
#*/
function fn_assert_file_exists() {

  some_file="$1"

  fail_on_error=$2

  if [ ! -f "${some_file}" ]; then

    fn_log_error "File ${some_file} does not exists"

    if [ "${fail_on_error}" == "${BOOLEAN_TRUE}" ];
    then

        exit ${EXIT_CODE_EXECUTABLE_NOT_PRESENT}

    fi
  fi

}

#/**
#* Check if file is empty or not.
#*@param file_to_be_checked path to the file
#*/
function fn_assert_file_not_empty(){

  file_to_be_checked="${1}"

  fn_assert_variable_is_set "file_to_be_checked" "${file_to_be_checked}"

  fn_assert_file_exists "${file_to_be_checked}" "${BOOLEAN_TRUE}"

  if [ ! -s "${file_to_be_checked}" ]; then

    fn_log_error "File ${file_to_be_checked} is empty"

    exit ${EXIT_CODE_FILE_IS_EMPTY}

  fi

}

#/**
#* Create a local directory
#*@param directory_path path to the directory
#*@param fail_on_error flag to handle exit code
#*/
function fn_create_local_directory(){

  directory_path="$1"

  fail_on_error="$2"

  fn_assert_variable_is_set "directory_path" "${directory_path}"

  mkdir -p "${directory_path}"

  exit_code=$?

  success_message="Successfully created directory ${directory_path}"

  failure_message="Failed to create directory ${directory_path}"

  fn_handle_exit_code "${exit_code}" "${success_message}" "${failure_message}" "${fail_on_error}"

}

#/**
#* Delete the directory and all its contents
#*@param directory_path path to the directory
#*@param fail_on_error flag to handle exit code
#*/
function fn_delete_recursive_local_directory(){

  directory_path="$1"

  fail_on_error="$2"

  fn_assert_variable_is_set "directory_path" "${directory_path}"

  rm -rf "${directory_path}"

  exit_code=$?

  success_message="Successfully deleted directory ${directory_path}"

  failure_message="Failed to delete directory ${directory_path}"

  fn_handle_exit_code "${exit_code}" "${success_message}" "${failure_message}" "${fail_on_error}"

}

#/**
#* Delete the directory and all its contents
#*@param directory_path path to the directory
#*@param fail_on_error flag to handle exit code
#*/
function fn_cp_file_to_local_directory(){

  file_path="$1"

  directory_path="$2"

  fail_on_error="$2"

  fn_assert_variable_is_set "file_path" "${file_path}"

  fn_assert_variable_is_set "directory_path" "${directory_path}"

  cp "${file_path}" "${directory_path}"

  exit_code=$?

  success_message="Successfully copied file ${file_path} to directory ${directory_path}"

  failure_message="Failed to copy file ${file_path} to directory ${directory_path}"

  fn_handle_exit_code "${exit_code}" "${success_message}" "${failure_message}" "${fail_on_error}"

}


function fn_run_git_init(){

  git init

  exit_code=$?

  success_message="Successfully executed git command $@"

  failure_message="Failed execute git command $@"

  fn_handle_exit_code "${exit_code}" "${success_message}" "${failure_message}" "${BOOLEAN_TRUE}"

}

function fn_run_git_add(){

  git add .

  exit_code=$?

  success_message="Successfully executed git command $@"

  failure_message="Failed execute git command $@"

  fn_handle_exit_code "${exit_code}" "${success_message}" "${failure_message}" "${BOOLEAN_TRUE}"

}

function fn_run_git_commit(){

  git commit -m 'initial commit'

  exit_code=$?

  success_message="Successfully executed git command $@"

  failure_message="Failed execute git command $@"

  fn_handle_exit_code "${exit_code}" "${success_message}" "${failure_message}" "${BOOLEAN_TRUE}"

}

function fn_run_git_remote_add(){

  gir_repo_url="$1"

  fn_assert_variable_is_set "gir_repo_url" "${gir_repo_url}"

  git remote add origin ${gir_repo_url}

  exit_code=$?

  success_message="Successfully executed git command $@"

  failure_message="Failed execute git command $@"

  fn_handle_exit_code "${exit_code}" "${success_message}" "${failure_message}" "${BOOLEAN_TRUE}"

}


function fn_run_git_push(){

  ssh_key="$1"

  fn_assert_variable_is_set "gir_repo_url" "${gir_repo_url}"

  ssh-agent sh -c "ssh-add ${ssh_key}; git push -u origin master"

  exit_code=$?

  success_message="Successfully executed git command $@"

  failure_message="Failed execute git command $@"

  fn_handle_exit_code "${exit_code}" "${success_message}" "${failure_message}" "${BOOLEAN_TRUE}"

}

################################################################################
#                                     End                                      #
################################################################################
