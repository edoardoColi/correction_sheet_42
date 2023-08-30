#!/bin/bash
#Author: Edoardo Coli
#
#Requirements: bash
#Tested with: GNU bash, version 4.4.20(1)-release (x86_64-pc-linux-gnu)
#Tested with: curl, version 7.58.0 (x86_64-pc-linux-gnu) Release-Date: 2018-01-24
#Tested with: jq-1.5-1-a5b5cbe

#Directory in executing path
_PATH_DIR="/home/eddy/.local/bin/"
#Reference strings
export _GITHUB_USERNAME=""		#'export' let the variable be accessible by child processes
export _GITHUB_ACCESS_TOKEN=""
#Reference strings for github
_ORIGINAL_OWNER="edoardocoli"
_TARGET_REPO="correction_sheet_42"
_REPO_URL="https://github.com/$_GITHUB_USERNAME/$_TARGET_REPO.git"
_WEBPAGE_URL=$1
#Colors
RED="\e[1;31m"
GREEN="\e[1;32m"
YELLOW="\e[1;33m"
BLUE="\e[1;34m"
ORANGE="\e[0;38;5;208m"
DEFAULT="\e[0m"

### error_msg(program_name, msg)
function error_msg()
{
	echo "Error: $2"
	echo "Usage: $1 https://link.correction_sheet"
	echo "Try '$1 -h' for more information."
}

### usage(program_name)
function usage()
{
	if [ -z "$_GITHUB_ACCESS_TOKEN" ]; then
		echo -e "${RED}HOW TO OBTAIN A PERSONAL ACCESS TOKEN FROM GitHub:"
		echo -e "${ORANGE}  Go to your GitHub >account >settings: https://github.com/settings/profile${DEFAULT}"
		echo -e "${ORANGE}  Click on \"Developer settings\" in the left sidebar.${DEFAULT}"
		echo -e "${ORANGE}  Under \"Personal access tokens\", click \"Tokens(classic)\", then click on \"Generate new token (classic)\".${DEFAULT}"
		echo -e "${ORANGE}  Give the token a name, select the scopes you need (at least repo), and click \"Generate token.\"${DEFAULT}"
		echo -e "${ORANGE}  Save the generated token securely, as you won't be able to see it again.${DEFAULT}"
		echo "More details about the characteristics of the token can be found here:"
		echo " https://docs.github.com/en/apps/oauth-apps/building-oauth-apps/scopes-for-oauth-apps"
	else
		echo "TODO qui mettere il secondo help"
	fi
}

### init_procedure(program_name)
init_procedure()
{
echo -e "${BLUE}Insert Github name:${DEFAULT}(remember it's case sensitive)"
while true; do
	read -r gitname
	if [ -z "$gitname" ]; then
		echo "Name cannot be empty. Insert again:"
	else
		break
	fi
done

echo -e "${BLUE}Insert Github token: ${DEFAULT}(use -h flag for more)"
while true; do
	read -r token
	if [ -z "$token" ]; then
		echo "Token cannot be empty. Insert again:"
	else
		break
	fi
done

echo
echo -e "${YELLOW}GitHub username: $gitname${DEFAULT}"
echo -e "${YELLOW}Token provided:  $token${DEFAULT}"
echo "Are those informations correct? (y/N)"
read -r confirmation
if [[ "$confirmation" =~ ^[Yy]|[Yy][Ee][Ss]$ ]]; then
	echo -e "${GREEN}Hello, $gitname! Let's get started.${DEFAULT}"
else
	return 2
fi

sed -e "s/_GITHUB_USERNAME=\"\"/_GITHUB_USERNAME=\"$gitname\"/" -e "s/_GITHUB_ACCESS_TOKEN=\"\"/_GITHUB_ACCESS_TOKEN=\"$token\"/" "$1" > $_PATH_DIR/42push		#use sed to create a modified copy of the file with updated _GITHUB_USERNAME and _GITHUB_ACCESS_TOKEN
if [ ! $? -eq 0 ]; then
	return 3
fi
chmod +x $_PATH_DIR/42push
if [ ! $? -eq 0 ]; then
	return 3
fi

return 0
}

### error_occurred(err_type)
error_occurred()
{
if [ "$1" -eq 1 ]; then
echo "An error occurred during initialization fase. Exiting..."
elif [ "$1" -eq 2 ]; then
	echo "Initialization aborted."
elif [ "$1" -eq 3 ]; then
	echo "Retry using sudo."
elif [ "$1" -eq 4 ]; then
	echo "Other type of error."
fi
exit 1
}

