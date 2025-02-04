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
- [Coding Guidelines](#coding-guidelines)
- [How to Contribute](#how-to-contribute)
- [Testing and Debugging](#testing-and-debugging)
- [Additional Resources](#additional-resources)
- [Questions and Support](#questions-and-support)

---

## Overview

The Universal Linux Setup Script is an interactive Bash script designed to automate the installation of development tools and configurations based on:
- **Linux Distribution:** Debian, Ubuntu, and Arch Linux.
- **User Role:** Developer, Tester, Database, or Others.

The script is modularly designed so that each functionality—whether it’s installing VSCode or setting up an SSH key—is encapsulated in its own function. This structure makes it easier to update, extend, and debug.

---

## Repository Structure

- **`setup.sh`**  
  The main executable Bash script. It contains:
  - Utility functions for repeated tasks (e.g., pausing for user input, generating SSH keys).
  - Functions to clone repositories and perform post-clone operations (e.g., building Docker projects).
  - Installation functions for various applications, separated by distribution (Debian/Ubuntu vs. Arch).
  - Role-based flows that guide the user through installing default and additional applications.
  - The main control flow that orchestrates the setup process based on user input.

- **`README.md`**  
  Provides an overview of the project, basic usage instructions, and links to additional documentation—including this contributing guide.

- **`CONTRIBUTING.md`** (this file)  
  Contains detailed documentation for contributors, including the design rationale, coding conventions, and steps for contributing new features or bug fixes.

---

## Script Architecture

### Utility Functions

- **`pause()`**  
  Pauses the script execution and waits for the user to press ENTER before continuing.

- **`generate_ssh_key()`**  
  Checks for an existing SSH key and creates one if not found. It then configures the SSH agent and displays the public key for the user to add to their Git hosting provider.

### Repository Management Functions

- **`clone_projects()`**  
  Prompts the user to select which projects to clone from Bitbucket and clones them into the `$HOME/Projects` directory.

- **`build_docker_projects()`**  
  For users with the Developer role, iterates over cloned projects to build Docker images—excluding those repositories that are not applicable (e.g., `channel_bay_design` and `pundit_lib`).

### Distribution-Specific Installation Functions

The script separates installation tasks by Linux distribution:

- **Debian/Ubuntu Functions**  
  These functions (e.g., `deb_install_vscode`, `deb_install_chrome`, `deb_install_docker`) use `apt-get` to install packages and configure the system.

- **Arch Linux Functions**  
  Functions prefixed with `arch_` (e.g., `arch_update_system`, `arch_install_vscode`, `arch_install_docker`) use `pacman` and AUR helpers (like `yay`) for installations.

Each function is self-contained and is designed to be easily modified or extended if new packages or tools need to be supported.

### Role-Based Flows

- **`run_debian_ubuntu_flow()`** and **`run_arch_flow()`**  
  These functions:
  - Prompt the user to select their role (Developer, Tester, Database, or Others).
  - Install a set of default applications based on the role.
  - Present an additional selection of apps (from a master list) for further customization.

### Main Flow

After the role-based installations:
1. The script prompts the user to set up (or confirm) their SSH key.
2. It then allows the user to clone projects from Bitbucket.
3. If the user’s role is Developer, the script triggers Docker builds for the appropriate repositories.
4. Finally, it reminds the user to log out/in or open a new terminal to apply changes such as group memberships.

---

## Coding Guidelines

- **Modularity:**  
  Each installation or configuration task is encapsulated in its own function. When adding a new feature, try to follow this pattern.

- **Naming Conventions:**  
  - Use a clear prefix for distribution-specific functions (`deb_` for Debian/Ubuntu and `arch_` for Arch Linux).
  - For role-based flows, use descriptive names like `run_debian_ubuntu_flow()`.

- **Comments:**  
  Include comments before complex logic or where the purpose of a code block isn’t immediately obvious. This makes it easier for other contributors to understand your changes.

- **Error Handling:**  
  Use checks (e.g., verifying the existence of directories or files) to make the script robust against failures.

- **Style:**  
  Maintain consistent indentation and spacing. Follow standard Bash scripting best practices.

---

## How to Contribute

1. **Fork and Clone:**  
   - Fork the repository and clone your fork to your local machine.
   - Create a new branch for your changes.

2. **Make Changes:**  
   - Add new functions or modify existing ones as needed.
   - Ensure that new functions follow the existing naming conventions and structure.
   - Update this documentation if you introduce significant changes.

3. **Test Your Changes:**  
   - Run the script in a controlled environment (e.g., a virtual machine or container) that mirrors your target distribution.
   - Verify that your modifications do not break the existing flows.

4. **Submit a Pull Request:**  
   - Provide a clear description of your changes.
   - Reference any related issues or feature requests.
   - Follow any additional guidelines as described in the repository’s pull request template.

---

## Testing and Debugging

- **Local Testing:**  
  Before committing, test your changes on the appropriate Linux distribution(s). It is recommended to use virtual machines or containers to prevent unintended system modifications.

- **Debugging Tips:**  
  - Run the script with `bash -x setup.sh` to see a trace of the commands.
  - Insert temporary `echo` statements or use logging within functions to trace the flow of execution.

---

## Additional Resources

- [Bash Scripting Guide (GNU)](https://www.gnu.org/software/bash/manual/bash.html)
- [ShellCheck – A Shell Script Linter](https://www.shellcheck.net/)
- [Best Practices for Bash Scripting](https://github.com/koalaman/shellcheck/wiki)

---

## Questions and Support

If you have any questions, encounter issues, or need further assistance, please:
- Open an issue on GitHub.
- Contact the repository maintainer via the project’s communication channels.

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

