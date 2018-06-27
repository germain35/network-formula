{% from "network/map.jinja" import network with context %}

{%- set os         = salt['grains.get']('os') %}
{%- set os_family  = salt['grains.get']('os_family') %}
{%- set osrelease  = salt['grains.get']('osrelease') %}
{%- set oscodename = salt['grains.get']('oscodename') %}

include:
  - network.install
  - network.system

{%- for k, v in network.get('dhclient', {}).items() %}
network_dhclient_{{k}}:
  file.replace:
    - name: {{ network.dhclient_conf_file }}
    - pattern: '^#{0,1}{{k}} .*;$'
    - repl: '{{k}} {{v}};'
    - append_if_not_found: True
    - require:
      - pkg: network_dhclient_packages
{%- endfor %}