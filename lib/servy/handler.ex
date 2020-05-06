defmodule Servy.Handler do

  def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> log
    |> route
    |> emojify
    |> track
    |> format_response
  end

  def log(conv), do: IO.inspect conv

  def parse(request) do
    [method, path, _] =
      request
      |> String.split("\n")
      |> List.first
      |> String.split(" ")
    %{method: method, path: path, resp_body: "", status: nil}
  end

  # TODO: Rewrite with ?id should leverage Regex

  def rewrite_path(%{path: "/wildlife"} = conv) do
    %{conv | path: "/wildthings"}
  end

  def rewrite_path(%{path: "/bears?id=" <> id } = conv) do
    %{conv | path: "/bears/" <> id}
  end

  def rewrite_path(conv), do: conv

  def track(%{status: 404, path: path} = conv) do
    IO.puts "Warning: #{path} does not exists"
    conv
  end

  def track(conv), do: conv

  def route(%{path: "/wildthings", method: "GET"} = conv) do
    %{conv | resp_body: "Bears, Lions, Tigers ", status: 200}
  end

  def route(%{path: "/bears", method: "GET"} = conv) do
    %{conv | resp_body: "Teddy, Smokey, Paddington", status: 200}
  end

  def route(%{path: "/bears/" <> id, method: "GET"} = conv) do
    %{conv | resp_body: "Bear #{id}", status: 200}
  end

  def route(%{path: "/bears/" <> id, method: "DELETE"} = conv) do
    %{conv | resp_body: "You're not allowed to delete 'Bear #{id}'", status: 403}
  end

  def route(conv) do
    %{conv | resp_body: "No #{conv.path} here", status: 404}
  end

  def format_response(conv) do
    """
    HTTP/1.1 #{conv.status} #{status_reason(conv.status)}
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

  defp emojify(%{status: 200} = conv) do
    emojies = String.duplicate("🎉", 5)
    body = emojies <> "\n" <> conv.resp_body <> "\n" <> emojies
    %{conv | resp_body: body}
  end

  defp emojify(conv), do: conv

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

