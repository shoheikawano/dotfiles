# alias
alias g='git '
alias gw='./gradlew '
alias inst='adb install app/build/outputs/apk/debug/app-debug.apk'
alias instdd='adb install app/build/outputs/apk/dev/debug/app-dev-debug.apk'
alias ad='./gradlew assembleDebug'
alias adevd='./gradlew assembleDevDebug'
alias bundletool='java -jar ~/bundletool.jar'

# git
test -f /usr/local/etc/bash_completion.d/.git-prompt.bash && . $_
test -f /usr/local/etc/bash_completion.d/.git-completion.bash && . $_
