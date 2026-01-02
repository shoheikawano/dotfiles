# --------- ZSH CONFIGURATION --------- #

autoload -Uz compinit
compinit

# Syntax highlighting
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Autosuggestions
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Better completion settings
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # Case insensitive completion

# History settings
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

# Colors
autoload -U colors && colors

# Customize prompt (simple but informative)
PROMPT='%F{green}%n@%m%f:%F{blue}%~%f$ '

# Customize syntax highlighting colors
ZSH_HIGHLIGHT_STYLES[command]='fg=blue,bold'
ZSH_HIGHLIGHT_STYLES[alias]='fg=magenta,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=yellow,bold'
ZSH_HIGHLIGHT_STYLES[function]='fg=green,bold'

# Customize autosuggestion color
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

bindkey '^I' autosuggest-accept # Tab to accept suggestion
ZSH_AUTOSUGGEST_STRATEGY=(history completion) # Use both history and completion for suggestions
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20 # Limit suggestion size
ZSH_AUTOSUGGEST_USE_ASYNC=1 # Async suggestions for better performance

# --------- ALIASES --------- #

# screenshot
alias cap='adb shell screencap -p /sdcard/screen.png && adb pull /sdcard/screen.png ~/Desktop/"$(date +"%Y_%m_%d_%I_%M_%S_%p").png" && adb shell rm /sdcard/screen.png'

# git
alias c='claude'
alias cl='clear'
alias g='git '
alias ga='git add .'
alias gb='git branch '
alias gci='git commit -m '
alias gco='git checkout '
alias gd='git diff '
alias gp='git pull '
alias gs='git status'
alias gsi='git switch '
alias gst='git stash '
alias gl='git log '
alias grm='git pull --rebase origin main'

# gradle
alias gc='./gradlew clean'
alias gw='./gradlew'

# scrcpy
alias sc='scrcpy'
alias rec='scrcpy -r ~/Desktop/$(date +%Y_%m_%d_%I_%M_%S_%p).mp4'

# zsh
alias sz='source ~/.zshrc'

# --------- FUNCTIONS --------- #
function gm() {
  if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Not a git repository"
    return 1
  fi

  local message="$*"
  git commit -m "$message"
}

# start android settings page
function as {
  adb shell am start -a android.settings.SETTINGS
}

# start android language settings page
function lang {
  adb shell am start -a android.settings.LOCALE_SETTINGS
}

# Java
alias java8='export JAVA_HOME=$JAVA_8_HOME'
alias java11='export JAVA_HOME=$JAVA_11_HOME'

# --------- PATHS --------- #

# Android build
export ANDROID_HOME=~/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools
export CMD_LINE_TOOLS="~/Library/Android/sdk/cmdline-tools/latest"

# Java
export SDK_MANAGER="~/Library/Android/sdk/tools/bin/sdkmanager"

# maestro
export PATH=$PATH:$HOME/.maestro/bin

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# ruby
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
export PATH="$HOME/.local/bin:$PATH"

# Added by Antigravity
export PATH="/Users/shoheikawano/.antigravity/antigravity/bin:$PATH"
