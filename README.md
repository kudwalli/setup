
# Universal Linux Setup Script

This repository contains an interactive Bash script that automates the setup of your development environment on Linux. It supports Debian, Ubuntu, and Arch Linux distributions and tailors installations based on your role (Developer, Tester, Database, or Others).

---

## Overview

The setup script guides you through the following:

- **Distribution Selection:**  
  Choose between Debian/Ubuntu and Arch Linux.

- **Role-Based Configuration:**  
  Depending on your role, the script installs a default set of applications:
  - **Developer:** Docker, DBeaver, OpenVPN3, Sublime Text.
  - **Tester:** DBeaver, Sublime Text, OpenVPN3, RVM + Ruby, PyEnv + Python.
  - **Database:** DBeaver, Sublime Text, OpenVPN3.
  - **Others:** No default applications (you may pick additional apps manually).

- **Custom Installations:**  
  Select additional applications from a master list to suit your needs.

- **SSH Key Setup:**  
  Automatically generate and configure your SSH key (if missing) for use with Git providers (e.g., Bitbucket).

- **Project Cloning:**  
  Clone a set of repositories (e.g., `shopifyexport_r7`, `report_pundit_r7`, etc.) based on your selections.

- **Docker Builds (Developer Only):**  
  For Developers, the script builds Docker projects in the cloned repositories (with specific repositories excluded).

- **Enhanced Error Handling:**  
  With a built-in error trap and a `safe_call` mechanism, the script pauses on errors and offers the option to retry or skip problematic steps, ensuring a smoother experience.

---

## Features

- **Interactive Prompts:**  
  Step-by-step guidance to configure your system.

- **Role-Specific Installations:**  
  Installs a pre-defined set of applications based on your role while also allowing for custom selections.

- **Flexible Application Choices:**  
  Choose additional applications from a comprehensive master list.

- **Automated SSH Configuration:**  
  Generates an SSH key (if needed) and automatically configures it for use with Git providers.

- **Repository Cloning:**  
  Easily clone your projects from Bitbucket.

- **Docker Automation:**  
  For Developer roles, automatically build Docker images after cloning projects.

- **Robust Error Handling:**  
  In case of any errors, the script pauses, reports the issue, and allows you to retry or skip the step—helping you resume from where the error occurred.

---

## Supported Distributions

- **Debian/Ubuntu:**  
  Utilizes `apt-get` for package management.

- **Arch Linux:**  
  Uses `pacman` and AUR helpers (such as `yay`) for installation.

---

## Prerequisites

- A Linux system running Debian, Ubuntu, or Arch Linux.
- Sudo privileges for installing system packages.
- A reliable internet connection for downloading packages and cloning repositories.

---

## How to Use

1. **Clone the Repository and Move the Script to Your Home Directory:**

   ```bash
   git clone git@github.com:kudwalli/setup.git
   mv setup/setup.sh ~
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

   - **Distribution Selection:**  
     Choose between Debian/Ubuntu or Arch Linux.

   - **Role Selection:**  
     Pick your role (Developer, Tester, Database, or Others).  
     Default applications will be installed based on your selection.

   - **Additional Application Installation:**  
     Optionally select extra applications from the master list.

   - **SSH Key Setup:**  
     The script will generate an SSH key (if one does not already exist) and display your public key for integration with your Git provider.

   - **Project Cloning:**  
     Select which projects to clone from Bitbucket.

   - **Docker Builds (for Developers):**  
     The script will attempt to build Docker projects for Developer roles (with certain repositories skipped).

---

## Customization

The script is designed to be highly modular. Each task (from installing applications to cloning repositories) is encapsulated in its own function. This makes it straightforward to:

- **Add or Remove Applications:**  
  Modify the installation functions or adjust the role-based flows.

- **Change Repository URLs:**  
  Update the repository management section to suit your organization's needs.

- **Adjust Configuration Settings:**  
  Customize environment settings or error-handling parameters for your personal or team environment.

Feel free to adapt and extend the script to better match your requirements.

---

## Disclaimer

**Use at your own risk.**  
This script performs system-level changes and installs various software packages. It is provided "as is" without any warranty. Always review the code and understand its actions before executing it on your system.

---

## Contributing

Interested in contributing? Please check out our [Contributor Guide](CONTRIBUTING.md) for detailed information on the project structure, coding guidelines, and how to get started.

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

---

## Contact

If you have any questions or need further assistance, please open an issue or contact the repository maintainer.


