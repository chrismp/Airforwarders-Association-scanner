[
	'csv',
	'selenium-webdriver'
].each{|g|
	require g
}

driver = Selenium::WebDriver.for :firefox
url = 'http://www.airforwarders.org/companies'
page = driver.navigate.to(url)

wait = Selenium::WebDriver::Wait.new(:timeout => 60)
wait.until{
	driver.find_elements(:css=>'.item_main')
	driver.find_elements(:css=>'.item_main').each{|div|
		itemMainA = div.find_element(:css=>'.title a')
		companyTitle = itemMainA.text
		companyURL = itemMainA.attribute('href')

		p "OPENING #{companyURL}"
		companyPage = driver.navigate.to(companyURL)
	}
}