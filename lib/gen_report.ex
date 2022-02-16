defmodule GenReport do
  alias GenReport.Parser

  @avariable_persons [
    "daniele",
    "mayk",
    "giuliano",
    "cleiton",
    "jakeliny",
    "joseph",
    "diego",
    "danilo",
    "rafael",
    "vinicius"
  ]
  def build(filename) do
    filename
    |> Parser.parse_file()
    |> Enum.reduce(report_acc(), &sum_values(&1, &2))
  end

  def build do
    {:error, "Not found file"}
  end


  def build_from_many(filenames) when not is_list(filenames) do
    {:error, "Please providers a list of strings"}
  end

  def build_from_many(filenames) do
    filenames
    |> Task.async_stream(&build/1)
    |> Enum.reduce(report_acc(), fn {:ok, result}, acc -> sum_reports(result, acc) end)
  end

  def sum_reports(
        %{
          "all_hours" => all_hours1,
          "hours_per_month" => hours_per_month1,
          "hours_per_year" => hours_per_year1
        },
        %{
          "all_hours" => all_hours2,
          "hours_per_month" => hours_per_month2,
          "hours_per_year" => hours_per_year2
        }
      ) do
    all_hours = merge_maps_value(all_hours1, all_hours2)
    hours_per_month = merge_maps(hours_per_month1, hours_per_month2)
    hours_per_year = merge_maps(hours_per_year1, hours_per_year2)
    build_reports(all_hours, hours_per_month, hours_per_year)
  end

  defp merge_maps(map1, map2) do
    Map.merge(map1, map2, fn _key, value1, value2 -> merge_maps_value(value1, value2)end)
  end
  defp merge_maps_value(map1, map2) do
    Map.merge(map1, map2, fn _key, value1, value2 -> value1 + value2 end)
  end

  defp sum_values([person, hour, _day, month, year], %{
         "all_hours" => all_hours,
         "hours_per_month" => hours_per_month,
         "hours_per_year" => hours_per_year
       }) do
    all_hours = Map.put(all_hours, person, all_hours[person] + hour)
    months = hours_per_month[person]
    months = Map.put(months, month, months[month] + hour)
    hours_per_month = Map.put(hours_per_month, person, months)
    years = hours_per_year[person]
    years = Map.put(years, year, years[year] + hour)
    hours_per_year = Map.put(hours_per_year, person, years)
    build_reports(all_hours, hours_per_month, hours_per_year)
  end

  defp report_acc() do
    all_hours = Enum.into(@avariable_persons, %{}, &{&1, 0})
    months = Enum.into(1..12, %{}, &{Parser.mouth_name(&1), 0})
    years = Enum.into(2016..2020, %{}, &{&1, 0})
    hours_per_month = Enum.into(@avariable_persons, %{}, &{&1, months})
    hours_per_year = Enum.into(@avariable_persons, %{}, &{&1, years})
    build_reports(all_hours, hours_per_month, hours_per_year)
  end

  defp build_reports(all_hours, hours_per_month, hours_per_year) do
    %{
      "all_hours" => all_hours,
      "hours_per_month" => hours_per_month,
      "hours_per_year" => hours_per_year
    }
  end
end