#!/usr/bin/env bash
#===============================================================================
# Comprehensive Setup Script with Error Handling and Retry/Skip Mechanism
#===============================================================================

# Enable extended error tracing (so functions inherit our trap)
set -o errtrace

#------------------------------------------------------------------------------
# Global Error Trap: When any command returns a nonzero exit status,
# print an error message with the line and command, and wait for the user.
#------------------------------------------------------------------------------
error_trap() {
  local last_line=$1
  local last_command=$2
  echo "--------------------------------------------------"
  echo "ERROR encountered at line ${last_line}:"
  echo "   Command: ${last_command}"
  echo "--------------------------------------------------"
  read -rp "Press ENTER to resume (or Ctrl-C to abort)..." dummy
}
trap 'error_trap ${LINENO} "$BASH_COMMAND"' ERR

#------------------------------------------------------------------------------
# safe_call: Wrap any function call so that if it returns a nonzero code,
# the user is prompted to retry the function or skip that step.
#
# Usage:
#   safe_call function_name [arguments...]
#------------------------------------------------------------------------------
safe_call() {
  local func="$1"
  shift
  while true; do
    # Call the function with any passed arguments.
    "$func" "$@"
    local ret=$?
    if [ $ret -eq 0 ]; then
      break
    else
      echo "--------------------------------------------------"
      echo "The step '$func' returned an error (exit code: $ret)."
      read -rp "Press ENTER to retry, or type 'skip' to skip this step: " choice
      if [[ "$choice" == "skip" ]]; then
        echo "Skipping step '$func' as per your input."
        break
      fi
      echo "Retrying '$func'..."
    fi
  done
}

#######################################
# Universal utility functions
#######################################

pause() {
  read -rp "Press ENTER to continue..." key
}

generate_ssh_key() {
  echo "========================================"
  echo "Generating SSH key..."
  [ -d "$HOME/.ssh" ] || mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"

  if [ ! -f "$HOME/.ssh/id_rsa" ]; then
    ssh-keygen -t rsa -b 4096 -f "$HOME/.ssh/id_rsa" -N ""
  else
    echo "SSH key already exists at $HOME/.ssh/id_rsa. Skipping generation."
  fi

  eval "$(ssh-agent -s)"
  ssh-add "$HOME/.ssh/id_rsa"

  echo ""
  echo "Below is your public key (add it to Bitbucket or your Git hosting provider):"
  echo "================================================"
  cat "$HOME/.ssh/id_rsa.pub"
  echo "================================================"
  return 0
}

clone_projects() {
  echo "========================================"
  echo "Cloning projects..."
  echo "Making Projects folder in $HOME/Projects..."
  mkdir -p "$HOME/Projects"
  cd "$HOME/Projects" || return 1

  echo ""
  echo "Which projects would you like to clone? (enter multiple numbers, space-separated)"
  PROJECTS=(
    "shopifyexport_r7"
    "report_pundit_r7"
    "pundit_lib"
    "bloom"
    "channel_bay"
    "channel_bay_design"
  )

  for i in "${!PROJECTS[@]}"; do
    echo "$((i+1))) ${PROJECTS[$i]}"
  done

  read -rp "Enter your choices (e.g. 1 3 5): " project_choices

  for choice in $project_choices; do
    idx=$((choice-1))
    if [ "$idx" -ge 0 ] && [ "$idx" -lt "${#PROJECTS[@]}" ]; then
      echo "Cloning ${PROJECTS[$idx]}..."
      git clone "git@bitbucket.org:freddy_dev/${PROJECTS[$idx]}.git"
    else
      echo "Invalid choice: $choice"
    fi
  done

  echo "Done cloning projects."
  return 0
}

