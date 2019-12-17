# Load bashrc
if [ -f ~/.bashrc ] ; then
  . ~/.bashrc
fi

# Android SDK
export PATH=$PATH:~/Library/Android/sdk/platform-tools
export ANDROID_HOME=~/Library/Android/sdk/platform-tools

# depot_tools
export PATH=$PATH:~/depot_tools

# repo
export PATH=$PATH:~/bin

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"
[ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm"

