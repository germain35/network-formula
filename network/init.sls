{% from "network/map.jinja" import network with context %}

include:
  - network.install
  - network.system
  - network.interface
  {%- if network.routes is defined %}
  - network.route
  {%- endif %}
  {%- if network.routing_tables is defined %}
  - network.routing_table
  {%- endif %}
  {%- if network.hosts is defined %}
  - network.host
  {%- endif %}
  {%- if network.dhclient is defined %}
  - network.dhclient
  {%- endif %}