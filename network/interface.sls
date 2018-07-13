{% from "network/map.jinja" import network with context %}

{%- set os         = salt['grains.get']('os') %}
{%- set os_family  = salt['grains.get']('os_family') %}
{%- set osrelease  = salt['grains.get']('osrelease') %}
{%- set oscodename = salt['grains.get']('oscodename') %}

include:
  - network.install
  - network.system


{% set interfaces_defaults = network.settings %}
{% set interfaces          = salt['pillar.get']('network:interfaces', {}) %}

{%- for interface, params in interfaces.items() %}
  {#- if (params.type|default('eth') == 'eth') and (interface not in salt['grains.get']('hwaddr_interfaces').keys()) #}
    {# continue #}
  {#- endif #}
  {%- if params.wpa is defined %}
    {%- if params.wpa.psk is defined %} 
{{interface}}_wpa:
  cmd.run:
    - name: wpa_passphrase '{{params.wpa.ssid}}' '{{params.wpa.psk}}' > {{network.wpa_conf_dir}}/wpa_{{interface}}.conf
    - require:
       - pkg: network_wireless_packages
    - require_in:
       - network: {{interface}}
  file.line:
    - name: {{network.wpa_conf_dir}}/wpa_{{interface}}.conf
    - mode: delete
    - content: '#psk'
    {%- else %}
{{interface}}_wpa:
  file.managed:
    - name: {{network.wpa_conf_dir}}/wpa_{{interface}}.conf
    - source: salt://network/templates/wpa_open.conf.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0600
    - makedirs: True
    - context:
        ssid: {{params.wpa.ssid}}
    - require_in:
      - network: {{interface}}
    {%- endif %}
  {%- endif %}

{{interface}}:
  network.managed:
    - enabled: {{params.enabled|default(interfaces_defaults.enabled)}}
    - hotplug: {{params.hotplug|default(interfaces_defaults.hotplug)}}
    - type: {{params.type|default(interfaces_defaults.type)}}
    - proto: {{params.proto|default(interfaces_defaults.proto)}}
    - enable_ipv6: {{params.enable_ipv6|default(interfaces_defaults.enable_ipv6)}}
    {%- if params.bridge is defined %}
    - bridge: {{params.bridge}}
    - ports: {{params.ports}}
    {%- endif %}
    {%- if params.proto|default('dhcp') == 'static' %}
    - ipaddr: {{params.ipaddr}}
    {%- if params.netmask is defined %}
    - netmask: {{params.netmask}}
    {%- endif %}
    {%- if params.gateway is defined %}
    - gateway: {{params.gateway}}
    {%- endif %}
    {%- if params.broadcast is defined %}
    - broadcast: {{params.broadcast}}
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
    {%- if params.autoneg is defined %}
    - autoneg: {{params.autoneg}}
    {%- endif %}
    {%- if params.speed is defined %}
    - speed: {{params.speed}}
    {%- endif %}
    {%- if params.duplex is defined %}
    - duplex: {{params.duplex}}
    {%- endif %}
    {%- if params.metric is defined %}
    - metric: {{params.metric}} 
    {%- endif %}
    {%- if params.slaves is defined %}
    - slaves: {{params.slaves|join(' ')}}
    {%- endif %}
    {%- if params.mode is defined %}
    - mode: {{params.mode}}
    {%- endif %}
    {%- if params.miimon is defined %}
    - miimon: {{params.miimon}}
    {%- endif %}
    {%- if params.updelay is defined %}
    - updelay: {{params.updelay}}
    {%- endif %}
    {%- if params.downdelay is defined %}
    - downdelay: {{params.downdelay}}
    {%- endif %}
    {%- if params.use_carrier is defined %}
    - use_carrier: {{params.use_carrier}}
    {%- endif %}
    {%- if params.xmit_hash_policy is defined %}
    - xmit_hash_policy: {{params.xmit_hash_policy}}
    {%- endif %}
    {%- if params.arp_interval is defined %}
    - arp_interval: {{params.arp_interval}}
    {%- endif %}
    {%- if params.lacp_rate is defined %}
    - lacp_rate: {{params.lacp_rate}}
    {%- endif %}
    {%- if params.noifupdown is defined %}
    - noifupdown: {{params.noifupdown}}
    {%- endif %}
    {%- if params.pre_up_cmds is defined %}
    - pre_up_cmds: {{params.pre_up_cmds}}
    {%- endif %}
    {%- if params.up_cmds is defined %}
    - up_cmds: {{params.up_cmds}} 
    {%- endif %}
    {%- if params.post_up_cmds is defined %}
    - post_up_cmds: {{params.post_up_cmds}}
    {%- endif %}
    {%- if params.pre_down_cmds is defined %}
    - pre_down_cmds: {{params.pre_down_cmds}}
    {%- endif %}
    {%- if params.down_cmds is defined %}
    - down_cmds: {{params.down_cmds}}
    {%- endif %}
    {%- if params.post_down_cmds is defined %}
    - post_down_cmds: {{params.post_down_cmds}}
    {%- endif %}
    {%- if params.type is defined %}
      {%- if params.type == 'vlan' %}
    - use:
      - network: {{params.network}}
    - require:
      - network: {{params.network}}
      {%- elif params.type == 'bond' %}
    - require:
      - network: {{params.slaves}}
      {%- endif %}
    {%- endif %}
    {%- if params.wpa is defined %}
    - wpa-conf: {{network.wpa_conf_dir}}/wpa_{{interface}}.conf
    {%- endif %}
    {%- if params.get('forceifupdown', False) %}
    - watch_in:
      - module: ifdown_{{interface}}
      - module: ifup_{{interface}}
    {%- endif %}

ifdown_{{interface}}:
  module.wait:
    - ip.down:
      - iface: {{interface}}
      - iface_type: {{params.type|default(interfaces_defaults.type)}}

ifup_{{interface}}:
  module.wait:
    - ip.up:
      - iface: {{interface}}
      - iface_type: {{params.type|default(interfaces_defaults.type)}}
    - watch:
      - module: ifdown_{{interface}}

{%- endfor %}
