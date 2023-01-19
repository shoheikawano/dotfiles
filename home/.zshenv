# Load zshrc
if [ -f ~/.zshrc ] ; then
  . ~/.zshrc
fi
if [ -f ~/.zshrcx ] ; then
  . ~/.zshrcx
fi

# Android SDK
export ANDROID_HOME=~/Library/Android/sdk
export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk

# Java
export JAVA_HOME=/Library/Java/JavaVirtualMachines/temurin-11.jdk/Contents/Home
export PATH=$PATH:$JAVA_HOME/bin

# ADB
export ADB_HOME=/Library/Android/sdk/platform-tools
export PATH=$PATH:$ADB_HOME

# depot_tools
export PATH=$PATH:~/depot_tools

# flutter
export PATH=$PATH:~/Library/flutter/bin

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"
[ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm"

# python
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

# ruby
export PATH="$HOME/.rbenv/bin:$PATH"

# homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"