build_docker_projects() {
  echo "========================================"
  echo "Building Docker projects (excluding channel_bay_design and pundit_lib)..."
  echo "========================================"
  PROJECTS_DIR="$HOME/Projects"
  if [ ! -d "$PROJECTS_DIR" ]; then
    echo "Projects directory not found!"
    return 1
  fi
  for repo in "$PROJECTS_DIR"/*; do
    if [ -d "$repo" ]; then
      repo_name=$(basename "$repo")
      # Skip repositories that should not be built.
      if [[ "$repo_name" == "channel_bay_design" || "$repo_name" == "pundit_lib" ]]; then
        echo "Skipping docker build for $repo_name"
        continue
      fi
      echo "Building docker project in $repo_name..."
      cd "$repo" || continue
      # Check for docker-compose file before building.
      if [ -f "docker-compose.yml" ] || [ -f "docker-compose.yaml" ]; then
        sudo docker compose build --no-cache
      else
        echo "No docker-compose file found in $repo_name, skipping..."
      fi
      cd "$PROJECTS_DIR" || return 1
      echo
    fi
  done
  return 0
}

#######################################
# Debian/Ubuntu installation functions
#######################################

deb_install_vscode() {
  echo "Installing VSCode..."
  sudo apt-get update -y
  sudo apt-get install -y wget gpg apt-transport-https
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
  sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
  echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] \
https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
  rm -f packages.microsoft.gpg
  sudo apt-get update -y
  sudo apt-get install -y code
  return 0
}

deb_install_chrome() {
  echo "Installing Google Chrome..."
  sudo apt-get update -y
  sudo apt-get install -y wget
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  sudo dpkg -i google-chrome-stable_current_amd64.deb || sudo apt-get -f install -y
  rm -f google-chrome-stable_current_amd64.deb
  return 0
}

deb_install_nvm_node() {
  echo "Installing NVM and Node (v22)..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  nvm install 22
  echo "Node version: $(node -v)"
  echo "NVM current: $(nvm current)"
  echo "NPM version: $(npm -v)"
  return 0
}

deb_install_dbeaver() {
  echo "Installing DBeaver CE..."
  sudo wget -O /usr/share/keyrings/dbeaver.gpg.key https://dbeaver.io/debs/dbeaver.gpg.key
  echo "deb [signed-by=/usr/share/keyrings/dbeaver.gpg.key] https://dbeaver.io/debs/dbeaver-ce /" | sudo tee /etc/apt/sources.list.d/dbeaver.list
  sudo apt-get update -y
  sudo apt-get install -y dbeaver-ce
  return 0
}

deb_install_zoom() {
  echo "Installing Zoom..."
  sudo apt-get install -y gdebi-core wget
  wget https://zoom.us/client/latest/zoom_amd64.deb
  sudo apt-get update -y
  sudo apt-get install -y \
    libglib2.0-0 \
    libgstreamer-plugins-base0.10-0 \
    libxcb-shape0 \
    libxcb-shm0 \
    libxcb-xfixes0 \
    libxcb-randr0 \
    libxcb-image0 \
    libfontconfig1 \
    libgl1-mesa-glx \
    libxi6 \
    libsm6 \
    libxrender1 \
    libpulse0 \
    libxcomposite1 \
    libxslt1.1 \
    libsqlite3-0 \
    libxcb-keysyms1 \
    libxcb-xtest0 \
    ibus
  sudo gdebi -n zoom_amd64.deb
  rm -f zoom_amd64.deb
  return 0
}

deb_install_docker() {
  echo "Installing Docker..."
  sudo apt-get update -y
  sudo apt-get install -y ca-certificates curl gnupg lsb-release
  if grep -q "Debian" /etc/os-release; then
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/debian \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  else
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc >/dev/null
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  fi

  sudo apt-get update -y
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  sudo usermod -aG docker "$USER"
  sudo systemctl enable docker.service
  sudo systemctl enable containerd.service
  echo "Docker installed. You must log out/in or run 'newgrp docker' to use Docker as non-root."
  return 0
}

deb_install_openvpn3() {
  echo "Installing OpenVPN 3..."
  DISTRO=$(lsb_release -cs)
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://packages.openvpn.net/packages-repo.gpg | sudo tee /etc/apt/keyrings/openvpn.asc >/dev/null
  echo "deb [signed-by=/etc/apt/keyrings/openvpn.asc] https://packages.openvpn.net/openvpn3/debian $DISTRO main" | sudo tee /etc/apt/sources.list.d/openvpn3.list
  sudo apt-get update -y
  sudo apt-get install -y openvpn3
  return 0
}

deb_install_warp() {
  echo "Installing Warp Terminal..."
  wget https://releases.warp.dev/stable/v0.2025.01.22.08.02.stable_05/warp-terminal_0.2025.01.22.08.02.stable.05_amd64.deb
  sudo dpkg -i warp-terminal_0.2025.01.22.08.02.stable.05_amd64.deb || sudo apt-get -f install -y
  rm -f warp-terminal_0.2025.01.22.08.02.stable.05_amd64.deb
  return 0
}

deb_install_pyenv_and_python() {
  echo "Installing PyEnv and Python 3.7.17..."
  sudo apt-get update -y
  sudo apt-get install -y curl git gnupg2 build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
  curl https://pyenv.run | bash
  {
    echo 'export PYENV_ROOT="$HOME/.pyenv"'
    echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"'
    echo 'eval "$(pyenv init -)"'
  } >> "$HOME/.profile"
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"
  pyenv install 3.7.17
  pyenv global 3.7.17
  python_version=$(python --version 2>&1)
  echo "Current Python version: $python_version"
  pip install --upgrade pip
  pip install selenium \
              robotframework \
              robotframework-databaselibrary \
              robotframework-datadriver \
              robotframework-seleniumlibrary \
              robotframework-selenium2library \
              psycopg2-binary
  return 0
}

deb_install_rvm_and_ruby() {
  echo "Installing RVM and Ruby 3.0.3..."
  gpg --keyserver keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
  sudo apt-get install -y software-properties-common
  sudo apt-add-repository -y ppa:rael-gc/rvm
  sudo apt-get update -y
  sudo apt-get install -y rvm
  sudo usermod -a -G rvm "$USER"
  echo 'source "/etc/profile.d/rvm.sh"' >> ~/.bashrc
  if [ -f /etc/profile.d/rvm.sh ]; then
    source /etc/profile.d/rvm.sh
  else
    source "$HOME/.rvm/scripts/rvm"
  fi
  echo "RVM loaded successfully."
  echo "Verifying RVM installation..."
  type rvm | head -n 1
  rvm pkg install openssl
  rvm install 3.0.3 --with-openssl-dir="$HOME/.rvm/usr"
  rvm use 3.0.3 --default
  gem install capistrano -v 3.16.0
  gem install capistrano-bundler capistrano-passenger capistrano-rails capistrano-nvm specific_install activesupport
  gem specific_install https://github.com/freddy-dev/rvm.git
  return 0
}

deb_install_sublime() {
  echo "Installing Sublime Text..."
  wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg > /dev/null
  echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
  sudo apt-get update -y
  sudo apt-get install -y sublime-text
  return 0
}

#######################################
# Arch installation functions
#######################################

arch_update_system() {
  echo "Updating system (pacman -Syu)..."
  sudo pacman -Syu --noconfirm
  return 0
}

arch_install_base_dev_git() {
  echo "Installing base-devel and git..."
  sudo pacman -S --needed --noconfirm base-devel git
  return 0
}

arch_install_yay() {
  echo "Installing yay (AUR helper)..."
  if command -v yay &>/dev/null; then
    echo "yay is already installed. Skipping..."
    return 0
  fi
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  cd /tmp/yay || return 1
  makepkg -si --noconfirm
  cd - || return 1
  echo "yay version: $(yay --version)"
  return 0
}

arch_install_vscode() {
  echo "Installing Visual Studio Code (AUR)..."
  yay -S --noconfirm visual-studio-code-bin
  return 0
}

arch_install_chrome() {
  echo "Installing Google Chrome (AUR)..."
  yay -S --noconfirm google-chrome
  return 0
}

arch_install_nvm_node() {
  echo "Installing NVM + Node.js (v22)..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  nvm install 22
  echo "Node version: $(node -v)"
  echo "NVM current: $(nvm current)"
  echo "NPM version: $(npm -v)"
  return 0
}

arch_install_dbeaver() {
  echo "Installing DBeaver..."
  sudo pacman -Sy --noconfirm dbeaver
  return 0
}

arch_install_zoom() {
  echo "Installing Zoom (AUR)..."
  yay -S --noconfirm zoom
  return 0
}

arch_install_docker() {
  echo "Installing Docker + docker-compose..."
  sudo pacman -S --noconfirm docker docker-compose bash-completion
  sudo systemctl enable docker.service
  sudo systemctl start docker.service
  sudo usermod -aG docker "$USER"
  echo "Docker installed. Log out/in (or use 'newgrp docker') to use Docker as non-root."
  return 0
}

arch_install_openvpn3() {
  echo "Installing openvpn3 (AUR)..."
  yay -S --noconfirm openvpn3
  return 0
}

arch_install_warp() {
  echo "Installing Warp Terminal (AUR)..."
  yay -S --noconfirm warp-terminal-bin
  return 0
}

arch_install_pyenv_and_python() {
  echo "Installing PyEnv + Python (3.7.17) on Arch..."
  sudo pacman -S --needed --noconfirm base-devel openssl zlib bzip2 readline sqlite ncurses xz tk libffi libxml2 libxmlsec liblzma
  curl https://pyenv.run | bash
  {
    echo 'export PYENV_ROOT="$HOME/.pyenv"'
    echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"'
    echo 'eval "$(pyenv init -)"'
  } >> "$HOME/.bashrc"
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"
  pyenv install 3.7.17
  pyenv global 3.7.17
  python_version=$(python --version 2>&1)
  echo "Current Python version: $python_version"
  pip install --upgrade pip
  pip install selenium \
              robotframework \
              robotframework-databaselibrary \
              robotframework-datadriver \
              robotframework-seleniumlibrary \
              robotframework-selenium2library \
              psycopg2-binary
  return 0
}

arch_install_rvm_and_ruby() {
  echo "Installing RVM + Ruby (3.0.3) on Arch..."
  sudo pacman -S --noconfirm gnupg curl
  gpg --keyserver keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
  \curl -sSL https://get.rvm.io | bash -s stable
  if [ -f /etc/profile.d/rvm.sh ]; then
    source /etc/profile.d/rvm.sh
  else
    source "$HOME/.rvm/scripts/rvm"
  fi
  echo "Verifying RVM installation..."
  type rvm | head -n 1
  rvm pkg install openssl
  rvm install 3.0.3 --with-openssl-dir="$HOME/.rvm/usr"
  rvm use 3.0.3 --default
  gem install capistrano -v 3.16.0
  gem install capistrano-bundler capistrano-passenger capistrano-rails capistrano-nvm specific_install activesupport
  gem specific_install https://github.com/freddy-dev/rvm.git
  return 0
}

arch_install_sublime() {
  echo "Installing Sublime Text..."
  curl -O https://download.sublimetext.com/sublimehq-pub.gpg
  sudo pacman-key --add sublimehq-pub.gpg
  sudo pacman-key --lsign-key 8A8F901A
  rm sublimehq-pub.gpg
  echo -e "\n[sublime-text]\nServer = https://download.sublimetext.com/arch/stable/x86_64" | sudo tee -a /etc/pacman.conf
  sudo pacman -Syu --noconfirm sublime-text
  return 0
}

#######################################
# Debian/Ubuntu Flow with Role Selection
#######################################

run_debian_ubuntu_flow() {
  echo "==========================================="
  echo "   Debian/Ubuntu Setup Script with Role Selection"
  echo "==========================================="
  echo "What is your role in the company?"
  echo "1) Developer"
  echo "2) Tester"
  echo "3) Database"
  echo "4) Others"
  read -rp "Enter your role number: " ROLE_CHOICE
  case $ROLE_CHOICE in
    1) ROLE="Developer" ;;
    2) ROLE="Tester" ;;
    3) ROLE="Database" ;;
    4) ROLE="Others" ;;
    *) echo "Invalid role, defaulting to Others"; ROLE="Others" ;;
  esac

  echo "Selected Role: $ROLE"
  echo

  declare -a default_apps=()
  if [[ $ROLE == "Developer" ]]; then
      default_apps=("Docker" "DBeaver" "OpenVPN3" "Sublime Text")
      echo "Installing default applications for Developer..."
      safe_call deb_install_docker
      safe_call deb_install_dbeaver
      safe_call deb_install_openvpn3
      safe_call deb_install_sublime
  elif [[ $ROLE == "Tester" ]]; then
      default_apps=("DBeaver" "Sublime Text" "OpenVPN3" "RVM + Ruby" "PyEnv + Python")
      echo "Installing default applications for Tester..."
      safe_call deb_install_dbeaver
      safe_call deb_install_sublime
      safe_call deb_install_openvpn3
      safe_call deb_install_rvm_and_ruby
      safe_call deb_install_pyenv_and_python
  elif [[ $ROLE == "Database" ]]; then
      default_apps=("DBeaver" "Sublime Text" "OpenVPN3")
      echo "Installing default applications for Database..."
      safe_call deb_install_dbeaver
      safe_call deb_install_sublime
      safe_call deb_install_openvpn3
  else
      default_apps=()
      echo "No default applications for Others."
  fi

  # Master list of available apps for Debian/Ubuntu.
  declare -A deb_apps
  deb_apps=(
    ["VSCode"]="deb_install_vscode"
    ["Google Chrome"]="deb_install_chrome"
    ["NVM + Node.js"]="deb_install_nvm_node"
    ["DBeaver"]="deb_install_dbeaver"
    ["Zoom"]="deb_install_zoom"
    ["Docker"]="deb_install_docker"
    ["OpenVPN3"]="deb_install_openvpn3"
    ["Warp Terminal"]="deb_install_warp"
    ["PyEnv + Python"]="deb_install_pyenv_and_python"
    ["RVM + Ruby"]="deb_install_rvm_and_ruby"
    ["Sublime Text"]="deb_install_sublime"
  )

  # Build additional selection list by removing the default apps.
  declare -a additional_apps=()
  for app in "${!deb_apps[@]}"; do
    skip=false
    for dapp in "${default_apps[@]}"; do
      if [[ "$app" == "$dapp" ]]; then
        skip=true
        break
      fi
    done
    if ! $skip; then
      additional_apps+=("$app")
    fi
  done

  echo
  echo "Which additional applications do you require? (enter numbers space-separated, or press ENTER to skip)"
  for i in "${!additional_apps[@]}"; do
    echo "$((i+1))) ${additional_apps[$i]}"
  done
  read -rp "Your selection: " additional_selections
  echo "You selected: $additional_selections"
  echo

  for choice in $additional_selections; do
    index=$((choice-1))
    if [[ $index -ge 0 && $index -lt ${#additional_apps[@]} ]]; then
      app_name="${additional_apps[$index]}"
      echo "Installing $app_name..."
      safe_call "${deb_apps[$app_name]}"
    else
      echo "Invalid selection: $choice"
    fi
    echo
  done
  return 0
}

#######################################
# Arch Flow with Role Selection
#######################################

run_arch_flow() {
  echo "==========================================="
  echo "   Arch Linux Setup Script with Role Selection"
  echo "==========================================="
  echo "What is your role in the company?"
  echo "1) Developer"
  echo "2) Tester"
  echo "3) Database"
  echo "4) Others"
  read -rp "Enter your role number: " ROLE_CHOICE
  case $ROLE_CHOICE in
    1) ROLE="Developer" ;;
    2) ROLE="Tester" ;;
    3) ROLE="Database" ;;
    4) ROLE="Others" ;;
    *) echo "Invalid role, defaulting to Others"; ROLE="Others" ;;
  esac

  echo "Selected Role: $ROLE"
  echo

  declare -a default_apps=()
  if [[ $ROLE == "Developer" ]]; then
      default_apps=("Docker" "DBeaver" "OpenVPN3" "Sublime Text")
      echo "Installing default applications for Developer..."
      safe_call arch_install_docker
      safe_call arch_install_dbeaver
      safe_call arch_install_openvpn3
      safe_call arch_install_sublime
  elif [[ $ROLE == "Tester" ]]; then
      default_apps=("DBeaver" "Sublime Text" "OpenVPN3" "RVM + Ruby" "PyEnv + Python")
      echo "Installing default applications for Tester..."
      safe_call arch_install_dbeaver
      safe_call arch_install_sublime
      safe_call arch_install_openvpn3
      safe_call arch_install_rvm_and_ruby
      safe_call arch_install_pyenv_and_python
  elif [[ $ROLE == "Database" ]]; then
      default_apps=("DBeaver" "Sublime Text" "OpenVPN3")
      echo "Installing default applications for Database..."
      safe_call arch_install_dbeaver
      safe_call arch_install_sublime
      safe_call arch_install_openvpn3
  else
      default_apps=()
      echo "No default applications for Others."
  fi

  # Master list of available apps for Arch.
  declare -A arch_apps
  arch_apps=(
    ["System Update"]="arch_update_system"
    ["Base-devel + Git"]="arch_install_base_dev_git"
    ["yay (AUR helper)"]="arch_install_yay"
    ["Visual Studio Code"]="arch_install_vscode"
    ["Google Chrome"]="arch_install_chrome"
    ["NVM + Node.js"]="arch_install_nvm_node"
    ["DBeaver"]="arch_install_dbeaver"
    ["Zoom"]="arch_install_zoom"
    ["Docker + docker-compose"]="arch_install_docker"
    ["OpenVPN3"]="arch_install_openvpn3"
    ["Warp Terminal"]="arch_install_warp"
    ["PyEnv + Python"]="arch_install_pyenv_and_python"
    ["RVM + Ruby"]="arch_install_rvm_and_ruby"
    ["Sublime Text"]="arch_install_sublime"
  )

  # Build additional selection list by removing the default apps.
  declare -a additional_apps=()
  for app in "${!arch_apps[@]}"; do
    skip=false
    for dapp in "${default_apps[@]}"; do
      if [[ "$app" == "$dapp" ]]; then
        skip=true
        break
      fi
    done
    if ! $skip; then
      additional_apps+=("$app")
    fi
  done

  echo
  echo "Which additional applications do you require? (enter numbers space-separated, or press ENTER to skip)"
  for i in "${!additional_apps[@]}"; do
    echo "$((i+1))) ${additional_apps[$i]}"
  done
  read -rp "Your selection: " additional_selections
  echo "You selected: $additional_selections"
  echo

  for choice in $additional_selections; do
    index=$((choice-1))
    if [[ $index -ge 0 && $index -lt ${#additional_apps[@]} ]]; then
      app_name="${additional_apps[$index]}"
      echo "Installing $app_name..."
      safe_call "${arch_apps[$app_name]}"
    else
      echo "Invalid selection: $choice"
    fi
    echo
  done
  return 0
}

#######################################
# Main Flow
#######################################

clear
echo "========================================"
echo "  Let's set up your distribution! "
echo "========================================"
echo "1) Debian"
echo "2) Ubuntu"
echo "3) Arch"
echo "========================================"
read -rp "Which distro are you using? (1/2/3): " DISTRO_CHOICE
echo

case "$DISTRO_CHOICE" in
  1|2)
    echo "Selected: Debian/Ubuntu"
    safe_call run_debian_ubuntu_flow
    ;;
  3)
    echo "Selected: Arch"
    safe_call run_arch_flow
    ;;
  *)
    echo "Invalid choice. Exiting..."
    exit 1
    ;;
esac

echo "========================================"
echo "Now we'll set up (or confirm) your SSH key."
echo "========================================"
safe_call generate_ssh_key
echo
echo "Have you added your SSH key to Bitbucket (or your Git provider)?"
pause
echo
safe_call clone_projects

# If the user's role is Developer, build docker projects in each repository (except channel_bay_design and pundit_lib).
if [[ "$ROLE" == "Developer" ]]; then
  safe_call build_docker_projects
fi

echo ""
echo "Script finished!"
echo "Remember to open a new terminal or log out/in for group memberships (e.g. Docker) or environment changes (PyEnv, RVM, NVM) to fully take effect."
exit 0
