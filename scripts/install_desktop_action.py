#!/usr/bin/env python3
"""Install an Automator Quick Action for iCloud-managed Desktop folders."""

import pathlib
import plistlib
import uuid

service_name = "在桌面新建文本文档"
service = pathlib.Path.home() / "Library" / "Services" / f"{service_name}.workflow"
contents = service / "Contents"
contents.mkdir(parents=True, exist_ok=True)

script = r'''desktop="$HOME/Desktop"
name="未命名文本文档"
for number in {1..10000}; do
  if [[ "$number" -eq 1 ]]; then
    filename="$name.txt"
  else
    filename="$name $number.txt"
  fi
  destination="$desktop/$filename"
  if ( set -C; : > "$destination" ) 2>/dev/null; then
    /usr/bin/open -R "$destination"
    exit 0
  fi
done
exit 1'''

info = {
    "CFBundleDevelopmentRegion": "zh_CN",
    "CFBundleExecutable": "",
    "CFBundleIdentifier": "dev.local.findernewfile.desktop-action",
    "CFBundleInfoDictionaryVersion": "6.0",
    "CFBundleName": service_name,
    "CFBundlePackageType": "BNDL",
    "CFBundleShortVersionString": "0.1.0",
    "CFBundleVersion": "1",
    "NSServices": [{
        "NSMenuItem": {"default": service_name},
        "NSMessage": "runWorkflowAsService",
        "NSRequiredContext": {"NSApplicationIdentifier": "com.apple.finder"},
    }],
}

action = {
    "AMAccepts": {"Container": "List", "Optional": True, "Types": ["com.apple.cocoa.path"]},
    "AMActionVersion": "2.0.3",
    "AMApplication": ["Automator"],
    "AMParameterProperties": {key: {} for key in ("COMMAND_STRING", "CheckedForUserDefaultShell", "inputMethod", "shell", "source")},
    "AMProvides": {"Container": "List", "Types": ["com.apple.cocoa.string"]},
    "ActionBundlePath": "/System/Library/Automator/Run Shell Script.action",
    "ActionName": "Run Shell Script",
    "ActionParameters": {
        "COMMAND_STRING": script,
        "CheckedForUserDefaultShell": True,
        "inputMethod": 1,
        "shell": "/bin/zsh",
        "source": "",
    },
    "BundleIdentifier": "com.apple.RunShellScript",
    "CFBundleVersion": "2.0.3",
    "CanShowSelectedItemsWhenRun": False,
    "CanShowWhenRun": True,
    "Category": ["AMCategoryUtilities"],
    "Class Name": "RunShellScriptAction",
    "InputUUID": str(uuid.uuid4()).upper(),
    "Keywords": ["Shell", "Script"],
    "OutputUUID": str(uuid.uuid4()).upper(),
    "UUID": str(uuid.uuid4()).upper(),
    "UnlocalizedApplications": ["Automator"],
}
workflow = {
    "AMApplicationBuild": "521",
    "AMApplicationVersion": "2.10",
    "AMDocumentVersion": "2",
    "actions": [{"action": action, "isViewVisible": True}],
    "connectors": {},
    "workflowMetaData": {
        "serviceApplicationBundleID": "com.apple.finder",
        "serviceApplicationPath": "/System/Library/CoreServices/Finder.app",
        "serviceInputTypeIdentifier": "com.apple.Automator.nothing",
        "serviceOutputTypeIdentifier": "com.apple.Automator.nothing",
        "serviceProcessesInput": False,
        "workflowTypeIdentifier": "com.apple.Automator.servicesMenu",
    },
}

with (contents / "Info.plist").open("wb") as file:
    plistlib.dump(info, file)
with (contents / "document.wflow").open("wb") as file:
    plistlib.dump(workflow, file)

print(service)
