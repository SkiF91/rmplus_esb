class Resb::Proxy::TradePoint < Resb::Proxy::Core::Body
  node_accessor :id, :name, :address
  node_reader :deleted
  node_accessor :storage_code, name: 'storageCode'
  node_accessor :region_code, name: 'regionCode'
  node_accessor :city_id, name: 'cityId'
  node_reader :can_sell_by_prescription, name: 'canSellByPrescription'
  node_reader :provides_delivery, name: 'providesDelivery'
  node_reader :firm_ids, name: 'firmIds'
  node_reader :supplier_ids, name: 'supplierIds'

  def self.node_name
    'trade-point'
  end

  def deleted=(value)
    @deleted = self.class.to_bool(value)
  end

  def can_sell_by_prescription=(value)
    @can_sell_by_prescription = self.class.to_bool(value)
  end

  def provides_delivery=(value)
    @provides_delivery = self.class.to_bool(value)
  end

  def firm_ids=(value)
    @firm_ids = self.class.to_array(value)
  end

  def supplier_ids=(value)
    @supplier_ids = self.class.to_array(value)
  end

  def handle
    tp = ResbTradePoint.where(foreign_id: self.id).first_or_initialize
    tp.attributes = {
      name: self.name,
      deleted: !!self.deleted,
      storage_code: self.storage_code,
      region_code: self.region_code,
      address: self.address,
      city_id: self.city_id
    }

    unless tp.save
      raise ActiveRecord::RecordNotSaved.new(tp.errors.full_messages.join("\n\t"))
    end
  end
end