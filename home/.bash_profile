# Load bashrc
if [ -f ~/.bashrc ] ; then
  . ~/.bashrc
fi

# Android SDK
export PATH=$PATH:~/Library/Android/sdk/platform-tools
export ANDROID_HOME=~/Library/Android/sdk/platform-tools

# Java 8
export JAVA_HOME=/Library/Java/JavaVirtualMachines/adoptopenjdk-8.jdk/Contents/Home

# depot_tools
export PATH=$PATH:~/depot_tools

# repo
export PATH=$PATH:~/bin

