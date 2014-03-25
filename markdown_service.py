import markdown
import web

urls = (
    '/', 'MarkdownService'
)

input = """
```python
import os
```
"""

import sys
# sys.exit()

class MarkdownService:
    def POST(self):
        return markdown.markdown(
            web.data().decode("utf-8"),
            extensions=['codehilite', 'fenced_code'])

if __name__ == "__main__":
    app = web.application(urls, globals())
    app.run()
else:
    wsgi = web.application(urls, globals()).wsgifunc()