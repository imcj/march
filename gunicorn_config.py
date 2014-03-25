# import app
import web
from os.path import abspath, dirname, join

TMP = join(abspath(dirname(__file__)), "tmp")

bind = "127.0.0.1:8001"
use = "markdown_service:wsgi"
workers = 2
worker_class = "gevent"
reload = True
pidfile = join(TMP, "gunicorn.pid")
worker_tmp_dir = TMP
application = "markdown_service:wsgi"