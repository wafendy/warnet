require 'rubygems'
require 'sinatra'
require 'sinatra/support/numeric'
require 'haml'
require 'yaml'
require 'json'
require 'win32ole'
require 'sequel'

register Sinatra::Numeric
set :default_currency_unit, 'Rp'
set :default_currency_precision, 0
set :default_currency_separator, '.'

#DB = Sequel.odbc('WarnetAaw', :password => "gemblunk")
DB = Sequel.ado(:conn_string=>'Provider=Microsoft.Jet.OLEDB.4.0;Data Source=C:\Billing2.mdb; Jet OLEDB:Database Password=gemblunk')


helpers do
  #helper methods go here
  def calculate_today_sum()
    #Get total rental by date
    results = {}
    results['accountsales'] = DB[:TRANSACC].exclude(:STATUS => '2').sum(:AMOUNT).to_i
    results['rentalsales'] = DB[:TRANS].sum(:AMOUNT).to_i
    results['productsales'] = DB[:SALES].sum(:AMOUNT).to_i

    results['accountsales'] = 0 if results['accountsales'] == nil
    results['rentalsales'] = 0 if results['rentalsales'] == nil
    results['productsales'] = 0 if results['productsales'] == nil

    results
  end

  def calculate_yesterday_sum()
    lastauditdate = DB[:COMMON].where(:CODE => 'LASTAUDIT').first[:DESCRIPTION]
    lastauditfound = DB[:TRANS_HIS].max(:AUDITDATE).strftime('%-m-%-d-%Y')

    results = {}
    results['accountsales'] = DB[:TRANSACC_HIS].where("Format(AUDITDATE, 'm-d-yyyy') = ?", lastauditfound).sum(:AMOUNT).to_i
    results['rentalsales'] = DB[:TRANS_HIS].where("Format(AUDITDATE, 'm-d-yyyy') = ?", lastauditfound).sum(:AMOUNT).to_i
    results['productsales'] = DB[:SALES_HIS].where("Format(AUDITDATE, 'm-d-yyyy') = ?", lastauditfound).sum(:AMOUNT).to_i

    results['accountsales'] = 0 if results['accountsales'] == nil
    results['rentalsales'] = 0 if results['rentalsales'] == nil
    results['productsales'] = 0 if results['productsales'] == nil

    results
  end
end

get '/' do
  #Total Number Online
  @total_online = DB[:TRANS].where(:clstatus => 'Aktif').count

  #Audit Info
  @audit_info = {}
  @audit_info['audit_date'] = DB[:COMMON].where(:code=>'DATUM').first[:DESCRIPTION]
  @audit_info['last_audit'] = DB[:COMMON].where(:code=>'LASTAUDIT').first[:DESCRIPTION]
  @audit_info['audit_found'] = DB[:TRANS_HIS].max(:AUDITDATE).strftime('%-d-%-m-%Y')

  #Get the online status of each PC
  @pcstatus = {}
  DB[:TRANS].select(:WS_ID).where(:CLSTATUS => 'Aktif').order(:WS_ID).all do |activepc| 
    @pcstatus[activepc[:WS_ID]] = 1 
  end


  today = calculate_today_sum()
  yesterday = calculate_yesterday_sum()

  @total_rental_today = today['rentalsales']
  @total_rental_yesterday = yesterday['rentalsales']
  @total_account_today = today['accountsales']
  @total_account_yesterday = yesterday['accountsales']
  @total_income_today = today['rentalsales'] + today['accountsales']
  @total_income_yesterday = yesterday['rentalsales'] + yesterday['accountsales']

  haml :index
end

get '/rental' do
  @account_details = {}


  haml :rental
end

get '/sales' do
  haml :sales
end

get '/about' do

  @hello = 'temp'
  @temp = 'hello'

  haml :about
end
