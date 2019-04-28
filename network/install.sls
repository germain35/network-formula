{% from "network/map.jinja" import network with context %}

{%- set os         = salt['grains.get']('os') %}
{%- set os_family  = salt['grains.get']('os_family') %}
{%- set osrelease  = salt['grains.get']('osrelease') %}
{%- set oscodename = salt['grains.get']('oscodename') %}

{%- if network.manage_netplug %}
network_netplug_packages:
  pkg.installed:
    - pkgs: {{network.netplug_packages}}
{%- endif %}

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

{%- if network.manage_bond %}
network_bond_packages:
  pkg.installed:
    - pkgs: {{network.bond_packages}}
{%- endif %}

{%- if network.manage_wireless %}
network_wireless_packages:
  pkg.installed:
    - pkgs: {{network.wireless_packages}}
{%- endif %}

{%- if network.manage_firmware %}
network_firmware_packages:
  pkg.installed:
    - pkgs: {{network.firmware_packages}}
{%- endif %}

{%- if network.manage_dhclient %}
network_dhclient_packages:
  pkg.installed:
    - pkgs: {{network.dhclient_packages}}
{%- endif %}

{%- if network.resolvconf.get('enabled', False) %}
network_resolvconf_packages:
  pkg.installed:
    - pkgs: {{network.resolvconf_packages}}
{%- endif %}
