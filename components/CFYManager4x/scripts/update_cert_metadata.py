#!/bin/python
import sys
import json

data = sys.stdin.readline()

networks = json.loads(data)

networks['networks'][sys.argv[1]] = sys.argv[2]

print json.dumps(networks)
