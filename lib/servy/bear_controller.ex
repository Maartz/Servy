defmodule Servy.BearController do
  alias Servy.Wildthings
  alias Servy.Bear
  alias Servy.View

  def index(conv) do
    bears =
      Wildthings.list_bears()
      |> Bear.alphabetical_sort()

    View.render(conv, "index.eex", bears: bears)
  end

  def show(conv, %{"id" => id}) do
    bear = Wildthings.get_bear(id)
      View.render(conv, "show.eex", bear: bear)
  end

  def create(conv, params) do
    %{conv | resp_body: "Create a #{params["type"]} bear named #{params["name"]}", status: 201}
  end

  def delete(conv, %{"id" => id}) do
    bear = Wildthings.get_bear(id)
    %{conv | resp_body: "You're not allowed to delete '#{bear.name}' with the id: '#{bear.id}'", status: 403}
  end

end
