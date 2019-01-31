local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;
local graphPanel = grafana.graphPanel;
local singlestat = grafana.singlestat;
local prometheus = grafana.prometheus;
local template = grafana.template;

dashboard.new(
  '{{ item.dashboard_name }}',
  schemaVersion=16,
  tags=[
{% for tag in item.tags %}
    '{{ tag }}'{% if not loop.last %},{% endif %}
{% endfor %}
  ],
  time_from='{{ item.time_from }}',
  refresh='{{ item.refresh }}',
)
{% for template in item.templates %}
.addTemplate(
  template.new(
    '{{ template.name }}',
    'default',
    '{{ template.query }}',
    label='{{ template.label }}',
    refresh='time',
    includeAll={{ template.includeAll }},
  )
)
{% endfor %}
{% for panel in item.panels %}
.addPanel(
{% if panel.type == "graph" %}
  graphPanel.new(
    '{{ panel.name }}',
    span={{ panel.span }},
    format='{{ panel.format }}',
    fill={{ panel.fill }},
    min={{ panel.min }},
    max={{ panel.max }},
    stack={{ panel.stack }},
    decimals={{ panel.decimals }},
    aliasColors={{ panel.alias_colors }},
    linewidth={{ panel.linewidth }},
    datasource='default',
    legend_values=true,
    legend_min=true,
    legend_max=true,
    legend_current=true,
    legend_total=false,
    legend_avg=true,
    legend_alignAsTable=true,
  )
{% else %}
  singlestat.new(
    '{{ panel.name }}',
    valueName='{{ panel.value_name }}',
    colorValue={{ panel.color_value }},
    datasource='default',
  )
{% endif %}
{% for target in panel.targets %}
  .addTarget(
    prometheus.target(
      '{{ target.expr }}',
      datasource='default',
      legendFormat='{{ target.legend_format }}',
      format='{{ target.format }}',
      intervalFactor='{{ target.interval_factor }}',
    )
  )
{% endfor %}
  , gridPos={
    x: {{ panel.gridpos_x }},
    y: {{ panel.gridpos_y }},
    w: {{ panel.gridpos_w }},
    h: {{ panel.gridpos_h }},
  }
)
{% endfor %}
