
#!/bin/bash
###############################################################################
#                               Documentation                                 #
###############################################################################
#                                                                             #
# Description                                                                 #
#     :                                                                       #
#                                                                             #
#                                                                             #
#                                                                             #
###############################################################################
#                           Identify Script Home                              #
###############################################################################

#Find the script file home
pushd . > /dev/null
SCRIPT_DIRECTORY="${BASH_SOURCE[0]}";
while([ -h "${SCRIPT_DIRECTORY}" ]);
do
  cd "`dirname "${SCRIPT_DIRECTORY}"`"
  SCRIPT_DIRECTORY="$(readlink "`basename "${SCRIPT_DIRECTORY}"`")";
done
cd "`dirname "${SCRIPT_DIRECTORY}"`" > /dev/null
SCRIPT_DIRECTORY="`pwd`";
popd  > /dev/null
MODULE_HOME="`dirname "${SCRIPT_DIRECTORY}"`"

###############################################################################
#                           Import Dependencies                               #
###############################################################################

if [ "${CONFIG_HOME}" == "" ]
then

     PROJECT_HOME="`dirname "${MODULE_HOME}"`"
     CONFIG_HOME="${PROJECT_HOME}/config"

fi

. ${MODULE_HOME}/bin/constants.sh
. ${MODULE_HOME}/bin/log-functions.sh
. ${MODULE_HOME}/bin/common-functions.sh

###############################################################################
#                              Variables                                      #
###############################################################################

git_org_nm=$1

git_repo_nm=$2

git_ssh_key="${MODULE_HOME}/etc/adm_key"

gir_repo_url=git@github.com:${git_org_nm}/${git_repo_nm}.git

temp_dir="${MODULE_HOME}/temp/${git_repo_nm}"

git_ignore_file="${MODULE_HOME}/etc/gitignore"

git_readme_file="${MODULE_HOME}/etc/README.md"



###############################################################################
#                             Validations                                     #
###############################################################################

fn_assert_variable_is_set "git_org_nm" "${git_org_nm}"

fn_assert_variable_is_set "git_repo_nm" "${git_repo_nm}"

fn_assert_executable_exists "git" "${BOOLEAN_TRUE}"

###############################################################################
#                                Main                                         #
###############################################################################

fn_delete_recursive_local_directory "${MODULE_HOME}/temp" "${BOOLEAN_TRUE}"

fn_create_local_directory "${temp_dir}" "${BOOLEAN_TRUE}"

fn_cp_file_to_local_directory "${git_ignore_file}"  "${temp_dir}/"

fn_cp_file_to_local_directory "${git_readme_file}"  "${temp_dir}/"

cd "${temp_dir}"

fn_run_git_init

fn_run_git_add

fn_run_git_commit

fn_run_git_remote_add "${gir_repo_url}"

fn_run_git_push "${git_ssh_key}"

###############################################################################
#                                     End                                     #
###############################################################################