{% from "network/map.jinja" import network_settings with context %}

{%- set os         = salt['grains.get']('os') %}
{%- set os_family  = salt['grains.get']('os_family') %}
{%- set osrelease  = salt['grains.get']('osrelease') %}
{%- set oscodename = salt['grains.get']('oscodename') %}

include:
  - network.install
  - network.system
  - network.interface

{% set interfaces_defaults = network_settings.settings %}
{% set interfaces          = salt['pillar.get']('network:interfaces', {}) %}

{%- for interface, params in interfaces.items() %}
ifdown_{{interface}}:
  module.run:
    - name: ip.down
    - iface: {{interface}}
    - iface_type: {{params.type|default(interfaces_defaults.type)}}
    - onchanges:
      - network: {{interface}}

ifup_{{interface}}:
  module.run:
    - name: ip.up
    - iface: {{interface}}
    - iface_type: {{params.type|default(interfaces_defaults.type)}}
    - require:
      - module: ifdown_{{interface}}
    - onchanges:
      - module: ifdown_{{interface}}

ifdown_wait_{{interface}}:
  module.wait:
    - name: ip.down
    - iface: {{interface}}
    - iface_type: {{params.type|default(interfaces_defaults.type)}}

ifup_wait_{{interface}}:
  module.wait:
    - name: ip.up
    - iface: {{interface}}
    - iface_type: {{params.type|default(interfaces_defaults.type)}}
    - watch:
      - module: ifdown_wait_{{interface}}
{%- endfor %}

