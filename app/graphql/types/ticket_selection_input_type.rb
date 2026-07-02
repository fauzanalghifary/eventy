module Types
  class TicketSelectionInputType < Types::BaseInputObject
    argument :ticket_type_id, ID, required: true
    argument :quantity, Integer, required: true
  end
end
