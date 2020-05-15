defmodule Servy.Handler do
  alias Servy.Plugins
  alias Servy.Parser
  alias Servy.FileHandler
  alias Servy.Conv
  alias Servy.BearController
  require Logger

  @pages_path Path.expand("pages", File.cwd!())

  def handle(request) do
    request
    |> Parser.parse()
    |> Plugins.rewrite_path()
    |> route
    |> Plugins.track()
    |> format_response
  end

  def route(%Conv{path: "/wildthings", method: "GET"} = conv) do
    %{conv | resp_body: "Bears, Lions, Tigers ", status: 200}
  end

  def route(%Conv{path: "/bears", method: "GET"} = conv) do
    BearController.index(conv)
  end

  def route(%Conv{path: "/bears/" <> id, method: "GET"} = conv) do
    params = Map.put(conv, "id", id)
    BearController.show(conv, params)
  end

  def route(%Conv{path: "/bears/" <> id, method: "DELETE"} = conv) do
    params = Map.put(conv, "id", id)
    BearController.delete(conv, params)
  end

  def route(%Conv{path: "/bears", method: "POST", params: params} = conv) do
    BearController.create(conv, params)
  end

  def route(%Conv{path: "/about", method: "GET"} = conv) do
    @pages_path
    |> Path.join("about.html")
    |> File.read()
    |> FileHandler.handle_file(conv)
  end

  def route(%Conv{path: "/bears/new", method: "GET"} = conv) do
    @pages_path
    |> Path.join("form.html")
    |> File.read()
    |> FileHandler.handle_file(conv)
  end

  def route(%Conv{path: "/pages/" <> value, method: "GET"} = conv) do
    @pages_path
    |> Path.join(value <> ".html")
    |> File.read()
    |> FileHandler.handle_file(conv)
  end

  def route(%Conv{} = conv) do
    %{conv | resp_body: "No #{conv.path} here", status: 404}
  end

  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}
    Content-Type: text/html
    Content-Length: #{byte_size(conv.resp_body)}

    #{conv.resp_body}
    \n
    """
  end
end

# request = """
# GET /wildthings HTTP/1.1
# Host: example.com
# User-Agent: ExampleBrowser/1.0
# Accept: */*
#
# """
#
# response = Servy.Handler.handle(request)
# IO.puts(response)

request = """
GET /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts(response)

# request = """
# GET /bigfoot HTTP/1.1
# Host: example.com
# User-Agent: ExampleBrowser/1.0
# Accept: */*
#
# """
#
# response = Servy.Handler.handle(request)
# IO.puts(response)

request = """
GET /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts(response)

request = """
GET /bears/10 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts(response)

request = """
DELETE /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts(response)

# request = """
# GET /wildlife HTTP/1.1
# Host: example.com
# User-Agent: ExampleBrowser/1.0
# Accept: */*
#
# """
#
# response = Servy.Handler.handle(request)
# IO.puts(response)
#
# request = """
# GET /fourohfour HTTP/1.1
# Host: example.com
# User-Agent: ExampleBrowser/1.0
# Accept: */*
#
# """
#
# response = Servy.Handler.handle(request)
# IO.puts(response)

request = """
GET /bears?id=1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts(response)
#
# request = """
# GET /about HTTP/1.1
# Host: example.com
# User-Agent: ExampleBrowser/1.0
# Accept: */*
#
# """
#
# response = Servy.Handler.handle(request)
# IO.puts(response)
#
# request = """
# GET /bears/new HTTP/1.1
# Host: example.com
# User-Agent: ExampleBrowser/1.0
# Accept: */*
#
# """
#
# response = Servy.Handler.handle(request)
# IO.puts(response)
#
# request = """
# GET /pages/contact HTTP/1.1
# Host: example.com
# User-Agent: ExampleBrowser/1.0
# Accept: */*
#
# """
#
# response = Servy.Handler.handle(request)
# IO.puts(response)
#
# request = """
# GET /pages/faq HTTP/1.1
# Host: example.com
# User-Agent: ExampleBrowser/1.0
# Accept: */*
#
# """
#
# response = Servy.Handler.handle(request)
# IO.puts(response)
#
# request = """
# POST /bears HTTP/1.1
# Host: example.com
# User-Agent: ExampleBrowser/1.0
# Accept: */*
# Content-Type: application/x-www-form-urlencoded
# Content-Length: 21
#
# name=Baloo&type=Brown
# """
#
# response = Servy.Handler.handle(request)
# IO.puts(response)
