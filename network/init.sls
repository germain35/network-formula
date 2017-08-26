{% from "network/map.jinja" import network_settings with context %}

include:
  - network.install
  - network.system
  - network.interface
  - network.if
