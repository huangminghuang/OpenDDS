#!/usr/bin/env python

import glob2
import json
import cgi
import os

title='OpenDDS Travis Build {} Test Errors'.format(os.getenv('TRAVIS_BUILD_NUMBER'))
print("<html>")
print("<head><title> {} </title></head>".format(title))
print('<body bgcolor="white">')
print('<h1>{}</h1>'.format(title))
for fn in glob2.glob("*/**/{}.json".format(os.getenv('TRAVIS_COMMIT'))):
  with open(fn, 'r') as f:
    data = json.load(f)
    print("<hr><h3> {} </h3><hr>".format(data["matrix"]))
    for test in data["tests"]:
      if test["status"] != "Passed":
        print('<h4><a href="{}">{}</a>: {}</h4>'.format(test['output'],test["name"],test['status']))
        if 'errors' not in test:
          continue
        print('<font color="FF0000">')
        for ln in test['errors']:
          print("<tt>{}</tt><br>".format(cgi.escape(ln)))
        print('</font>')

print("</body>")
print("</html>")