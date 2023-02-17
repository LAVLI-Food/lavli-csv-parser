defmodule CSVParser.CLI do
  @moduledoc """
    Handle the command line parsing and the dispatch to
    the various functions that end up a Connexys candidates CSV dump to
    a processed JSON file that can be imported into Algolia.
  """

  require Logger

  @default_output "data/out/parsed.csv"

  def main(argv) do
    argv
    |> parse_args
    |> process
  end

  @doc """
    `argv` can be -h or --help, which returns :help.
    Otherwise it is a input filename.
    Returns a tuple of `{ input, to_file }`, or `:help` if help was given.
  """
  def parse_args(argv) do
    parse =
      OptionParser.parse(
        argv,
        switches: [help: :boolean],
        aliases: [h: :help]
      )

    case parse do
      {[help: true], _, _} -> :help
      {_, [input, output], _} -> {input, output}
      {_, [input], _} -> {input, @default_output}
      _ -> :help
    end
  end

  def process(:help) do
    IO.puts("""
      usage: csv_parser <input.csv> [ <output.csv> | #{@default_output} ]
    """)

    System.halt(0)
  end

  def process({input, output}) do
    # Open file
    # { :ok, file } = File.open(input, [ :read, :utf8 ])

    # Read from IO device
    # IO.read(file, :all)

    # Run the transformation
    # |> CSV.Parser.run

    # Write parsed data to file
    # |> save(output)

    input
    |> File.stream!()
    |> Stream.map(& &1)
    |> CSV.decode!(separator: ?;, strip_fields: true)
    |> Enum.map_every(1, fn [email, added_time, modified_time] ->
      [email, format_yyyy_mm_dd(added_time), format_yyyy_mm_dd(modified_time)]
    end)
    |> IO.inspect()
    |> CSV.encode(separator: ?;, delimiter: "\n")
    |> Enum.take_every(1)
    |> save(output)
  end

  defp format_yyyy_mm_dd(date) do
    case String.split(date, "-") do
      [day, month, year] -> "#{year}-#{month}-#{day}"
      _ -> date
    end
  end

  defp save(data, output) do
    handle_write = fn
      :ok -> "File saved: #{output}"
      {:error, reason} -> "Error: #{:file.format_error(reason)}"
    end

    Logger.info(handle_write.(File.write(output, data)))
  end
end
