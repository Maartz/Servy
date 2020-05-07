defmodule Servy.Plugins do

  require Logger
  # TODO: Rewrite with ?id should leverage Regex

  def rewrite_path(%{path: "/wildlife"} = conv) do
    %{conv | path: "/wildthings"}
  end

  def rewrite_path(%{path: "/bears?id=" <> id } = conv) do
    %{conv | path: "/bears/" <> id}
  end

  def rewrite_path(conv), do: conv

  def track(%{status: 404, path: path} = conv) do
    IO.puts "Error: #{path} does not exists"
    Logger.error conv.path
    conv
  end

  def track(%{method: "DELETE"} = conv) do
    Logger.warn conv.path
    conv
  end

  def track(conv) do
    Logger.info conv.path
    conv
  end

end
