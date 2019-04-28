{% from "network/map.jinja" import network with context %}

{%- set os         = salt['grains.get']('os') %}
{%- set os_family  = salt['grains.get']('os_family') %}
{%- set osrelease  = salt['grains.get']('osrelease') %}
{%- set oscodename = salt['grains.get']('oscodename') %}

include:
  - network.install
  - network.system

{%- if network.get('resolvconf', False) %}
  {# update interface-order configuration #}
  {%- if network.resolvconf.get('interface_order', False) %}
network_resolvconf_interface_order:
  file.managed:
    - name: {{ network.resolvconf_interface_order_file }}
    - mode: 644
    - contents: {{network.resolvconf.get('interface_order', [])|tojson}}
    - require:
      - pkg: network_resolvconf_packages
  {%- endif %}

  {# update resolv.conf.d #}
  {%- for conf_file, contents in network.resolvconf.get('config', {}).items() %}
    {%- if conf_file in ['base', 'head', 'original', 'tail'] %}
network_resolvconf_conf_{{conf_file}}:
  file.managed:
    - name: {{ network.resolvconf_conf_dir | path_join(conf_file) }}
    - mode: 644
    - contents: {{contents|tojson}}
    - require:
      - pkg: network_resolvconf_packages
    {%- endif %}
  {%- endfor %}
{%- endif %}
