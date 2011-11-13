class KupongidParser < Parser::Base

  set_authentication_details :address => 'http://kupongid.ru/', :params => {
    :login => 'kuponavt.co@gmail.com',
    :password => 'aq0b30su',
    :authenticate => 1,
    :remember => 1
  }

  def self.authenticate!
    $agent.get( authentication_details[:address] + 'index.php?authenticate=1' )
    authentication_form = $agent.page.form_with(:id => 'login_form')
    authentication_form['login'] = authentication_details[:params][:login]
    authentication_form['password'] = authentication_details[:params][:password]

    authentication_form.submit
  end


end
