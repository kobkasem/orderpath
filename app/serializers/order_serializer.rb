class OrderSerializer
  def self.serialize(order)
    {
      id: order.id,
      order_number: order.order_number,
      airway_bill_number: order.airway_bill_number,
      status: order.status,
      customer: {
        id: order.customer.id,
        name: order.customer.name
      },
      items: order.order_items.map do |item|
        {
          id: item.id,
          sku_code: item.sku.sku_code,
          sku_name: item.sku.name,
          quantity: item.quantity,
          quantity_from_robot: item.quantity_from_robot,
          quantity_from_bin: item.quantity_from_bin,
          status: item.status
        }
      end,
      picking_slips: order.picking_slips.map do |slip|
        {
          id: slip.id,
          slip_number: slip.slip_number,
          status: slip.status,
          printed_at: slip.printed_at
        }
      end,
      created_at: order.created_at,
      processed_at: order.processed_at
    }
  end
end


