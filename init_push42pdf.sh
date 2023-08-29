#!/bin/bash
#Author: Edoardo Coli
#
#Requirements: bash
#Tested with: GNU bash, version 4.4.20(1)-release (x86_64-pc-linux-gnu)

#Directory in executing path
_PATH_DIR="/home/eddy/.local/bin/"
#Reference strings
export _GITHUB_USERNAME="edoardocoli"		#'export' let the variable be accessible by child processes
export _GITHUB_ACCESS_TOKEN=""
#Reference strings for fork request
_ORIGINAL_OWNER="edoardocoli"
_ORIGINAL_REPO="correction_sheet_42"
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
		echo -e "${ORANGE}  Under \"Personal access tokens\", click on \"Generate new token\".${DEFAULT}"
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
echo -e "${BLUE}Insert Github name:${DEFAULT}"
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
# forked_repo_url="https://api.github.com/repos/$USER/$_ORIGINAL_REPO"
# fork_url="https://api.github.com/repos/$_ORIGINAL_OWNER/$_ORIGINAL_REPO/forks"

# # Check if the repository is already forked
# existing_fork=$(curl -s -H "Authorization: token $_GITHUB_ACCESS_TOKEN" "$forked_repo_url")
# if [ "$existing_fork" = "Not Found" ]; then
#   # Fork the repository
#   response=$(curl -s -X POST -H "Authorization: token $_GITHUB_ACCESS_TOKEN" "$fork_url")
#   echo "Forking repository..."
#   # Extract the new repository URL from the response
#   new_repo_url=$(echo "$response" | jq -r '.html_url')
#   echo "Forked repository URL: $new_repo_url"
# else
#   echo "Repository is already forked. Cloning..."
#   new_repo_url="https://github.com/$USER/$_ORIGINAL_REPO.git"
# fi

# # Clone the forked repository
# git clone "$new_repo_url" forked_repo
# cd forked_repo

# # Create a new file called TEST.txt
# echo "This is a test file." > TEST.txt
# git add TEST.txt
# git commit -m "Add pdf correction sheet by $NOME-42Roma"
# git push origin master

# # Create the pull request
# pr_url="https://api.github.com/repos/$_ORIGINAL_OWNER/$_ORIGINAL_REPO/pulls"
# title="Pull Request for Adding TEST.txt"
# body="This pull request adds a TEST.txt file to the repository."
# base="main"
# head="$USER:master"

# curl -s -X POST -H "Authorization: token $_GITHUB_ACCESS_TOKEN" -d "{
#   \"title\": \"$title\",
#   \"body\": \"$body\",
#   \"base\": \"$base\",
#   \"head\": \"$head\"
# }" "$pr_url"

# echo "Pull request created!"


## questo per creare il pdf della correzione
# Replace <URL> with the webpage's URL you want to convert
# webpage_url="https://www.example.com"
# output_file="output.pdf"

# # Step 1: Download the webpage using curl
# curl -s "$webpage_url" > webpage.html

# # Step 2: Use PDFCrowd to convert the downloaded webpage to PDF
# curl -F "url=file:@webpage.html" https://pdfcrowd.com/url-to-pdf/ -o "$output_file"

# # Step 3: Remove the temporary downloaded webpage file
# rm webpage.html

# echo "Webpage converted to PDF and saved as $output_file"
