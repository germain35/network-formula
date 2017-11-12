{% from "network/map.jinja" import network with context %}

{%- set os         = salt['grains.get']('os') %}
{%- set os_family  = salt['grains.get']('os_family') %}
{%- set osrelease  = salt['grains.get']('osrelease') %}
{%- set oscodename = salt['grains.get']('oscodename') %}

include:
  - network.install
  - network.system
  - network.if


{% set interfaces_defaults = network.settings %}
{% set interfaces          = salt['pillar.get']('network:interfaces', {}) %}

{%- for interface, params in interfaces.items() %}
  {#- if (params.type|default('eth') == 'eth') and (interface not in salt['grains.get']('hwaddr_interfaces').keys()) #}
    {# continue #}
  {#- endif #}
  {%- if params.wpa is defined %}
{{interface}}_wpa:
  cmd.run:
    - name: wpa_passphrase '{{params.wpa.ssid}}' '{{params.wpa.psk}}' > {{network.wpa_conf_dir}}/wpa_{{interface}}.conf
    - require:
       - pkg: network_wpa_packages
    - require_in:
       - network: {{interface}}
{{interface}}_wpa_secure:
  file.line:
    - name: {{network.wpa_conf_dir}}/wpa_{{interface}}.conf
    - mode: delete
    - match: '#psk'
    - content: ''
    - require:
      - cmd: {{interface}}_wpa
  {%- endif %}

{{interface}}:
  network.managed:
    - enabled: {{params.enabled|default(interfaces_defaults.enabled)}}
    - hotplug: {{params.hotplug|default(interfaces_defaults.hotplug)}}
    - type: {{params.type|default(interfaces_defaults.type)}}
    - proto: {{params.proto|default(interfaces_defaults.proto)}}
    - enable_ipv6: {{params.enable_ipv6|default(interfaces_defaults.enable_ipv6)}}
    {%- if params.proto|default('dhcp') == 'static' %}
    - ipaddr: {{params.ipaddr}}
    {%- if params.netmask is defined %}
    - netmask: {{params.netmask}}
    {%- endif %}
    {%- if params.gateway is defined %}
    - gateway: {{params.gateway}}
    {%- endif %}
    {%- if params.dns is defined %}
    - dns: {{params.dns}}
    {%- endif %}
    {%- if params.enable_ipv6|default(True) %}
    - ipv6_autoconf: 'yes'
      {%- endif %}
    {%- endif %}
    {%- if params.search is defined %}
    - search: {{params.search}}
    {%- endif %}
    {%- if params.dns is defined %}
    - dns: {{params.dns}}
    {%- endif %}
    {%- if params.mtu is defined %}
    - mtu: {{params.mtu}}
    {%- endif %}
    {%- if params.type is defined %}
      {%- if params.type == 'vlan' %}
    - use:
      - network: {{params.vlan_device|default(interface.split('.')[0])}}
    - require:
      - network: {{params.vlan_device|default(interface.split('.')[0])}}
      {%- endif %}
    {%- endif %}
    {%- if params.wpa is defined %}
    - wpa-conf: {{network.wpa_conf_dir}}/wpa_{{interface}}.conf
    {%- endif %}

{%- endfor %}
