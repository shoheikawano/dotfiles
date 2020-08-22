# alias
alias g='git '
alias gst='g st'
alias gp='g pull'
alias gpr='g pull --rebase'
alias gd='git diff '
alias gw='./gradlew '
alias gbd='g b -d '
alias gbD='g b -D '
alias gl='g log'
alias gcim='g commit -m '
alias gcp='g cherry-pick '
alias gcemp='g commit --allow-empty'
alias instd='adb install app/build/outputs/apk/debug/app-debug.apk'
alias instr='adb install app/build/outputs/apk/release/app-release.apk'
alias uninst='adb uninstall '
alias instdd='adb install app/build/outputs/apk/dev/debug/app-dev-debug.apk'
alias instdr='adb install app/build/outputs/apk/dev/release/app-dev-release.apk'
alias gc='./gradlew clean cleanBuildCache'
alias ad='./gradlew assembleDebug'
alias ar='./gradlew assembleRelease'
alias adevd='./gradlew assembleDevDebug'
alias adevr='./gradlew assembleDevRelease'
alias dept='./gradlew dependencyUpdates'
alias cap='adb exec-out screencap -p > ~/Desktop/"$(date +"%Y_%m_%d_%I_%M_%S_%p").png"'
alias sdebug='adb shell am set-debug-app -w --persistent'
alias cdebug='adb shell am clear-debug-app'

# git
test -f /usr/local/etc/bash_completion.d/.git-prompt.bash && . $_
test -f /usr/local/etc/bash_completion.d/.git-completion.bash && . $_

eval "$(rbenv init -)"

# autocompletion
autoload -Uz compinit
compinit
setopt COMPLETE_ALIASES

