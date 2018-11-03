{% from "network/map.jinja" import network with context %}

{%- set os         = salt['grains.get']('os') %}
{%- set os_family  = salt['grains.get']('os_family') %}
{%- set osrelease  = salt['grains.get']('osrelease') %}
{%- set oscodename = salt['grains.get']('oscodename') %}

include:
  - network.install
  - network.system

{%- for interface, params in network.get('interfaces', {}).items() %}
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
    {%- for k, v in params.items() %}
      {%- if k == 'wpa' %}
    - wpa-conf: {{network.wpa_conf_dir}}/wpa_{{interface}}.conf
      {%- elif k == 'forceifupdown' %}
        {%- if params.get(k, False) %}
    - watch_in:
      - module: ifdown_{{interface}}
      - module: ifup_{{interface}}
        {%- endif %}
      {%- else %}
    - {{k}}: {{v}}
      {%- endif %}
    {%- endfor %}

ifdown_{{interface}}:
  module.wait:
    - ip.down:
      - iface: {{interface}}
      - iface_type: {{params.get('type', 'eth')}}

ifup_{{interface}}:
  module.wait:
    - ip.up:
      - iface: {{interface}}
      - iface_type: {{params.get('type', 'eth')}}
    - watch:
      - module: ifdown_{{interface}}

{%- endfor %}
