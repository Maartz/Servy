defmodule Servy do
  def hello(name \\ "world") do
    "Hello #{name}"
  end
end

IO.puts(Servy.hello())
