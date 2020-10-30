require 'open-uri'
require 'net/http'
require 'pry'

class Scraper

  def self.scrape_index_page(index_url)
    html = Net::HTTP.get(URI.parse(index_url))
    index_page = Nokogiri::HTML(html)

    students = []
    index_page.css("div.student-card").each do |student|
      students << {
      :name => student.css("div.card-text-container h4.student-name").text,
      :location => student.css("div.card-text-container p.student-location").text,
      :profile_url => student.css("a").attribute("href").value}
    end
    students
  end

  def self.scrape_profile_page(profile_url)
    html = Net::HTTP.get(URI.parse(profile_url))
    profile_page = Nokogiri::HTML(html)
    hash = {}
    
    bio = profile_page.css("div.description-holder p").text
    hash[:bio] = bio if bio != ""

    profile_quote = profile_page.css("div.profile-quote").text
    hash[:profile_quote] = profile_quote if profile_quote != ""
    
    profile_page.css("div.social-icon-container a").each do |icon|
      social = icon.children[0].attributes["src"].value[-15..-10]
      url = icon.attributes["href"].value
      case social
      when "witter"
        hash[:twitter] = url
      when "nkedin"
        hash[:linkedin] = url
      when "github"
        hash[:github] = url
      else
        hash[:blog] = url
      end
    end
    hash
  end
end

