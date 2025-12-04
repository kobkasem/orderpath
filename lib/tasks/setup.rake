namespace :setup do
  desc "Setup initial data"
  task init: :environment do
    puts "Setting up OrderPath..."
    
    # Create admin customer if not exists
    unless Customer.exists?
      customer = Customer.create!(
        name: "Admin Customer",
        api_endpoint: "https://api.example.com/orders",
        active: true
      )
      puts "✓ Created admin customer (API Key: #{customer.api_key})"
    end
    
    # Create default printer if not exists
    unless Printer.exists?
      printer = Printer.create!(
        name: "Default Printer",
        ip_address: "192.168.1.100",
        port: 9100,
        printer_type: "picking_slip",
        active: true
      )
      puts "✓ Created default printer"
    end
    
    puts "\nSetup complete!"
  end
end


