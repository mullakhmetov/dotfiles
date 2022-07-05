# Finder: show hidden files by default
defaults write com.apple.finder AppleShowAllFiles -bool true

# Automatically hide and show the Dock. Setup the Dock size
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock largesize -int 46
defaults write com.apple.dock tilesize -int 42
defaults write com.apple.dock magnification -int 0
defaults write com.apple.dock mineffect -string scale
defaults write com.apple.dock "minimize-to-application" -int 1
defaults write com.apple.dock "show-recents" -int 0
defaults write com.apple.Dock autohide-time-modifier -float 0

# Save screenshots to the desktop
defaults write com.apple.screencapture location -string "$HOME/Desktop"

# Display full POSIX path as Finder window title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Disable the sound effects on boot
sudo nvram SystemAudioVolume=" "

# set highlight color to purple
defaults write NSGlobalDomain AppleHighlightColor -string "0.764700 0.976500 0.568600"

# Trackpad: enable tap to click for this user and for the login screen
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Enable full keyboard access for all controls. (e.g. enable Tab in modal dialogs)
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Disable press-and-hold for keys in favor of key repeat
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Set a blazingly fast keyboard repeat rate
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 10

# Set language and text formats
defaults write NSGlobalDomain AppleLanguages -array "en-RU" "ru-RU"
defaults write NSGlobalDomain AppleLocale -string "en_RU"
defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
defaults write NSGlobalDomain AppleMetricUnits -bool true


# Show language menu in the top right corner of the boot screen
sudo defaults write /Library/Preferences/com.apple.loginwindow showInputMenu -bool true


