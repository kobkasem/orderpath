class Api::V1::PrintersController < ApplicationController
  def index
    printers = Printer.all
    render json: {
      printers: printers.map { |p| printer_serializer(p) }
    }
  end
  
  def show
    printer = Printer.find(params[:id])
    render json: { printer: printer_serializer(printer) }
  end
  
  def create
    printer = Printer.new(printer_params)
    
    if printer.save
      render json: {
        printer: printer_serializer(printer),
        message: "Printer created successfully"
      }, status: :created
    else
      render json: { errors: printer.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def update
    printer = Printer.find(params[:id])
    
    if printer.update(printer_params)
      render json: {
        printer: printer_serializer(printer),
        message: "Printer updated successfully"
      }
    else
      render json: { errors: printer.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def destroy
    printer = Printer.find(params[:id])
    printer.destroy
    render json: { message: "Printer deleted successfully" }
  end
  
  private
  
  def printer_params
    params.require(:printer).permit(:name, :ip_address, :port, :printer_type, :active, config: {})
  end
  
  def printer_serializer(printer)
    {
      id: printer.id,
      name: printer.name,
      ip_address: printer.ip_address,
      port: printer.port,
      printer_type: printer.printer_type,
      active: printer.active,
      print_url: printer.print_url,
      config: printer.config
    }
  end
end


