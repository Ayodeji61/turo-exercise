#!/usr/bin/env python
import subprocess
import requests
from dotenv import load_dotenv
import os


def git_operations(new_version, branch_name):
    # This function handles Git operations required for a new version
    # It creates a new branch, adds changes, commits, and pushes the branch to remote

    # Create a new branch with the name 'update-vX.X'
    subprocess.run(["git", "checkout", "-b", branch_name])
    # Add all changed files to the staging area
    subprocess.run(["git", "add", "."])
    # Commit these changes with a message including the new version number
    subprocess.run(["git", "commit", "-m", f"Update to version {new_version}"])
    # Push the new branch to the remote repository
    subprocess.run(["git", "push", "--set-upstream", "origin", branch_name])


def create_pull_request(repo_name, new_branch, title, body, token):
    # This function creates a pull request on GitHub using the GitHub API
    # It requires the repository name, branch to pull from, PR title, body, and a GitHub token

    # GitHub API URL for creating pull requests
    url = f"https://api.github.com/repos/{repo_name}/pulls"
    # Setup headers with the GitHub token for authentication
    headers = {
        "Authorization": f"token {token}",
        "Accept": "application/vnd.github.v3+json",
    }
    # Data payload for the pull request
    data = {
        "title": title,  # Title of the pull request
        "head": new_branch,  # Source branch of the pull request
        "base": "main",  # Target branch of the pull request (main branch)
        "body": body,  # Description/body of the pull request
    }
    # Make a POST request to create the pull request and return the response
    response = requests.post(url, json=data, headers=headers)
    return response.json()


if __name__ == "__main__":
    load_dotenv()
    # Main execution starts here
    # Read the current version from the VERSION file
    with open("VERSION", "r") as file:
        new_version = file.read().strip()
    # Set up repository details and branch naming convention
    repo_name = "Ayodeji61/turo-exercise"
    branch_name = f"update-{new_version}"
    body = f"pr-update-{new_version}"
    title = f"update-{new_version}"
    token = os.environ.get("TOKEN")
    # Perform Git operations and create a pull request
    git_operations(new_version, branch_name)
    # Uncomment the next line to enable pull request creation
    create_pull_request(repo_name, branch_name, title, body, token)
