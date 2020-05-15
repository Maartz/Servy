defmodule Servy.Bear do
  defstruct id: nil, name: "", type: "", hibernating: false

  def alphabetical_sort(list) do
    Enum.sort(list, &(&1.name <= &2.name))
  end

  def is_grizzly(bear) do
    bear.type == "Grizzly"
  end
end
