{% from "network/map.jinja" import network with context %}
{% import_yaml "network/defaults.yaml" as default_settings %}

include:
  - network.install
  - network.if

{% set settings = salt['pillar.get']('network:system', {}) %}

{% if settings.fqdn is defined %}
system:
  network.system:
    - enabled: True
    - hostname: {{settings.fqdn}}
    - apply_hostname: True
    - retain_settings: True
{% endif %}

{% set interfaces_defaults = default_settings.network.interfaces %}
{% set interfaces = salt['pillar.get']('network:interfaces', {}) %}

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
    {%- if params.dns is defined %}
    - dns: {{params.dns}}
    {%- endif %}
    {%- if params.mtu is defined %}
    - mtu: {{params.mtu}}
    {%- endif %}
    {%- if params.type == 'vlan' %}
    - use:
      - network: {{params.'vlan-raw-device'|default(interface.split('.')[1])}}
    - require:
      - network: {{params.'vlan-raw-device'|default(interface.split('.')[1])}}
    {%- endif %}
    {%- if params.wpa is defined %}
    - wpa-conf: {{network.wpa_conf_dir}}/wpa_{{interface}}.conf
    {%- endif %}

{%- endfor %}
