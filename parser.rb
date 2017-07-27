require 'nokogiri'
require 'open-uri'

class Parser
  attr_reader :final_url
  def initialize(infos = {})
    @track = infos[:tracks_name]
    @artist = infos[:artists_name]
    @url = what_url
    @doc = Nokogiri::HTML(open(@url), nil, 'utf-8')
    @final_url = give_me_url
  end

  def give_me_url
    ending = @doc.css('.item-section > li:first-child h3>a').attr('href').value
    return /=(.*)/.match(ending)[1]
  end



  private



  def what_url
    "https://www.youtube.com/results?search_query=#{@track}+#{@artist}"
  end
end
