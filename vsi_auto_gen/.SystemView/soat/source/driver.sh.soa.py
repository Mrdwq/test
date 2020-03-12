__soa_out = ""
if str(h.ctx.cpu) != 'ARMR5' and  len( utils.blocks_for(h,  vlnv='vsi_common_driver')):
    target_template = "./driver.sh/driver.sh.j2"
    import datetime
    from jinja2 import Environment, FileSystemLoader
    from jinja2.utils import generate_lorem_ipsum
    loader = FileSystemLoader(__soa_target)
    jinja_env = Environment(loader=loader, trim_blocks=True, lstrip_blocks=True)
    jinja_template = jinja_env.get_template(target_template)
    generationtime = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    __soa_out += """
"""
    system_block = system._block
    __soa_out += """
"""
    jinja_process_context = dict()
    jinja_process_context.update(platform=platform._block)
    jinja_process_context.update(system=system_block)
    __soa_out += """
"""
    jinja_process_context.update(system_context_hierarchy = h._block )
    jinja_process_context.update(utils=utils)
    jinja_process_context.update(generationtime=generationtime)
    jinja_process_context.update(type=type)
    jinja_process_context.update(int=int)
    __soa_out += """
"""
    jinja_process_context.update(help=help)
    jinja_process_context.update(dir=dir)
    __soa_out += """
"""
    __soa_nodes[45].val = str(jinja_template.render(jinja_process_context))
    __soa_out += __soa_nodes[45].val
    if __soa_last_callback:    __soa_last_callback(__soa_state(), {**globals(), **locals()})
