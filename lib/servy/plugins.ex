defmodule Servy.Plugins do

  alias Servy.Conv
  require Logger
  # TODO: Rewrite with ?id should leverage Regex

  def rewrite_path(%Conv{path: "/wildlife"} = conv) do
    %{conv | path: "/wildthings"}
  end

  def rewrite_path(%Conv{path: "/bears?id=" <> id } = conv) do
    %{conv | path: "/bears/" <> id}
  end

  def rewrite_path(%Conv{} = conv), do: conv

  def track(%Conv{status: 404, path: path} = conv) do
    IO.puts "Error: #{path} does not exists"
    Logger.error conv.path
    conv
  end

  def track(%Conv{method: "DELETE"} = conv) do
    Logger.warn conv.path
    conv
  end

  def track(%Conv{} = conv) do
    Logger.info conv.path
    conv
  end

end