### START EXECUTION

_PROCESS_ID=$$		#save the process ID of the current shell

if [ ! -z "$_GITHUB_ACCESS_TOKEN" ] && [ $# -le 0 ]; then		#if is setup token is set and the number of arguments is less than or equal to 0.
	error_msg $0 "Need a link for generating the pdf."
	exit 1
else
	while getopts 'h' flag; do		#colon(:) to indicate that the flag has one argument.
	case "${flag}" in
		h) usage $0
		exit 0;;
		*) exit 1;;
	esac
	done
fi

if [ -z "$_GITHUB_ACCESS_TOKEN" ]; then		#conditional statement used to checks whether the variable is empty or not
echo "GitHub personal access token is missing. Starting initialization procedure..."
sleep 1		#pause for few seconds
init_procedure $0 || error_occurred $?		#if init_procedure exit code is non-zero (indicating an error), it calls the error_occurred function
echo
echo -e "Now keep using \"42push\" command to share your correction sheet."
echo -e "${ORANGE}GitHub personal access token is set."
echo -e "Installed in $_PATH_DIR folder. Be sure this belongs to your \$PATH environment variable${DEFAULT}"
exit 0;
fi

# se USER e _ORIGINAL_OWNER sono lo stesso niente fork ne pull, solo push
_FORKED_REPO_URL="https://api.github.com/repos/$_ORIGINAL_OWNER/$_TARGET_REPO"
_FORKS_URL="https://api.github.com/repos/$_ORIGINAL_OWNER/$_TARGET_REPO/forks"

existing_repo=$(curl -s -H "Authorization: token $_GITHUB_ACCESS_TOKEN" "$_FORKED_REPO_URL")
existing_forks=$(curl -s -H "Authorization: token $_GITHUB_ACCESS_TOKEN" "$_FORKS_URL")
if echo "$existing_repo" | grep -q "\"$_GITHUB_USERNAME/$_TARGET_REPO\""; then		#check if the repository needs to be forked
	echo "Repository is your own"
else
	if echo "$existing_forks" | grep -q "\"$_GITHUB_USERNAME/$_TARGET_REPO\""; then
		echo "Repository has already been forked by you"
	else
		echo "Repository has not been forked by you yet"
		# Fork the repository using the GitHub API
		fork_response=$(curl -s -X POST -H "Authorization: token $_GITHUB_ACCESS_TOKEN" "$_FORKS_URL")
		if echo "$fork_response" | grep -q "\"Bad credentials\""; then
			echo You provide bad credentials, try reset your token.
			exit 1;
		fi
		# _REPO_URL=$(echo "$fork_response" | jq -r '.clone_url')		#don't really need to use jq to figure out the new url if we know the correct github username
	fi
fi
dir_name=forked_to_push_pdf
git clone -q "$_REPO_URL" $dir_name
cd $dir_name

#create file pdf to push

###TODO
# output_file="output.pdf"
# # Use PDFCrowd to convert the downloaded webpage to PDF
# curl -s -F "src=file:$_WEBPAGE_URL" https://pdfcrowd.com/api/pdf/convert/html/ -o "$output_file"
# echo "Webpage converted to PDF and saved as $output_file"
echo "This is a test file for github api" > TEST1.txt
git add TEST1.txt
git commit -m "Add pdf correction sheet by $_GITHUB_USERNAME-42Roma"
git push -q origin master

if echo "$existing_repo" | grep -q "\"$_GITHUB_USERNAME/$_TARGET_REPO\""; then		#check if the repository needs to be forked
	echo -e "${ORANGE}(TODO)Pdf pushed in the repository!${DEFAULT}"
else
	#TODO
	echo -e "${ORANGE}(TODO)Pull request done to the origin repository!${DEFAULT}"
fi
# cd ..
# rm -fr $dir_name

# Create the pull request
# _PULL_REQ_URL="https://api.github.com/repos/$_ORIGINAL_OWNER/$_TARGET_REPO/pulls"
# title="Pull Request for Adding TEST"
# body="This pull request adds a TEST file to the repository."
# base="main"
# head="$USER:master"

# curl -s -X POST -H "Authorization: token $_GITHUB_ACCESS_TOKEN" -d "{
#   \"title\": \"$title\",
#   \"body\": \"$body\",
#   \"base\": \"$base\",
#   \"head\": \"$head\"
# }" "$_PULL_REQ_URL"
