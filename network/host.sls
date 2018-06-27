{% from "network/map.jinja" import network with context %}

{%- set os         = salt['grains.get']('os') %}
{%- set os_family  = salt['grains.get']('os_family') %}
{%- set osrelease  = salt['grains.get']('osrelease') %}
{%- set oscodename = salt['grains.get']('oscodename') %}

include:
  - network.install
  - network.system

{%- if network.hosts is defined %}

  {%- for host, ip in network.hosts.get('absent', {}).items() %}
host_absent_{{host}}:
  host.absent:
    - name: {{ host }}
    - ip: {{ ip }}
  {%- endfor %}

  {%- for ip, hosts in network.hosts.get('only', {}).items() %}
host_only_{{ip}}:
  host.only:
    - name: {{ ip }}
    - hostnames: {{ hosts }} 
  {%- endfor %}

  {%- for host, ip in network.hosts.get('present', {}).items() %}
host_present_{{host}}:
  host.present:
    - name: {{ host }} 
    - ip: {{ ip }}
  {%- endfor %}

{%- endif %}