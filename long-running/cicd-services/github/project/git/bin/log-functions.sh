#!/bin/bash

###############################################################################
#                               Documentation                                 #
###############################################################################
#                                                                             #
# Description                                                                 #
#     : This script contains definitions for logging related utility          #
#       functions.                                                            #
# Note                                                                        #
#     : 1) Arguments to the functions that are mandatory are marked with '*'  #
#                                                                             #
#                                                                             #
###############################################################################
#                             Function Definitions                            #
###############################################################################

#/**
#* Log any message
#*@param message string message
#*/
function fn_log(){

  #Message to be logged should be passed as first argument to
  #this function
  message=$1

  #Print message along with the current timestamp
  echo "[`date`]" ${message}

}

#/**
#* Log information message
#*@param message string message
#*/
function fn_log_info(){

  #Message to be logged should be passed as first argument to
  #this function
  message=$1

  #Log message with INFO label
  fn_log "INFO ${message}"

}

#/**
#* Log warning message
#*@param message string message
#*/
function fn_log_warn(){

  #Message to be logged should be passed as first argument to
  #this function
  message=$1

  #Log message with WARN label
  fn_log "WARN ${message}"

}

#/**
#* Log error message
#*@param message string message
#*/
function fn_log_error(){

  #Message to be logged should be passed as first argument to
  #this function
  message=$1

  #Log message with ERROR label
  fn_log "ERROR ${message}"

}

###############################################################################
#                                     End                                     #
###############################################################################
