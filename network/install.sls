{% from "network/map.jinja" import network with context %}
{% import_yaml "network/defaults.yaml" as default_settings %}

{% set network_settings = salt['pillar.get']('network:system', default_settings.network.system, merge=True) %}

{% if network_settings.vlan %}
network_vlan_packages:
  pkg.installed:
    - pkgs: {{network.vlan_packages}}
{% endif %}

{% if network_settings.wpa %}
network_wpa_packages:
  pkg.installed:
    - pkgs: {{network.wpa_packages}}
{% endif %}
