# alias
alias g='git '
alias gw='./gradlew '
alias devd='adb install app/build/outputs/apk/dev/debug/app-dev-debug.apk'
alias adevd='./gradlew assembleDevDebug'
alias bundletool='java -jar ~/bundletool.jar'

# git
test -f /usr/local/etc/bash_completion.d/.git-prompt.bash && . $_
test -f /usr/local/etc/bash_completion.d/.git-completion.bash && . $_
