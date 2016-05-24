require "json"
require "sinatra"

class Chef
  class Node
    # dummy class for JSON parsing
  end
end

class Counter
  def self.reset
    @@counters = Hash.new { |h, k| h[k] = 0 }
  end

  def self.increment(body)
    payload      = JSON.load(body)
    message_type = payload["message_type"]
    counter_name = message_type == "run_converge" ? "#{message_type}.#{payload["status"]}" : message_type

    @@counters[counter_name] += 1
  end

  def self.to_json
    @@counters.to_json
  end

end

Counter.reset

get "/" do
  "Data Collector API server"
end

get "/reset-counters" do
  Counter.reset
  "counters reset"
end

get "/counters" do
  Counter.to_json
end

post "/data-collector/v0" do
  body = request.body.read
  Counter.increment(body)

  status 201
  "message received"
end