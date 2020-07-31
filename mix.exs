defmodule UNZR.Mixfile do
  use Mix.Project

  def project do
    [
      app: :unzr,
      version: "0.7.0",
      description: "UNZR Identity",
      package: package(),
      deps: deps()
    ]
  end

  def application do
    [mod: {:unzr, []}, applications: [:kvs]]
  end

  def package do
    [
      files: ~w(include src mix.exs),
      licenses: ["ISC"],
      maintainers: ["Namdak Tonpa"],
      name: :unzr,
      links: %{"GitHub" => "https://github.com/erpuno/unzr"}
    ]
  end

  def deps do
    [
      {:ex_doc, "~> 0.11", only: :dev},
      {:kvs, "~> 7.1.1"}
    ]
  end
end
