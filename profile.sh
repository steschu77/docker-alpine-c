# Enable and configure ccache
export PATH="/usr/lib/ccache/bin:$PATH"
export BUILD_ROOT="$PWD"
export CCACHE_DIR="$BUILD_ROOT/.ccache"

# A good value is an almost full cache after building with a clean cache.
ccache --set-config=max_size=50.0M
ccache -s

# A more convenient shell
export PS1='\w\$ '
alias ls="ls -la --color --group-directories-first"
