require 'json'
require 'neatjson'
require 'xeroizer'
require 'selenium-webdriver'
require 'watir'


#	Connect with my Xero public app called BeanTest
xero = Xeroizer::PublicApplication.new('J2LUCTJAL3YAZMIL5J3IJ6OIXRU5FR', 'VCJVYVHQV0GTOM3CGKUQUAB2WSCH5L')
# Get a request token
request_token = xero.request_token
puts request_token.authorize_url

#	Launch a headless Chrome instance and go to the authorize url
browser = Watir::Browser.new :chrome, switches: %w[--ignore-certificate-errors --disable-popup-blocking --disable-translate --disable-notifications --start-maximized --disable-gpu --headless]
browser.goto request_token.authorize_url
puts browser.title

# Enter login info
browser.input(id: 'email').send_keys 'alvin@email.com'
browser.input(id: 'password').send_keys '******'
browser.button(id: 'submitButton').click
Watir::Wait.until { browser.title.include? 'Authorise Application' }
puts browser.title

# Click authorize for the public app to use my org data
browser.link(id: 'cancel-button').wait_until_present
browser.input(id: 'submit-button').click

# Get the pin code for authorize
(pin = browser.input(id: 'pin-input')).wait_until_present
puts browser.title
puts pin = pin.value

# Authorize subsequent API data access with the request token and the pin code
xero.authorize_from_request(request_token.token, request_token.secret, oauth_verifier: pin)
access_key = xero.access_token.token
access_secret = xero.access_token.secret

# Get the list of accounts from my sample org
contacts = xero.Contact.all
accounts = xero.Account.all

# write to file in local directory
file = open('xero_data.txt' ,'w')

accounts.each do |acct|
  json = JSON.neat_generate(acct.to_h, aligned:true)
  puts json
  file.write json
  file.write ",\n"
end

file.close
