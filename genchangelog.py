import json

with open("changes.json", "r") as f:
    changelogData = json.load(f)

changelog = ""

typeToFriendly = {
    "feat": "Added",
    "patch": "Fixed",
    "change": "Changed"
}

for typ in changelogData:
    changelog += f"# {typeToFriendly[typ]}:\n"
    for message in changelogData[typ].pop("_"):
        changelog += f"- {message}\n"
    changelog += "\n"
    for scope, messages in changelogData[typ].items():
        subheader = []
        for i in scope.split(" "):
            subheader.append(i[0].upper() + i[1:])
        changelog += f"## {' '.join(subheader)}:\n"
        for message in messages:
            changelog += f"  - {message}\n"
    changelog += "\n"

with open("changelog.md", "w") as f:
    f.write(changelog)