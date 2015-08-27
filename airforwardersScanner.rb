[
	'selenium-webdriver',
	'nokogiri',
	'open-uri'
].each{|g|
	require g
}

driver = Selenium::WebDriver.for :firefox
url = 'http://www.airforwarders.org/companies'
page = driver.navigate.to(url)
companyURLArray = []

def companyURLScraper(driver, companyURLArray, pageNumber)
	sleep 3
	driver.find_elements(:css=>'.item_main').each{|div|
		itemMainA = div.find_element(:css=>'.title a')
		companyTitle = itemMainA.text
		companyURL = itemMainA.attribute('href')
		companyURLArray << companyURL
	}

	paginationToolbar = driver.find_element(:css=>'.pagination-toolbar')
	lastPageNumber = paginationToolbar.find_elements(:css=>'.btn')[-3].text.gsub(/\D/,'').to_i
	
	if(pageNumber===lastPageNumber)
		return companyURLArray
	end

	paginationToolbar.find_elements(:css=>'.btn')[-2].click # Clicking the next button
	companyURLScraper(driver, companyURLArray, pageNumber+=1)
end

def getStringAfterColon(elem)
	return elem.text.split(':')[-1].gsub(/\s{2,}/,' ').strip
end

companyURLScraper(driver, companyURLArray, 1)
driver.quit

File.open("Airforwarders Association contacts.txt", "w"){|file|  
	headersArray = [
		# 'Airforwarders URL',
		# 'Company',
		'Contact person',
		'Contact email'#,
		# 'Company email',
		# 'Website',
		# 'Phone',
		# 'Fax',
		# 'Street',
		# 'City, State, Zip'
	]
	file.puts(headersArray.join("\t"))

	companyURLArray.each{|companyURL|
		begin
			page = Nokogiri::HTML(open(companyURL))
			listGroupItems = page.css('#secondary_content .list-group-item')
			dataArray = [
				# companyURL,
				# page.css('h2').text,
				getStringAfterColon(listGroupItems[0]),
				getStringAfterColon(listGroupItems[1])#,
				# getStringAfterColon(listGroupItems[2]),
				# getStringAfterColon(listGroupItems[3]),
				# getStringAfterColon(listGroupItems[4]),
				# getStringAfterColon(listGroupItems[5]),
				# listGroupItems[6].text.strip,
				# listGroupItems[7].text.strip
			]
			file.puts(dataArray.join("\t"))
			p dataArray			
		rescue Exception => e
			next
		end
	}
}
