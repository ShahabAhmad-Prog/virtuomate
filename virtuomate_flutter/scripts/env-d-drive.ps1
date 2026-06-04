# Load D: cache paths in current PowerShell session (called by run scripts)
$DevRoot = 'D:\Virtomate\dev-cache'
$env:GRADLE_USER_HOME = Join-Path $DevRoot '.gradle'
$env:PUB_CACHE = Join-Path $DevRoot 'pub-cache'
$env:ANDROID_HOME = Join-Path $DevRoot 'Android\Sdk'
$env:ANDROID_SDK_ROOT = $env:ANDROID_HOME
# Must be parent of .android folder (see ANDROID_SDK_HOME in Android docs)
$env:ANDROID_SDK_HOME = $DevRoot
