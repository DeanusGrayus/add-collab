#!/bin/bash
#
# Adds a github user to all repositories of another user
# Credit to https://gist.github.com/thenoseman 
#

SCRIPTNAME=`basename $0`
GITHUB_SOURCE_USER=""
GITHUB_TARGET_USER=""
GITHUB_SOURCE_ACCESS_TOKEN=""

usage () {
  echo "A script to add a new collaborator to all repositories of a given github user"
  echo
  echo "Usage:"
  echo "------"
  echo "./$SCRIPTNAME -s github-username-of-repos-admin -t github-repos-admin-access-token -c github-username-of-collaborator"
  echo 
  echo "All parameters mandatory"
  exit
}

add_collab () {
  # Check login
  echo "Checking credentials..."
  token_user=`curl -H "Authorization: Bearer $GITHUB_SOURCE_ACCESS_TOKEN" https://api.github.com/user | grep -s "login" | sed "s/ //g" | cut -d '"' -f 4`
  if [ "$token_user" == $GITHUB_SOURCE_USER ]; then
    echo "Credentials OK"
    echo "Fetching repos..."
    repos=`curl -H "Authorization: Bearer $GITHUB_SOURCE_ACCESS_TOKEN" https://api.github.com/user/repos\?sort=pushed\&per_page=100 | grep -s "full_name" | sed "s/ //g"`
    for repo_string in $repos ; do
      owner_repo=`echo $repo_string | cut -d '"' -f 4`
      echo "Repro '$owner_repo' -> adding collaborator '$GITHUB_TARGET_USER'"
      curl -X PUT -H "Authorization: Bearer $GITHUB_SOURCE_ACCESS_TOKEN" https://api.github.com/repos/$owner_repo/collaborators/$GITHUB_TARGET_USER -d '{"permission":"push"}'
    done
  else
    echo "Could not authenticate with github.com api. Check credentials given."
    exit
  fi

}

# Must have three arguments
if [ ! $# == 6 ]; then
  usage
  exit
fi

while getopts "s:c:t:" option
do
  case $option in
  s)  GITHUB_SOURCE_USER=$OPTARG 
      ;;
  c)  GITHUB_TARGET_USER=$OPTARG 
      ;;
  t)  GITHUB_SOURCE_ACCESS_TOKEN=$OPTARG 
      ;;
  *)  usage
      exit
      ;;
  \?) usage
      exit
      ;;
  esac
done


if [[ -n "$GITHUB_SOURCE_USER" && -n "$GITHUB_TARGET_USER" && -n "$GITHUB_SOURCE_ACCESS_TOKEN" ]]; then
  add_collab
else
  usage
fi
