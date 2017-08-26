{% from "network/map.jinja" import network_settings with context %}

{%- set os         = salt['grains.get']('os') %}
{%- set os_family  = salt['grains.get']('os_family') %}
{%- set osrelease  = salt['grains.get']('osrelease') %}
{%- set oscodename = salt['grains.get']('oscodename') %}

{% if network_settings.manage_vlan %}
network_vlan_packages:
  pkg.installed:
    - pkgs: {{network_settings.vlan_packages}}
{% endif %}

{% if network_settings.manage_wpa %}
network_wpa_packages:
  pkg.installed:
    - pkgs: {{network_settings.wpa_packages}}
{% endif %}
