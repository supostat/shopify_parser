require 'rubygems'
require 'mechanize'

class ShopifyParser

  BASE_URL = 'https://publicwww.com/websites/%22Shopify.shop+%3D%22/'

  def initialize(browser_agent = 'Mac Safari')
    @agent = Mechanize.new { |agent|
      agent.user_agent_alias = browser_agent
    }
  end

  def links
    page_number = 1
    @links = []

    begin
      hrefs = []
      result = page(page_number).search('table tr td:first-child a')
      hrefs = result.map do |link|
        link['href']
      end
      @links.concat(hrefs)
      page_number = page_number.next
    end while page_number < 5

    @links
  end

  def shopify_page
    # pp links
    links.each do |link|
      begin
        page = @agent.get(link + '/pages/contact-us')
        puts page.uri
        puts page.links_with(href: /mailto/)
      rescue => e
        if e.response_code == '404'
          puts "Нет такой страницы - #{e.page.uri}"
        end
      end
    end
  end

  private
  def page(page_number = 1)
    @agent.get(BASE_URL + page_number.to_s)
  end
end

parser = ShopifyParser.new

parser.shopify_page