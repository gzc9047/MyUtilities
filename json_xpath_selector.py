#coding: utf-8
import codecs
import json
import jsonpath
import sys
file_object = open("/dev/stdin", "r")
string_object = file_object.read().strip()
json_object = json.loads(string_object)
selected_object = jsonpath.jsonpath(json_object, '$.' + sys.argv[1])
output_object = codecs.open('/dev/stdout', 'a', encoding='UTF-8')
json.dump(obj=selected_object, fp=output_object, ensure_ascii=False)
# output_object.write(json.dumps(selected_object))
# print json.dumps(selected_object)
