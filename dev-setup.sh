#!/usr/bin/env bash

set -e

echo "🚀 Iniciando ApolloStack — preparando seu ambiente de desenvolvimento..."

# -------------------------
# Atualiza o sistema
# -------------------------
sudo apt update && sudo apt upgrade -y

# -------------------------
# Instalações essenciais
# -------------------------
sudo apt install -y curl git unzip build-essential libssl-dev libreadline-dev zlib1g-dev \
  libsqlite3-dev libbz2-dev libffi-dev liblzma-dev libxml2-dev libxslt1-dev libncurses5-dev \
  libncursesw5-dev xz-utils tk-dev software-properties-common libgdbm-dev libnss3-dev \
  libcurl4-openssl-dev

# -------------------------
# Instala Docker
# -------------------------
echo "🐳 Instalando Docker..."
if ! command -v docker &> /dev/null; then
sudo apt install -y curl apt-transport-https ca-certificates software-properties-common
  sudo apt install -y docker.io
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt update
  sudo apt install -y docker-ce
  sudo usermod -aG docker $USER
  su $USER -c "newgrp docker"
else
  echo "Docker já está instalado."
fi

# -------------------------
# Instala Git
# -------------------------
echo "🔧 Instalando Git..."
sudo apt install -y git

# -------------------------
# Instala NVM e Node.js
# -------------------------
echo "🔧 Instalando NVM e Node.js..."
export NVM_DIR="$HOME/.nvm"
if [ ! -d "$NVM_DIR" ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
fi
source "$HOME/.nvm/nvm.sh"
nvm install --lts
nvm alias default 'lts/*'

# -------------------------
# Instala PHP (phpenv + php-build)
# -------------------------
echo "🔧 Instalando phpenv e php-build..."
if ! command -v phpenv &> /dev/null; then
  if [ ! -d "$HOME/.phpenv" ]; then
    git clone https://github.com/phpenv/phpenv.git ~/.phpenv
    echo 'export PATH="$HOME/.phpenv/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(phpenv init -)"' >> ~/.bashrc
    export PATH="$HOME/.phpenv/bin:$PATH"
    eval "$(phpenv init -)"
  fi

  if [ ! -d "$(phpenv root)/plugins/php-build" ]; then
    git clone https://github.com/php-build/php-build.git "$(phpenv root)/plugins/php-build"
  fi

  # Instala PHP 8.2.17 como exemplo
  sudo apt install -y libcurl4-openssl-dev libreadline-dev libedit-dev libsqlite3-dev libonig-dev libzip-dev libssl-dev libjpeg-dev libpng-dev libxpm-dev libfreetype6-dev libxml2-dev libicu-dev libbz2-dev libtidy-dev libxslt1-dev libargon2-dev libdb-dev pkg-config re2c bison autoconf
  PHP_BUILD_CONFIGURE_OPTS="--enable-phar" phpenv install 8.2.17
  phpenv global 8.2.17
fi

# -------------------------
# Instala utilitários modernos
# -------------------------
echo "🔧 Instalando ferramentas auxiliares..."

# Eza (substituto do exa)
sudo apt install -y eza

# Bat
if ! command -v bat &> /dev/null; then
  sudo apt install -y bat
fi

# Lazygit
if ! command -v lazygit &> /dev/null; then
  echo "🔧 Instalando Lazygit..."
  LAZYGIT_VERSION=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep tag_name | cut -d '"' -f 4)
  curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION#v}_Linux_x86_64.tar.gz"
  tar xf lazygit.tar.gz lazygit
  sudo install lazygit /usr/local/bin
  rm -f lazygit lazygit.tar.gz
fi

# -------------------------
# Instala Neovim
# -------------------------
if ! command -v nvim &> /dev/null; then
  echo "🧠 Instalando Neovim..."

  NEOVIM_VERSION=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest | grep tag_name | cut -d '"' -f 4)
  curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
  sudo rm -rf /opt/nvim
  sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
  export PATH="$PATH:/opt/nvim-linux-x86_64/bin"
  rm nvim-linux-x86_64.tar.gz
fi
# Verificação
if command -v nvim &> /dev/null; then
  echo "✅ Neovim instalado com sucesso: $(nvim --version | head -n 1)"
else
  echo "❌ Erro ao instalar o Neovim!"
fi

# -------------------------
# Instala ASDF
# -------------------------
if ! command -v asdf &> /dev/null; then
  echo "🔧 Instalando ASDF..."
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.13.1
  echo -e '\n. "$HOME/.asdf/asdf.sh"' >> ~/.zshrc
  echo -e '\n. "$HOME/.asdf/completions/asdf.bash"' >> ~/.zshrc
fi

# -------------------------
# Zsh + Oh My Zsh + Powerlevel10k
# -------------------------
echo "🎨 Instalando Zsh e Powerlevel10k..."

sudo apt install -y zsh fonts-powerline
chsh -s $(which zsh)

# Instala Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Instala Powerlevel10k
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
fi

echo -e '\n# ApolloStack Configuration' >> ~/.zshrc
echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.zshrc
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.zshrc
echo 'export PHPENV_ROOT="$HOME/.phpenv"' >> ~/.zshrc
echo 'export PATH="$PHPENV_ROOT/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(phpenv init -)"' >> ~/.zshrc
echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >> ~/.zshrc
echo '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' >> ~/.zshrc

echo "🧙 Iniciando a configuração do Powerlevel10k..."

# Garante que o Zsh esteja carregado com as configs do powerlevel10k
if [ -f ~/.zshrc ]; then
  # Executa um subshell do zsh com o tema já carregado e roda o configurador
  zsh -i -c '[[ $(type -t p10k) == function ]] && p10k configure || echo "⚠️ Powerlevel10k não carregou completamente. Tente abrir um novo terminal e rodar p10k configure manualmente."'
else
  echo "⚠️ .zshrc não encontrado. Pulei a configuração automática do Powerlevel10k."
fi

# -------------------------
# Finalização
# -------------------------
echo "✅ ApolloStack finalizado com sucesso! Reinicie o terminal para aplicar todas as mudanças."

