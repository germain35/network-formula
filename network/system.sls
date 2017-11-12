{% from "network/map.jinja" import network with context %}

{%- set os         = salt['grains.get']('os') %}
{%- set os_family  = salt['grains.get']('os_family') %}
{%- set osrelease  = salt['grains.get']('osrelease') %}
{%- set oscodename = salt['grains.get']('oscodename') %}
{%- set hostname   = salt['grains.get']('hostname') %}
{%- set fqdn       = salt['grains.get']('fqdn') %}

include:
  - network.install

{%- set settings = network.system %}

{%- if settings.hostname is defined %}
  {%- if salt['grains.get']('os_family') == 'Debian' %}

/etc/hostname:
  file.managed:
    - contents: {{ settings.hostname.split('.')[0] }}

127.0.0.1:
  host.only:
    - hostnames:
      - localhost

127.0.1.1:
  host.only:
    - hostnames:
      - {{settings.hostname}}
      - {{settings.hostname.split('.')[0]}}

  {%- else %}

system:
  network.system:
    - enabled: True
    {%- if settings.hostname is defined %}
    - hostname: {{settings.hostname}}
    - apply_hostname: {{settings.apply_hostname}}
    - retain_settings: {{settings.retain_settings}}
    - require_reboot: {{settings.require_reboot}}
    {%- endif %}
    {%- if settings.gateway is defined %}
    - gateway: {{settings.gateway}}
    {%- endif %}
    {%- if settings.gatewaydev is defined %}
    - gatewaydev: {{settings.gatewaydev}}
    {%- endif %}

  {%- endif %}
{%- endif %}
