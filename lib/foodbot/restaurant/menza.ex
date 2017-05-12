defmodule Foodbot.Restaurant.Menza do
  alias Foodbot.Format

  def name, do: "WTC Menza"
  def url, do: "http://www.femec.si/poslovne-enote/"

  def process(%{body: body}, date) do
    menu =
      body
      |> Floki.parse
      |> Floki.find("##{week_day(date)} .menucontent")
      |> process_menu
    {menu, date}
  end

  def process_menu(menu_html) do
    menu_html
    |> Enum.map(&process_item/1)
  end

  def process_item({"div", _, list}) do
    title =
      list
      |> Enum.flat_map(fn p -> String.split(Floki.text(p), "\n") end)
      |> Enum.reject(&is_blank?/1)
      |> Enum.reject(&is_generic?/1)
      |> Enum.join(", ")
      |> Format.title

    {title, nil}
  end

  def is_generic?(text) do
    String.match?(text, ~r{solatni bife|dnevna sladica|juha}i)
  end

  def is_blank?(text) do
    String.strip(text) == ""
  end

  def week_day(date) do
    case :calendar.day_of_the_week(date.year, date.month, date.day) do
      1 -> "ponedeljek"
      2 -> "torek"
      3 -> "sreda"
      4 -> "cetrtek"
      5 -> "petek"
    end
  end
end
