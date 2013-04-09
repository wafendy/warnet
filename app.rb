require 'rubygems'
require 'sinatra'
require 'haml'
require 'yaml'
require 'json'
require 'win32ole'
require 'sequel'

helpers do
  #helper methods go here
end

conn = Sequel.ado(:conn_string=>'Provider=Microsoft.ACE.OLEDB.12.0;Data Source=drive:/Users/wafendy/Downloads/Billing.mdb')


puts conn



get '/' do
  # @albums = Array.new
  # Dir[File.join(File.expand_path(File.dirname(__FILE__)), 'public/galleries/*/')].map do |dir|
  #   cover_photo = nil
  #   Dir.glob(File.join(dir, '*.{jpg,gif,png}')) do |jpg_file|
  #     filename = File.basename(jpg_file,File.extname(jpg_file))
  #     unless filename.end_with?('_tn')
  #       thumbnail_name = [filename, '_tn', File.extname(jpg_file)].join()
  #       cover_photo ||= thumbnail_name
  #       unless File.exists?(File.join(dir,thumbnail_name))
  #         image = MiniMagick::Image.open(jpg_file)
  #         image.resize('200')
  #         image.write File.join(dir, thumbnail_name)
  #       end
  #     end
  #   end
  #   info = YAML.load_file(File.join(dir,'info.yaml'))
  #   #puts "#{info['title']} - #{info['desc']}"
  #   @albums.push({:title => info['title'], :desc => info['desc'], :album => File.basename(dir), :cover_photo => cover_photo})
  # end














  haml :index
end

get '/about' do

  @hello = 'temp'
  @temp = 'hello'

  haml :about
end
