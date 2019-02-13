# Load bashrc
if [ -f ~/.bashrc ] ; then
  . ~/.bashrc
fi

# Android SDK
export PATH=$PATH:~/Library/Android/sdk/platform-tools

# depot_tools
export PATH=$PATH:~/depot_tools
