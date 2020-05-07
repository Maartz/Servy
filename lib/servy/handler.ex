defmodule Servy.Handler do
  alias Servy.Plugins
  alias Servy.Parser
  alias Servy.FileHandler
  alias Servy.Conv
  require Logger

  @pages_path Path.expand("pages", File.cwd!)

def handle(request) do
    request
    |> Parser.parse
    |> Plugins.rewrite_path
    |> route
    |> Plugins.track
    |> format_response
  end

  def route(%Conv{path: "/wildthings", method: "GET"} = conv) do
    %{conv | resp_body: "Bears, Lions, Tigers ", status: 200}
  end

  def route(%Conv{path: "/bears", method: "GET"} = conv) do
    %{conv | resp_body: "Teddy, Smokey, Paddington", status: 200}
  end

  def route(%Conv{path: "/bears/" <> id, method: "GET"} = conv) do
    %{conv | resp_body: "Bear #{id}", status: 200}
  end

  def route(%Conv{path: "/bears/" <> id, method: "DELETE"} = conv) do
    %{conv | resp_body: "You're not allowed to delete 'Bear #{id}'", status: 403}
  end


  def route(%Conv{path: "/about", method: "GET"} = conv) do
    @pages_path
    |> Path.join("about.html")
    |> File.read
    |> FileHandler.handle_file(conv)
  end

  def route(%Conv{path: "/bears/new", method: "GET"} = conv ) do
    @pages_path
    |> Path.join("form.html")
    |> File.read
    |> FileHandler.handle_file(conv)
  end

  def route(%Conv{path: "/pages/" <> value, method: "GET"} = conv) do
      @pages_path
      |> Path.join(value <> ".html")
      |> File.read
      |> FileHandler.handle_file(conv)
  end


  def route(%Conv{} = conv) do
    %{conv | resp_body: "No #{conv.path} here", status: 404}
  end

  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}
    Content-Type: text/html
    Content-Lenght: #{byte_size(conv.resp_body)}

    #{conv.resp_body}
    """
  end

  defp status_reason(code) do
    %{ 200 => "OK",
      201 => "Created",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "Not Found",
      500 => "Internal Server Error"
    }[code]
  end

end



request = """
GET /wildthings HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""


response = Servy.Handler.handle(request)
IO.puts response

request = """
GET /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts response

request = """
GET /bigfoot HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts response

request = """
GET /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts response

request = """
DELETE /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts response

request = """
GET /wildlife HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts response

request = """
GET /fourohfour HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts response


request = """
GET /bears?id=1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts response

request = """
GET /about HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts response

request = """
GET /bears/new HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts response


request = """
GET /pages/contact HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts response


request = """
GET /pages/faq HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts response
