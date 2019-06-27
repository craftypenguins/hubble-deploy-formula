{% from "hubble/map.jinja" import hubble with context %}

hubble_pkg:
  pkg.installed:
    - refresh: True
    - pkgs:
      {{ hubble.pkgs | yaml(False) | indent(6) }}

hubble_config:
  file.managed:
    - name: {{ hubble.config_dir }}/hubble
    - source: salt://hubble/templates/hubble.config
    - template: jinja
    - require:
      - pkg: hubble_pkg

hubble_grains:
  file.managed:
    - name: {{ hubble.config_dir }}/grains
    - source: salt://hubble/templates/hubble.grains
    - template: jinja
    - require:
      - pkg: hubble_pkg

{% if hubble.custom_git_seed is defined and hubble.custom_git_name is defined and not salt['file.directory_exists']( hubble.config_dir + '/' + hubble.custom_git_name ) %}
hubble_custom_seed:
   git.latest:
    - name: {{ hubble.custom_git_seed }}
    - target: {{ hubble.config_dir }}/{{ hubble.custom_git_name }}
{% endif %}

hubble_service:
  service.running:
    - name: hubble
    - enable: True
    - require:
      - pkg: hubble_pkg
    - watch:
      - file: hubble_config
      - file: hubble_grains
