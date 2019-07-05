local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;
local graphPanel = grafana.graphPanel;
local tablePanel = grafana.tablePanel;
local singlestat = grafana.singlestat;
local prometheus = grafana.prometheus;
local sql = grafana.sql;
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
  refresh='{% if item.refresh is defined %}{{ item.refresh }}{% else %}30s{% endif %}',
)
{% if item.templates is defined %}
{% for template in item.templates %}
.addTemplate(
{% if template.type is not defined or template.type == "query" %}
  template.new(
    '{{ template.name }}',
    'default',
    '{{ template.query }}',
    label='{{ template.label }}',
    refresh='time',
    includeAll={{ template.includeAll }},
  )
{% elif template.type == "custom" %}
  template.custom(
    '{{ template.name }}',
    '{{ template.query }}',
    '{{ template.current }}',
    label='{{ template.label }}',
  )
{% else %}
{% endif %}
)
{% endfor %}
{% endif %}
{% for panel in item.panels %}
.addPanel(
{% if panel.type is not defined or panel.type == "graph" %}
  graphPanel.new(
    '{{ panel.name }}',
    span={{ panel.span }},
    format='{{ panel.format }}',
    fill={{ panel.fill }},
    min={% if panel.min is defined %}{{ panel.min }}{% else %}null{% endif %},
    max={% if panel.max is defined %}{{ panel.max }}{% else %}null{% endif %},
    stack={% if panel.stack is defined %}{{ panel.stack }}{% else %}false{% endif %},
    decimals={{ panel.decimals }},
    aliasColors={% if panel.alias_colors is defined %}{{ '{ ' }}{% for alias, color in panel.alias_colors.iteritems() %}"{{ alias }}": "{{ color }}", {% endfor %}{{ ' }' }}{% else %}{}{% endif %},
    linewidth={% if panel.linewidth is defined %}{{ panel.linewidth }}{% else %}1{% endif %},
    datasource='default',
    legend_show={% if panel.legend_show is defined %}{{ panel.legend_show }}{% else %}true{% endif %},
    legend_values={% if panel.legend_values is defined %}{{ panel.legend_values }}{% else %}true{% endif %},
    legend_min={% if panel.legend_min is defined %}{{ panel.legend_min }}{% else %}true{% endif %},
    legend_max={% if panel.legend_max is defined %}{{ panel.legend_max }}{% else %}true{% endif %},
    legend_current=true,
    legend_total=false,
    legend_avg={% if panel.legend_avg is defined %}{{ panel.legend_avg }}{% else %}true{% endif %},
    legend_alignAsTable={% if panel.legend_table is defined %}{{ panel.legend_table }}{% else %}true{% endif %},
  )
{% elif panel.type == "singlestat" %}
  singlestat.new(
    '{{ panel.name }}',
    valueName='{{ panel.value_name }}',
    colorValue={{ panel.color_value }},
    gaugeShow={% if panel.gauge_show is defined %}{{ panel.gauge_show }}{% else %}false{% endif %},
    gaugeMinValue={% if panel.gauge_min_value is defined %}{{ panel.gauge_min_value }}{% else %}0{% endif %},
    gaugeMaxValue={% if panel.gauge_max_value is defined %}{{ panel.gauge_max_value }}{% else %}100{% endif %},
    datasource='default',
  )
{% elif panel.type == "table" %}
  tablePanel.new(
    '{{ panel.name }}',
    datasource='default',
  )
{% else %}
{% endif %}
{% for target in panel.targets %}
  .addTarget(
{% if target.raw_sql is not defined %}
    prometheus.target(
      '{{ target.expr }}',
      datasource='default',
      legendFormat='{{ target.legend_format }}',
      format='{% if target.format is defined %}{{ target.format }}{% else %}time_series{% endif %}',
      intervalFactor='{% if target.interval_factor is defined %}{{ target.interval_factor }}{% else %}2{% endif %}',
    )
{% else %}
    sql.target(
      "{{ target.raw_sql }}",
      datasource='default',
      format='{% if target.format is defined %}{{ target.format }}{% else %}time_series{% endif %}',
    )
{% endif %}
  )
{% endfor %}
{% if panel.series_overrides is defined %}
{% for override_alias, overrides_hash in panel.series_overrides.iteritems() %}
  .addSeriesOverride(
    {
      "alias": "{{ override_alias }}",
{% for override_param, override_val in overrides_hash.iteritems() %}
      "{{ override_param }}": {{ override_val }},
{% endfor %}
    }
  )
{% endfor %}
{% endif %}
  , gridPos={
    x: {{ panel.gridpos_x }},
    y: {{ panel.gridpos_y }},
    w: {{ panel.gridpos_w }},
    h: {{ panel.gridpos_h }},
  }
)
{% endfor %}
