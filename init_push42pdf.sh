#!/bin/bash

#aggiungere i colori

init_procedure()
{
  #TODO

  # Obtain a personal access token from GitHub:
  
  # Go to your GitHub account settings: https://github.com/settings/profile
  # Click on "Developer settings" in the left sidebar.
  # Under "Personal access tokens," click on "Generate new token."
  # Give the token a name, select the scopes you need (at least repo), and click "Generate token."
  # Save the generated token securely, as you won't be able to see it again.

  # More details about the characteristics of the token can be found here
  # https://docs.github.com/en/apps/oauth-apps/building-oauth-apps/scopes-for-oauth-apps

  echo "Insert github name:"
  while true; do
    read -r gitname
    if [ -z "$gitname" ]; then
      echo "github name cannot be empty. Insert again:"
    else
      break
    fi
  done

  echo "Insert token:"
  while true; do
  read -r token
    if [ -z "$token" ]; then
      echo "token cannot be empty. Insert again:"
    else
      break
    fi
  done
  
  echo
  echo GitHub username: $gitname
  echo Token provided:  $token
  echo "Are those informations correct? (y/n)"
  read -r confirmation
  if [[ "$confirmation" =~ ^[Yy]|[Yy][Ee][Ss]$ ]]; then
    echo "Hello, $gitname! Let's get started."
  else
    return 2
  fi

  # Crea il nuovo file con le informazioni scritte direttamente dentro
  # dare i permessi di esecuzione e istallare lo script, stile make install
  # se gia presente perche magari il token expired, cancellare e riscrivere
  return 0
}

error_occurred()
{
  if [ "$1" -eq 1 ]; then
   echo "An error occurred during initialization fase. Exiting..."
  elif [ "$1" -eq 2 ]; then
    echo "Initialization aborted."
  elif [ "$1" -eq 3 ]; then
    echo "Other type of error."
  fi
  exit 1
}

#export let the variable be accessible by child processes
export GITHUB_USERNAME=""
export GITHUB_ACCESS_TOKEN=""

#conditional statement used to checks whether the variable is empty or not
if [ -z "$GITHUB_ACCESS_TOKEN" ]; then
  echo "GitHub personal access token is missing. Starting initialization procedure..."
  #pause for 7 seconds
  sleep 7
  #if init_procedure exit code is non-zero (indicating an error), it calls the show_error function
  init_procedure || error_occurred $?
  echo
  echo "GitHub personal access token is set."
  echo "Now keep using \"TODO_NAME\" to share your correction sheet."
  exit 0;
fi

#setup string for fork request

original_owner = edoardocoli
original_repo = correction_sheet_42

# se USER e original_owner sono lo stesso niente fork ne pull, solo push
# forked_repo_url="https://api.github.com/repos/$USER/$original_repo"
# fork_url="https://api.github.com/repos/$original_owner/$original_repo/forks"

# # Check if the repository is already forked
# existing_fork=$(curl -s -H "Authorization: token $GITHUB_ACCESS_TOKEN" "$forked_repo_url")
# if [ "$existing_fork" = "Not Found" ]; then
#   # Fork the repository
#   response=$(curl -s -X POST -H "Authorization: token $GITHUB_ACCESS_TOKEN" "$fork_url")
#   echo "Forking repository..."
#   # Extract the new repository URL from the response
#   new_repo_url=$(echo "$response" | jq -r '.html_url')
#   echo "Forked repository URL: $new_repo_url"
# else
#   echo "Repository is already forked. Cloning..."
#   new_repo_url="https://github.com/$USER/$original_repo.git"
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
# pr_url="https://api.github.com/repos/$original_owner/$original_repo/pulls"
# title="Pull Request for Adding TEST.txt"
# body="This pull request adds a TEST.txt file to the repository."
# base="main"
# head="$USER:master"

# curl -s -X POST -H "Authorization: token $GITHUB_ACCESS_TOKEN" -d "{
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
