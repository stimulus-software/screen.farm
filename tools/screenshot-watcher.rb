channel = ARGV[0] or raise "Please provide a channel ID"
host = ARGV[1] || "192.168.1.69:9292"
dir = ARGV[2] || File.expand_path("~/Desktop")

require 'rest_client'

def get_screenshots(dir)
  Dir["#{dir}/Screen Shot *.png"]
end

def upload(filepath, host)
  RestClient.post("http://#{host}/f", file: File.new(filepath))
end

current_list = get_screenshots(dir)

puts "Watching for screenshots in #{dir}..."
loop do
  new_list = get_screenshots(dir)
  new_items = new_list - current_list
  if new_items.any?
    new_filepath = new_items.first
    puts "NEW: #{new_filepath}"
    ret = upload(new_filepath, host)
    hosted_filename = ret.strip

    RestClient.post("http://#{host}/c/#{channel}", url: "http://#{host}/f/#{hosted_filename}")
    puts ret.inspect

    current_list = new_list
  end
  sleep 0.5
end
