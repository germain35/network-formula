{% from "network/map.jinja" import network with context %}

include:
  - network.install
  - network.config
  - network.if
