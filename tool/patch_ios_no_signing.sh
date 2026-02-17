#!/usr/bin/env bash
set -euo pipefail

PBX="ios/Runner.xcodeproj/project.pbxproj"
PODFILE="ios/Podfile"

if [ ! -f "$PBX" ]; then
  echo "iOS project not found at $PBX (run flutter create first)."
  exit 0
fi

# Patch project.pbxproj: add/override signing flags.
# Safe-ish text patch: ensures these keys exist in each buildSettings block.
python3 - <<'PY'
from pathlib import Path
pbx = Path("ios/Runner.xcodeproj/project.pbxproj")
text = pbx.read_text(encoding="utf-8")

def patch_block(block: str) -> str:
    keys = {
        "CODE_SIGNING_ALLOWED": "NO",
        "CODE_SIGNING_REQUIRED": "NO",
        "CODE_SIGN_IDENTITY": '""',
        "CODE_SIGN_IDENTITY[sdk=iphoneos*]": '""',
        "EXPANDED_CODE_SIGN_IDENTITY": '""',
        "EXPANDED_CODE_SIGN_IDENTITY[sdk=iphoneos*]": '""',
    }
    for k, v in keys.items():
        if f"{k} =" in block:
            # replace existing
            import re
            block = re.sub(rf"{re.escape(k)}\s*=\s*[^;]+;", f"{k} = {v};", block)
        else:
            block = block.replace("buildSettings = {", "buildSettings = {\n\t\t\t\t" + f"{k} = {v};")
    return block

out=[]
i=0
while True:
    start = text.find("buildSettings = {", i)
    if start == -1:
        out.append(text[i:])
        break
    out.append(text[i:start])
    end = text.find("};", start)
    if end == -1:
        out.append(text[start:])
        break
    block = text[start:end+2]
    out.append(patch_block(block))
    i = end+2

patched="".join(out)
pbx.write_text(patched, encoding="utf-8")
print("Patched", pbx)
PY

# Ensure Podfile has a post_install that disables signing for pods too.
if [ -f "$PODFILE" ]; then
  if ! grep -q "CODE_SIGNING_ALLOWED = 'NO'" "$PODFILE"; then
    cat >> "$PODFILE" <<'RUBY'

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
      config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
      config.build_settings['CODE_SIGN_IDENTITY'] = ''
      config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ''
    end
  end
end
RUBY
    echo "Updated $PODFILE"
  fi
fi

echo "iOS code signing disabled for Simulator/CI builds."
