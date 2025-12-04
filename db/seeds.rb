# Create sample customer
customer = Customer.create!(
  name: "Sample Customer",
  api_endpoint: "https://api.example.com/orders",
  active: true
)

puts "Created customer: #{customer.name} (API Key: #{customer.api_key})"

# Create sample SKUs
iphone17 = Sku.create!(
  sku_code: "IPHONE17-128GB",
  name: "iPhone 17 128GB",
  category: "Smartphone",
  model: "iPhone 17",
  robot_threshold: 5,
  active: true
)

iphone17_pro = Sku.create!(
  sku_code: "IPHONE17-PRO-256GB",
  name: "iPhone 17 Pro 256GB",
  category: "Smartphone",
  model: "iPhone 17 Pro",
  robot_threshold: 5,
  active: true
)

puts "Created SKUs: #{iphone17.sku_code}, #{iphone17_pro.sku_code}"

# Create inventory locations
# Robot warehouse
InventoryLocation.create!(
  sku: iphone17,
  location_type: "robot",
  location_code: "ROBOT-A1",
  quantity: 50,
  reserved_quantity: 0
)

InventoryLocation.create!(
  sku: iphone17_pro,
  location_type: "robot",
  location_code: "ROBOT-A2",
  quantity: 30,
  reserved_quantity: 0
)

# BIN locations
InventoryLocation.create!(
  sku: iphone17,
  location_type: "bin",
  location_code: "BIN-101",
  quantity: 100,
  reserved_quantity: 0
)

InventoryLocation.create!(
  sku: iphone17,
  location_type: "bin",
  location_code: "BIN-102",
  quantity: 50,
  reserved_quantity: 0
)

InventoryLocation.create!(
  sku: iphone17_pro,
  location_type: "bin",
  location_code: "BIN-201",
  quantity: 75,
  reserved_quantity: 0
)

puts "Created inventory locations"

# Create sample printer
printer = Printer.create!(
  name: "Main Picking Slip Printer",
  ip_address: "192.168.1.100",
  port: 9100,
  printer_type: "picking_slip",
  active: true,
  config: {
    paper_size: "A4",
    orientation: "portrait"
  }
)

puts "Created printer: #{printer.name} (#{printer.ip_address}:#{printer.port})"

puts "\nSeed data created successfully!"
puts "\nSample API Key for testing: #{customer.api_key}"


