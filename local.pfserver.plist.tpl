<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>Label</key>
    <string>local.pfserver</string>
    <key>ProgramArguments</key>
    <array>
      <string>python</string>
      <string>-m</string>
      <string>SimpleHTTPServer</string>
      <string>8020</string>
    </array>
    <key>WorkingDirectory</key>
    <string>PATH</string>
    <key>UserName</key>
    <string>nobody</string>
    <key>StandardOutPath</key>
    <string>/tmp/pfserver.out</string>
    <key>StandardErrorPath</key>
    <string>/tmp/pfserver.err</string>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
  </dict>
</plist>
