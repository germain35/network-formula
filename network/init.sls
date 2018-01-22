{% from "network/map.jinja" import network with context %}

include:
  - network.install
  - network.system
  - network.host
  - network.interface
