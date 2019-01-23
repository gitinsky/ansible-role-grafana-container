local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;
local graphPanel = grafana.graphPanel;
local singlestat = grafana.singlestat;
local prometheus = grafana.prometheus;
local template = grafana.template;

dashboard.new(
  'Nginx',
  schemaVersion=16,
  tags=['nginx'],
)
.addTemplate(
  template.new(
    'instance',
    'default',
    'label_values(nginx_http_requests_total, instance)',
    label='Instance',
    refresh='time',
  )
)
.addRow(
  row.new(
    title='Requests',
    height='250px',
  )
  .addPanel(
    graphPanel.new(
      'Total requests',
      span=6,
      format='short',
      fill=0,
      min=0,
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
    .addTarget(
      prometheus.target(
        'nginx_http_requests_total{instance="$instance",status="200"}',
        datasource='default',
        legendFormat='200'
      )
    )
  )
)
