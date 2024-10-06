import sys
import re
import json

regex = re.compile(r'^(?P<type>.*?)(?P<area>\(.*?\))?: (?P<msg>.*)$')

with open(sys.argv[-1]) as f:
    commit_message = f.read()


match = regex.search(commit_message)
if not match:
    quit(0) # all good
type = match.group("type")
area = (match.group("area") or "_").lstrip("(").rstrip(")")
msg = match.group("msg")

if not msg:
    print("[HOOK]: Enter the message properly.")
    quit(1)

try:
    with open("changes.json", "r") as f:
        jsonData = f.read()
except FileNotFoundError:
    jsonData = "{}"

jsonData = json.loads(jsonData)
if not (type in jsonData):
    jsonData[type] = {}
if not (area in jsonData[type]):
    jsonData[type][area] = []
jsonData[type][area].append(msg)

with open("changes.json", "w") as f:
    json.dump(jsonData, f, indent = 4)
