 #!/bin/bash

 # A one-off for use on kids' computers
# brew install caffeine
# brew install google-chrome
# brew install hazel
# brew install lastpass
# brew install obs
# brew install openemu
# brew install paintbrush
# brew install spotify
# brew install steam


APPS=('caffeine', 'google-chrome', 'hazel', 'lastpass', 'obs', 'openemu', 'paintbrush', 'spotify', 'steam')
for app in "${APPS[@]}"
do
  brew install $app
done