# alias
alias g='git '
alias ga='git add .'
alias gb='git branch '
alias gs='g status'
alias gp='g pull'
alias gpr='g pull --rebase'
alias gd='git diff '
alias gdc='git diff --cached '
alias gw='./gradlew '
alias gbd='g b -d '
alias gbD='g b -D '
alias gl='g log'
alias gci='g commit -m '
alias gcp='g cherry-pick '
alias gr='g reset HEAD '
alias gco='git checkout '

alias uninst='adb uninstall '
alias instd='gw installDebug'
alias instr='gw installRelease'
alias gc='./gradlew clean'
alias dep='./gradlew dependencyUpdates'
alias cap='adb exec-out screencap -p > ~/Desktop/"$(date +"%Y_%m_%d_%I_%M_%S_%p").png"'
alias rec='scrcpy -r ~/Desktop/$(date +%Y_%m_%d_%I_%M_%S_%p).mp4'
alias analyticsdebug='adb shell setprop debug.firebase.analytics.app '
alias sc='scrcpy'

# java
alias java8='export JAVA_HOME=$JAVA_8_HOME'
alias java11='export JAVA_HOME=$JAVA_11_HOME'

# git
test -f /usr/local/etc/bash_completion.d/.git-prompt.bash && . $_
test -f /usr/local/etc/bash_completion.d/.git-completion.bash && . $_

# autocompletion
autoload -Uz compinit
compinit
setopt COMPLETE_ALIASES

# ruby
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

export SDK_MANAGER="~/Library/Android/sdk/tools/bin/sdkmanager"
export CMD_LINE_TOOLS="~/Library/Android/sdk/cmdline-tools/latest"

. /opt/homebrew/opt/asdf/libexec/asdf.sh
