#!/usr/bin/env python3
"""仅修复上游 dispatcher 的退出状态；不修改组装算法或参数。"""
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()
old = '            subprocess.call(subcmd)'
assert text.count(old) == 11, 'unexpected upstream dispatcher; review patch'
text = text.replace(old, '            status = subprocess.call(subcmd)\n            sys.exit(status if status >= 0 else 128 - status)')
old_error = '            print("\\n** unrecognized command: %s **" % cmd)'
assert text.count(old_error) == 1
text = text.replace(old_error, old_error + '\n            sys.exit(2)')
path.write_text(text)
