{% from "network/map.jinja" import network with context %}

{%- set os         = salt['grains.get']('os') %}
{%- set os_family  = salt['grains.get']('os_family') %}
{%- set osrelease  = salt['grains.get']('osrelease') %}
{%- set oscodename = salt['grains.get']('oscodename') %}

include:
  - network.install
  - network.system

{%- if network.get('resolvconf', False) %}
  {%- for conf_file, contents in network.resolvconf.get('config', {}).items() %}
    {%- if conf_file in ['base', 'head', 'original', 'tail'] %}
network_resolvconf_conf_{{conf_file}}:
  file.managed:
    - name: {{ network.resolvconf_conf_dir | path_join(conf_file) }}
    - mode: 644
    - contents: {{ contents }}
    - require:
      - pkg: network_resolvconf_packages
    {%- endif %}
  {%- endfor %}
{%- endif %}
