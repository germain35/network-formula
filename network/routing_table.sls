{% from "network/map.jinja" import network with context %}

{%- set os         = salt['grains.get']('os') %}
{%- set os_family  = salt['grains.get']('os_family') %}
{%- set osrelease  = salt['grains.get']('osrelease') %}
{%- set oscodename = salt['grains.get']('oscodename') %}

include:
  - network.install
  - network.system
  - network.interface

{% set tables = salt['pillar.get']('network:routing_tables', []) %}

{%- for table in tables %}
network_routing_table_{{table}}:
  file.replace:
    - name: {{ network.rt_tables_file }}
    - pattern: '[0-9]+ {{table}}$'
    - repl: '{{loop.index}} {{table}}'
    - append_if_not_found: True
{%- endfor %}