from cloudify import ctx

from openstack_plugin_common import Config, NovaClient

config = Config().get()
nova_client = NovaClient().get(config)

server_id = ctx.instance.runtime_properties['external_id']
ctx.logger.info('server_id={}'.format(server_id))
server = nova_client.servers.get(server_id)
ctx.logger.info('server={}'.format(server))

nova_client.servers.suspend(server)