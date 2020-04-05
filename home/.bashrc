# alias
alias g='git '
alias gst='g st'
alias gp='g pull'
alias gpr='g pull --rebase'
alias gw='./gradlew '
alias gbd='g b -d '
alias gbD='g b -D '
alias instd='adb install app/build/outputs/apk/debug/app-debug.apk'
alias instr='adb install app/build/outputs/apk/release/app-release.apk'
alias uninst='adb uninstall '
alias instdd='adb install app/build/outputs/apk/dev/debug/app-dev-debug.apk'
alias instdr='adb install app/build/outputs/apk/dev/release/app-dev-release.apk'
alias gc='./gradlew clean'
alias ad='./gradlew assembleDebug'
alias ar='./gradlew assembleRelease'
alias adevd='./gradlew assembleDevDebug'
alias adevr='./gradlew assembleDevRelease'
alias dept='./gradlew dependencyUpdates'
alias bundletool='java -jar ~/bundletool.jar'
alias cap='adb exec-out screencap -p > ~/Desktop/"$(date +"%Y_%m_%d_%I_%M_%S_%p").png"'

# git
test -f /usr/local/etc/bash_completion.d/.git-prompt.bash && . $_
test -f /usr/local/etc/bash_completion.d/.git-completion.bash && . $_

