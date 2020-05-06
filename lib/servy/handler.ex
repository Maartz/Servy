defmodule Servy.Handler do

  require Logger

def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> route
    |> emojify
    |> track
    |> format_response
  end

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

  # First way to handle file serving
  # def route(%{path: "/about", method: "GET"} = conv) do

  #   file =
  #     Path.expand("../../pages", __DIR__)
  #     |> Path.join("about.html")

  #   case File.read(file) do
  #     {:ok, content} ->
  #       %{conv | resp_body: content, status: 200}

  #     {:error, :enoent} ->
  #       %{conv | resp_body: "Oops, something is missing here.", status: 404}

  #     {:error, reason} ->
  #       Logger.error(IO.iodata_to_binary(reason))
  #       %{conv | resp_body: "Oops, something wrong goes here", status: 500}
  #   end
  # end

  # Second way to handle file serving

  def route(%{path: "/about", method: "GET"} = conv) do
    Path.expand("../../pages", __DIR__)
    |> Path.join("about.html")
    |> File.read
    |> handle_file(conv)
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

  def handle_file({:ok, content}, conv) do
    %{conv | resp_body: content, status: 200}
  end

  def handle_file({:error, :enoent}, conv) do
    %{conv | resp_body: "Oops, something is missing here", status: 404}
  end

  def handle_file({:error, reason}, conv) do
    Logger.error(IO.iodata_to_binary(reason))
    %{conv | resp_body: "Oops, somethings seems to be broken...", status: 500}
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

request = """
GET /about HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts response

