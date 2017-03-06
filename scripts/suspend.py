from cloudify import ctx

from openstack_plugin_common import Config, NovaClient

SERVER_STATUS_ACTIVE = 'ACTIVE'

config = Config().get()
nova_client = NovaClient().get(config)

server_id = ctx.instance.runtime_properties['external_id']

ctx.logger.info('server_id={}'.format(server_id))

server = nova_client.servers.get(server_id)

ctx.logger.info('server={}'.format(server))

ctx.logger.info("Server Status: {}" . format(server.status) )

if server.status == SERVER_STATUS_ACTIVE :

   nova_client.servers.suspend(server)

else:
   ctx.logger.info("Can't suspend, Server status is not  {} " . format( SERVER_STATUS_ACTIVE ) );