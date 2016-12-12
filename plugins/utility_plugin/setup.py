
from setuptools import setup

# Replace the place holders with values for your project

setup(

    # Do not use underscores in the plugin name.
    name='utils',

    version='0.1',
    author='Michael Shnizer',
    author_email='michaels@gigaspaces.com',
    description='A Utility plugin',

    # This must correspond to the actual packages in the plugin.
    packages=['vms'],

    license='LICENSE',
    zip_safe=False,
    install_requires=[
        # Necessary dependency for developing plugins, do not remove!
        "cloudify-plugins-common==3.4","cloudify-openstack-plugin==1.4"
    ]
)