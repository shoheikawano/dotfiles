# alias
alias c='clear'

## adb related
alias cap='adb shell screencap -p /sdcard/screen.png && adb pull /sdcard/screen.png ~/Desktop/"$(date +"%Y_%m_%d_%I_%M_%S_%p").png" && adb shell rm /sdcard/screen.png'
alias rec='scrcpy -r ~/Desktop/$(date +%Y_%m_%d_%I_%M_%S_%p).mp4'
alias analyticsdebug='adb shell setprop debug.firebase.analytics.app '
alias sc='scrcpy'

## git
alias g='git '
alias ga='git add .'
alias gb='git branch '
alias gs='g status'
alias gsh='git stash'
alias gshp='git stash pop'
alias gp='g pull'
alias gpr='g pull --rebase'
alias gd='git diff '
alias gdc='git diff --cached '
alias gbd='g b -d '
alias gbD='g b -D '
alias gl='g log'
alias gci='g commit -m '
alias gcp='g cherry-pick '
alias gr='g rebase --origin '
alias gsi='git switch '

## git completion
test -f /usr/local/etc/bash_completion.d/.git-prompt.bash && . $_
test -f /usr/local/etc/bash_completion.d/.git-completion.bash && . $_

## gradle
alias gw='./gradlew '
alias gco='git checkout '
alias uninst='adb uninstall '
alias instd='gw installDebug'
alias instr='gw installRelease'
alias gc='./gradlew clean'
alias dep='./gradlew dependencyUpdates'

# java
alias java8='export JAVA_HOME=$JAVA_8_HOME'
alias java11='export JAVA_HOME=$JAVA_11_HOME'

# autocompletion
autoload -Uz compinit
compinit
setopt COMPLETE_ALIASES

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# ruby
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

export SDK_MANAGER="~/Library/Android/sdk/tools/bin/sdkmanager"
export CMD_LINE_TOOLS="~/Library/Android/sdk/cmdline-tools/latest"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

