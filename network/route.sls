{% from "network/map.jinja" import network with context %}

{%- set os         = salt['grains.get']('os') %}
{%- set os_family  = salt['grains.get']('os_family') %}
{%- set osrelease  = salt['grains.get']('osrelease') %}
{%- set oscodename = salt['grains.get']('oscodename') %}

include:
  - network.install
  - network.system
  - network.interface
  - network.routing_table

{%- for interface, routes in network.get('routes', {}).items() %}
network_route_{{interface}}:
  network.routes:
    - name: {{interface}}
    - routes: {{routes}}
{%- endfor %}
