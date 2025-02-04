```markdown
# Universal Linux Setup Script

This repository contains an interactive Bash script designed to automate the setup of your development environment on Linux. It supports Debian, Ubuntu, and Arch Linux distributions and tailors installations based on your role (Developer, Tester, Database, or Others).

## Overview

The script guides you through:
- **Distribution Selection:** Choose between Debian/Ubuntu and Arch Linux.
- **Role-Based Configuration:** Select your role to install default applications suited for:
  - **Developer:** Docker, DBeaver, OpenVPN3, Sublime Text.
  - **Tester:** DBeaver, Sublime Text, OpenVPN3, RVM + Ruby, PyEnv + Python.
  - **Database:** DBeaver, Sublime Text, OpenVPN3.
  - **Others:** No default apps (you can pick additional apps manually).
- **Custom Installations:** Choose additional applications to install from a master list.
- **SSH Key Setup:** Automatically generate (if missing) and configure your SSH key for Git providers (e.g., Bitbucket).
- **Project Cloning:** Clone a set of repositories (e.g., `shopifyexport_r7`, `report_pundit_r7`, etc.) based on your selection.
- **Docker Builds:** If you’re a Developer, perform Docker builds for your projects (excluding specified repositories).

## Features

- **Interactive Prompts:** Step-by-step guidance to configure your system.
- **Role-Specific Installations:** Automatically installs a set of applications based on your role.
- **Flexible Application Choices:** Allows you to select additional apps to install.
- **Automated SSH Configuration:** Generates and adds your SSH key to the agent.
- **Repository Cloning:** Easily clone your projects from Bitbucket.
- **Docker Automation:** Build Docker projects post-clone for Developers.

## Supported Distributions

- **Debian/Ubuntu:** Uses `apt-get` for package management.
- **Arch Linux:** Uses `pacman` and AUR helpers (like `yay`) for installation.

## Prerequisites

- A Linux distribution running Debian, Ubuntu, or Arch Linux.
- Sudo privileges to install system packages.
- An active internet connection for downloading packages and repositories.

## How to Use

1. **Clone the Repository:**

   ```bash
   git clone https://github.com/yourusername/your-repo-name.git
   cd your-repo-name
   ```

2. **Make the Script Executable:**

   ```bash
   chmod +x setup.sh
   ```

3. **Run the Script:**

   ```bash
   ./setup.sh
   ```

4. **Follow the On-Screen Prompts:**

   - **Select your Distribution:** Choose between Debian/Ubuntu or Arch.
   - **Select your Role:** Pick your role (Developer, Tester, Database, or Others).
   - **Default & Additional Applications:** The script will install default apps for your role and prompt you for any additional applications you may require.
   - **SSH Key Setup:** The script will generate an SSH key (if one does not exist) and display your public key for use with Git providers.
   - **Clone Projects:** Choose which projects to clone from Bitbucket.
   - **Docker Builds (Developer only):** For Developers, the script will attempt to build Docker projects in the cloned repositories.

## Customization

The script is highly modular with separate functions for each installation and setup task. You can easily modify or extend it to:
- Add or remove applications.
- Change repository URLs.
- Adjust configuration settings for your personal or team environment.

## Disclaimer

**Use at your own risk.**  
This script makes system-level changes and installs software packages. It is provided "as is" without any warranty. It is highly recommended to review the code and understand its actions before running it on your system.

## Contributing

Interested in contributing? Please check out our [Contributor Guide](CONTRIBUTING.md) for detailed information on the project structure, coding guidelines, and how to get started.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

## Contact

If you have any questions or need further assistance, please open an issue or contact the repository maintainer.
```


