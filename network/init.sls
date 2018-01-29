{% from "network/map.jinja" import network with context %}

include:
  - network.install
  - network.system
  - network.interface
  {%- if network.hosts is defined %}
  - network.host
  {%- endif %}
  {%- if network.dhclient is defined %}
  - network.dhclient
  {%- endif %}