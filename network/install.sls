{% from "network/map.jinja" import network with context %}

{%- set os         = salt['grains.get']('os') %}
{%- set os_family  = salt['grains.get']('os_family') %}
{%- set osrelease  = salt['grains.get']('osrelease') %}
{%- set oscodename = salt['grains.get']('oscodename') %}

{%- if network.manage_metric %}
network_metric_packages:
  pkg.installed:
    - pkgs: {{network.metric_packages}}
{%- endif %}

{%- if network.manage_bridge %}
network_bridge_packages:
  pkg.installed:
    - pkgs: {{network.bridge_packages}}
{%- endif %}

{%- if network.manage_vlan %}
network_vlan_packages:
  pkg.installed:
    - pkgs: {{network.vlan_packages}}
{%- endif %}

{%- if network.manage_wireless %}
network_wireless_packages:
  pkg.installed:
    - pkgs: {{network.wireless_packages}}
{%- endif %}
