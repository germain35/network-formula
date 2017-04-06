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

{{interface}}:
  network.managed:
    - enabled: {{params.enabled|default(interfaces_defaults.enabled)}}
    - hotplug: {{params.hotplug|default(interfaces_defaults.hotplug)}}
    - type: {{params.type|default(interfaces_defaults.type)}}
    - proto: {{params.proto|default(interfaces_defaults.proto)}}
    - enable_ipv6: {{params.enable_ipv6|default(interfaces_defaults.enable_ipv6)}}
    - ipv6_autoconf: {{params.ipv6_autoconf|default(interfaces_defaults.ipv6_autoconf)}}
    {%- if params.proto|default('dhcp') == 'static' %}
    - ipaddrs: {{params.ipaddrs}}
    - gateway: {{params.gateway}}
      {%- if params.enable_ipv6|default(True) %}
    - ipv6addrs: {{params.ipv6addrs}}
      {%- endif %}
    {%- endif %}
    {%- if params.dns is defined %}
    - dns: {{params.dns}}
    {%- endif %}
    {%- if params.mtu is defined %}
    - mtu: {{params.mtu}}
    {%- endif %}

  {%- if params.wpa is defined  %}
{{interface}}_network_wpa_conf:
  file.line:
    - name: {{network.conf_file}}
    - mode: ensure
    - indent: False
    - after: 'iface {{interface}}'
    - content: '    wpa-conf {{network.wpa_conf_dir}}/wpa_{{interface}}.conf'
    - require:
      - network: {{interface}}
{{interface}}_wpa:
  cmd.run:
    - name: wpa_passphrase '{{params.wpa.ssid}}' '{{params.wpa.psk}}' > '{{network.wpa_conf_dir}}/wpa_{{interface}}.conf'
    - require:
       - pkg: network_wpa_packages
       - file: {{interface}}_network_wpa_conf
{{interface}}_wpa_secure:
  file.line:
    - name: {{network.wpa_conf_dir}}/wpa_{{interface}}.conf
    - mode: delete
    - match: '#psk'
    - content: '' 
    - require:
      - cmd: {{interface}}_wpa
    - watch_in:
      - module: ifdown_wait_{{interface}}
      - module: ifup_wait_{{interface}}
  {%- endif %}

{%- endfor %}
