require 'csv'

puts
puts 'Loading customer data...'
csv_text = File.read('data/bruce_profile.csv')
CSV.parse(csv_text, headers: true) do |row|
  cust = Customer.new(row.to_hash)
  cust.save
  puts "#{1}:#{cust.user.name}:#{cust.inspect}"
end
puts "Loaded #{Customer.count} customers."


User.create!(name:     'David Thomason', email: 'david@example.com',
             password: 'password', password_confirmation: 'password',
             admin:    true)

User.create!(name:     'Avijit', email: 'avijit@example.com',
             password: 'password', password_confirmation: 'password',
             admin:    true)

User.create!(name:     'John', email: 'john@example.com',
             password: 'password', password_confirmation: 'password',
             admin:    true)

# Load transaction fraud data
CSV.foreach('data/fraud.csv', headers: true) do |row|
  FraudTransaction.create!(row.to_h)
end

if ENV['VCAP_SERVICES']
  bmix_ml_service = MlScoringService.detect_wml_services
  bmix_ml_service.save
end

if ENV['ML_HOSTNAME'] and ENV['ML_USERNAME'] and ENV['ML_PASSWORD'] and ENV['ML_DEPLOYMENT']
  ml_service = MlScoringService.create! name: ENV['ML_NAME'],
                                        hostname:   ENV['ML_HOSTNAME'],
                                        username:   ENV['ML_USERNAME'],
                                        password:   ENV['ML_PASSWORD'],
                                        deployment: ENV['ML_DEPLOYMENT']
end