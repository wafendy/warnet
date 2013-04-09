require 'rubygems'
require 'sinatra'
require 'sinatra/support/numeric'
require 'haml'
require 'yaml'
require 'json'
require 'sequel'

register Sinatra::Numeric
set :default_currency_unit, 'Rp'
set :default_currency_precision, 0
set :default_currency_separator, '.'

DB = Sequel.odbc('WarnetAaw', :password => "gemblunk")

helpers do
  #helper methods go here
  def calculate_today_sum()
    #Get total rental by date
    results = {}
    results['accountsales'] = DB["SELECT SUM(AMOUNT) as sum FROM TRANSACC WHERE STATUS <> '2'"].single_record[:sum].to_i
    results['rentalsales'] = DB["SELECT SUM(AMOUNT) as sum FROM TRANS"].single_record[:sum].to_i
    results['productsales'] = DB["SELECT SUM(AMOUNT) as sum FROM SALES"].single_record[:sum].to_i

    results['accountsales'] = 0 if results['accountsales'] == nil
    results['rentalsales'] = 0 if results['rentalsales'] == nil
    results['productsales'] = 0 if results['productsales'] == nil

    results
  end

  def calculate_yesterday_sum()
    lastauditdate = DB["SELECT DESCRIPTION FROM COMMON WHERE CODE = 'LASTAUDIT'"].single_record[:description]
    lastauditfound = DB["SELECT Format(MAX(AUDITDATE), 'm-d-yyyy') as audit FROM TRANS_HIS"].single_record[:audit]

    results = {}
    results['accountsales'] = DB["SELECT SUM(AMOUNT) as sum FROM TRANSACC_HIS WHERE Format(AUDITDATE, 'm-d-yyyy') = ?;", lastauditfound].single_record[:sum].to_i
    results['rentalsales']  = DB["SELECT SUM(AMOUNT) as sum FROM TRANS_HIS WHERE Format(AUDITDATE, 'm-d-yyyy') = ?;", lastauditfound].single_record[:sum].to_i
    results['productsales'] = DB["SELECT SUM(AMOUNT) as sum FROM SALES_HIS WHERE Format(AUDITDATE, 'm-d-yyyy') = ?;", lastauditfound].single_record[:sum].to_i
          
    result['accountsales'] = 0 if results['accountsales'] == nil
    result['rentalsales'] = 0 if results['rentalsales'] == nil
    result['productsales'] = 0 if results['productsales'] == nil

    results
  end
end

get '/' do
  #Total Number Online
  @total_online = DB[:TRANS].where(:clstatus => 'Aktif').all.count

  #Audit Info
  @audit_info = {}
  @audit_info['audit_date'] = DB["SELECT DESCRIPTION FROM COMMON WHERE CODE = 'DATUM'"].single_record[:description]
  @audit_info['last_audit'] = DB["SELECT DESCRIPTION FROM COMMON WHERE CODE = 'LASTAUDIT'"].single_record[:description]
  @audit_info['audit_found'] = DB["SELECT Format(MAX(AUDITDATE), 'd-m-yyyy') as audit FROM TRANS_HIS"].single_record[:audit]

  #Get the online status of each PC
  @pcstatus = {}
  DB[:TRANS].select(:WS_ID).where(:clstatus => 'Aktif').order(:WS_ID).all do |activepc| 
    @pcstatus[activepc[:ws_id]] = 1 
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
