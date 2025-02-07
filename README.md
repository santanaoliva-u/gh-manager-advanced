
# GH Manager Advanced

**GH Manager Advanced** is a powerful Bash script to manage your GitHub repositories, issues, pull requests, SSH/GPG keys, gists, user interactions, and more directly from your terminal. It simplifies common GitHub tasks with an intuitive CLI, robust logging, and smart autocompletion.

## 🚀 Features

- **Repository Management**:
  - Create, list, and delete repositories.
- **Issue Management**:
  - Create and list issues.
- **Pull Request Management**:
  - Create pull requests and list open PRs.
- **SSH/GPG Key Management**:
  - List, add SSH keys, and upload GPG keys.
- **Gist Management**:
  - Create public or private Gists.
- **Monitoring and Security**:
  - Verify GitHub API status and list recent events.
- **User Management**:
  - Block/unblock users and list followers.
- **Notifications**:
  - Displays success notifications via `notify-send`.
- **Advanced Logging**:
  - Logs all activities to `~/.gh-manager.log`.
- **Autocompletion**:
  - Intelligent Bash/Zsh autocompletion for commands.

## 📋 Prerequisites

Ensure you have the following tools installed:
- **GitHub CLI (`gh`)** (optional but recommended)
- `curl`
- `jq`
- `notify-send`
- `ssh-add`
- `gpg`

You must also have a **GitHub Personal Access Token** with the necessary scopes:
- `repo`
- `read:user`
- `write:public_key`
- `write:gpg_key`
- `gist`

## ⚙️ Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/santanaoliva-u/gh-manager-advanced.git
   cd gh-manager-advanced
   ```

2. Make the script executable:
   ```bash
   sudo su
   chmod +x gh-manager.sh 
   mv gh-manager.sh  /usr/local/bin/

   ```

3. Optionally, add it to your PATH for easier access:
   ```bash
   echo "export PATH=\$PATH:$(pwd)" >> ~/.bashrc
   source ~/.bashrc
   ```

4. Install autocompletion:
   ```bash
   echo "source <(complete -p gh-manager)" >> ~/.bashrc
   source ~/.bashrc
   ```

## 🔑 Configuration

1. **Set up your GitHub Token**:
   - Create a personal access token in GitHub: [Generate a Token](https://github.com/settings/tokens).
   - Save it as an environment variable in your `.bashrc` or `.zshrc`:
     ```bash
     export GITHUB_TOKEN="your_personal_access_token"
     export GITHUB_USER="your_github_username"
     ```

2. Reload your terminal:
   ```bash
   source ~/.bashrc
   ```

## 🛠️ Usage

Run `gh-manager.sh` followed by the desired command:

### Repository Management
- Create a repository:
  ```bash
  ./gh-manager.sh repo create my-new-repo
  ```
- List repositories:
  ```bash
  ./gh-manager.sh repo list
  ```
- Delete a repository:
  ```bash
  ./gh-manager.sh repo delete my-new-repo
  ```

### Issue Management
- Create an issue:
  ```bash
  ./gh-manager.sh issue create my-repo "Issue Title" "Issue description"
  ```
- List issues:
  ```bash
  ./gh-manager.sh issue list my-repo
  ```

### Pull Request Management
- Create a pull request:
  ```bash
  ./gh-manager.sh pr create my-repo "PR Title" "PR description" feature-branch
  ```
- List open pull requests:
  ```bash
  ./gh-manager.sh pr list my-repo
  ```

### SSH/GPG Key Management
- List keys:
  ```bash
  ./gh-manager.sh keys list
  ```
- Add an SSH key:
  ```bash
  ./gh-manager.sh keys add-ssh ~/.ssh/id_rsa.pub
  ```
- Add a GPG key:
  ```bash
  ./gh-manager.sh keys add-gpg "GPG_KEY_CONTENT"
  ```

### Gist Management
- Create a public/private Gist:
  ```bash
  ./gh-manager.sh gists create "My Gist Description" public file.txt "Gist Content"
  ```

### Monitoring and Security
- Check GitHub API status:
  ```bash
  ./gh-manager.sh status
  ```
- List recent events:
  ```bash
  ./gh-manager.sh events list
  ```

### User Management
- Block a user:
  ```bash
  ./gh-manager.sh user block username
  ```
- Unblock a user:
  ```bash
  ./gh-manager.sh user unblock username
  ```
- List followers:
  ```bash
  ./gh-manager.sh user followers
  ```

## 📝 Notes

- Logs are stored in `~/.gh-manager.log` for debugging and auditing.
- Notifications require `notify-send` to be installed and accessible.

## 🤝 Contributing

Feel free to submit issues or pull requests to improve this script. Contributions are always welcome!

## 📜 License

This project is licensed under the MIT License. See the `LICENSE` file for details.

---

### Repository Details

**Repository Name**: `gh-manager-advanced`  
**GitHub Link**: [https://github.com/santanaoliva-u/gh-manager-advanced](https://github.com/santanaoliva-u/gh-manager-advanced)

