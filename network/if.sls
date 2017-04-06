{% import_yaml "network/defaults.yaml" as default_settings %}

include:
  - network.install
  - network.config

{% set interfaces_defaults = default_settings.network.interfaces %}
{% set interfaces          = salt['pillar.get']('network:interfaces', {}) %}

{%- for interface, params in interfaces.items() %}
ifdown_{{interface}}:
  module.run:
    - name: ip.down
    - iface: {{interface}}
    - iface_type: {{params.type|default(interfaces_defaults.type)}}
    - onchanges:
      - network: {{interface}}

ifup_{{interface}}:
  module.run:
    - name: ip.up
    - iface: {{interface}}
    - iface_type: {{params.type|default(interfaces_defaults.type)}}
    - require:
      - module: ifdown_{{interface}}
    - onchanges:
      - module: ifdown_{{interface}}

ifdown_wait_{{interface}}:
  module.wait:
    - name: ip.down
    - iface: {{interface}}
    - iface_type: {{params.type|default(interfaces_defaults.type)}}

ifup_wait_{{interface}}:
  module.wait:
    - name: ip.up
    - iface: {{interface}}
    - iface_type: {{params.type|default(interfaces_defaults.type)}}
    - watch:
      - module: ifdown_wait_{{interface}}
{%- endfor %}

