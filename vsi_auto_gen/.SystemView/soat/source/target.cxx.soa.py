__soa_out = ""
import systemview as sv
from jinja2 import Environment, FileSystemLoader
from jinja2.utils import generate_lorem_ipsum
__soa_out += """
"""
target_template = "./target.cxx.j2"
__soa_out += """
"""
loader = FileSystemLoader(__soa_target)
import time
import datetime
import base64, json;
__soa_out += """
"""
generationtime = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
jinja_env = Environment(loader=loader, trim_blocks=True, lstrip_blocks=True)
jinja_template = jinja_env.get_template(target_template)
system_block = sv.bl_system()
platform_block = sv.bl_platform()
jinja_process_context = dict()
jinja_process_context.update(time=time)
jinja_process_context.update(datetime=datetime)
jinja_process_context.update(str=str)
jinja_process_context.update(system=system)
jinja_process_context.update(platform=platform_block)
jinja_process_context.update(system_context_hierarchy=h )
jinja_process_context.update(base64=base64)
jinja_process_context.update(json=json)
jinja_process_context.update(target=targ)
jinja_process_context.update(generationtime=generationtime)
jinja_process_context.update(utils=utils)
__soa_out += """
"""
__soa_nodes[67].val = str(jinja_template.render(jinja_process_context))
__soa_out += __soa_nodes[67].val
__soa_out += """
"""
if __soa_last_callback:__soa_last_callback(__soa_state(), {**globals(), **locals()})
