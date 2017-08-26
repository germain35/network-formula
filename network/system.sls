{% from "network/map.jinja" import network_settings with context %}

{%- set os         = salt['grains.get']('os') %}
{%- set os_family  = salt['grains.get']('os_family') %}
{%- set osrelease  = salt['grains.get']('osrelease') %}
{%- set oscodename = salt['grains.get']('oscodename') %}

include:
  - network.install

{%- set settings = salt['pillar.get']('network_settings:system', {}) %}

{%- if settings %}
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
