__soa_out = ""
target_template = "./sources.j2"
from jinja2 import Environment, FileSystemLoader, select_autoescape
from jinja2.utils import generate_lorem_ipsum
loader = FileSystemLoader(__soa_target)
import time
import datetime
import base64, json;
generationtime = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
jinja_env = Environment(loader=loader, trim_blocks=True, lstrip_blocks=True)
jinja_template = jinja_env.get_template(target_template)
jinja_process_context = dict()
jinja_process_context.update(time=time)
jinja_process_context.update(datetime=datetime)
jinja_process_context.update(str=str)
jinja_process_context.update(enumerate=enumerate)
jinja_process_context.update(int=int)
jinja_process_context.update(system=system)
jinja_process_context.update(system_context_hierarchy=h )
jinja_process_context.update(base64=base64)
jinja_process_context.update(len=len)
jinja_process_context.update(print=print)
jinja_process_context.update(json=json)
jinja_process_context.update(hex=hex)
jinja_process_context.update(generationtime=generationtime)
jinja_process_context.update(utils=utils)
__soa_nodes[68].val = str(jinja_template.render(jinja_process_context))
__soa_out += __soa_nodes[68].val
if __soa_last_callback:__soa_last_callback(__soa_state(), {**globals(), **locals()})
