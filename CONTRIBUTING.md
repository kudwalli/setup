# Contributing to the Universal Linux Setup Script

Thank you for your interest in contributing to this project! This document provides a detailed overview of the script’s design, structure, and guidelines for making improvements. Whether you’re an employee or an open-source contributor, please follow the guidelines below to help keep the project clean, modular, and easy to maintain.

---

## Table of Contents

- [Overview](#overview)
- [Repository Structure](#repository-structure)
- [Script Architecture](#script-architecture)
  - [Utility Functions](#utility-functions)
  - [Repository Management Functions](#repository-management-functions)
  - [Distribution-Specific Installation Functions](#distribution-specific-installation-functions)
  - [Role-Based Flows](#role-based-flows)
  - [Main Flow](#main-flow)
  - [Enhanced Error Handling](#enhanced-error-handling)
- [Coding Guidelines](#coding-guidelines)
- [How to Contribute](#how-to-contribute)
- [Testing and Debugging](#testing-and-debugging)
- [Additional Resources](#additional-resources)
- [Questions and Support](#questions-and-support)
- [License](#license)

---

## Overview

The **Universal Linux Setup Script** is an interactive Bash script designed to automate the installation of development tools and configurations based on:

- **Linux Distribution:** Debian, Ubuntu, and Arch Linux.
- **User Role:** Developer, Tester, Database, or Others.

The script is built using a modular design where each functionality—whether it’s installing VSCode, setting up an SSH key, or handling errors—is encapsulated in its own function. This architecture simplifies updates, extensions, and debugging.

---

## Repository Structure

- **`setup.sh`**  
  The main executable Bash script. It includes:
  - **Utility functions** for common tasks (e.g., pausing execution, generating SSH keys).
  - **Repository management functions** for cloning projects and executing post-clone operations (e.g., Docker builds).
  - **Distribution-specific installation functions** (separated into Debian/Ubuntu and Arch Linux sections).
  - **Role-based flows** that guide the user through default and additional application installations.
  - **Enhanced error handling** via a centralized error trap and a `safe_call` mechanism, which lets the script pause on errors and optionally retry or skip a failing step.
  - **The main control flow** that orchestrates the setup process based on user input.

- **`README.md`**  
  Provides an overview of the project, basic usage instructions, and links to additional documentation.

- **`CONTRIBUTING.md`** (this file)  
  Contains detailed documentation for contributors, including design rationale, coding conventions, and steps for contributing new features or bug fixes.

---

## Script Architecture

### Utility Functions

- **`pause()`**  
  Pauses the script execution and waits for the user to press ENTER before continuing.

- **`generate_ssh_key()`**  
  Checks for an existing SSH key and creates one if not found. It then sets up the SSH agent and displays the public key for the user to add to their Git hosting provider.

### Repository Management Functions

- **`clone_projects()`**  
  Prompts the user to select projects to clone from Bitbucket and places them into the `$HOME/Projects` directory.

- **`build_docker_projects()`**  
  Iterates over cloned projects to build Docker images for Developer roles—skipping repositories that aren’t applicable (e.g., `channel_bay_design` and `pundit_lib`).

### Distribution-Specific Installation Functions

The script splits installation tasks by Linux distribution:

- **Debian/Ubuntu Functions**  
  Functions such as `deb_install_vscode`, `deb_install_chrome`, and `deb_install_docker` use `apt-get` to install packages and set up the system.

- **Arch Linux Functions**  
  Functions prefixed with `arch_` (e.g., `arch_update_system`, `arch_install_vscode`, `arch_install_docker`) use `pacman` and AUR helpers (like `yay`) for package management.

Each function is self-contained and designed to be easily modified or extended for supporting new packages or tools.

### Role-Based Flows

- **`run_debian_ubuntu_flow()`** and **`run_arch_flow()`**  
  These functions:
  - Prompt the user to select their role (Developer, Tester, Database, or Others).
  - Install a default set of applications based on the selected role.
  - Offer an additional selection of apps for further customization.

### Main Flow

After performing role-based installations, the script:

1. Prompts the user to set up (or confirm) their SSH key.
2. Clones projects from Bitbucket.
3. Triggers Docker builds for Developer roles.
4. Reminds the user to log out/in or open a new terminal session for changes (such as group memberships) to take effect.

### Enhanced Error Handling

One of the key features added to the script is a comprehensive error-handling system. Key points include:

- **Global Error Trap:**  
  An error trap catches any command that returns a nonzero exit status, displays the error location and command, and then pauses for user input. This prevents the script from terminating unexpectedly.

- **`safe_call` Function:**  
  This helper function wraps calls to critical functions. If an error occurs, it gives the user the option to retry the step or skip it. This approach ensures that if the script encounters an error, you can resume from that point rather than starting over.

Contributors modifying error handling should preserve this pattern to maintain consistency and robustness across the script.

---

## Coding Guidelines

- **Modularity:**  
  Encapsulate each installation or configuration task in its own function. When adding new features, follow this pattern to maintain a clean structure.

- **Naming Conventions:**  
  - Use clear prefixes for distribution-specific functions (`deb_` for Debian/Ubuntu, `arch_` for Arch Linux).
  - Use descriptive names for role-based flows (e.g., `run_debian_ubuntu_flow()`).

- **Comments:**  
  Add comments before complex logic or non-obvious code sections. This helps other contributors understand your changes quickly.

- **Error Handling:**  
  Ensure that new functions include robust error checks (e.g., validating file/directory existence) and integrate with the existing error-handling system.

- **Style:**  
  Follow consistent indentation, spacing, and general Bash scripting best practices.

---

## How to Contribute

1. **Fork and Clone:**  
   - Fork the repository and clone your fork to your local machine.
   - Create a new branch dedicated to your changes.

2. **Make Changes:**  
   - Add new functions or modify existing ones as needed.
   - Adhere to the established naming conventions and modular structure.
   - If you enhance or modify the error-handling mechanism (e.g., updating the `safe_call` function), update this document accordingly.
   - Ensure your changes are backward compatible with the current flows.

3. **Test Your Changes:**  
   - Run the script in a controlled environment (e.g., virtual machine or container) that mirrors the target distributions.
   - Verify that your modifications do not disrupt the existing functionality.
   - Add tests or logging if necessary to help diagnose issues.

4. **Submit a Pull Request:**  
   - Provide a clear description of your changes, including the rationale behind them.
   - Reference any related issues or feature requests.
   - Follow the repository’s pull request template and guidelines.

---

## Testing and Debugging

- **Local Testing:**  
  Test your changes on the appropriate Linux distribution(s) before committing. Virtual machines or containers are recommended to avoid unintended system modifications.

- **Debugging Tips:**  
  - Run the script with `bash -x setup.sh` to enable a command trace.
  - Use temporary `echo` statements or logging within functions to track execution flow.
  - Utilize the built-in error-handling and retry logic to quickly address any issues.

---

## Additional Resources

- [Bash Scripting Best Practices](https://devhints.io/bash)
- [GNU Bash Manual](https://www.gnu.org/software/bash/manual/bash.html)
- [Docker Documentation](https://docs.docker.com/)
- [GitHub Pull Request Guidelines](https://docs.github.com/en/pull-requests)

---

## Questions and Support

If you have any questions, encounter issues, or need further assistance, please:
- Open an issue on GitHub.
- Contact the repository maintainer via the project’s communication channels.

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

