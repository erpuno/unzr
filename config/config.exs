use Mix.Config

config :kvs,
  dba: :kvs_mnesia,
  dba_st: :kvs_stream,
  schema: [:kvs, :kvs_stream, :unzr]

config :unzr,
  logger_level: :debug,
  logger: [{:handler, :synrc, :logger_std_h,
            %{level: :debug,
              id: :synrc,
              module: :logger_std_h,
              config: %{type: :file, file: 'unzr.log'},
              formatter: {:logger_formatter,
                          %{template: [:time,' ',:pid,' ',:msg,'\n'],
                            single_line: true,}}}}]
