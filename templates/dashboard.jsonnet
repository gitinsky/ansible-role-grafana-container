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
  tags=['{{ item.tag }}'],
  time_from='now-3h',
  refresh='30s',
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
  graphPanel.new(
    '{{ panel.name }}',
    span={{ panel.span }},
    format='{{ panel.format }}',
    fill={{ panel.fill }},
    min=0,
    stack={{ panel.stack }},
    decimals=2,
    datasource='default',
    legend_values=true,
    legend_min=true,
    legend_max=true,
    legend_current=true,
    legend_total=false,
    legend_avg=true,
    legend_alignAsTable=true,
  )
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
