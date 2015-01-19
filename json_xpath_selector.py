import json
import jsonpath
import sys
file_object = open("/dev/stdin", "r")
string_object = file_object.read().strip()
json_object = json.loads(string_object)
selected_object = jsonpath.jsonpath(json_object, '$.' + sys.argv[1])
print json.dumps(selected_object)
