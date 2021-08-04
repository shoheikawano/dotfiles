# Load zshrc
if [ -f ~/.zshrc ] ; then
  . ~/.zshrc
fi
if [ -f ~/.zshrcx ] ; then
  . ~/.zshrcx
fi

# Android SDK
export PATH=$PATH:~/Library/Android/sdk/platform-tools
export ANDROID_HOME=~/Library/Android/sdk/platform-tools

# Java
export JAVA_HOME=$(/usr/libexec/java_home -v11)
export JAVA_8_HOME=$(/usr/libexec/java_home -v1.8)
export JAVA_11_HOME=$(/usr/libexec/java_home -v11)

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
